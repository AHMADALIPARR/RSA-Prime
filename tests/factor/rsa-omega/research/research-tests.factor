! SPDX-License-Identifier: AGPL-3.0-only
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU Affero General Public License as published by
! the Free Software Foundation, version 3.
! See the LICENSE file.

! Unit tests for the research-document conformance vocabulary.
! These assert mathematically correct engine values for the concrete
! numbers in research/RSA-OMEGA-RESEARCH.md, and pin the exact set of
! document claims that the engine disagrees with (see
! docs/RESEARCH-CONFORMANCE.md for the explanation of each one).
USING: accessors kernel math math.functions sequences tools.test
       rsa-omega.arithmetic rsa-omega.numtheory rsa-omega.factoring
       rsa-omega.symbolic rsa-omega.research ;
IN: rsa-omega.research.tests

! ---- N = 3233 worked example (section I) ----
{ 3233 } [ 61 53 * ] unit-test
{ 3120 } [ { { 61 1 } { 53 1 } } totient-from-factors ] unit-test
{ 780 } [ 61 53 carmichael-pq ] unit-test
{ 8 -367 1 } [ 780 17 extended-gcd ] unit-test
{ 413 } [ 17 780 mod-inverse ] unit-test
{ 2790 } [ 65 17 3233 modexp ] unit-test
{ 65 } [ 2790 413 3233 modexp ] unit-test
{ t } [ 3233 17 413 61 53 rsa-key-consistent? ] unit-test
{ t } [ 17 780 inv-certificate inv-cert-valid? ] unit-test

! ---- Results(N) table rows ----
{ 3 } [ 15 3 trial-division factor>> ] unit-test
{ 43 } [ 7 60 mod-inverse ] unit-test
{ 29 } [ 5 144 mod-inverse ] unit-test
{ 191 } [ 11 420 mod-inverse ] unit-test
{ 611 } [ 11 840 mod-inverse ] unit-test
{ 3643 } [ 7 5100 mod-inverse ] unit-test
{ 29 } [ 899 100 fermat factor>> ] unit-test
{ 41 } [ 1763 100 fermat factor>> ] unit-test
{ 101 } [ 10403 101 trial-division factor>> ] unit-test
{ 5100 } [ 101 103 carmichael-pq ] unit-test
{ 0 } [ 10403 7 3643 roundtrip-failures ] unit-test
{ 0 } [ 15 3 3 roundtrip-failures ] unit-test
! The engine's key check needs n > 42 for its fixed round-trip message,
! so it reports roundtrip-ok f for the n = 15 and n = 21 toy keys even
! though every message round-trips (previous two tests).
{ f } [ 15 3 3 3 5 check-rsa-key roundtrip-ok>> ] unit-test
{ t } [ 77 7 13 7 11 rsa-key-consistent? ] unit-test

! ---- n = 65537^2: correct values (the document prints different ones) ----
{ 4295098369 } [ 65537 sq ] unit-test
{ 4295032832 } [ { { 65537 2 } } totient-from-factors ] unit-test
{ 4295032832 } [ { { 65537 2 } } carmichael-from-factors ] unit-test
{ 4295032832 } [ 65537 65536 * ] unit-test
{ 4294967296 } [ 65536 sq ] unit-test
{ 1431677611 } [ 3 4295032832 mod-inverse ] unit-test
{ 42 } [ 42 3 4295098369 modexp 1431677611 4295098369 modexp ] unit-test
{ f } [ 42 3 4295098369 modexp 2863311531 4295098369 modexp 42 = ] unit-test

! ---- Newton-Schulz, exact rationals ----
{ { { 3/20 -11/20 } { -11/20 7/20 } } } [ ns-iterates first ns-residual ] unit-test
{ t } [
    ns-iterates last mfloat
    { { 0.29980453 -0.09976578 } { -0.19968372 0.39962103 } }
    [ [ - abs ] 2map supremum ] 2map supremum 0.000000005 <=
] unit-test

! ---- floating point ----
{ 0.0 } [ { 100.0 -100.0 } softmax-row second f32 ] unit-test
{ t } [ 0.0 1/0. * fp-nan? ] unit-test
{ t } [ attention-fd-delta 1e-6 <= ] unit-test
{ t } [ matmul-fd-delta 1e-6 <= ] unit-test
{ t } [ jacobian-vjp-delta 1e-15 <= ] unit-test

! ---- the full claim set: 180 claims, these 11 disagree with the doc ----
{ 180 } [ run-research-checks length ] unit-test
{
    {
        "P.06" "P.07" "P.08" "P.09" "P.10" "P.14" "P.15" "P.16"
        "N.10" "N.12.0" "B.09"
    }
} [ failing-claim-ids ] unit-test
