#!/usr/bin/env bash
# Same nine engine vocabularies as scripts/run-tests.sh (unchanged), but
# exits non-zero if any unit test fails. run-tests.sh prints every test and
# always exits 0, so CI and `make test` use this wrapper.
set -euo pipefail
FACTOR_BIN="${FACTOR_BIN:-/home/box/factor/factor/factor}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
"$FACTOR_BIN" -roots="$REPO/factor" -e='
USING: io kernel namespaces sequences system tools.test vocabs.loader ;
{
    "rsa-omega.arithmetic" "rsa-omega.numtheory" "rsa-omega.factoring"
    "rsa-omega.qs" "rsa-omega.gnfs" "rsa-omega.weakness"
    "rsa-omega.padding" "rsa-omega.symbolic" "rsa-omega.attacks"
} [ [ require ] [ test ] bi ] each
test-failures get empty?
[ "ALL ENGINE UNIT TESTS PASSED" print 0 exit ]
[ "==== FAILING TESTS" print :test-failures 1 exit ] if
'
