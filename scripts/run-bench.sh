#!/usr/bin/env bash
set -euo pipefail
FACTOR_BIN="${FACTOR_BIN:-/home/box/factor/factor/factor}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)/factor"
mkdir -p "$(cd "$(dirname "$0")/.." && pwd)/results"
"$FACTOR_BIN" -roots="$ROOT" -run=rsa-omega.harness
