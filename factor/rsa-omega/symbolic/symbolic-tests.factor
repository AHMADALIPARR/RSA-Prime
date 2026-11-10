USING: accessors kernel math sequences tools.test
       rsa-omega.symbolic ;
IN: rsa-omega.symbolic.tests

{ { 1 3 3 1 } } [ { 1 2 1 } { 1 1 } poly* ] unit-test
{ { 1 -1 1 } } [ { 1 0 0 1 } { 1 1 } poly-divmod drop ] unit-test

:: poly-gcd-ok? ( -- ? )
    { 1 0 -1 } { 1 -1 } poly-gcd
    dup { -1 1 } = swap { 1 -1 } = or ;

{ t } [ poly-gcd-ok? ] unit-test
{ t } [ 9 6 gcd-certificate gcd-cert-valid? ] unit-test
{ t } [ 7 13 inv-certificate inv-cert-valid? ] unit-test
{ { 1 0 } } [ { { 1 0 } { 0 1 } } lll first ] unit-test

:: copper-ok? ( -- ? )
    1000003 1000033 * :> N
    20 :> x0
    N x0 - N 200 copper-deg1
    [ root>> 20 = ] [ verified>> ] bi and ;

{ t } [ copper-ok? ] unit-test
{ { 4 6 0 6 4 } } [ { 1 2 3 } { 4 5 6 } 7 poly*-mod ] unit-test
