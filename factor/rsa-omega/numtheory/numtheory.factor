! Copyright (C) 2026 RSA-CRYPTANALYSIS-OMEGA (synthetic research only).
! Number-theory foundations: Jacobi/Legendre, CRT, totient, Carmichael,
! integer roots, perfect powers, Miller-Rabin, strong Lucas, Baillie-PSW,
! RSA key consistency.
USING: accessors arrays combinators kernel math math.functions math.order
       ranges sequences rsa-omega.arithmetic ;
IN: rsa-omega.numtheory

! NOTE: Factor `mod` keeps the sign of the dividend; `rem` is always >= 0.

! ---------- Jacobi / Legendre ----------
:: jacobi ( a n -- j )
    n 0 <= n even? or [ "jacobi: n must be odd and positive" throw ] when
    a n rem :> aa!
    n :> nn!
    1 :> result!
    [ aa 0 = not ] [
        [ aa even? ] [
            aa 2/ aa!
            nn 8 rem :> r
            r 3 = r 5 = or [ result neg result! ] when
        ] while
        aa :> tmp
        nn aa!
        tmp nn!
        aa 4 rem 3 = nn 4 rem 3 = and [ result neg result! ] when
        aa nn rem aa!
    ] while
    nn 1 = [ result ] [ 0 ] if ;

:: legendre ( a p -- l )
    ! Euler criterion, independent from jacobi (used to cross-check it).
    a p rem 0 = [ 0 ] [
        a p 1 - 2/ p ^mod :> x
        x 1 = [ 1 ] [ x p 1 - = [ -1 ] [ "legendre: p is not an odd prime" throw ] if ] if
    ] if ;

! ---------- CRT ----------
:: crt2 ( r1 m1 r2 m2 -- r m )
    m1 m2 extended-gcd :> ( s t g )
    g 1 = [ "crt: moduli not coprime" throw ] unless
    m1 m2 * :> m
    r1 t * m2 * r2 s * m1 * + m rem m ;

:: crt ( residues moduli -- r m )
    residues first moduli first :> ( r! m! )
    residues rest moduli rest [| r2 m2 |
        r m r2 m2 crt2 m! r!
    ] 2each
    r m ;

! ---------- totient / Carmichael ----------
: lcm* ( a b -- l ) [ * abs ] [ gcd nip ] 2bi /i ;

:: totient-from-factors ( pairs -- phi )
    ! pairs: { { p k } ... }
    1 pairs [ first2 :> ( p k ) p 1 - p k 1 - ^ * * ] each ;

:: lambda-prime-power ( p k -- l )
    p 2 = k 3 >= and [ 2 k 2 - ^ ] [ p 1 - p k 1 - ^ * ] if ;

: carmichael-from-factors ( pairs -- l )
    1 [ first2 lambda-prime-power lcm* ] reduce ;

: carmichael-pq ( p q -- l ) [ 1 - ] bi@ lcm* ;

! ---------- integer k-th root and perfect powers ----------
:: iroot ( n k -- r )
    ! floor(n^(1/k)) by Newton iteration from an upper bound
    n 2 < [ n ] [
        n log2 k /i 1 + 2^ :> x!
        f :> done!
        [ done not ] [
            k 1 - x * n x k 1 - ^ /i + k /i :> y
            y x >= [ t done! ] [ y x! ] if
        ] while
        x
    ] if ;

:: perfect-power ( n -- base/f exp/f )
    ! Largest exponent first, so 64 -> 2^6.
    n 4 < [ f f ] [
        f :> rb!
        f :> re!
        n log2 :> maxe
        maxe 2 [a..b] [| e |
            rb [
                n e iroot :> b
                b e ^ n = [ b rb! e re! ] when
            ] unless
        ] each
        rb re
    ] if ;

: perfect-power? ( n -- ? ) perfect-power drop >boolean ;

! ---------- Miller-Rabin (own implementation) ----------
:: mr-witness-composite? ( a n -- ? )
    ! true => a proves n composite
    n 1 - :> d!
    0 :> s!
    [ d even? ] [ d 2/ d! s 1 + s! ] while
    a d n ^mod :> x!
    x 1 = x n 1 - = or [ f ] [
        t :> composite!
        1 :> i!
        [ i s < composite and ] [
            x sq n rem x!
            x n 1 - = [ f composite! ] when
            i 1 + i!
        ] while
        composite
    ] if ;

CONSTANT: small-primes { 2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 }

:: miller-rabin-bases? ( n bases -- ? )
    {
        { [ n 2 < ] [ f ] }
        { [ n small-primes member? ] [ t ] }
        { [ small-primes [ n swap rem 0 = ] any? ] [ f ] }
        [ bases [ n rem 2 < not ] filter [ n mr-witness-composite? ] none? ]
    } cond ;

: miller-rabin? ( n -- ? )
    ! First 13 prime bases: deterministic below 3.3e24; probabilistic beyond.
    { 2 3 5 7 11 13 17 19 23 29 31 37 41 } miller-rabin-bases? ;

! ---------- strong Lucas PRP (Selfridge method A) ----------
:: selfridge-D ( n -- D/f )
    ! f if some D shares a factor with n (n composite)
    5 :> D!
    0 :> j!
    f :> done!
    f :> result!
    [ done not ] [
        D n jacobi j!
        {
            { [ j -1 = ] [ D result! t done! ] }
            { [ j 0 = D abs n = not and ] [ f result! t done! ] }
            [ D 0 > [ D neg 2 - ] [ D neg 2 + ] if D! ]
        } cond
    ] while
    result ;

:: half-mod ( x n -- y )
    x n rem :> v
    v odd? [ v n + ] [ v ] if 2/ ;

:: strong-lucas-prp? ( n -- ? )
    {
        { [ n 2 < ] [ f ] }
        { [ n 2 = ] [ t ] }
        { [ n even? ] [ f ] }
        { [ n perfect-square? ] [ f ] }
        [
            n selfridge-D :> D
            D [
                1 :> P
                1 D - 4 /i :> Q
                n 1 + :> d!
                0 :> s!
                [ d even? ] [ d 2/ d! s 1 + s! ] while
                1 :> U!
                P :> V!
                Q n rem :> Qk!
                d log2 1 - :> i!
                [ i 0 >= ] [
                    U V * n rem U!
                    V sq 2 Qk * - n rem V!
                    Qk sq n rem Qk!
                    d i bit? [
                        P U * V + :> ut
                        D U * P V * + :> vt
                        ut n half-mod U!
                        vt n half-mod V!
                        Qk Q * n rem Qk!
                    ] when
                    i 1 - i!
                ] while
                U 0 = V 0 = or [ t ] [
                    f :> hit!
                    1 :> r!
                    [ r s < hit not and ] [
                        V sq 2 Qk * - n rem V!
                        Qk sq n rem Qk!
                        V 0 = [ t hit! ] when
                        r 1 + r!
                    ] while
                    hit
                ] if
            ] [ f ] if
        ]
    } cond ;

: baillie-psw? ( n -- ? )
    ! MR base 2 + strong Lucas (Selfridge A). No known counterexample.
    {
        { [ dup 2 < ] [ drop f ] }
        { [ dup small-primes member? ] [ drop t ] }
        { [ dup small-primes [ dupd rem 0 = ] any? nip ] [ drop f ] }
        [ dup { 2 } miller-rabin-bases? [ strong-lucas-prp? ] [ drop f ] if ]
    } cond ;

: prime*? ( n -- ? ) baillie-psw? ;

! ---------- RSA key consistency (spec section 9 invariants) ----------
TUPLE: key-check product-ok p-prime q-prime p-ne-q exponent-ok roundtrip-ok valid ;

:: check-rsa-key ( n e d p q -- key-check )
    p q * n = :> a
    p prime*? :> b
    q prime*? :> c
    p q = not :> c2
    p 1 - q 1 - lcm* :> lam
    e d * lam rem 1 = :> dd
    ! round trip on a fixed test message (and on m=2)
    42 n < [ 42 e n ^mod d n ^mod 42 = ] [ f ] if
    2 e n ^mod d n ^mod 2 = and :> rt
    a b c c2 dd rt
    a b and c and c2 and dd and rt and
    key-check boa ;

: rsa-key-consistent? ( n e d p q -- ? ) check-rsa-key valid>> ;
