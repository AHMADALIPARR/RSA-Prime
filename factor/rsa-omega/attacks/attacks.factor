! SPDX-License-Identifier: AGPL-3.0-only
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU Affero General Public License as published by
! the Free Software Foundation, version 3.
! See the LICENSE file.

! Copyright (C) 2026 RSA-CRYPTANALYSIS-OMEGA (synthetic research only).
USING: accessors kernel math math.functions math.order
       sequences arrays combinators make
       rsa-omega.arithmetic rsa-omega.factoring ;
IN: rsa-omega.attacks

: (cf-quotients) ( num den -- )
    dup zero? [ 2drop ] [
        2dup /i ,
        swap over mod   ! ( den  num_mod_den )
        (cf-quotients)
    ] if ;

: cf-quotients ( num den -- seq )
    [ (cf-quotients) ] { } make ;

:: convergents ( quotients -- pairs )
    V{ } clone :> out
    0 :> hm2!
    1 :> hm1!
    1 :> km2!
    0 :> km1!
    quotients [
        :> a
        a hm1 * hm2 + :> h
        a km1 * km2 + :> k
        h k 2array out push
        hm1 hm2!
        h hm1!
        km1 km2!
        k km1!
    ] each
    out >array ;

:: wiener-check-convergent ( e n k d -- d/f )
    d 0 = [ f ] [
        k 0 = [ f ] [
            e d * 1 - :> ed1
            ed1 k mod zero? [
                ed1 k /i :> phi
                phi 0 <= [ f ] [
                    n phi - 1 + :> s
                    s sq n 4 * - :> disc
                    disc 0 >= [
                        disc perfect-square? [ d ] [ f ] if
                    ] [ f ] if
                ] if
            ] [ f ] if
        ] if
    ] if ;

:: wiener-attack ( e n -- d/f )
    e n cf-quotients convergents
    f :> found!
    [
        first2 :> ( k d )
        found [
        ] [
            e n k d wiener-check-convergent
            dup [ found! ] [ drop ] if
        ] if
    ] each
    found ;

:: pow-signed ( c exp n -- r )
    exp 0 >= [
        c exp n ^mod
    ] [
        c n mod-inverse exp neg n ^mod
    ] if ;

:: common-modulus-attack ( c1 c2 e1 e2 n -- m/f )
    e1 e2 extended-gcd :> ( s t g )
    g 1 = [
        c1 s n pow-signed
        c2 t n pow-signed
        * n mod
    ] [ f ] if ;

:: icbrt ( x -- r )
    x 0 = [ 0 ] [
        x log2 3 /i 1 + 2^ :> r!
        0 :> i!
        [ i 64 < ] [
            2 r * x r sq /i + 3 /i :> nr
            nr r = [ 64 i! ] [ nr r! i 1 + i! ] if
        ] while
        r
    ] if ;

:: hastad-e3-crt ( c1 n1 c2 n2 c3 n3 -- m/f )
    n1 n2 * n3 * :> N
    N n1 /i :> N1
    N n2 /i :> N2
    N n3 /i :> N3
    N1 dup n1 mod-inverse * c1 * :> t1
    N2 dup n2 mod-inverse * c2 * :> t2
    N3 dup n3 mod-inverse * c3 * :> t3
    t1 t2 + t3 + N mod :> x
    x icbrt :> r
    r 3 ^ x = [ r ] [ f ] if ;

: fermat-attack ( n max-steps -- factor/f ) fermat factor>> ;
