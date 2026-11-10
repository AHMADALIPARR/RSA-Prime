import Lake
open Lake DSL

package «rsa-omega» where
  version := v!"0.1.0"

@[default_target]
lean_lib RsaOmega where
  roots := #[`RsaOmega]
