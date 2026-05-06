#!/usr/bin/env bash
# Run the Python benchmark scene.
# Called by benchmark/run.sh with environment variables:
#   PARALLEL=true|false — enable multiprocessing parallel rendering
# Args forwarded to scene.py: --scene tiny|small|medium --output /path/to/out.ppm
# Outputs: one JSON timing line on stdout; render progress goes to stderr.
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

command -v mise &>/dev/null || { echo "ERROR: 'mise' is not installed or not on PATH" >&2; exit 1; }

exec mise exec -- uv run benchmark/scene.py "$@"
