#!/usr/bin/env bash
# Cross-language ray tracer benchmark runner.
# Auto-discovers any language that has <lang>/benchmark/variants.conf,
# builds a randomised run queue, executes all variants, compares PPM output,
# and generates JSON + Markdown + HTML reports in benchmark/results/.
#
# Usage:
#   ./benchmark/run.sh              # run full benchmark
#   ./benchmark/run.sh --dry-run    # print shuffled queue without rendering
#   ./benchmark/run.sh --iterations N  # override iteration count (default: 2)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BENCHMARK_DIR="${REPO_ROOT}/benchmark"
RESULTS_DIR="${BENCHMARK_DIR}/results"
ITERATIONS=2
DRY_RUN=false
TIMESTAMP="$(date -u +"%Y-%m-%dT%H-%M-%S")"

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)    DRY_RUN=true ;;
        --iterations) ITERATIONS="$2"; shift ;;
        *)            echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

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

# ---------------------------------------------------------------------------
# Get language versions
# ---------------------------------------------------------------------------
declare -A LANG_VERSIONS=()
for lang in "${LANGUAGES[@]}"; do
    version_script="${REPO_ROOT}/${lang}/benchmark/version.sh"
    if [[ -x "${version_script}" ]]; then
        LANG_VERSIONS["${lang}"]="$("${version_script}" 2>/dev/null | head -1 || echo "unknown")"
    else
        LANG_VERSIONS["${lang}"]="unknown"
    fi
    echo "  ${lang}: ${LANG_VERSIONS[${lang}]}"
done

# ---------------------------------------------------------------------------
# Build run queue: lang|variant_name|variant_desc|variant_env|scene|iteration
# ---------------------------------------------------------------------------
declare -a RUN_QUEUE=()
SCENES=("tiny" "small" "medium")

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

# Shuffle to eliminate thermal/cache ordering bias
mapfile -t SHUFFLED_QUEUE < <(printf '%s\n' "${RUN_QUEUE[@]}" | shuf)

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
NDJSON_FILE="${TMP_DIR}/results.ndjson"
touch "${NDJSON_FILE}"

total="${#SHUFFLED_QUEUE[@]}"
current=0

for run in "${SHUFFLED_QUEUE[@]}"; do
    current=$((current + 1))
    IFS='|' read -r lang variant_name variant_desc variant_env scene iter <<< "${run}"

    ppm_path="${TMP_DIR}/${lang}-${variant_name}-${scene}-iter${iter}.ppm"
    run_script="${REPO_ROOT}/${lang}/benchmark/run_scene.sh"

    printf "[%d/%d] %-8s %-22s scene=%-6s iter=%s\n" \
        "${current}" "${total}" "${lang}" "${variant_name}" "${scene}" "${iter}"

    # Build env array from variant-specific vars (e.g. YJIT=true PARALLEL=false)
    declare -a run_env=()
    if [[ -n "${variant_env}" ]]; then
        read -r -a run_env <<< "${variant_env}"
    fi

    lang_version="${LANG_VERSIONS[${lang}]:-unknown}"

    # Execute scene runner; render progress prints to stderr (visible), JSON to stdout
    timing_json="$(env "${run_env[@]+"${run_env[@]}"}" "${run_script}" \
        --scene "${scene}" --output "${ppm_path}")"

    printf "  => %s\n" "${timing_json}"

    # Enrich timing JSON with run metadata via env vars (no shell string injection)
    BENCH_TIMING_JSON="${timing_json}" \
    BENCH_LANG="${lang}" \
    BENCH_LANG_VER="${lang_version}" \
    BENCH_VARIANT="${variant_name}" \
    BENCH_VARIANT_DESC="${variant_desc}" \
    BENCH_ITER="${iter}" \
    BENCH_PPM_PATH="${ppm_path}" \
    ruby_exec "${ENRICH_SCRIPT}" >> "${NDJSON_FILE}"

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
