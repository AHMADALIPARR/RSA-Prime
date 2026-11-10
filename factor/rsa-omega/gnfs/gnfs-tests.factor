! SPDX-License-Identifier: AGPL-3.0-only
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU Affero General Public License as published by
! the Free Software Foundation, version 3.
! See the LICENSE file.

USING: accessors kernel math tools.test rsa-omega.gnfs ;
IN: rsa-omega.gnfs.tests

:: gnfs-partial-ok? ( -- ? )
    1000003 1000033 * 3 100 500 gnfs-setup
    [ poly-check>> ] [ status>> "partial: setup-only (no sieving/linalg/sqrt)" = ] bi and ;

{ t } [ gnfs-partial-ok? ] unit-test
