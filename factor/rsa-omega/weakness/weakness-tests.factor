! SPDX-License-Identifier: AGPL-3.0-only
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU Affero General Public License as published by
! the Free Software Foundation, version 3.
! See the LICENSE file.

USING: accessors kernel math sequences tools.test
       rsa-omega.weakness rsa-omega.arithmetic rsa-omega.numtheory ;
IN: rsa-omega.weakness.tests

{ { 101 101 f } } [
    101 103 * 101 107 * 109 113 * 3array shared-prime-attack
] unit-test

{ t } [
    1000000007 1000000009 * 1000 close-prime-attack
    first 1000000007 =
] unit-test

{ "n is a perfect power (repeated prime)" } [
    15485863 sq malformed-modulus
] unit-test
{ "n is prime" } [ 17 malformed-modulus ] unit-test
{ "n is even" } [ 100 malformed-modulus ] unit-test
{ f } [ 1000003 1000033 * malformed-modulus ] unit-test

:: wiener-ok? ( -- ? )
    1009 1013 * :> n
    5 1008 1012 * mod-inverse :> e
    e n wiener-attack 5 = ;

{ t } [ wiener-ok? ] unit-test

{ 42 } [
    42 3 ^ 1000000007 textbook-cube-root-attack
] unit-test

{ "qinv*q != 1 (mod p)" } [
    61 53 17 17 0 65537 bad-crt-params
] unit-test

:: weak-prng-ok? ( -- ? )
    4 24 weak-prng-key :> ( n p q )
    n 4 24 weak-prng-attack drop p = ;

{ t } [ weak-prng-ok? ] unit-test
