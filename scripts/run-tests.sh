#!/usr/bin/env bash
set -euo pipefail
FACTOR_BIN="${FACTOR_BIN:-/home/box/factor/factor/factor}"
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
