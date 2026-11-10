! SPDX-License-Identifier: AGPL-3.0-only
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU Affero General Public License as published by
! the Free Software Foundation, version 3.
! See the LICENSE file.

USING: byte-arrays continuations kernel math sequences tools.test
       rsa-omega.padding ;
IN: rsa-omega.padding.tests

{ B{ 72 73 } } [
    B{ 72 73 } 20 15 [ 1 ] B{ } replicate-as pkcs1-pad
    20 pkcs1-unpad
] unit-test

{ t } [
    B{ 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 72 73 }
    [ 20 pkcs1-unpad drop f ] [ 2drop t ] recover
] unit-test

{ t } [
    B{ 0 2 1 1 1 0 72 73 }
    [ 8 pkcs1-unpad drop f ] [ 2drop t ] recover
] unit-test

{ B{ 104 105 33 } } [
    B{ 104 105 33 } 128 32 [ 7 ] B{ } replicate-as oaep-encode
    128 oaep-decode
] unit-test

{ t } [
    ! Negative: corrupt Y byte (must be 0)
    B{ 104 105 33 } 128 32 [ 7 ] B{ } replicate-as oaep-encode
    0 1 pick set-nth
    [ 128 oaep-decode drop f ] [ 2drop t ] recover
] unit-test

{ t } [
    ! Negative: wrong block length
    B{ 1 2 3 }
    [ 128 oaep-decode drop f ] [ 2drop t ] recover
] unit-test
