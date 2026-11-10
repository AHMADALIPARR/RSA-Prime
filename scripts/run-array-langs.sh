#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, version 3.
# See the LICENSE file.

# Run every extracted BQN and J program with the real interpreters.
# Writes stdout, stderr and the exit code under results/box-run/bqn and
# results/box-run/j. Does not edit the programs and does not substitute
# another language. Exits non-zero if an interpreter is missing or if any
# program exits non-zero (after every program has been run).
set -u
REPO="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=require-tool.sh
source "$REPO/scripts/require-tool.sh"
require_tool BQN BQN
require_tool jconsole jconsole
require_tool timeout timeout

BQN_BIN="$(command -v BQN)"
J_BIN="$(command -v jconsole)"
TIMEOUT_BIN="$(command -v timeout)"

mkdir -p "$REPO/results/box-run/bqn" "$REPO/results/box-run/j"
fail=0

run_one() {
    local interp="$1" src="$2" outdir="$3"
    local base stem rc
    base="$(basename "$src")"
    stem="${base%.*}"
    set +e
    "$TIMEOUT_BIN" 60 "$interp" "$src" >"$outdir/$stem.stdout" 2>"$outdir/$stem.stderr"
    rc=$?
    set -e
    printf '%s\n' "$rc" >"$outdir/$stem.exit"
    echo "$base exit $rc"
    if [[ "$rc" -ne 0 ]]; then
        fail=1
    fi
}

set -e
for src in "$REPO"/bqn/*.bqn; do
    run_one "$BQN_BIN" "$src" "$REPO/results/box-run/bqn"
done
for src in "$REPO"/j/*.ijs; do
    run_one "$J_BIN" "$src" "$REPO/results/box-run/j"
done

{
    echo "BQN: $BQN_BIN"
    set +e
    "$BQN_BIN" --version
    echo "BQN --version exit $?"
    echo "jconsole: $J_BIN"
    "$J_BIN" -js "echo 9!:14 ''"
    echo "jconsole version exit $?"
    set -e
} >"$REPO/results/box-run/array-versions.txt" 2>&1

exit "$fail"
