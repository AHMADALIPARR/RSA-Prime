! SPDX-License-Identifier: AGPL-3.0-only
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU Affero General Public License as published by
! the Free Software Foundation, version 3.
! See the LICENSE file.

! Copyright (C) 2026 RSA-CRYPTANALYSIS-OMEGA (synthetic research only).
! RSA weakness research on LOCAL synthetic fixtures only.
USING: accessors arrays combinators kernel math math.functions
       math.order sequences rsa-omega.arithmetic rsa-omega.numtheory ;
IN: rsa-omega.weakness

! ---------- Batch GCD via product / remainder tree ----------
:: product-tree ( leaves -- levels )
    V{ } clone :> levels
    leaves >array levels push
    [ levels last length 1 > ] [
        levels last :> cur
        cur length 1 + 2/ <iota> [| i |
            i 2 * :> a
            a 1 + :> b
            b cur length < [ a cur nth b cur nth * ] [ a cur nth ] if
        ] map levels push
    ] while
    levels ;

:: batch-gcd ( moduli -- gcds )
    ! Bernstein: g_i = gcd(N_i, (P mod N_i^2) / N_i), P = prod N_j
    moduli product-tree :> levels
    levels last :> rems!
    levels length 2 - :> lvl!
    [ lvl 0 >= ] [
        lvl levels nth :> nodes
        rems :> prem
        nodes length <iota> [| i |
            i 2/ prem nth i nodes nth sq rem
        ] map rems!
        lvl 1 - lvl!
    ] while
    moduli length <iota> [| i |
        i moduli nth :> ni
        i rems nth ni /i ni gcd nip
    ] map ;

:: shared-prime-attack ( moduli -- factors )
    moduli batch-gcd [| g i |
        g 1 > g i moduli nth < and [ g ] [ f ] if
    ] map-index ;

! ---------- Wiener (small d) ----------
:: cf-expansion ( num den -- qs )
    V{ } clone :> qs
    num :> a!
    den :> b!
    [ b 0 = not ] [
        a b /i qs push
        a b rem :> r
        b a!
        r b!
    ] while
    qs >array ;

:: convergents ( qs -- pairs )
    V{ } clone :> out
    0 :> h2!
    1 :> h1!
    1 :> k2!
    0 :> k1!
    qs [| a |
        a h1 * h2 + :> h
        a k1 * k2 + :> k
        h k 2array out push
        h1 h2! h h1! k1 k2! k k1!
    ] each
    out >array ;

:: wiener-attack ( e n -- d/f )
    e n cf-expansion convergents :> cs
    f :> found!
    cs [| pair |
        found [
            pair first2 :> ( k d )
            d 0 = k 0 = or [
                e d * 1 - :> ed1
                ed1 k rem 0 = [
                    ed1 k /i :> phi
                    n phi - 1 + :> s
                    s sq n 4 * - :> disc
                    disc 0 >= [ disc perfect-square? [ d found! ] when ] when
                ] when
            ] unless
        ] unless
    ] each
    found ;

! ---------- Low exponent: textbook e=3 without padding ----------
:: textbook-cube-root-attack ( c n -- m/f )
    ! if m^3 < n then c = m^3 over the integers
    c 3 iroot :> r
    r 3 ^ c = [ r ] [ f ] if ;

:: hastad-e3 ( residues moduli -- m/f )
    residues moduli crt drop :> x
    x 3 iroot :> r
    r 3 ^ x = [ r ] [ f ] if ;

! ---------- Common modulus ----------
:: pow-signed ( c exp n -- r )
    exp 0 >= [ c exp n ^mod ] [ c n mod-inverse exp neg n ^mod ] if ;

:: common-modulus-attack ( c1 c2 e1 e2 n -- m/f )
    e1 e2 extended-gcd :> ( s t g )
    g 1 = [ c1 s n pow-signed c2 t n pow-signed * n rem ] [ f ] if ;

! ---------- Close primes (Fermat) ----------
:: close-prime-attack ( n max-steps -- pq/f )
    n isqrt :> a0
    a0 sq n < [ a0 1 + ] [ a0 ] if :> a!
    a sq n - :> b2!
    0 :> it!
    f :> res!
    [ res not it max-steps < and ] [
        it 1 + it!
        b2 perfect-square? [
            b2 isqrt :> b
            a b - a b + 2array res!
        ] [ b2 2 a * 1 + + b2! a 1 + a! ] if
    ] while
    res ;

! ---------- Structural validators: repeated / malformed moduli ----------
: repeated-prime? ( n -- ? ) perfect-power drop >boolean ;

:: malformed-modulus ( n -- reason/f )
    {
        { [ n 2 < ] [ "n < 2" ] }
        { [ n even? ] [ "n is even" ] }
        { [ n prime*? ] [ "n is prime" ] }
        { [ n repeated-prime? ] [ "n is a perfect power (repeated prime)" ] }
        [ f ]
    } cond ;

! ---------- Incorrect CRT parameters ----------
:: bad-crt-params ( p q dp dq qinv e -- reason/f )
    {
        { [ q qinv * p rem 1 = not ] [ "qinv*q != 1 (mod p)" ] }
        { [ e dp * p 1 - rem 1 = not ] [ "e*dp != 1 (mod p-1)" ] }
        { [ e dq * q 1 - rem 1 = not ] [ "e*dq != 1 (mod q-1)" ] }
        [ f ]
    } cond ;

:: crt-sign ( m p q dp dq qinv -- s )
    m dp p ^mod :> s1
    m dq q ^mod :> s2
    s1 s2 - qinv * p rem :> h
    s2 h q * + ;

:: crt-fault-attack ( m s-faulty e n -- factor/f )
    ! Boneh-DeMillo-Lipton: faulty CRT signature leaks gcd(s^e - m, n)
    s-faulty e n ^mod m - n gcd nip :> g
    g 1 > g n < and [ g ] [ f ] if ;

! ---------- Weak PRNG key generation (synthetic) ----------
! A 64-bit LCG seeded from only SEED-BITS bits: the whole key space can be
! enumerated. Used ONLY to generate local fixtures and demonstrate recovery.
:: lcg-step ( s -- s' )
    s 6364136223846793005 * 1442695040888963407 + 64 2^ rem ;

:: lcg-bits ( state bits -- state' n )
    state :> s!
    0 :> acc!
    0 :> have!
    [ have bits < ] [
        s lcg-step s!
        acc 32 shift s -32 shift + acc!
        have 32 + have!
    ] while
    s acc have bits - neg shift ;

:: lcg-prime ( state bits -- state' p )
    state :> s!
    0 :> p!
    [ p 0 = ] [
        s bits lcg-bits :> ( s2 cand )
        s2 s!
        cand 1 bits 1 - shift bitor 1 bitor :> c
        c prime*? [ c p! ] when
    ] while
    s p ;

:: weak-prng-key ( seed bits -- n p q )
    seed bits 2/ lcg-prime :> ( s1 p )
    s1 bits 2/ lcg-prime :> ( s2 q )
    p q * p q ;

:: weak-prng-attack ( n seed-bits bits -- p/f seeds-tried )
    f :> found!
    0 :> tried!
    0 :> s!
    [ found not s seed-bits 2^ < and ] [
        tried 1 + tried!
        s bits 2/ lcg-prime nip :> p
        n p rem 0 = [ p found! ] when
        s 1 + s!
    ] while
    found tried ;
