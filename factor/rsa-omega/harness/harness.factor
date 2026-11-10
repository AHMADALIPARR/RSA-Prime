! Copyright (C) 2026 RSA-CRYPTANALYSIS-OMEGA harness.
USING: accessors arrays assocs byte-arrays calendar combinators
       continuations formatting io io.encodings.utf8 io.files json
       kernel math math.functions math.parser math.primes namespaces
       prettyprint random random.mersenne-twister sequences system
       tools.memory vectors
       rsa-omega.arithmetic rsa-omega.numtheory rsa-omega.factoring
       rsa-omega.qs rsa-omega.gnfs rsa-omega.weakness
       rsa-omega.padding rsa-omega.symbolic ;
IN: rsa-omega.harness

SYMBOL: results-acc
SYMBOL: seed-sym

: ms-of ( nanos -- ms ) 1000000 /f ;
: mem-now ( -- bytes ) data-room tenured>> occupied>> ;

:: push-row ( name bits outcome detail ms iters mem timeout? -- )
    H{ } clone
    name "name" pick set-at
    bits "bits" pick set-at
    outcome "outcome" pick set-at
    detail "detail" pick set-at
    ms "ms" pick set-at
    iters "iterations" pick set-at
    mem "mem_bytes" pick set-at
    timeout? "timeout" pick set-at
    results-acc get push ;

: bitlen ( n -- b ) log2 1 + ;

:: gen-semiprime ( bits -- n p q )
    bits 2/ random-prime
    bits bits 2/ - random-prime
    [ * ] 2keep ;

:: gen-close ( bits gap -- n p q )
    bits generate-prime-bits :> p
    p gap + next-prime-from :> q
    p q * p q ;

:: gen-smooth-p1 ( B qbits -- n p q )
    B primes-upto product :> sm
    1 :> k!
    [ sm k * 1 + prime*? not ] [ k 1 + k! ] while
    sm k * 1 + :> p
    qbits generate-prime-bits :> q
    p q * p q ;

:: check9 ( n e d p q -- ok? )
    n e d p q check-rsa-key valid>> ;

:: record-factor ( name n r ms mem timeout? -- )
    r factor>> :> g
    r iterations>> :> it
    g [
        n g rem 0 = [
            name n bitlen "factored" g number>string ms it mem timeout? push-row
        ] [
            name n bitlen "failed" "bad-factor" ms it mem timeout? push-row
        ] if
    ] [
        name n bitlen r status>> "no-factor" ms it mem timeout? push-row
    ] if ;

:: run-trial ( -- )
    42 <mersenne-twister> [ 32 gen-semiprime ] with-random :> ( n p q )
    mem-now :> m0 nano-count :> t0
    n p bitlen 2^ trial-division :> r
    nano-count t0 - ms-of :> ms mem-now m0 - :> mem
    "trial-division" n r ms mem f record-factor ;

:: run-wheel ( -- )
    43 <mersenne-twister> [ 40 gen-semiprime ] with-random :> ( n p q )
    mem-now :> m0 nano-count :> t0
    n p bitlen 2^ wheel-factor :> r
    nano-count t0 - ms-of :> ms mem-now m0 - :> mem
    "wheel-30" n r ms mem f record-factor ;

:: run-fermat ( -- )
    44 <mersenne-twister> [ 64 500 gen-close ] with-random :> ( n p q )
    mem-now :> m0 nano-count :> t0
    n 100000 fermat :> r
    nano-count t0 - ms-of :> ms mem-now m0 - :> mem
    "fermat" n r ms mem f record-factor ;

:: run-rho ( -- )
    45 <mersenne-twister> [ 64 gen-semiprime ] with-random :> ( n p q )
    mem-now :> m0 nano-count :> t0
    n 1 5000000 rho-brent :> r
    nano-count t0 - ms-of :> ms mem-now m0 - :> mem
    "pollard-rho-brent" n r ms mem f record-factor ;

:: run-p1 ( -- )
    46 <mersenne-twister> [ 40 40 gen-smooth-p1 ] with-random :> ( n p q )
    mem-now :> m0 nano-count :> t0
    n 500 pollard-p-1 :> r
    nano-count t0 - ms-of :> ms mem-now m0 - :> mem
    "pollard-p-1" n r ms mem f record-factor ;

:: run-williams ( -- )
    30 primes-upto product :> sm
    1 :> k!
    [ sm k * 1 - prime*? not ] [ k 1 + k! ] while
    sm k * 1 - :> p
    47 <mersenne-twister> [ 16 generate-prime-bits ] with-random :> q
    p q * :> n
    mem-now :> m0 nano-count :> t0
    n 200 williams-p+1 :> r
    nano-count t0 - ms-of :> ms mem-now m0 - :> mem
    "williams-p+1" n r ms mem f record-factor ;

:: run-ecm ( -- )
    48 <mersenne-twister> [ 28 generate-prime-bits 64 generate-prime-bits * ] with-random :> n
    mem-now :> m0 nano-count :> t0
    n 2000 100000 40 1 ecm :> r
    nano-count t0 - ms-of :> ms mem-now m0 - :> mem
    "ecm" n r ms mem f record-factor ;

:: run-qs ( bits -- )
    bits :> b
    50 b + <mersenne-twister> [ b gen-semiprime ] with-random :> ( n p q )
    mem-now :> m0 nano-count :> t0
    n qs :> r
    nano-count t0 - ms-of :> ms mem-now m0 - :> mem
    r factor>> :> g
    r status>> "budget-exhausted" = :> to
    g [
        n g rem 0 = [
            "quadratic-sieve" n bitlen "factored" g number>string
            ms r deps-tried>> mem to push-row
        ] [
            "quadratic-sieve" n bitlen "failed" "bad-factor"
            ms r deps-tried>> mem to push-row
        ] if
    ] [
        "quadratic-sieve" n bitlen r status>> "no-factor"
        ms r deps-tried>> mem to push-row
    ] if ;

:: run-gnfs-partial ( -- )
    51 <mersenne-twister> [ 64 gen-semiprime ] with-random :> ( n p q )
    mem-now :> m0 nano-count :> t0
    n 3 100 500 gnfs-setup :> s
    nano-count t0 - ms-of :> ms mem-now m0 - :> mem
    s poly-check>> [
        "gnfs-partial" n bitlen "setup-ok" s status>>
    ] [
        "gnfs-partial" n bitlen "setup-bad" s status>>
    ] if
    ms s algebraic-fb-size>> mem f push-row ;

:: run-wiener ( -- )
    52 <mersenne-twister> [ 256 gen-semiprime ] with-random :> ( n p q )
    p 1 - q 1 - * :> phi
    1000003 :> d!
    [ d phi gcd nip 1 = not ] [ d 2 + d! ] while
    d phi mod-inverse :> e
    mem-now :> m0 nano-count :> t0
    e n wiener-attack :> drec
    nano-count t0 - ms-of :> ms mem-now m0 - :> mem
    drec d = [
        "wiener" n bitlen "recovered-d" d number>string
    ] [
        "wiener" n bitlen "failed" "no"
    ] if
    ms 0 mem f push-row ;

:: run-batch-gcd ( -- )
    53 <mersenne-twister> [ 64 gen-semiprime ] with-random :> ( n1 p1 q1 )
    54 <mersenne-twister> [ 64 generate-prime-bits ] with-random :> q2
    p1 q2 * :> n2
    55 <mersenne-twister> [ 64 gen-semiprime ] with-random :> ( n3 p3 q3 )
    n1 n2 n3 3array :> mods
    mem-now :> m0 nano-count :> t0
    mods shared-prime-attack :> facs
    nano-count t0 - ms-of :> ms mem-now m0 - :> mem
    facs first p1 = [
        "batch-gcd" 64 "shared-prime" p1 number>string
    ] [
        "batch-gcd" 64 "failed" "no"
    ] if
    ms 0 mem f push-row ;

:: run-copper ( -- )
    56 <mersenne-twister> [ 40 gen-semiprime ] with-random :> ( n p q )
    42 :> x0
    n x0 - :> a
    mem-now :> m0 nano-count :> t0
    a n 200 copper-deg1 :> r
    nano-count t0 - ms-of :> ms mem-now m0 - :> mem
    r verified>> [
        "copper-deg1" n bitlen "recovered-root" r root>> number>string
    ] [
        "copper-deg1" n bitlen r status>> "no"
    ] if
    ms 0 mem f push-row ;

:: run-padding ( -- )
    mem-now :> m0 nano-count :> t0
    B{ 1 2 3 4 } 32 25 [ 7 ] B{ } replicate-as pkcs1-pad
    32 pkcs1-unpad B{ 1 2 3 4 } = :> pkcs-ok
    57 <mersenne-twister> [ 1024 gen-semiprime ] with-random :> ( n p q )
    65537 :> e
    e p 1 - q 1 - * mod-inverse :> d
    n bitlen 7 + 8 /i :> k
    B{ 9 8 7 } k 32 [ 3 ] B{ } replicate-as oaep-encode :> em
    em os2ip e n ^mod d n ^mod k i2osp k oaep-decode B{ 9 8 7 } = :> oaep-ok
    em clone 0 1 pick set-nth
    [ k oaep-decode drop f ] [ 2drop t ] recover :> rejected
    nano-count t0 - ms-of :> ms mem-now m0 - :> mem
    pkcs-ok oaep-ok and rejected and [
        "padding-pkcs-oaep" k 8 * "ok" "roundtrip+negative"
    ] [
        "padding-pkcs-oaep" k 8 * "failed" "see-detail"
    ] if
    ms 0 mem f push-row ;

:: run-invariants-suite ( -- )
    { 32 64 128 256 512 1024 2048 } [| bits |
        bits 70 + <mersenne-twister> [ bits gen-semiprime ] with-random :> ( n p q )
        65537 :> e
        e p 1 - q 1 - * mod-inverse :> d
        n e d p q check9 :> ok
        ok [
            "key-invariants" bits "pass" "p*q,prime,ed,roundtrip"
        ] [
            "key-invariants" bits "fail" "invariant-broken"
        ] if
        0.0 0 0
        bits 1024 >= push-row
    ] each ;

:: run-skip-factor-2048 ( -- )
    "rsa-2048-factor" 2048 "skipped"
    "synthetic 2048-bit n not factored (secure size)"
    0.0 0 0 t push-row ;

: run-all ( -- seq )
    V{ } clone results-acc set
    run-trial
    run-wheel
    run-fermat
    run-rho
    run-p1
    run-williams
    run-ecm
    60 run-qs
    80 run-qs
    100 run-qs
    run-gnfs-partial
    run-wiener
    run-batch-gcd
    run-copper
    run-padding
    run-invariants-suite
    run-skip-factor-2048
    results-acc get ;

:: write-results ( path -- )
    run-all :> rs
    rs >json path utf8 set-file-contents
    rs results-acc set ;

: harness-main ( -- )
    "/workspace/rsa-omega/results/results.json" write-results
    "Wrote results.json (" write results-acc get length pprint " rows)" print
    results-acc get [
        dup "name" of write " " write
        dup "bits" of pprint " " write
        dup "outcome" of write " " write
        "ms" of .
    ] each ;

MAIN: harness-main
