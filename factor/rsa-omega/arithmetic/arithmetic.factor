! SPDX-License-Identifier: AGPL-3.0-only
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU Affero General Public License as published by
! the Free Software Foundation, version 3.
! See the LICENSE file.

! Copyright (C) 2026 RSA-CRYPTANALYSIS-OMEGA (synthetic research only).
USING: kernel math math.functions math.order math.primes
       math.bits random ;
IN: rsa-omega.arithmetic

:: extended-gcd ( a b -- s t g )
    a :> aa!
    b :> bb!
    1 :> old-s!
    0 :> s!
    0 :> old-t!
    1 :> t!
    [ bb zero? not ] [
        aa bb /i :> q
        bb :> rtmp!
        aa q bb * - bb!
        rtmp aa!
        s :> stmp!
        old-s q s * - s!
        stmp old-s!
        t :> ttmp!
        old-t q t * - t!
        ttmp old-t!
    ] while
    old-s old-t aa ;

:: mod-inverse ( a m -- a^-1 )
    a m extended-gcd 2drop :> s
    s 0 < [ s m + ] [ s ] if ;

:: isqrt ( n -- root )
    n 0 <= [ 0 ] [
        n log2 2/ 1 + 2^ :> x!
        [ x sq n > ] [
            x n x /i + 2/ x!
        ] while
        x
    ] if ;

: perfect-square? ( n -- ? )
    dup isqrt sq = ;

: modexp ( base exp mod -- r ) ^mod ;

: generate-prime-bits ( bits -- p )
    random-prime ;

: next-prime-from ( n -- p )
    next-prime ;
