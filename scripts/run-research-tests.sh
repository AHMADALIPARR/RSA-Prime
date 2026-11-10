#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, version 3.
# See the LICENSE file.

# Runs the research-document conformance unit tests (new vocab
# rsa-omega.research under tests/factor) and fails on any test failure.
set -euo pipefail
FACTOR_BIN="${FACTOR_BIN:-/home/box/factor/factor/factor}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=require-tool.sh
source "$REPO/scripts/require-tool.sh"
require_tool factor "$FACTOR_BIN"
"$FACTOR_BIN" -roots="$REPO/factor:$REPO/tests/factor" -e='
USING: io kernel namespaces sequences system tools.test vocabs.loader ;
"rsa-omega.research" require "rsa-omega.research" test
test-failures get empty?
[ "RESEARCH CONFORMANCE TESTS PASSED" print 0 exit ]
[ "==== FAILING TESTS" print :test-failures 1 exit ] if
'
