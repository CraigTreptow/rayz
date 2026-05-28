#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mise exec -- crystal --version | head -1
