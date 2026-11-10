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
