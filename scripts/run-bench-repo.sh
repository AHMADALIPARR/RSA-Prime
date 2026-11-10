#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, version 3.
# See the LICENSE file.

# Runs the unchanged benchmark harness (rsa-omega.harness) but writes the
# JSON inside this repository. harness-main in harness.factor hard-codes
# /workspace/rsa-omega/results/results.json, so this wrapper calls the
# harness word write-results with a repo-relative path instead and then
# prints the same one-line-per-row summary harness-main prints.
# Usage: scripts/run-bench-repo.sh [json-output-path]
set -euo pipefail
FACTOR_BIN="${FACTOR_BIN:-/home/box/factor/factor/factor}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$REPO/results/box-run/results.json}"
mkdir -p "$(dirname "$OUT")"
"$FACTOR_BIN" -roots="$REPO/factor" -e="
USING: assocs io kernel namespaces prettyprint sequences rsa-omega.harness ;
\"$OUT\" write-results
\"Wrote \" write \"$OUT\" write \" (\" write results-acc get length pprint \" rows)\" print
results-acc get [
    dup \"name\" of write \" \" write
    dup \"bits\" of pprint \" \" write
    dup \"outcome\" of write \" \" write
    \"ms\" of .
] each
"
