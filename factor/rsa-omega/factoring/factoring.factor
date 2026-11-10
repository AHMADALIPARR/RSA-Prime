! SPDX-License-Identifier: AGPL-3.0-only
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU Affero General Public License as published by
! the Free Software Foundation, version 3.
! See the LICENSE file.

! Copyright (C) 2026 RSA-CRYPTANALYSIS-OMEGA (synthetic research only).
! Instrumented factorization engines. Every engine returns a fact-result
! with factor (or f), iteration count, and a status string.
USING: accessors arrays combinators kernel math math.functions
       math.order math.primes ranges sequences
       rsa-omega.arithmetic ;
IN: rsa-omega.factoring

TUPLE: fact-result algo factor iterations status ;

:: <found-or-not> ( algo n g iters budget-hit? -- result )
    g [ g 1 > g n < and ] [ f ] if [
        algo g iters "found" fact-result boa
    ] [
        algo f iters budget-hit? [ "budget-exhausted" ] [ "not-found" ] if
        fact-result boa
    ] if ;

! ---------- trial division ----------
:: trial-division ( n bound -- result )
    2 :> p!
    f :> found!
    0 :> it!
    [ p bound <= found not and p sq n <= and ] [
        it 1 + it!
        n p rem 0 = [ p found! ] [ p 2 = [ 3 ] [ p 2 + ] if p! ] if
    ] while
    "trial-division" n found it found not p bound > and <found-or-not> ;

! ---------- wheel factorization (mod-30 wheel) ----------
CONSTANT: wheel30 { 4 2 4 2 4 6 2 6 }

:: wheel-factor ( n bound -- result )
    0 :> it!
    f :> found!
    { 2 3 5 } [| p | found [ it 1 + it! n p rem 0 = [ p found! ] when ] unless ] each
    7 :> p!
    0 :> w!
    [ found not p bound <= and p sq n <= and ] [
        it 1 + it!
        n p rem 0 = [ p found! ] [
            p w wheel30 nth + p!
            w 1 + 8 rem w!
        ] if
    ] while
    "wheel-30" n found it found not p bound > and <found-or-not> ;

! ---------- Fermat ----------
:: fermat ( n max-steps -- result )
    n isqrt :> a!
    a sq n < [ a 1 + a! ] when
    a sq n - :> b2!
    0 :> it!
    f :> found!
    [ found not it max-steps < and ] [
        it 1 + it!
        b2 perfect-square? [ a b2 isqrt - found! ] [
            b2 2 a * 1 + + b2!
            a 1 + a!
        ] if
    ] while
    "fermat" n found it found not <found-or-not> ;

! ---------- Pollard rho with Brent's cycle detection (own) ----------
:: rho-brent ( n c max-iter -- result )
    2 :> y!
    1 :> r!
    1 :> q!
    1 :> g!
    0 :> it!
    128 :> m
    y :> x!
    y :> ys!
    [ g 1 = it max-iter < and ] [
        y x!
        r [ y sq c + n rem y! it 1 + it! ] times
        0 :> k!
        [ k r < g 1 = and ] [
            y ys!
            m r k - min [
                y sq c + n rem y!
                x y - abs q * n rem q!
                it 1 + it!
            ] times
            q n gcd nip g!
            k m + k!
        ] while
        r 2 * r!
    ] while
    g n = [
        ! backtrack one step at a time
        1 g!
        0 :> bt!
        [ g 1 = bt 1000000 < and ] [
            ys sq c + n rem ys!
            x ys - abs n gcd nip g!
            bt 1 + bt!
            it 1 + it!
        ] while
    ] when
    "pollard-rho-brent" n g it it max-iter >= <found-or-not> ;

! ---------- Pollard p-1 (stage 1) ----------
:: prime-power-below ( p B -- pk )
    p :> pk!
    [ pk p * B <= ] [ pk p * pk! ] while
    pk ;

:: pollard-p-1 ( n B -- result )
    0 :> it!
    f :> found!
    { 2 3 5 7 11 } [| a0 |
        found [
            a0 :> a!
            B primes-upto [| p |
                a p B prime-power-below n ^mod a!
                it 1 + it!
            ] each
            a 1 - n gcd nip :> g
            g 1 > g n < and [ g found! ] when
        ] unless
    ] each
    "pollard-p-1" n found it f <found-or-not> ;

! ---------- Williams p+1 (stage 1) ----------
:: lucas-v ( A m n -- V )
    ! V_m(A) mod n by the Lucas ladder: V_{2k}=V_k^2-2, V_{2k+1}=V_k V_{k+1}-A
    m 0 = [ 2 n rem ] [
    A :> x!
    A sq 2 - n rem :> y!
    m log2 1 - :> i!
    [ i 0 >= ] [
        m i bit? [
            x y * A - n rem x!
            y sq 2 - n rem y!
        ] [
            x y * A - n rem y!
            x sq 2 - n rem x!
        ] if
        i 1 - i!
    ] while
    x ] if ;

:: williams-p+1 ( n B -- result )
    0 :> it!
    f :> found!
    { 3 5 7 9 11 13 17 19 } [| a0 |
        found [
            a0 :> A!
            B primes-upto [| p |
                A p B prime-power-below n lucas-v A!
                it 1 + it!
            ] each
            A 2 - n gcd nip :> g
            g 1 > g n < and [ g found! ] when
        ] unless
    ] each
    "williams-p+1" n found it f <found-or-not> ;

! ---------- Lenstra ECM, Montgomery curves, Suyama parametrization ----------
:: xdbl ( P a24 n -- P2 )
    P first2 :> ( X Z )
    X Z + sq n rem :> t1
    X Z - sq n rem :> t2
    t1 t2 - n rem :> t3
    t1 t2 * n rem
    t3 t2 a24 t3 * + * n rem 2array ;

:: xadd ( P Q D n -- R )
    P first2 :> ( XP ZP )
    Q first2 :> ( XQ ZQ )
    D first2 :> ( XD ZD )
    XP ZP - XQ ZQ + * n rem :> u
    XP ZP + XQ ZQ - * n rem :> v
    ZD u v + sq * n rem
    XD u v - sq * n rem 2array ;

:: ladder ( k P a24 n -- kP )
    P :> R0!
    P a24 n xdbl :> R1!
    k log2 1 - :> i!
    [ i 0 >= ] [
        k i bit? [
            R1 R0 P n xadd R0!
            R1 a24 n xdbl R1!
        ] [
            R0 R1 P n xadd R1!
            R0 a24 n xdbl R0!
        ] if
        i 1 - i!
    ] while
    R0 ;

TUPLE: ecm-curve a24 point factor ;

:: suyama-curve ( sigma n -- curve )
    ! returns curve; if setup hits a non-invertible element, factor slot is set
    sigma sq 5 - n rem :> u
    4 sigma * n rem :> v
    u 3 ^ n rem :> x0
    v 3 ^ n rem :> z0
    v u - 3 ^ 3 u * v + * n rem :> num
    16 u 3 ^ * v * n rem :> den
    den n gcd nip :> g
    g 1 = [
        num den n mod-inverse * n rem
        x0 z0 2array f ecm-curve boa
    ] [
        f f g 1 > g n < and [ g ] [ f ] if ecm-curve boa
    ] if ;

:: ecm ( n B1 B2 curves seed -- result )
    0 :> it!
    f :> found!
    0 :> used!
    B1 primes-upto :> stage1
    B2 primes-upto [ B1 > ] filter :> stage2
    curves <iota> [| ci |
        found [
            used 1 + used!
            seed ci + 6 + n suyama-curve :> cv
            cv factor>> [ cv factor>> found! ] [
                cv a24>> :> a24
                cv point>> :> Q!
                stage1 [| p |
                    p B1 prime-power-below Q a24 n ladder Q!
                    it 1 + it!
                ] each
                Q second n gcd nip :> g!
                g 1 > g n < and [ g found! ] [
                    g 1 = [
                        ! stage 2 (prime-by-prime continuation)
                        1 :> acc!
                        stage2 [| q |
                            q Q a24 n ladder second acc * n rem acc!
                            it 1 + it!
                        ] each
                        acc n gcd nip g!
                        g 1 > g n < and [ g found! ] when
                    ] when
                ] if
            ] if
        ] unless
    ] each
    "ecm" n found it f <found-or-not> ;

! convenience: factor or f
: result-factor ( result -- f/factor ) factor>> ;
