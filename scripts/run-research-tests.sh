#!/usr/bin/env bash
# Runs the research-document conformance unit tests (new vocab
# rsa-omega.research under tests/factor) and fails on any test failure.
set -euo pipefail
FACTOR_BIN="${FACTOR_BIN:-/home/box/factor/factor/factor}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
"$FACTOR_BIN" -roots="$REPO/factor:$REPO/tests/factor" -e='
USING: io kernel namespaces sequences system tools.test vocabs.loader ;
"rsa-omega.research" require "rsa-omega.research" test
test-failures get empty?
[ "RESEARCH CONFORMANCE TESTS PASSED" print 0 exit ]
[ "==== FAILING TESTS" print :test-failures 1 exit ] if
'
