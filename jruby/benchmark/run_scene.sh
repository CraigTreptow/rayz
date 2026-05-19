#!/usr/bin/env bash
# Run the JRuby benchmark scene.
# Called by benchmark/run.sh with environment variables:
#   PARALLEL=true|false — enable Thread-based parallel rendering
# Args forwarded to scene.rb: --scene tiny|small|medium --output /path/to/out.ppm
# Outputs: one JSON timing line on stdout; render progress goes to stderr.
#
# Note: JRuby has real OS threads (no GIL), so Thread parallelism gives genuine
# CPU-level speedup. YJIT is not supported; the JVM handles JIT compilation.
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

command -v mise &>/dev/null || { echo "ERROR: 'mise' is not installed or not on PATH" >&2; exit 1; }

exec mise exec -- ruby \
    -J-server \
    -J-XX:+UseG1GC \
    -J-Xss4m \
    benchmark/scene.rb "$@" --parallel "${PARALLEL:-false}"
