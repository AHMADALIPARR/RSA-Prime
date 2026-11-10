#!/usr/bin/env bash
# Prints the claim-by-claim research conformance report and writes it as
# JSON. Usage: scripts/run-research-report.sh [json-output-path]
# Default JSON path: results/box-run/research-claims.json
set -euo pipefail
FACTOR_BIN="${FACTOR_BIN:-/home/box/factor/factor/factor}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$REPO/results/box-run/research-claims.json}"
mkdir -p "$(dirname "$OUT")"
"$FACTOR_BIN" -roots="$REPO/factor:$REPO/tests/factor" -e="
USING: rsa-omega.research ;
research-report
\"$OUT\" write-research-json
"
