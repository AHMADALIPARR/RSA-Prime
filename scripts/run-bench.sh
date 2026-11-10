#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, version 3.
# See the LICENSE file.

set -euo pipefail
FACTOR_BIN="${FACTOR_BIN:-/home/box/factor/factor/factor}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)/factor"
mkdir -p "$(cd "$(dirname "$0")/.." && pwd)/results"
"$FACTOR_BIN" -roots="$ROOT" -run=rsa-omega.harness
