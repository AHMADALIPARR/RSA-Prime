#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, version 3.
# See the LICENSE file.

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
