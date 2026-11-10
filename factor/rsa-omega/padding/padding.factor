! Copyright (C) 2026 RSA-CRYPTANALYSIS-OMEGA (synthetic research only).
! PKCS#1 v1.5 (type 2) and OAEP (MGF1/SHA-256) encode/decode, with the
! structural validation that the negative tests exercise.
USING: accessors arrays byte-arrays checksums checksums.sha
       combinators kernel math math.bitwise math.order
       sequences ;
IN: rsa-omega.padding

ERROR: padding-error reason ;

: sha256 ( bytes -- digest ) sha-256 checksum-bytes ;
: hlen ( -- n ) 32 ;

! ---------- integer <-> big-endian octet string ----------
:: i2osp ( m len -- bytes )
    len <byte-array> :> out
    m :> x!
    len <iota> [| i |
        x 255 bitand len 1 - i - out set-nth
        x -8 shift x!
    ] each
    x 0 = [ "i2osp: integer too large" padding-error ] unless
    out ;

: os2ip ( bytes -- m ) 0 [ [ 8 shift ] dip + ] reduce ;

! ---------- PKCS#1 v1.5 type 2 ----------
:: pkcs1-pad ( msg k random-bytes -- bytes )
    ! random-bytes: caller-supplied nonzero padding of length k - msg len - 3
    msg length :> mlen
    k mlen - 3 - :> pslen
    pslen 8 < [ "pkcs1: message too long" padding-error ] when
    random-bytes length pslen = [ "pkcs1: wrong PS length" padding-error ] unless
    random-bytes [ 0 = ] any? [ "pkcs1: PS has zero byte" padding-error ] when
    B{ 0 2 } random-bytes B{ 0 } msg 4array concat >byte-array ;

:: pkcs1-unpad ( bytes k -- msg )
    bytes length k = [ "pkcs1: wrong block length" padding-error ] unless
    bytes first 0 = [ "pkcs1: byte0 != 0" padding-error ] unless
    bytes second 2 = [ "pkcs1: byte1 != 2" padding-error ] unless
    bytes 2 tail-slice [ 0 = ] find drop :> sep
    sep [ "pkcs1: no 0x00 separator" padding-error ] unless
    sep 8 < [ "pkcs1: PS shorter than 8" padding-error ] when
    bytes 2 sep + 1 + tail >byte-array ;

! ---------- MGF1 with SHA-256 ----------
:: mgf1 ( seed len -- mask )
    V{ } clone :> acc
    0 :> counter!
    [ acc length len < ] [
        seed counter 4 i2osp append sha256 acc push-all
        counter 1 + counter!
    ] while
    acc len head >byte-array ;

: xor-bytes ( a b -- c ) [ bitxor ] 2map >byte-array ;

! ---------- OAEP (label = "") ----------
: empty-label-hash ( -- digest ) B{ } sha256 ;

:: oaep-encode ( msg k seed -- bytes )
    ! seed: hlen random bytes (caller-supplied for determinism in tests)
    msg length :> mlen
    k 2 hlen * - 2 - :> maxm
    mlen maxm > [ "oaep: message too long" padding-error ] when
    seed length hlen = [ "oaep: seed must be hlen" padding-error ] unless
    k 1 - hlen - :> dblen
    empty-label-hash :> lhash
    dblen mlen - 1 - hlen - :> pslen
    lhash pslen <byte-array> B{ 1 } msg 4array concat >byte-array :> db
    seed dblen mgf1 :> dbmask
    db dbmask xor-bytes :> masked-db
    masked-db hlen mgf1 :> seedmask
    seed seedmask xor-bytes :> masked-seed
    B{ 0 } masked-seed masked-db 3array concat >byte-array ;

:: oaep-decode ( bytes k -- msg )
    bytes length k = [ "oaep: wrong length" padding-error ] unless
    k 2 hlen * 2 + < [ "oaep: k too small" padding-error ] when
    bytes first 0 = [ "oaep: Y byte nonzero" padding-error ] unless
    k 1 - hlen - :> dblen
    1 1 hlen + bytes <slice> >byte-array :> masked-seed
    bytes 1 hlen + tail >byte-array :> masked-db
    masked-db hlen mgf1 :> seedmask
    masked-seed seedmask xor-bytes :> seed
    seed dblen mgf1 :> dbmask
    masked-db dbmask xor-bytes :> db
    empty-label-hash :> lhash
    db hlen head >byte-array lhash = [ "oaep: lHash mismatch" padding-error ] unless
    db hlen tail-slice [ 1 = ] find drop :> one-pos
    one-pos [ "oaep: no 0x01 marker" padding-error ] unless
    db hlen tail-slice one-pos head [ 0 = ] all? [ "oaep: nonzero in PS" padding-error ] unless
    db hlen one-pos + 1 + tail >byte-array ;
