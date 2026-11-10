USING: kernel math prettyprint io math.primes.factors sequences
       rsa-omega.factoring rsa-omega.fixtures ;
IN: rsa-omega.smoke
:: smoke-main ( -- )
    30 40 make-smooth-p1-modulus :> ( n p q )
    "max " write p 1 - factors maximum . flush
    n 200000 pollard-p1-factor :> g
    g [ n g mod zero? . ] [ "fail" print ] if
    ;
MAIN: smoke-main
