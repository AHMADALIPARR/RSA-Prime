! SPDX-License-Identifier: AGPL-3.0-only
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU Affero General Public License as published by
! the Free Software Foundation, version 3.
! See the LICENSE file.

! Copyright (C) 2026 RSA-CRYPTANALYSIS-OMEGA (synthetic research only).
! Quadratic sieve (single polynomial Q(x) = x^2 - n, x > sqrt(n)):
!  1. factor base of primes p <= B with (n/p) = 1
!  2. Tonelli-Shanks roots of x^2 = n (mod p)
!  3. block log-sieve, candidates verified by full trial division
!  4. GF(2) Gaussian elimination on parity vectors (bitmask rows)
!  5. square root step: X = prod x, Y = prod p^(e/2), gcd(X - Y, n)
! No fallback to any other method.
USING: accessors arrays byte-arrays combinators kernel math
       math.functions math.order math.primes ranges sequences
       vectors rsa-omega.arithmetic rsa-omega.numtheory
       rsa-omega.factoring ;
IN: rsa-omega.qs

! ---------- Tonelli-Shanks ----------
:: sqrt-mod ( a p -- r )
    a p rem :> a0
    {
        { [ a0 0 = ] [ 0 ] }
        { [ p 2 = ] [ a0 ] }
        { [ p 4 rem 3 = ] [ a0 p 1 + 4 /i p ^mod ] }
        [
            p 1 - :> q!
            0 :> s!
            [ q even? ] [ q 2/ q! s 1 + s! ] while
            2 :> z!
            [ z p legendre -1 = not ] [ z 1 + z! ] while
            s :> m!
            z q p ^mod :> c!
            a0 q p ^mod :> t!
            a0 q 1 + 2/ p ^mod :> r!
            [ t 1 = not ] [
                0 :> i!
                t :> tt!
                [ tt 1 = not ] [ tt sq p rem tt! i 1 + i! ] while
                c 2 m i - 1 - ^ p ^mod :> b
                i m!
                b sq p rem c!
                t c * p rem t!
                r b * p rem r!
            ] while
            r
        ]
    } cond ;

TUPLE: qs-run factor status fb-size relations needed blocks
    candidates sieved deps-tried bound ;

:: qs-default-bound ( n -- B )
    ! L(n)^(1/2) heuristic scaled; min 150
    n log2 0.6931471805599453 * :> ln-n
    ln-n ln-n log * sqrt 0.5 * e^ 2.2 * >integer 150 max ;

:: factor-base ( n B -- primes )
    B primes-upto [| p |
        p 2 = [ t ] [ n p rem 0 = [ t ] [ n p legendre 1 = ] if ] if
    ] filter ;

:: trial-factor-fb ( q fb -- exps/f )
    ! full trial division of q over fb; exps array if q is fb-smooth
    q :> r!
    fb length 0 <array> :> ex
    fb [| p i |
        [ r p rem 0 = ] [ r p /i r! i ex [ 1 + ] change-nth ] while
    ] each-index
    r 1 = [ ex ] [ f ] if ;

:: parity-mask ( exps -- mask )
    0 exps [| e i | e odd? [ 1 i shift bitor ] when ] each-index ;

:: gf2-dependencies ( masks -- deps )
    ! returns sequence of relation-index bitmasks whose parity sum is 0
    masks >array clone :> rows
    rows length <iota> [ 1 swap shift ] map :> hist
    rows length f <array> :> pivoted
    rows length 0 = [ { } ] [
        rows [ ] [ bitor ] map-reduce :> allbits
        allbits 0 = [ 0 ] [ allbits log2 1 + ] if :> ncols
        ncols <iota> [| col |
            f :> piv!
            rows length <iota> [| j |
                piv [
                    j pivoted nth not [ j rows nth col bit? [ j piv! ] when ] when
                ] unless
            ] each
            piv [
                t piv pivoted set-nth
                piv rows nth :> prow
                piv hist nth :> phist
                rows length <iota> [| j |
                    j piv = not [
                        j rows nth col bit? [
                            j rows nth prow bitxor j rows set-nth
                            j hist nth phist bitxor j hist set-nth
                        ] when
                    ] when
                ] each
            ] when
        ] each
        rows length <iota> [ rows nth 0 = ] filter [ hist nth ] map
    ] if ;

:: qs-sqrt-step ( dep xs exps-list fb n -- g )
    1 :> X!
    fb length 0 <array> :> tot
    xs length <iota> [| i |
        dep i bit? [
            X i xs nth * n rem X!
            i exps-list nth [| e k | k tot [ e + ] change-nth ] each-index
        ] when
    ] each
    1 :> Y!
    tot [| e k |
        e odd? [ "qs: dependency is not a square (bug)" throw ] when
        Y k fb nth e 2/ n ^mod * n rem Y!
    ] each-index
    X Y - n gcd nip ;

:: quadratic-sieve ( n B block-size max-blocks -- run )
    n isqrt 1 + :> s
    n B factor-base :> fb
    ! trivial divisor inside factor base?
    fb [ n swap rem 0 = ] find nip :> small
    small [
        small "found-in-factor-base" fb length 0 0 0 0 0 0 B qs-run boa
    ] [
        fb length 10 + :> needed
        ! per-prime sieve data: roots as offsets relative to s
        fb [| p |
            p 2 = [ { 1 } ] [ n p sqrt-mod :> t t p t - 2array ] if
            [ s - p rem ] map
        ] map :> offsets
        fb [ log 0.6931471805599453 / round >integer ] map :> logp
        fb last :> pmax
        V{ } clone :> xs
        V{ } clone :> exps-list
        V{ } clone :> masks
        0 :> blocks!
        0 :> cands!
        [ masks length needed < blocks max-blocks < and ] [
            blocks block-size * :> j0
            block-size <byte-array> :> sieve
            ! sieve with primes >= 30 (small primes accounted for by slack)
            fb [| p k |
                p 30 >= [
                    k logp nth :> lp
                    k offsets nth [| off |
                        off j0 - p rem :> i!
                        [ i block-size < ] [
                            i sieve [ lp + ] change-nth
                            i p + i!
                        ] while
                    ] each
                ] when
            ] each-index
            s j0 + block-size 2/ + :> xmid
            xmid sq n - log2 pmax log2 2 * - 4 - :> target
            block-size <iota> [| i |
                i sieve nth target >= [
                    cands 1 + cands!
                    s j0 + i + :> x
                    x sq n - fb trial-factor-fb :> ex
                    ex [
                        ex parity-mask :> mk
                        x xs push ex exps-list push mk masks push
                    ] when
                ] when
            ] each
            blocks 1 + blocks!
        ] while
        masks length needed < [
            f "budget-exhausted" fb length masks length needed blocks cands
            blocks block-size * 0 B qs-run boa
        ] [
            masks gf2-dependencies :> deps
            f :> g!
            0 :> tried!
            deps [| dep |
                g [
                    tried 1 + tried!
                    dep xs exps-list fb n qs-sqrt-step :> gg
                    gg 1 > gg n < and [ gg g! ] when
                ] unless
            ] each
            g g [ "found" ] [ "dependencies-exhausted" ] if
            fb length masks length needed blocks cands
            blocks block-size * tried B qs-run boa
        ] if
    ] if ;

: qs ( n -- run )
    dup qs-default-bound 32768 4000 quadratic-sieve ;
