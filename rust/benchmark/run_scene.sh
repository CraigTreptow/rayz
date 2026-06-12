#!/usr/bin/env bash
# Run the Rust benchmark scene.
# Called by benchmark/run.sh.
# Args: --scene small|medium|large --output /path/to/out.ppm
# Outputs: one JSON timing line on stdout; build progress goes to stderr.
set -euo pipefail

cd "$(dirname "$0")/.."

command -v mise &>/dev/null || { echo "ERROR: 'mise' is not installed or not on PATH" >&2; exit 1; }

# Build with --release for fair benchmarking.
# Redirect build output to stderr so stdout stays clean for the JSON line.
mise exec -- cargo build --release --bin scene 1>&2

exec ./target/release/scene "$@"
