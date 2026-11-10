| algorithm | bits | outcome | iterations | detail | run 1 ms | run 2 ms | run 3 ms | median ms |
|---|---|---|---|---|---|---|---|---|
| trial-division | 32 | factored | 24286 | 48571 | 0.660 | 0.526 | 0.563 | 0.563 |
| wheel-30 | 39 | factored | 180043 | 675151 | 7.404 | 7.283 | 7.784 | 7.404 |
| fermat | 128 | factored | 1 | 16923431781128670641 | 0.009 | 0.010 | 0.009 | 0.009 |
| pollard-rho-brent | 64 | factored | 125694 | 4247772127 | 46.266 | 47.752 | 46.951 | 46.951 |
| pollard-p-1 | 85 | factored | 95 | 29682952539241 | 0.172 | 0.174 | 0.172 | 0.172 |
| williams-p+1 | 51 | factored | 46 | 38039 | 0.074 | 0.080 | 0.078 | 0.078 |
| ecm | 92 | factored | 38368 | 209337857 | 1218.677 | 1560.985 | 1222.016 | 1222.016 |
| quadratic-sieve | 60 | factored | 1 | 1035339919 | 19.407 | 20.925 | 20.328 | 20.328 |
| quadratic-sieve | 80 | factored | 4 | 969858954509 | 41.935 | 42.352 | 42.828 | 42.352 |
| quadratic-sieve | 100 | factored | 1 | 1074437236025807 | 585.076 | 594.320 | 601.237 | 594.320 |
| gnfs-partial | 63 | setup-ok | 101 | partial: setup-only (no sieving/linalg/sqrt) | 1.649 | 1.639 | 1.553 | 1.639 |
| wiener | 256 | recovered-d | 0 | 1000003 | 0.076 | 0.073 | 0.080 | 0.076 |
| batch-gcd | 64 | shared-prime | 0 | 3636387361 | 0.053 | 0.049 | 0.047 | 0.049 |
| copper-deg1 | 40 | recovered-root | 0 | 42 | 21.250 | 21.314 | 21.965 | 21.314 |
| padding-pkcs-oaep | 1024 | ok | 0 | roundtrip+negative | 308.896 | 311.392 | 323.408 | 311.392 |
| key-invariants | 32 | pass | 0 | p*q,prime,ed,roundtrip | 0.000 | 0.000 | 0.000 | 0.000 |
| key-invariants | 64 | pass | 0 | p*q,prime,ed,roundtrip | 0.000 | 0.000 | 0.000 | 0.000 |
| key-invariants | 128 | pass | 0 | p*q,prime,ed,roundtrip | 0.000 | 0.000 | 0.000 | 0.000 |
| key-invariants | 256 | pass | 0 | p*q,prime,ed,roundtrip | 0.000 | 0.000 | 0.000 | 0.000 |
| key-invariants | 512 | pass | 0 | p*q,prime,ed,roundtrip | 0.000 | 0.000 | 0.000 | 0.000 |
| key-invariants | 1024 | pass | 0 | p*q,prime,ed,roundtrip | 0.000 | 0.000 | 0.000 | 0.000 |
| key-invariants | 2048 | pass | 0 | p*q,prime,ed,roundtrip | 0.000 | 0.000 | 0.000 | 0.000 |
| rsa-2048-factor | 2048 | skipped | 0 | synthetic 2048-bit n not factored (secure size) | 0.000 | 0.000 | 0.000 | 0.000 |

Runs (in column order): /workspace/rsa-omega-prod/results/box-run/results.json, /workspace/rsa-omega-prod/results/box-run/results-repeat-2.json, /workspace/rsa-omega-prod/results/box-run/results-repeat-3.json
