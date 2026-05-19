#!/usr/bin/env bash
# Cross-language ray tracer benchmark runner.
# Auto-discovers any language that has <lang>/benchmark/variants.conf,
# builds a randomised run queue, executes all variants, compares PPM output,
# and generates JSON + Markdown + HTML reports in benchmark/results/.
#
# Usage:
#   ./benchmark/run.sh              # run full benchmark (production sizes)
#   ./benchmark/run.sh --dev        # run with small dev sizes for fast iteration
#   ./benchmark/run.sh --dry-run    # print shuffled queue without rendering
#   ./benchmark/run.sh --iterations N  # override iteration count (default: 2)

# bash 4+ required (macOS ships 3.2). Re-exec with a newer bash if available.
if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
    for _bash in /opt/homebrew/bin/bash /usr/local/bin/bash; do
        # shellcheck disable=SC2016  # single quotes intentional: evaluated by the new bash, not this one
        if [[ -x "${_bash}" ]] && "${_bash}" -c '[[ "${BASH_VERSINFO[0]}" -ge 4 ]]' 2>/dev/null; then
            exec "${_bash}" "$0" "$@"
        fi
    done
    echo "ERROR: bash 4+ required (found bash ${BASH_VERSION})" >&2
    echo "  Install with: brew install bash" >&2
    exit 1
fi

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BENCHMARK_DIR="${REPO_ROOT}/benchmark"
RESULTS_DIR="${BENCHMARK_DIR}/results"
ITERATIONS=2
DRY_RUN=false
DEV_MODE=false
TIMESTAMP="$(date -u +"%Y-%m-%dT%H-%M-%S")"

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)    DRY_RUN=true ;;
        --dev)        DEV_MODE=true ;;
        --iterations) ITERATIONS="$2"; shift ;;
        *)            echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

if ! [[ "${ITERATIONS}" =~ ^[1-9][0-9]*$ ]]; then
    echo "ERROR: --iterations must be a positive integer, got: '${ITERATIONS}'" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Helper: run a Ruby script via mise exec from ruby/ so the right version
# and gems are used regardless of the caller's shell environment.
# ---------------------------------------------------------------------------
ruby_exec() {
    (cd "${REPO_ROOT}/ruby" && mise exec -- ruby "$@")
}

# ---------------------------------------------------------------------------
# Temp dir — cleaned up automatically on exit
# ---------------------------------------------------------------------------
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

mkdir -p "${RESULTS_DIR}"

# ---------------------------------------------------------------------------
# System info
# ---------------------------------------------------------------------------
HOSTNAME_VAL="$(hostname)"
CPU_MODEL="$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs || echo "unknown")"
CPU_CORES="$(nproc 2>/dev/null || echo "unknown")"
MEMORY_GB="$(free -g 2>/dev/null | awk '/^Mem:/{print $2}' || echo "unknown")"
OS_INFO="$(uname -srm)"

# ---------------------------------------------------------------------------
# Auto-discover languages (any dir with benchmark/variants.conf)
# ---------------------------------------------------------------------------
declare -a LANGUAGES=()
for variants_file in "${REPO_ROOT}"/*/benchmark/variants.conf; do
    [[ -f "${variants_file}" ]] || continue
    lang_name="$(basename "$(dirname "$(dirname "${variants_file}")")")"
    LANGUAGES+=("${lang_name}")
done

if [[ ${#LANGUAGES[@]} -eq 0 ]]; then
    echo "No languages found. Add <lang>/benchmark/variants.conf to enable a language." >&2
    exit 1
fi

echo "Discovered languages: ${LANGUAGES[*]}"
if [[ "${DEV_MODE}" == "true" ]]; then
    echo "Mode: DEV (tiny scene sizes for fast iteration)"
else
    echo "Mode: PRODUCTION (full scene sizes)"
fi

# ---------------------------------------------------------------------------
# Get language versions
# ---------------------------------------------------------------------------
declare -A LANG_VERSIONS=()
for lang in "${LANGUAGES[@]}"; do
    version_script="${REPO_ROOT}/${lang}/benchmark/version.sh"
    if [[ -x "${version_script}" ]]; then
        if version_out="$("${version_script}" 2>&1)"; then
            LANG_VERSIONS["${lang}"]="$(echo "${version_out}" | head -1)"
            [[ -z "${LANG_VERSIONS[${lang}]}" ]] && LANG_VERSIONS["${lang}"]="unknown"
        else
            echo "WARNING: version script for ${lang} failed — ${version_out}" >&2
            LANG_VERSIONS["${lang}"]="unknown"
        fi
    else
        LANG_VERSIONS["${lang}"]="unknown"
    fi
    echo "  ${lang}: ${LANG_VERSIONS[${lang}]}"
done

# ---------------------------------------------------------------------------
# Build run queue: lang|variant_name|variant_desc|variant_env|scene|iteration
# ---------------------------------------------------------------------------
declare -a RUN_QUEUE=()
SCENES=("tiny" "small" "medium" "large")

for lang in "${LANGUAGES[@]}"; do
    variants_file="${REPO_ROOT}/${lang}/benchmark/variants.conf"
    while IFS='|' read -r variant_name variant_desc variant_env || [[ -n "${variant_name}" ]]; do
        # Skip blank lines and comments
        trimmed="${variant_name#"${variant_name%%[![:space:]]*}"}"
        [[ -z "${trimmed}"     ]] && continue
        [[ "${trimmed}" == \#* ]] && continue
        for scene in "${SCENES[@]}"; do
            for ((iter = 1; iter <= ITERATIONS; iter++)); do
                RUN_QUEUE+=("${lang}|${variant_name}|${variant_desc}|${variant_env:-}|${scene}|${iter}")
            done
        done
    done < "${variants_file}"
done

# Shuffle to eliminate thermal/cache ordering bias (Fisher-Yates; no shuf needed)
SHUFFLED_QUEUE=("${RUN_QUEUE[@]}")
for ((i = ${#SHUFFLED_QUEUE[@]} - 1; i > 0; i--)); do
    j=$((RANDOM % (i + 1)))
    tmp="${SHUFFLED_QUEUE[i]}"
    SHUFFLED_QUEUE[i]="${SHUFFLED_QUEUE[j]}"
    SHUFFLED_QUEUE[j]="${tmp}"
done

echo ""
echo "Total runs: ${#SHUFFLED_QUEUE[@]}  (${#LANGUAGES[@]} language(s), ${ITERATIONS} iterations each)"

# ---------------------------------------------------------------------------
# Dry-run: just print the queue
# ---------------------------------------------------------------------------
if [[ "${DRY_RUN}" == "true" ]]; then
    echo ""
    echo "DRY RUN — shuffled run queue:"
    for run in "${SHUFFLED_QUEUE[@]}"; do
        IFS='|' read -r lang variant_name variant_desc variant_env scene iter <<< "${run}"
        printf "  [%s/%s] scene=%-6s iter=%s  env='%s'\n" \
            "${lang}" "${variant_name}" "${scene}" "${iter}" "${variant_env}"
    done
    exit 0
fi

# ---------------------------------------------------------------------------
# Pre-write small Ruby helper scripts to temp dir so the main loop is clean
# ---------------------------------------------------------------------------
ENRICH_SCRIPT="${TMP_DIR}/enrich.rb"
cat > "${ENRICH_SCRIPT}" << 'RUBY_EOF'
require 'json'
data = JSON.parse(ENV.fetch('BENCH_TIMING_JSON'))
data['language']         = ENV.fetch('BENCH_LANG')
data['language_version'] = ENV.fetch('BENCH_LANG_VER')
data['variant']          = ENV.fetch('BENCH_VARIANT')
data['variant_desc']     = ENV.fetch('BENCH_VARIANT_DESC')
data['iteration']        = ENV.fetch('BENCH_ITER').to_i
data['ppm_path']         = ENV.fetch('BENCH_PPM_PATH')
puts JSON.generate(data)
RUBY_EOF

SYSTEM_SCRIPT="${TMP_DIR}/system.rb"
cat > "${SYSTEM_SCRIPT}" << 'RUBY_EOF'
require 'json'
puts JSON.generate(
  hostname:  ENV.fetch('BENCH_HOSTNAME'),
  cpu_model: ENV.fetch('BENCH_CPU'),
  cpu_cores: ENV.fetch('BENCH_CORES'),
  memory_gb: ENV.fetch('BENCH_MEM'),
  os:        ENV.fetch('BENCH_OS')
)
RUBY_EOF

# ---------------------------------------------------------------------------
# Execute runs
# ---------------------------------------------------------------------------
NDJSON_FILE="${RESULTS_DIR}/${TIMESTAMP}.ndjson"
touch "${NDJSON_FILE}"

total="${#SHUFFLED_QUEUE[@]}"
current=0

for run in "${SHUFFLED_QUEUE[@]}"; do
    current=$((current + 1))
    IFS='|' read -r lang variant_name variant_desc variant_env scene iter <<< "${run}"

    ppm_path="${TMP_DIR}/${lang}-${variant_name}-${scene}-iter${iter}.ppm"
    run_script="${REPO_ROOT}/${lang}/benchmark/run_scene.sh"

    if [[ ! -x "${run_script}" ]]; then
        echo "ERROR: run_scene.sh not found or not executable for language '${lang}'" >&2
        echo "  Expected: ${run_script}" >&2
        exit 1
    fi

    echo ""
    echo "──────────────────────────────────────────────────────────────"
    printf "[%d/%d] %-8s %-22s scene=%-6s iter=%s\n" \
        "${current}" "${total}" "${lang}" "${variant_name}" "${scene}" "${iter}"
    echo "──────────────────────────────────────────────────────────────"

    # Build env array from variant-specific vars (e.g. YJIT=true PARALLEL=false)
    declare -a run_env=()
    if [[ -n "${variant_env}" ]]; then
        read -r -a run_env <<< "${variant_env}"
    fi

    lang_version="${LANG_VERSIONS[${lang}]:-unknown}"

    # Execute scene runner; render progress prints to stderr (visible), JSON to stdout
    timing_json="$(DEV_MODE="${DEV_MODE}" env "${run_env[@]+"${run_env[@]}"}" "${run_script}" \
        --scene "${scene}" --output "${ppm_path}")" || {
        echo "ERROR: renderer failed for ${lang}/${variant_name}/${scene} iter=${iter}" >&2
        exit 1
    }
    if [[ -z "${timing_json}" ]]; then
        echo "ERROR: ${lang}/${variant_name}/${scene} iter=${iter} produced no JSON on stdout" >&2
        exit 1
    fi

    elapsed_val="$(grep -o '"elapsed":[0-9.]*' <<< "${timing_json}" | cut -d: -f2)"
    pxs_val="$(grep -o '"pixels_per_second":[0-9]*' <<< "${timing_json}" | cut -d: -f2)"
    printf "  => %ss  (%s px/s)\n" "${elapsed_val}" "${pxs_val}"

    # Enrich timing JSON with run metadata via env vars (no shell string injection)
    enriched="$(BENCH_TIMING_JSON="${timing_json}" \
        BENCH_LANG="${lang}" \
        BENCH_LANG_VER="${lang_version}" \
        BENCH_VARIANT="${variant_name}" \
        BENCH_VARIANT_DESC="${variant_desc}" \
        BENCH_ITER="${iter}" \
        BENCH_PPM_PATH="${ppm_path}" \
        ruby_exec "${ENRICH_SCRIPT}")" || {
        echo "ERROR: failed to enrich timing data for ${lang}/${variant_name}/${scene} iter=${iter}" >&2
        echo "  Raw timing JSON: ${timing_json}" >&2
        exit 1
    }
    echo "${enriched}" >> "${NDJSON_FILE}"

    unset run_env
done

# ---------------------------------------------------------------------------
# Write system info JSON
# ---------------------------------------------------------------------------
SYSTEM_JSON="${TMP_DIR}/system.json"
BENCH_HOSTNAME="${HOSTNAME_VAL}" \
BENCH_CPU="${CPU_MODEL}" \
BENCH_CORES="${CPU_CORES}" \
BENCH_MEM="${MEMORY_GB}" \
BENCH_OS="${OS_INFO}" \
ruby_exec "${SYSTEM_SCRIPT}" > "${SYSTEM_JSON}"

# ---------------------------------------------------------------------------
# Generate reports
# ---------------------------------------------------------------------------
echo ""
echo "Generating reports..."
ruby_exec "${BENCHMARK_DIR}/report.rb" \
    --results    "${NDJSON_FILE}" \
    --system     "${SYSTEM_JSON}" \
    --timestamp  "${TIMESTAMP}"   \
    --output-dir "${RESULTS_DIR}"

echo ""
echo "Results saved to ${RESULTS_DIR}/"
echo "  ${RESULTS_DIR}/${TIMESTAMP}.json"
echo "  ${RESULTS_DIR}/${TIMESTAMP}.md"
echo "  ${RESULTS_DIR}/${TIMESTAMP}.html"
