-- SPDX-License-Identifier: AGPL-3.0-only
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as published by
-- the Free Software Foundation, version 3.
-- See the LICENSE file.

import Lake
open Lake DSL

package «rsa-omega» where
  version := v!"0.1.0"

@[default_target]
lean_lib RsaOmega where
  roots := #[`RsaOmega]
