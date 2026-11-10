#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, version 3.
# See the LICENSE file.

set -euo pipefail
FACTOR_BIN="${FACTOR_BIN:-/home/box/factor/factor/factor}"
# shellcheck source=require-tool.sh
source "$(cd "$(dirname "$0")" && pwd)/require-tool.sh"
require_tool factor "$FACTOR_BIN"
ROOT="$(cd "$(dirname "$0")/.." && pwd)/factor"
"$FACTOR_BIN" -roots="$ROOT" -e='
USING: tools.test io prettyprint vocabs.loader ;
"rsa-omega.arithmetic" require "rsa-omega.arithmetic" test
"rsa-omega.numtheory" require "rsa-omega.numtheory" test
"rsa-omega.factoring" require "rsa-omega.factoring" test
"rsa-omega.qs" require "rsa-omega.qs" test
"rsa-omega.gnfs" require "rsa-omega.gnfs" test
"rsa-omega.weakness" require "rsa-omega.weakness" test
"rsa-omega.padding" require "rsa-omega.padding" test
"rsa-omega.symbolic" require "rsa-omega.symbolic" test
"rsa-omega.attacks" require "rsa-omega.attacks" test
"ALL UNIT TESTS FINISHED" print
0 exit
'
