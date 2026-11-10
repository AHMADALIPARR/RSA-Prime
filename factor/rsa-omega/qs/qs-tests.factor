USING: accessors kernel math tools.test rsa-omega.qs ;
IN: rsa-omega.qs.tests

{ 2641 } [ 2 10007 sqrt-mod ] unit-test

:: qs-small-ok? ( -- ? )
    1000003 1000033 * :> n
    n qs factor>> :> g
    g [ n g rem 0 = ] [ f ] if ;

{ t } [ qs-small-ok? ] unit-test

:: qs-60bit-ok? ( -- ? )
    1000000007 1000000009 * :> n
    n qs :> r
    r factor>> :> g
    g [ n g rem 0 = ] [ f ] if
    r status>> "found" = and ;

{ t } [ qs-60bit-ok? ] unit-test
