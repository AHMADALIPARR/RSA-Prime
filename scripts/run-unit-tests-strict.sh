#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, version 3.
# See the LICENSE file.

# Same nine engine vocabularies as scripts/run-tests.sh (unchanged), but
# exits non-zero if any unit test fails. run-tests.sh prints every test and
# always exits 0, so `make test` uses this wrapper.
set -euo pipefail
FACTOR_BIN="${FACTOR_BIN:-/home/box/factor/factor/factor}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=require-tool.sh
source "$REPO/scripts/require-tool.sh"
require_tool factor "$FACTOR_BIN"
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
