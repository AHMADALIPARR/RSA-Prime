! SPDX-License-Identifier: AGPL-3.0-only
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU Affero General Public License as published by
! the Free Software Foundation, version 3.
! See the LICENSE file.

USING: kernel math prettyprint io math.primes.factors sequences
       rsa-omega.factoring rsa-omega.fixtures ;
IN: rsa-omega.smoke
:: smoke-main ( -- )
    30 40 make-smooth-p1-modulus :> ( n p q )
    "max " write p 1 - factors maximum . flush
    n 200000 pollard-p1-factor :> g
    g [ n g mod zero? . ] [ "fail" print ] if
    ;
MAIN: smoke-main
