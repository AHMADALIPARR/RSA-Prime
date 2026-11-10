USING: accessors kernel math tools.test rsa-omega.gnfs ;
IN: rsa-omega.gnfs.tests

:: gnfs-partial-ok? ( -- ? )
    1000003 1000033 * 3 100 500 gnfs-setup
    [ poly-check>> ] [ status>> "partial: setup-only (no sieving/linalg/sqrt)" = ] bi and ;

{ t } [ gnfs-partial-ok? ] unit-test
