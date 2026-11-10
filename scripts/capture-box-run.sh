#!/usr/bin/env bash
# Runs every check in this repository and captures the raw output, the
# exit code and the wall time of each step into results/box-run/.
# Nothing in results/ outside results/box-run/ is touched (those are the
# original files from the upload and are kept byte-identical).
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$REPO/results/box-run"
FACTOR_BIN="${FACTOR_BIN:-/home/box/factor/factor/factor}"
export FACTOR_BIN
export PATH="$HOME/.elan/bin:$PATH"
mkdir -p "$OUT"
printf 'step\texit_code\twall_ms\n' > "$OUT/steps.tsv"

step() {
    local name="$1"; shift
    local log="$OUT/$name.txt"
    local t0 t1 rc
    t0=$(date +%s%N)
    ( cd "$REPO" && "$@" ) > "$log" 2>&1
    rc=$?
    t1=$(date +%s%N)
    printf '%s\t%s\t%s\n' "$name" "$rc" "$(( (t1 - t0) / 1000000 ))" >> "$OUT/steps.tsv"
    echo "$name: exit $rc, $(( (t1 - t0) / 1000000 )) ms"
}

{
    echo "date: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "uname: $(uname -a)"
    echo "factor: $FACTOR_BIN"
    "$FACTOR_BIN" -e='USING: io system ; vm-version print' 2>&1 | sed 's/^/factor vm-version: /'
    [ -f "$(dirname "$FACTOR_BIN")/git-id" ] && echo "factor git-id: $(cat "$(dirname "$FACTOR_BIN")/git-id")"
    lean --version 2>&1 | sed 's/^/lean: /'
    lake --version 2>&1 | sed 's/^/lake: /'
    echo "--- lscpu"
    lscpu
    echo "--- free -m"
    free -m
} > "$OUT/machine.txt" 2>&1

step manifest-verify   sha256sum -c MANIFEST.sha256
step unit-tests        ./scripts/run-tests.sh
step unit-tests-strict ./scripts/run-unit-tests-strict.sh
step research-tests    ./scripts/run-research-tests.sh
step research-report   ./scripts/run-research-report.sh "$OUT/research-claims.json"
step bench-run         ./scripts/run-bench-repo.sh "$OUT/results.json"
step bench-run-repeat-2 ./scripts/run-bench-repo.sh "$OUT/results-repeat-2.json"
step bench-run-repeat-3 ./scripts/run-bench-repo.sh "$OUT/results-repeat-3.json"
python3 "$REPO/scripts/summarize-bench.py" "$OUT/results.json" \
    "$OUT/results-repeat-2.json" "$OUT/results-repeat-3.json" > "$OUT/bench-summary.md"
step smoke             "$FACTOR_BIN" -roots="$REPO/factor" -run=rsa-omega.smoke
step lake-build        bash -c 'cd lean && rm -rf .lake && lake build'
step lake-build-research bash -c 'cd tests/lean && rm -rf .lake && lake build'
echo "wrote $OUT"
