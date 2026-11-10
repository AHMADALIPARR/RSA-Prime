USING: accessors kernel math sequences tools.test
       rsa-omega.numtheory rsa-omega.arithmetic ;
IN: rsa-omega.numtheory.tests

{ 1 } [ 2 15 jacobi ] unit-test
{ -1 } [ 1001 9907 jacobi ] unit-test
{ 1 } [ 5 11 legendre ] unit-test
{ -1 } [ 3 7 legendre ] unit-test
{ 0 } [ 14 21 jacobi ] unit-test
{ 23 } [ { 2 3 2 } { 3 5 7 } crt drop ] unit-test
{ 105 } [ { 2 3 2 } { 3 5 7 } crt nip ] unit-test
{ 100 } [ 1000000 3 iroot ] unit-test
{ t } [ 64 perfect-power? ] unit-test
{ f } [ 1001 perfect-power? ] unit-test
{ 2 6 } [ 64 perfect-power ] unit-test
{ f } [ 561 miller-rabin? ] unit-test
{ t } [ 2 127 ^ 1 - miller-rabin? ] unit-test
{ f } [ 561 baillie-psw? ] unit-test
{ f } [ 3215031751 baillie-psw? ] unit-test
{ t } [ 2 89 ^ 1 - baillie-psw? ] unit-test
{ 780 } [ 61 53 carmichael-pq ] unit-test
{ t } [ 3233 17 2753 61 53 rsa-key-consistent? ] unit-test
{ f } [ 3233 17 2754 61 53 rsa-key-consistent? ] unit-test
