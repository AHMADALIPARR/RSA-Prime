# RSA-CRYPTANALYSIS-OMEGA

An educational toolkit for studying classical RSA weaknesses, written in
[Factor](https://factorcode.org) with formal proofs in
[Lean 4](https://lean-lang.org). It contains the number theory behind
RSA, eight factoring engines (trial division through ECM and the quadratic
sieve), a set of key-weakness attacks, padding validation, lattice tools, a benchmark harness and machine-checked proofs, together with the
author's research document. The 180 concrete numeric claims we could
extract from that document are checked against the engine.

The repository combines three things:

1. **The original engine, proofs and specification**, as uploaded. All 36
   files plus the research document are kept **byte-identical** and are
   checked by `MANIFEST.sha256`.
2. **The author's research document**, verbatim, at
   `research/RSA-OMEGA-RESEARCH.md`.
3. **New production scaffolding**: research conformance tests in Factor
   and Lean, strict test runners, a benchmark wrapper, a Makefile and
   documentation. Every result quoted below comes from a run on the build
   machine on 2026-11-10 at about 06:00 PST, with the raw logs in
   `results/box-run/`.

## Status at a glance

| Check | Result on the build machine | Log |
|---|---|---|
| Preserved files byte-identical | 37 / 37 sha256 match | `results/box-run/manifest-verify.txt` |
| Engine unit tests (9 vocabularies) | 61 tests, 0 failures | `results/box-run/unit-tests-strict.txt` |
| Original `scripts/run-tests.sh` | exits 0, 61 tests printed, ends `ALL UNIT TESTS FINISHED` | `results/box-run/unit-tests.txt` |
| Research conformance unit tests | 40 tests, 0 failures | `results/box-run/research-tests.txt` |
| Research document claims | 180 checked: 169 agree, 11 disagree | `results/box-run/research-report.txt` |
| Benchmark harness | 23 rows, 3 runs, identical outcomes each run | `results/box-run/bench-summary.md` |
| `lake build` (original `lean/`) | Build completed successfully, 3 linter warnings | `results/box-run/lake-build.txt` |
| `lake build` (`tests/lean/`) | Build completed successfully | `results/box-run/lake-build-research.txt` |
| `rsa-omega.smoke` | **fails to load** (see Limitations) | `results/box-run/smoke.txt` |

## Ethics and scope

This is a research and teaching toolkit. Its rules:

* **Synthetic keys only.** Every modulus the harness and tests use is
  generated locally from a fixed Mersenne Twister seed, or is a textbook
  toy value such as 3233 = 61 x 53. Do not point the toolkit at real
  third-party keys, certificates or traffic.
* **RSA-2048 is not broken here.** The harness generates a 2048-bit
  modulus, checks its key invariants and then records
  `rsa-2048-factor 2048 skipped` with the detail "synthetic 2048-bit n
  not factored (secure size)". No factoring of a secure 2048-bit modulus
  is attempted or claimed.
* **Attacks succeed only where the key is deliberately weak**: close
  primes for Fermat, smooth p - 1 for Pollard p - 1, small d for Wiener,
  a shared prime for batch GCD, a small root for Coppersmith-style lattice
  methods. A recovery is reported only after it has been verified (for
  example, n mod factor = 0).
* **No invented results.** A tool that failed is recorded with its error.

## Repository layout

| Path | Contents | Origin |
|---|---|---|
| `factor/rsa-omega/` | Factor engine: 12 vocabularies and their unit tests | original, unchanged |
| `factor/scratch/check/` | a short scratch probe (`scratch.check`) | original, unchanged |
| `lean/` | Lean 4 package `rsa-omega` (`RsaOmega.lean`, lakefile, toolchain) | original, unchanged |
| `scripts/run-tests.sh`, `scripts/run-bench.sh` | original test and benchmark scripts | original, unchanged |
| `results/*.txt`, `results/results.json` | results that shipped with the upload | original, unchanged |
| `SPEC.md`, `SPEC-original.txt` | implementation brief (sections 1-9) | original, unchanged |
| `docs/README-original.md` | the README from the upload | original, moved only |
| `research/RSA-OMEGA-RESEARCH.md` | the author's research document | original, verbatim |
| `tests/factor/rsa-omega/research/` | vocab `rsa-omega.research`: 154 claim checks and 38 unit tests | new |
| `bqn/`, `j/` | the author's BQN and J programs, verbatim from the research document | new |
| `tests/lean/` | Lake package `rsa-omega-research`: kernel-checked proofs of the document's numbers | new |
| `scripts/run-unit-tests-strict.sh` | the 9 engine test vocabularies; exits 1 on any failure | new |
| `scripts/run-research-tests.sh` / `run-research-report.sh` | conformance tests / claim report (text and JSON) | new |
| `scripts/run-bench-repo.sh` | runs the unchanged harness and writes JSON inside the repository | new |
| `scripts/capture-box-run.sh`, `scripts/summarize-bench.py` | run everything, capture logs and exit codes, tabulate benchmarks | new |
| `results/box-run/` | fresh logs, JSON and machine information from the build machine | new |
| `docs/` | conformance report, provenance, research-document note | new |
| `MANIFEST.sha256` | sha256 of all 37 preserved files | new |
| `Makefile` | entry points | new |

## Requirements

* **Factor 0.102.** Set `FACTOR_BIN` to the VM binary, with
  `factor.image` next to it. The scripts default to
  `/home/box/factor/factor/factor`, the build machine's Factor
  (vm-version 0.102, git id `6f604bb0fa28362bb2f20ddb133bc73b19b6a50f`).
  On many Linux systems `/usr/bin/factor` is the GNU coreutils
  prime-factor tool, which is a different program.
* **Lean 4.35.0 and Lake**, installed with `elan`. Both `lean-toolchain`
  files pin `leanprover/lean4:v4.35.0`. Neither package needs Mathlib.
* **CBQN** (`BQN` on `PATH`) and **J9** (`jconsole` on `PATH`) to run
  `bqn/*.bqn` and `j/*.ijs`. `make array` and `scripts/run-array-langs.sh`
  exit with `missing BQN` or `missing jconsole` when either binary is
  absent. They do not substitute Factor.
* `bash`, `sha256sum`, `timeout` and `python3` for the wrapper scripts.
  `make` is optional for the Factor and Lean targets, since each of those
  is a single script or `lake` call. A missing `factor`, `lean` or `lake`
  binary fails with `missing factor`, `missing lean` or `missing lake`.

## Quick start

```bash
export FACTOR_BIN=/path/to/factor/factor     # Factor 0.102 VM
sha256sum -c MANIFEST.sha256                 # make verify
./scripts/run-unit-tests-strict.sh           # make test-engine
./scripts/run-research-tests.sh              # make test-research
./scripts/run-research-report.sh             # make report
./scripts/run-bench-repo.sh                  # make bench  -> results/box-run/results.json
(cd lean && lake build)                      # make lean
(cd tests/lean && lake build)                # make lean-research
./scripts/capture-box-run.sh                 # make box-run: all of the above, logged
```

The original scripts still work exactly as shipped: `./scripts/run-tests.sh`
prints every test, and `./scripts/run-bench.sh` runs `harness-main`.
Note that `harness-main` writes its JSON to the fixed path
`/workspace/rsa-omega/results/results.json`. Use
`scripts/run-bench-repo.sh` to keep results inside the repository.

## The Factor engine, module by module

All vocabularies live under `factor/rsa-omega/` and load with
`-roots=<repo>/factor`.

* **`rsa-omega.arithmetic`**: iterative `extended-gcd` (returns s, t, g
  with s a + t b = g), `mod-inverse`, Newton `isqrt`, `perfect-square?`,
  `modexp` (Factor's `^mod`), and prime generation helpers.
* **`rsa-omega.numtheory`**: Jacobi symbol (binary algorithm) and an
  independent Legendre symbol via Euler's criterion, used to cross-check
  it; two-modulus and general `crt`; `totient-from-factors`,
  `lambda-prime-power` and `carmichael-from-factors`, with the 2^k
  special case for lambda; integer k-th roots and `perfect-power`
  detection; Miller-Rabin over the first 13 prime bases (deterministic below 3.3e24, per the code comment); a strong Lucas
  test with Selfridge parameters; `baillie-psw?`; and `check-rsa-key`,
  which returns a tuple recording p q = n, p and q prime, p != q,
  e d = 1 (mod lcm(p-1, q-1)), and a round trip of the messages 42 and 2.
* **`rsa-omega.factoring`**: every engine returns a `fact-result` with the
  factor or f, an iteration count, and a status (`found`, `not-found` or
  `budget-exhausted`). The engines are trial division; a mod-30 wheel;
  Fermat's difference of squares; Pollard rho with Brent's cycle
  detection; Pollard p - 1 stage 1; Williams p + 1 stage 1 using Lucas V
  sequences; and Lenstra ECM on Montgomery curves with Suyama
  parametrisation, a Montgomery ladder, and stages 1 and 2.
* **`rsa-omega.qs`**: a single-polynomial quadratic sieve. It builds a
  factor base of primes with (n/p) = 1, finds Tonelli-Shanks roots, runs
  a block log-sieve whose candidates are confirmed by trial division,
  performs Gaussian elimination over GF(2) on bitmask parity vectors, and
  finishes with the square-root step gcd(X - Y, n). It has no fallback to
  any other method.
* **`rsa-omega.gnfs`**: GNFS **setup only**. It does base-m polynomial
  selection, checks that f(m) = n, and builds rational and algebraic
  factor bases. It has no sieving, linear algebra or square-root stage,
  and the harness labels its row `partial: setup-only`.
* **`rsa-omega.weakness`**: batch GCD over a product and remainder tree,
  and a shared-prime attack. Wiener's attack by continued fractions. A
  textbook e = 3 cube-root attack. Håstad's e = 3 broadcast attack via
  CRT. A common-modulus attack. A close-prime attack via Fermat. A
  malformed-modulus classifier (even, prime, or perfect power). A
  CRT-parameter validator (`bad-crt-params`) and the CRT-fault (Bellcore)
  attack. A deliberately weak LCG key generator with a seed-search attack.
* **`rsa-omega.attacks`**: an independent second implementation of
  Wiener, common-modulus and Håstad e = 3, plus `fermat-attack`. Its unit
  tests build their keys with `rsa-omega.fixtures`.
* **`rsa-omega.padding`**: PKCS#1 v1.5 type-2 padding and strict unpadding
  that rejects a wrong block length, a bad first or second byte, a missing
  0x00 separator, and a PS shorter than 8 bytes. OAEP with
  SHA-256 and MGF1, with negative tests for a corrupted byte and a wrong
  length.
* **`rsa-omega.symbolic`**: integer polynomials (`poly+`, `poly*`,
  `poly-divmod`, `poly-gcd`, and arithmetic modulo n); exact-rational
  Gram-Schmidt and **LLL** reduction; a Howgrave-Graham univariate
  small-root experiment and a degree-1 Coppersmith demonstration
  (`copper-deg1`); and proof-producing `gcd-certificate` and
  `inv-certificate` with validators.
* **`rsa-omega.fixtures`**: synthetic key builders for close primes,
  smooth p - 1, Wiener keys, common modulus, Håstad triples and unbalanced
  moduli.
* **`rsa-omega.harness`**: the benchmark harness. It uses fixed seeds per
  row, times each run with `nano-count`, takes memory deltas from
  `data-room`, writes JSON, and runs the key-invariant suite at 32 to
  2048 bits.
* **`rsa-omega.smoke`** and **`scratch.check`** are small probes. The smoke
  vocabulary does not load (see Limitations).

## How the research document maps to the code

| Research document section | Engine words that check it | Conformance claims |
|---|---|---|
| I. Number theory: N = 3233, phi, lambda, extended Euclid, d = 413, 65^17 = 2790 | `totient-from-factors`, `carmichael-pq`, `extended-gcd`, `mod-inverse`, `modexp`, `inv-certificate`, `rsa-key-consistent?` | I.01-I.17 |
| Results(N) table, n = 15 ... 10403 | `miller-rabin?`, `trial-division`, `carmichael-pq`, `gcd-certificate`, full message round-trip | T.n=*.* (80) |
| Worked Euclid traces for 899, 1763 and 10403; "30^2 - 1", "42^2 - 1" | `fermat`, `/mod` traces, `mod-inverse` | E.* (21) |
| The n = 65537^2 counterexample | `perfect-power`, `totient-from-factors`, `carmichael-from-factors`, `check-rsa-key` (p-ne-q) | P.* (22) |
| Complexity tables | asymptotic statements only; not numerically testable | none |
| Attention and softmax gradients, finite-difference bounds | new FP64 code in `rsa-omega.research` (softmax, attention forward and backward, central differences, FP32 rounding) | F.* (14) |
| J Newton-Schulz program | `j/newton-schulz.ijs` and `j/newton-schulz-expression.ijs`, run by `jconsole` | `results/box-run/j/` |
| BQN fused kernel and Möbius-bridge program | `bqn/fused-kernel.bqn` and `bqn/mobius-bridge.bqn`, run by CBQN (`BQN`) | `results/box-run/bqn/` |

The BQN and J sources are the author's programs, copied verbatim out of
`research/RSA-OMEGA-RESEARCH.md`. `scripts/run-array-langs.sh` runs each
one with CBQN and J. It does not reimplement them in Factor. If `BQN` or
`jconsole` is not on `PATH`, that script exits with `missing BQN` or
`missing jconsole`.

### Research claims that failed

Eight printed values in the Factor-checked sections do not match the
arithmetic. They are explained in `docs/RESEARCH-CONFORMANCE.md`. The
document itself is not changed. The J and BQN programs are not part of
that Factor check; their interpreter logs are under `results/box-run/j/`
and `results/box-run/bqn/`.

* **n = 65537^2.** phi(p^2) = lambda(p^2) = p(p - 1) = **4295032832**.
  The table and proof print 4294967296, which is 65536^2. The
  counterexample section prints 4294901760 (65536 x 65535) as the
  "correct" value, and 65536^2 = 4294836225 (which is actually 65535^2).
  The printed d = 2863311531 is therefore not an inverse of 3 modulo
  lambda: 3d mod 4295032832 = 4294901761, and decrypting m = 42 gives
  1655333588. The true inverse is d = 1431677611, and it decrypts
  correctly. The document's main point, that p = q violates the RSA
  precondition, is right, and the engine's `check-rsa-key` rejects the key.
Two claims are printed truncated rather than rounded (sqrt 10403 ~ 101.99
and 3.6e-11) and are accepted as truncations. One part of the document
moves from unresolved to measured: the attention-gradient finite-difference
check, which the document marks "EMPIRICALLY UNTESTED". It ran in FP64
and agrees to 5.36e-12, below the document's own bound of 3.6e-11.

## Verification: Lean 4 proofs

**Original package (`lean/RsaOmega.lean`, unchanged).** It proves in
general form: the difference of squares; the Bezout identity, by
`Nat.gcd` induction; the existence of a modular inverse when
gcd(a, m) = 1; CRT reconstruction for two coprime moduli; and
`rsa_inversion_general`, which says that under a `ValidRSA` key (e d = 1 +
k lambda, and m^lambda = 1 for units) decryption recovers every plaintext
coprime to n. `lake build` succeeds, with three linter warnings (an
unnecessary `simpa` and two unused simp arguments). `#print axioms` shows
`rsa_inversion_general` depends only on `propext` and `Quot.sound`. One
exception to the file header's "no custom axioms": `demo_rsa_roundtrip` is
closed by `native_decide`, so it depends on the compiler-trust axiom
`RsaOmega.demo_rsa_roundtrip._native.native_decide.ax_1_1`.

**New package (`tests/lean/ResearchConformance.lean`).** It requires the
original package and imports `RsaOmega`. It contains:

* The N = 3233 example. The Euclid trace, the back-substitution in `Int`,
  -367 mod 780 = 413, 65^17 mod 3233 = 2790, 2790^413 mod 3233 = 65, and
  the inverse's existence derived from the original `exists_mod_inverse`.
* All 8 Results(N) rows, through a `rowOK` predicate that checks
  primality, p q = n, phi, lambda, gcd(e, lambda) = 1, 1 < e < lambda and
  e d = 1 mod lambda. Primality uses a trial-division checker with a proof
  of soundness (`isPrimeTD_sound`). All messages round-trip for
  n = 15, 21, 77 and 143.
* The Euclid traces for 899, 1763 and 10403, and the N = 15 facts.
* The n = 65537^2 **errata as theorems**. For example,
  `erratum_table_phi : 65537 * 65536 ≠ 4294967296`,
  `erratum_d : 3 * 2863311531 % 4295032832 ≠ 1` and
  `p2_true_d : 3 * 1431677611 % 4295032832 = 1`.

Everything is closed by `decide` (kernel evaluation, with no
`native_decide`) or by a short proof. There is no `sorry` or `admit`.
`#print axioms` in the build log shows `roundtrip_3233`, `row_10403` and
`erratum_d` depend on no axioms, and `inverse_exists_3233` and
`isPrimeTD_sound` depend only on `propext` and `Quot.sound`.

## Benchmarks

**Machine:** KVM guest, Intel(R) Xeon(R) Processor (family 6, model 207),
8 vCPUs (1 thread per core), L2 16 MiB, 16,002 MiB RAM, Linux 6.12.113+
x86_64, Factor 0.102 (git `6f604bb`), Lean 4.35.0. The full `lscpu` output
is in `results/box-run/machine.txt`.

**Method:** `scripts/run-bench-repo.sh` was run three times in a row
(captured by `scripts/capture-box-run.sh`). Each row uses a fixed seed, so
the modulus, the factor found and the iteration count were identical in
all three runs (`scripts/summarize-bench.py` refuses to merge runs that
differ). Only wall time varies. Times are single-threaded milliseconds from
`nano-count`.

| Algorithm | n bits | Outcome | Iterations | Factor / detail | Run 1 ms | Run 2 ms | Run 3 ms | Median ms |
|---|---|---|---|---|---|---|---|---|
| trial-division | 32 | factored | 24286 | 48571 | 0.660 | 0.526 | 0.563 | 0.563 |
| wheel-30 | 39 | factored | 180043 | 675151 | 7.404 | 7.283 | 7.784 | 7.404 |
| fermat (close primes) | 128 | factored | 1 | 16923431781128670641 | 0.009 | 0.010 | 0.009 | 0.009 |
| pollard-rho-brent | 64 | factored | 125694 | 4247772127 | 46.266 | 47.752 | 46.951 | 46.951 |
| pollard-p-1 (smooth p-1) | 85 | factored | 95 | 29682952539241 | 0.172 | 0.174 | 0.172 | 0.172 |
| williams-p+1 (smooth p+1) | 51 | factored | 46 | 38039 | 0.074 | 0.080 | 0.078 | 0.078 |
| ecm | 92 | factored | 38368 | 209337857 | 1218.677 | 1560.985 | 1222.016 | 1222.016 |
| quadratic-sieve | 60 | factored | 1 | 1035339919 | 19.407 | 20.925 | 20.328 | 20.328 |
| quadratic-sieve | 80 | factored | 4 | 969858954509 | 41.935 | 42.352 | 42.828 | 42.352 |
| quadratic-sieve | 100 | factored | 1 | 1074437236025807 | 585.076 | 594.320 | 601.237 | 594.320 |
| gnfs-partial | 63 | setup-ok | 101 | setup only | 1.649 | 1.639 | 1.553 | 1.639 |
| wiener (small d) | 256 | recovered-d | 0 | d = 1000003 | 0.076 | 0.073 | 0.080 | 0.076 |
| batch-gcd (3 moduli) | 64 | shared-prime | 0 | 3636387361 | 0.053 | 0.049 | 0.047 | 0.049 |
| copper-deg1 | 40 | recovered-root | 0 | root 42 | 21.250 | 21.314 | 21.965 | 21.314 |
| padding-pkcs-oaep | 1024 | ok | 0 | round trip + negative test | 308.896 | 311.392 | 323.408 | 311.392 |
| key-invariants | 32-2048 (7 rows) | pass | 0 | p*q, prime, ed, roundtrip | not timed | not timed | not timed | - |
| rsa-2048-factor | 2048 | skipped | 0 | not factored (secure size) | - | - | - | - |

How to read the table, based on the harness code:

* The "iterations" column means a different thing for each engine. For
  `quadratic-sieve` it is the number of GF(2) dependencies tried. For
  `gnfs-partial` it is the algebraic factor-base size. For ECM it is the
  number of ladder multiplications over all curves, stage 1 and stage 2.
* The `padding-pkcs-oaep` time includes generating the 1024-bit key inside
  the timed block, so it mostly measures key generation.
* The `key-invariants` rows are recorded with `ms = 0.0` because they are
  not timed. Their `timeout` field is `true` for 1024 and 2048 bits only
  because the harness passes `bits 1024 >=` in that slot. They did pass.
* `mem_bytes` is the change in tenured-space occupancy and is mostly 0;
  it is not a peak-memory measurement.
* ECM run 2 (1560.985 ms) is an outlier against 1218.677 and 1222.016 ms.
  Treat single runs on a shared VM as approximate.

The `results/bench-run.txt` that shipped with the upload (an earlier run) has the same
23 rows with the same outcomes. Its times are of the same magnitude (for
example, ECM 1364.376 ms and QS-100 700.662 ms).

## Limitations and partial parts

* **GNFS is setup only.** It has no sieve, linear algebra or square root,
  so it never factors n.
* **`rsa-omega.smoke` does not load.** It calls `pollard-p1-factor`, which
  does not exist; the factoring vocabulary exports `pollard-p-1`. The
  error is in `results/box-run/smoke.txt`. The file is kept unchanged.
* **Two engine test files rely on auto-restarts.**
  `numtheory-tests.factor` and `weakness-tests.factor` are missing some
  `USING:` entries. Factor adds the vocabularies automatically and prints
  "Restarts were invoked", and the tests still pass.
* **`check-rsa-key` round-trips the fixed message 42**, so it reports
  `roundtrip-ok f` for moduli of 42 or less, even for valid keys.
* **Duplicate implementations.** `rsa-omega.attacks` and
  `rsa-omega.weakness` both define `wiener-attack`, `convergents`,
  `pow-signed` and `common-modulus-attack`.
* **Benchmarks cover one modulus per row**, from fixed seeds. They are not
  statistical runtime distributions.
* The build machine has no `make` binary, so the `Makefile` targets were
  run here as their underlying script commands.

## Provenance

`docs/PROVENANCE.md` lists exactly which files are original and which are
new. In short, `sha256sum -c MANIFEST.sha256` must print `OK` for all 37
preserved files. The only moves are the original README (to
`docs/README-original.md`) and the research document (into `research/`).
The original README's note that the research attachment was missing is
superseded by `docs/RESEARCH-DOCUMENT.md`.

## License

See `LICENSE`.
