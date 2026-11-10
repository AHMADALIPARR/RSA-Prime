! Copyright (C) 2026 RSA-CRYPTANALYSIS-OMEGA — synthetic fixtures only.
USING: kernel math math.functions math.order sequences
       assocs hashtables prettyprint
       math.primes random
       rsa-omega.arithmetic ;
IN: rsa-omega.fixtures

TUPLE: rsa-pub n e ;
C: <rsa-pub> rsa-pub

TUPLE: rsa-priv n e d p q ;
C: <rsa-priv> rsa-priv

: make-close-prime-modulus ( bits gap -- n p q )
    [ generate-prime-bits ] dip
    over + next-prime-from
    [ * ] 2keep ;

:: smooth-enough? ( k bound -- ? )
    ! All prime factors of k are <= bound (trial)
    k :> n!
    bound :> B
    n 1 = [ t ] [
        2 :> p!
        t :> ok!
        [ n 1 > ok and ] [
            n p mod zero? [
                p B > [ f ok! ] when
                n p /i n!
            ] [
                p 1 + p!
                p sq n > [
                    n 1 = not [
                        n B > [ f ok! ] when
                    ] when
                    1 n!
                ] when
            ] if
        ] while
        ok
    ] if ;

:: make-smooth-p1-prime ( smooth-bound bits-hint -- p )
    ! p = k*sm + 1 with k smooth (<= bound) so p-1 is bound-smooth.
    bits-hint drop
    1 :> sm!
    2 :> pr!
    [ pr smooth-bound <= ] [
        sm pr * sm!
        pr next-prime-from pr!
    ] while
    1 :> k!
    f :> found!
    [ found not k 50000 < and ] [
        k smooth-bound smooth-enough? [
            sm k * 1 + :> cand
            cand prime? [
                cand 3 > [ cand found! ] when
            ] when
        ] when
        k 1 + k!
    ] while
    found [ found ] [ "smooth-p1 prime not found" throw ] if ;

:: make-smooth-p1-modulus ( B bits-q -- n p q )
    B 48 make-smooth-p1-prime :> p
    bits-q generate-prime-bits :> q
    p q * p q ;

:: make-wiener-key ( bits -- n e d p q )
    bits 2/ generate-prime-bits :> p
    bits 2/ generate-prime-bits :> q
    p q = [ bits make-wiener-key ] [
        p q * :> n
        p 1 - q 1 - * :> phi
        n isqrt isqrt 3 /i 1 max :> dmax
        3 :> d!
        [ d phi gcd nip 1 = not d dmax < and ] [ d 2 + d! ] while
        d dmax >= [ bits 1 + make-wiener-key ] [
            d phi mod-inverse :> e
            n e d p q
        ] if
    ] if ;

:: make-common-modulus ( bits -- n e1 e2 c1 c2 m )
    bits 2/ generate-prime-bits :> p
    bits 2/ generate-prime-bits :> q
    p q * :> n
    p 1 - q 1 - * :> phi
    65537 :> e1!
    65539 :> e2!   ! next odd after Fermat prime; ensure coprime
    e1 phi gcd nip 1 = [
    ] [ 3 e1! ] if
    e1 phi gcd nip 1 = not [ bits make-common-modulus ] [
        e2 phi gcd nip 1 = not [ bits make-common-modulus ] [
            e1 e2 gcd nip 1 = not [ bits make-common-modulus ] [
                42 :> m
                m e1 n ^mod :> c1
                m e2 n ^mod :> c2
                n e1 e2 c1 c2 m
            ] if
        ] if
    ] if ;

:: make-hastad-triple ( bits -- c1 n1 c2 n2 c3 n3 m )
    7 :> m
    bits generate-prime-bits :> p1
    bits generate-prime-bits :> q1
    bits generate-prime-bits :> p2
    bits generate-prime-bits :> q2
    bits generate-prime-bits :> p3
    bits generate-prime-bits :> q3
    p1 q1 * :> n1
    p2 q2 * :> n2
    p3 q3 * :> n3
    m 3 n1 ^mod :> c1
    m 3 n2 ^mod :> c2
    m 3 n3 ^mod :> c3
    c1 n1 c2 n2 c3 n3 m ;

:: make-unbalanced ( bits-small bits-large -- n p q )
    bits-small generate-prime-bits :> p
    bits-large generate-prime-bits :> q
    p q * p q ;
