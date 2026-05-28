#!/usr/bin/env bash
# Run the Crystal benchmark scene.
# Called by benchmark/run.sh.
# Args: --scene tiny|small|medium|large --output /path/to/out.ppm
# Outputs: one JSON timing line on stdout; compilation progress goes to stderr.
set -euo pipefail

cd "$(dirname "$0")/.."

command -v mise &>/dev/null || { echo "ERROR: 'mise' is not installed or not on PATH" >&2; exit 1; }

BINARY="${TMPDIR:-/tmp}/rayz-crystal-scene-$$"

# Compile with --release for fair benchmarking (LLVM optimisations enabled).
# Compilation output goes to stderr so stdout stays clean for the JSON line.
mise exec -- crystal build --release -o "${BINARY}" benchmark/scene.cr 1>&2

trap 'rm -f "${BINARY}"' EXIT

exec "${BINARY}" "$@"
