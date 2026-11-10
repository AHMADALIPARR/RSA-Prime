#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, version 3.
# See the LICENSE file.

# require_tool NAME COMMAND
# COMMAND is a PATH name (no slash) or an executable path (contains a slash).
# Exits 1 and prints "missing NAME" when that binary is not executable.
# There is no alternate binary, language, or cached output.
require_tool() {
    local name="$1"
    local bin="$2"
    if [[ "$bin" == */* ]]; then
        if [[ ! -x "$bin" ]]; then
            echo "missing $name" >&2
            exit 1
        fi
    elif ! command -v "$bin" >/dev/null 2>&1; then
        echo "missing $name" >&2
        exit 1
    fi
}
