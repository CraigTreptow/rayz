#!/usr/bin/env bash
# Run the Python benchmark scene.
# Called by benchmark/run.sh.
# Args forwarded to scene.py: --scene tiny|small|medium --output /path/to/out.ppm
# Outputs: one JSON timing line on stdout.
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

exec mise exec -- uv run benchmark/scene.py "$@"
