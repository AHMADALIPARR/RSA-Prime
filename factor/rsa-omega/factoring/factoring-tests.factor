! SPDX-License-Identifier: AGPL-3.0-only
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU Affero General Public License as published by
! the Free Software Foundation, version 3.
! See the LICENSE file.

USING: accessors kernel math tools.test rsa-omega.factoring ;
IN: rsa-omega.factoring.tests

{ 3 } [ 15 10 trial-division factor>> ] unit-test
{ 3 } [ 15 10 wheel-factor factor>> ] unit-test
{ 101 } [ 101 103 * 1000 fermat factor>> ] unit-test

:: rho-ok? ( -- ? )
    8051 1 2000000 rho-brent factor>> :> g
    g [ 8051 g rem 0 = ] [ f ] if ;

{ t } [ rho-ok? ] unit-test

:: p1-ok? ( -- ? )
    30031 10007 * 100 pollard-p-1 factor>> :> g
    g [ 30031 10007 * g rem 0 = ] [ f ] if ;

{ t } [ p1-ok? ] unit-test
