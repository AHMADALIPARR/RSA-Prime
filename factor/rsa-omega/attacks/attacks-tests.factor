USING: kernel math tools.test
       rsa-omega.attacks rsa-omega.fixtures ;
IN: rsa-omega.attacks.tests


:: (common-mod-ok?) ( -- ? )
    96 make-common-modulus :> ( n e1 e2 c1 c2 m )
    c1 c2 e1 e2 n common-modulus-attack m = ;

:: (hastad-ok?) ( -- ? )
    24 make-hastad-triple :> ( c1 n1 c2 n2 c3 n3 m )
    c1 n1 c2 n2 c3 n3 hastad-e3-crt m = ;

:: (wiener-ok?) ( -- ? )
    128 make-wiener-key :> ( n e d p q )
    e n wiener-attack d = ;

{ t } [ (common-mod-ok?) ] unit-test
{ t } [ (hastad-ok?) ] unit-test
{ t } [ (wiener-ok?) ] unit-test
