! SPDX-License-Identifier: AGPL-3.0-only
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU Affero General Public License as published by
! the Free Software Foundation, version 3.
! See the LICENSE file.

! Copyright (C) 2026 RSA-CRYPTANALYSIS-OMEGA (synthetic research only).
! GNFS -- PARTIAL. Only the stages below are implemented and testable:
!   * base-m polynomial selection: n in base m gives f(x) with f(m) = n
!   * rational factor base (primes up to bound)
!   * algebraic factor base: pairs (p, r) with f(r) = 0 (mod p)
!   * verification that f(m) = n exactly
! Sieving / linear algebra / square-root over number fields are NOT done.
! This module NEVER returns a factorization and never claims one.
USING: accessors arrays kernel math math.functions math.order
       math.primes ranges sequences rsa-omega.numtheory ;
IN: rsa-omega.gnfs

TUPLE: nfs-poly m degree coeffs ;

:: select-poly-base-m ( n degree -- poly )
    ! m = floor(n^(1/degree)); expand n in base m => coefficients (low..high)
    n degree iroot :> m
    n :> r!
    V{ } clone :> cs
    [ r 0 > ] [ r m rem cs push r m /i r! ] while
    cs length degree <= [ 0 cs push ] when      ! ensure leading term present
    m degree cs >array nfs-poly boa ;

:: poly-eval ( poly x -- v )
    ! Horner evaluation of f(x) over the integers
    0 poly coeffs>> <reversed> [ swap x * + ] each ;

:: poly-value-at-m ( poly -- n )
    poly dup m>> poly-eval ;

:: rational-factor-base ( bound -- primes )
    bound primes-upto ;

:: algebraic-factor-base ( poly bound -- pairs )
    ! pairs { p r } with f(r) = 0 (mod p)
    bound primes-upto [| p |
        p <iota> [| r | poly r poly-eval p rem 0 = [ r p 2array ] [ f ] if ] map
        [ ] filter
    ] map concat ;

TUPLE: nfs-setup poly n rational-fb-size algebraic-fb-size
    poly-check status note ;

:: gnfs-setup ( n degree rat-bound alg-bound -- setup )
    n degree select-poly-base-m :> poly
    poly poly-value-at-m n = :> ok
    rat-bound rational-factor-base length :> rfb
    poly alg-bound algebraic-factor-base length :> afb
    poly n rfb afb ok
    "partial: setup-only (no sieving/linalg/sqrt)"
    "GNFS is intentionally incomplete; it never returns factors."
    nfs-setup boa ;
