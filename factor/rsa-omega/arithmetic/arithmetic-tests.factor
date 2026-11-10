! SPDX-License-Identifier: AGPL-3.0-only
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU Affero General Public License as published by
! the Free Software Foundation, version 3.
! See the LICENSE file.

USING: kernel math tools.test rsa-omega.arithmetic ;
IN: rsa-omega.arithmetic.tests

{ 1 -1 3 } [ 9 6 extended-gcd ] unit-test
{ 1 } [ 7 13 mod-inverse 7 * 13 mod ] unit-test
{ 10 } [ 100 isqrt ] unit-test
{ t } [ 144 perfect-square? ] unit-test
{ f } [ 145 perfect-square? ] unit-test
{ 24 } [ 2 10 1000 modexp ] unit-test
