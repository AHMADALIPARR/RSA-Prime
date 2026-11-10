USING: kernel math tools.test rsa-omega.arithmetic ;
IN: rsa-omega.arithmetic.tests

{ 1 -1 3 } [ 9 6 extended-gcd ] unit-test
{ 1 } [ 7 13 mod-inverse 7 * 13 mod ] unit-test
{ 10 } [ 100 isqrt ] unit-test
{ t } [ 144 perfect-square? ] unit-test
{ f } [ 145 perfect-square? ] unit-test
{ 24 } [ 2 10 1000 modexp ] unit-test
