# Research document conformance

Source of every number below: `results/box-run/research-report.txt` and
`results/box-run/research-claims.json`, produced on this box by
`scripts/run-research-report.sh` (vocabulary `rsa-omega.research` in
`tests/factor/`). The kernel-checked Lean counterparts are in
`tests/lean/ResearchConformance.lean`.

The research document (`research/RSA-OMEGA-RESEARCH.md`) is **not
modified**. Where it disagrees with the arithmetic, the disagreement is
recorded here.

## Summary

| Section of the document | Claims checked | Agree | Disagree |
|---|---|---|---|
| I. N = 3233, e = 17, d = 413, m = 65, c = 2790 | 17 | 17 | 0 |
| Results(N) table, 8 rows x 10 checks | 80 | 80 | 0 |
| Extended-Euclid traces, n = 899 / 1763 / 10403 | 21 | 21 | 0 |
| n = 65537^2 (the p = q counterexample) | 22 | 14 | 8 |
| Newton-Schulz matrix inversion | 17 | 15 | 2 |
| Finite-difference bounds, softmax, IEEE 754, attention gradients | 14 | 14 | 0 |
| BQN N = 15 section | 9 | 8 | 1 |
| **Total** | **180** | **169** | **11** |

How a claim is compared: integers, rationals and booleans must be equal.
Decimals are compared at the precision the document printed (a stated
tolerance per claim). Two claims print a truncated rather than rounded
value (sqrt 10403 ~ 101.99, actual 101.99509...; FP64 bound ~ 3.6e-11,
actual 3.6669e-11); these are checked as truncations and agree.

## What agrees (highlights)

* The full N = 3233 example: phi = 3120, lambda = 780, the Euclid steps
  780 = 45(17) + 15, 17 = 1(15) + 2, 15 = 7(2) + 1, the back-substitution
  1 = 8(780) - 367(17) (the engine's `extended-gcd 780 17` returns exactly
  8, -367, 1), d = 413, 17 x 413 = 7021 = 9(780) + 1,
  65^17 mod 3233 = 2790 and 2790^413 mod 3233 = 65.
* All 8 rows of the Results(N) table (n = 15 ... 10403): p and q prime,
  p q = n, phi, lambda, 1 < e < lambda, gcd(e, lambda) = 1, the printed d is
  the engine's `mod-inverse`, e d = 1 (mod lambda), and every message
  m in [0, n) round-trips (0 failures for every row).
* Newton-Schulz: det A = 10, the exact inverse, T0, E0, ||E0||_inf = 0.9,
  E_{n+1} = E_n^2 exactly (checked in exact rationals for n = 0..4),
  ||E5||_inf <= 0.9^32 ~ 0.0343, and the 8-decimal T5 matrix
  (engine: 0.2998045287793502, -0.09976578389760107,
  -0.19968372092116624, 0.399621030385606).
* Iteration table rows 1-5 match the Frobenius norm ||E_n||_F to 6 d.p.
* softmax(<10, -10>)_2 = 2.06e-9 (~2e-9); softmax(<100, -100>)_2 is 0.0
  after rounding to FP32 (it is 1.38e-87 in FP64); 0 x inf = NaN and
  1 + NaN = NaN.
* The softmax Jacobian J = diag(p) - p p^T is symmetric and
  J^T v = p (.) (v - <p, v>): max |difference| = 5.55e-17.
* The attention backward-pass formulas (dV = P^T G, dP = G V^T,
  dS = P (.) (dP - rowsum(dP (.) P)), dQ = dS K / sqrt d,
  dK = dS^T Q / sqrt d) agree with central finite differences
  (h = eps^(1/3)) to max |difference| = 5.36e-12 in FP64, for a 3x2
  example. The document marks this check "UNRESOLVED / EMPIRICALLY
  UNTESTED"; it has now been run. The matrix-product rule
  dA = G B^T, dB = A^T G agrees to 5.05e-12.
* N = 15: the 8 units, the listed squares mod 15, no square root of -1,
  lambda = 4, phi = 8, 7 x 3 = 1 (mod 4).

## The 11 disagreements

### n = 65537^2 (claims P.06, P.07, P.08, P.09, P.10, P.14, P.15, P.16)

The true values are phi(p^2) = lambda(p^2) = p(p - 1) = 65537 x 65536 =
**4295032832** (engine `totient-from-factors { { 65537 2 } }` and
`carmichael-from-factors`; Lean `p2_phi_true`).

| Claim | Document prints | Correct value | What the printed number actually is |
|---|---|---|---|
| P.06 / P.09 table and proof: phi(p^2) = 65537 x 65536 | 4294967296 | 4295032832 | 65536^2 = (p - 1)^2 |
| P.07 table: lambda(p^2) | 4294967296 | 4295032832 | 65536^2 |
| P.08 counterexample section: "correct" phi(p^2) = p(p - 1) | 4294901760 | 4295032832 | 65536 x 65535 |
| P.10 counterexample section: (p - 1)(q - 1) = 65536^2 | 4294836225 | 4294967296 | 65535^2 |
| P.14 3 x 2863311531 = 1 (mod lambda(p^2)) | 1 | 4294901761 | - |
| P.15 d = 3^-1 mod lambda(p^2) | 2863311531 | **1431677611** | inverse of 3 mod 2^32 |
| P.16 the key (e = 3, d = 2863311531) decrypts m = 42 | 42 | 1655333588 | - |

The arithmetic 3 x 2863311531 = 8589934593 = 2(4294967296) + 1 is itself
correct (P.13 agrees); the error is that 4294967296 is not lambda(p^2).
With the correct d = 1431677611 the engine decrypts m = 42 (P.16b) and
3d = 1 (mod 4295032832) (P.16c). The engine's `check-rsa-key` rejects the
modulus because p = q (P.17). The document's main point, that
65537^2 breaks the p != q precondition, stands.

### Newton-Schulz (claims N.10, N.12.0)

* N.10: the first T5 printed, ~[[0.297, -0.093], [-0.194, 0.386]], is off
  at 3 d.p.; the exact iterate is [[0.29980..., -0.09976...],
  [-0.19968..., 0.39962...]]. The later 8-d.p. T5 in the document is
  correct (N.11).
* N.12.0: iteration table row 0 prints 1.118034. Rows 1-5 equal
  ||E_n||_F, but ||E_0||_F = sqrt(0.75) = 0.8660254. We could not find the
  quantity that 1.118034 measures, so it is reported as a mismatch.

### BQN N = 15 (claim B.09)

* theta = arctan(7 / sqrt 15) is printed as ~1.062 rad; it is
  1.0654358165107394 rad.

## Engine behaviour found while checking (not document errors)

* `check-rsa-key` round-trips the fixed message 42, so it reports
  `roundtrip-ok f` for n <= 42 (the n = 15 and n = 21 toy keys) although
  every message round-trips for those keys. Pinned in
  `research-tests.factor`.
