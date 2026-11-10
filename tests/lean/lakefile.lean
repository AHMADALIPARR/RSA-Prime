-- SPDX-License-Identifier: AGPL-3.0-only
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as published by
-- the Free Software Foundation, version 3.
-- See the LICENSE file.

import Lake
open Lake DSL

-- Research-document conformance proofs. Depends on the unchanged
-- RsaOmega library in ../../lean (Andrew's original Lean package).
package «rsa-omega-research» where
  version := v!"0.1.0"

require «rsa-omega» from ".." / ".." / "lean"

@[default_target]
lean_lib ResearchConformance where
  roots := #[`ResearchConformance]
