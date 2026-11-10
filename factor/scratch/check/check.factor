USING: accessors io kernel math math.primes namespaces prettyprint
       random random.mersenne-twister sequences
       rsa-omega.arithmetic rsa-omega.factoring ;
IN: scratch.check

: with-seed ( ..a seed quot: ( ..a -- ..b ) -- ..b )
    [ <mersenne-twister> ] dip with-random ;

:: gen-semiprime ( bits -- n p q )
    bits 2/ random-prime
    bits bits 2/ - random-prime
    [ * ] 2keep ;

:: run-trial ( -- )
    42 [ 32 gen-semiprime ] with-seed
    :> q :> p :> n
    n .
    ;
MAIN: run-trial
