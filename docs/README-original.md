# RSA-CRYPTANALYSIS-OMEGA

Educational research toolkit for classical RSA weaknesses on **locally
generated synthetic test keys only**.

## Important

- The original pasted attachment (`e3bc6b12…txt`) was **missing from disk**
  when this tree was built. `SPEC.md` reconstructs the brief from the task
  constraints and standard RSA-cryptanalysis curriculum.
- Never point this at real third-party keys or certificates.
- Secure RSA-2048 is **generated then skipped**; we do not claim to factor it.

## Layout

| Path | Role |
|------|------|
| `factor/rsa-omega/` | Factor engine (arithmetic, factoring, attacks, fixtures, harness, symbolic) |
| `lean/` | Lean 4 proofs (`lake build`) |
| `scripts/run-tests.sh` | Factor unit tests |
| `scripts/run-bench.sh` | Benchmark harness → `results/results.json` |
| `SPEC.md` | Spec (reconstructed) |

## Requirements

- Factor 0.102+ (`FACTOR_BIN` env, default `/home/box/factor/factor/factor`)
- Lean 4.35+ / Lake (`elan`)

## Commands

```bash
./scripts/run-tests.sh
./scripts/run-bench.sh
cd lean && lake build
```
