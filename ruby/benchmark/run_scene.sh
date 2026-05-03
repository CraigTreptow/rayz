#!/usr/bin/env bash
# Run the Ruby benchmark scene.
# Called by benchmark/run.sh with environment variables:
#   YJIT=true|false     — enable Ruby YJIT JIT compiler
#   PARALLEL=true|false — enable Thread-based parallel rendering
# Args forwarded to scene.rb: --scene tiny|small|medium --output /path/to/out.ppm
# Outputs: one JSON timing line on stdout; render progress goes to stderr.
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

command -v mise &>/dev/null || { echo "ERROR: 'mise' is not installed or not on PATH" >&2; exit 1; }

ruby_flags=()
if [[ "${YJIT:-false}" == "true" ]]; then
    ruby_flags+=("--yjit")
fi

exec mise exec -- ruby "${ruby_flags[@]}" benchmark/scene.rb "$@" --parallel "${PARALLEL:-false}"
