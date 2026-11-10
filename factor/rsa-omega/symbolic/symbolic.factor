! Copyright (C) 2026 RSA-CRYPTANALYSIS-OMEGA (synthetic research only).
! Polynomial arithmetic, modular polynomial rings, n-dimensional LLL,
! Coppersmith/Howgrave-Graham small-root experiment, GCD/inverse certificates.
USING: accessors arrays combinators io kernel math math.functions
       math.order sequences vectors
       rsa-omega.arithmetic rsa-omega.numtheory ;
IN: rsa-omega.symbolic

! ---------- dense univariate polynomials over Z (coeffs low..high) ----------
:: poly-trim ( cs -- cs' )
    cs length :> n!
    [ n 0 > [ n 1 - cs nth 0 = ] [ f ] if ] [ n 1 - n! ] while
    n 0 = [ { 0 } ] [ cs n head ] if ;

:: poly+ ( a b -- c )
    a length b length max :> n
    n <iota> [| i |
        i a length < [ i a nth ] [ 0 ] if
        i b length < [ i b nth ] [ 0 ] if +
    ] map poly-trim ;

: poly-neg ( a -- -a ) [ neg ] map ;
: poly- ( a b -- c ) poly-neg poly+ ;
:: poly-scale ( a k -- c ) a [ k * ] map poly-trim ;

:: poly* ( a b -- c )
    a length b length + 1 - 0 <array> :> out
    a [| ai i |
        b [| bj j |
            i j + out [ ai bj * + ] change-nth
        ] each-index
    ] each-index
    out poly-trim ;

:: poly-divmod ( a b -- q r )
    ! Exact division over Z when leading coefficient of b divides all pivots
    ! (always true for monic b). Returns (q, r) with a = q*b + r, deg r < deg b.
    b last :> bl
    bl 0 = [ "poly-divmod: zero divisor" throw ] when
    a clone >array :> r!
    V{ } clone :> qcoeffs
    [ r length b length >= [ r last 0 = not ] [ f ] if ] [
        r last bl /i :> coef
        r length b length - :> shift
        ! ensure qcoeffs has index `shift`
        [ qcoeffs length shift <= ] [ 0 qcoeffs push ] while
        coef shift qcoeffs set-nth
        ! r := r - coef * b * x^shift
        b length <iota> [| j |
            shift j + :> idx
            idx r nth j b nth coef * - idx r set-nth
        ] each
        ! trim trailing zeros from r without going empty-illegal
        r length :> rl!
        [ rl 0 > [ rl 1 - r nth 0 = ] [ f ] if ] [ rl 1 - rl! ] while
        rl 0 = [ { 0 } ] [ r rl head >array ] if r!
    ] while
    ! qcoeffs are stored low-to-high already if we filled by shift index
    qcoeffs >array poly-trim :> qq
    qq r ;

: poly-mod ( a m -- r ) poly-divmod nip ;

:: poly-gcd ( a b -- g )
    a :> aa!
    b :> bb!
    [ bb { 0 } = not ] [
        aa bb poly-mod :> rr
        bb aa!
        rr bb!
    ] while
    aa last :> lc
    lc 0 = [ { 0 } ] [
        aa [ lc rem 0 = ] all?
        [ aa [ lc /i ] map ] [ aa ] if
    ] if ;

! ---------- modular polynomial rings Z/nZ[x] ----------
:: poly-mod-n ( a n -- a' ) a [ n rem ] map poly-trim ;
:: poly+-mod ( a b n -- c ) a b poly+ n poly-mod-n ;
:: poly*-mod ( a b n -- c ) a b poly* n poly-mod-n ;
:: poly-mod-mod ( a m n -- r ) a m poly-mod n poly-mod-n ;

! ---------- vectors / rationals ----------
: vec+ ( a b -- c ) [ + ] 2map ;
: vec- ( a b -- c ) [ - ] 2map ;
: vec*s ( a s -- c ) [ * ] curry map ;
: dot ( a b -- d ) [ * ] 2map sum ;

:: rat-simplify ( a/b -- p/q )
    a/b first2 :> ( a b )
    a b gcd nip :> g
    g 0 = [ 0 1 2array ] [
        a g /i :> aa
        b g /i :> bb
        bb 0 < [ aa neg bb neg 2array ] [ aa bb 2array ] if
    ] if ;

:: rat-mul ( x y -- z )
    x first2 :> ( a b )
    y first2 :> ( c d )
    a c * b d * 2array rat-simplify ;

:: rat-add ( x y -- z )
    x first2 :> ( a b )
    y first2 :> ( c d )
    a d * c b * + b d * 2array rat-simplify ;

:: rat-sub ( x y -- z )
    x first2 :> ( a b )
    y first2 :> ( c d )
    a d * c b * - b d * 2array rat-simplify ;

: rat-neg ( x -- y ) first2 [ neg ] dip 2array rat-simplify ;

:: rat-dot ( u v -- p/q )
    { 0 1 } u v [| ui vi | ui vi rat-mul rat-add ] 2each ;

:: rat-vec-sub ( u v -- w )
    u v [| ui vi | ui vi rat-sub ] 2map ;

:: rat-vec-scale ( u s -- w )
    u [ s rat-mul ] map ;

: int->rat-vec ( v -- rv ) [ 1 2array ] map ;

:: nearest-int ( a/b -- q )
    a/b first2 :> ( a b )
    a 0 < :> neg?
    a abs :> aa
    aa 2 * b + 2 b * /i :> q
    neg? [ q neg ] [ q ] if ;

! ---------- classical exact LLL, delta = 3/4 ----------
:: rat-div ( x y -- z )
    ! x/y for rationals {n d}
    x first2 :> ( a b )
    y first2 :> ( c d )
    a d * b c * 2array rat-simplify ;

:: rebuild-gs ( B mu Bs Bsnorm -- )
    B length :> n
    n <iota> [| i |
        i B nth int->rat-vec :> v!
        i <iota> [| j |
            v j Bs nth rat-dot j Bsnorm nth rat-div :> mij
            mij j i mu nth set-nth
            j Bs nth mij rat-vec-scale v swap rat-vec-sub v!
        ] each
        v i Bs set-nth
        v v rat-dot i Bsnorm set-nth
    ] each ;

:: lll ( B0 -- Bred )
    B0 [ clone ] map >array :> B
    B length :> n
    n <iota> [ drop n <iota> [ drop { 0 1 } clone ] map >array ] map >array :> mu
    n f <array> :> Bs
    n <iota> [ drop { 0 1 } clone ] map >array :> Bsnorm
    B mu Bs Bsnorm rebuild-gs
    1 :> k!
    0 :> steps!
    [ k n < steps 10000 < and ] [
        k 1 - :> j!
        [ j 0 >= ] [
            j k mu nth nth nearest-int :> qq
            qq 0 = [
            ] [
                k B nth j B nth qq vec*s vec- k B set-nth
                k mu nth :> row
                j <iota> [| t |
                    t row nth
                    j t mu nth nth qq 1 2array rat-mul
                    rat-sub t row set-nth
                ] each
                j row nth first2 :> ( a b )
                a qq b * - b 2array rat-simplify j row set-nth
            ] if
            j 1 - j!
        ] while
        k Bsnorm nth first2 :> ( nk dk )
        k 1 - Bsnorm nth first2 :> ( nm dm )
        k 1 - k mu nth nth first2 :> ( ma mb )
        nk dm * 4 * mb sq * :> lhs
        3 mb sq * 4 ma sq * - nm * dk * :> rhs
        steps 1 + steps!
        lhs rhs >= [
            k 1 + k!
        ] [
            k B nth k 1 - B nth
            k 1 - B set-nth k B set-nth
            k mu nth :> ri
            k 1 - mu nth :> rj
            k 1 - <iota> [| t |
                t ri nth t rj nth
                t rj set-nth t ri set-nth
            ] each
            B mu Bs Bsnorm rebuild-gs
            k 1 - 1 max k!
        ] if
    ] while
    B ;

! ---------- Coppersmith / Howgrave-Graham small-root experiment ----------
! Univariate: find small root of f(x) = 0 (mod N) with |x0| < N^{1/d}.
! Lattice of dimension h = d*m constructed from g_{i,j}(x) = x^j N^{m-i} f(x)^i.
TUPLE: copper-result root verified status lattice-dim ;

:: monicize ( f N -- f' )
    f last N mod-inverse f [ N * rem ] with map ;

:: copper-shift-poly ( f i j N m -- g )
    ! g(x) = x^j * N^{m-i} * f(x)^i
    { 1 } :> fp!
    i [
        fp f poly* fp!
    ] times
    m i - :> e
    e 0 = [ 1 ] [ N e ^ ] if :> Nm
    fp [ Nm * ] map poly-trim :> g0
    j 0 = [ g0 ] [
        ! x^j * g0 = shift coeffs up by j
        j 0 <array> g0 append poly-trim
    ] if ;

:: howgrave-graham ( poly N Xbound m -- result )
    ! Howgrave-Graham univariate small-root experiment.
    ! Builds the lattice from g_{i,j}(x) = x^j * N^{m-i} * poly(x)^i
    ! for i = 0..m, j = 0..d-1; vector length = d*(m+1).
    ! Integer root search on the shortest LLL vector after x -> Xbound*x.
    poly length 1 - :> d
    d m 1 + * :> dim
    V{ } clone :> rows
    0 :> ii!
    [ ii m <= ] [
        0 :> jj!
        [ jj d < ] [
            poly ii jj N m copper-shift-poly :> gg
            dim 0 <array> :> row
            0 :> kk!
            [ kk gg length < kk dim < and ] [
                kk gg nth Xbound kk ^ * kk row set-nth
                kk 1 + kk!
            ] while
            row rows push
            jj 1 + jj!
        ] while
        ii 1 + ii!
    ] while
    rows >array lll :> reduced
    ! Try several short vectors, not just the first
    f :> found!
    f :> ok!
    reduced [| short |
        found [
            V{ } clone :> Href
            0 :> kk!
            [ kk short length < ] [
                kk short nth Xbound kk ^ /i Href push
                kk 1 + kk!
            ] while
            Href >array poly-trim :> H
            Xbound neg :> cand!
            [ cand Xbound <= found not and ] [
                0 :> acc!
                H [| c | acc cand * c + acc! ] each
                acc 0 = [
                    0 :> acc2!
                    poly [| c | acc2 cand * c + acc2! ] each
                    acc2 N rem 0 = [
                        cand found!
                        t ok!
                    ] when
                ] when
                cand 1 + cand!
            ] while
        ] unless
    ] each
    found [ found ok "found" ] [ f f "not-found" ] if
    dim copper-result boa ;


:: copper-deg1 ( a N Xbound -- result )
    ! Linear Coppersmith/Howgrave: f(x)=x+a ≡ 0 (mod N), |root|<Xbound.
    ! Lattice:
    !   [ N       0 ]
    !   [ a  Xbound ]
    N 0 2array
    a Xbound 2array
    2array lll :> reduced
    f :> found!
    f :> ok!
    reduced [| vec |
        found [
            vec first2 :> ( v0 v1 )
            v1 0 = [
            ] [
                ! candidates near -v0*Xbound/v1
                v0 neg Xbound * :> num
                num v1 /i :> q1
                num v1 / :> qf
                qf 0 < [ qf neg 0.5 + >integer neg ] [ qf 0.5 + >integer ] if :> q2
                V{ } clone :> cands
                q1 cands push
                q2 cands push
                q1 1 + cands push
                q1 1 - cands push
                q2 1 + cands push
                q2 1 - cands push
                0 cands push
                cands [| c |
                    found [
                        c abs Xbound <= [
                            c a + N rem 0 = [ c found! t ok! ] when
                        ] when
                    ] unless
                ] each
            ] if
        ] unless
    ] each
    found [ found ok "found" ] [ f f "not-found" ] if
    2 copper-result boa ;

! ---------- GCD / modular-inverse certificates ----------
TUPLE: gcd-cert a b s t g ;
:: gcd-certificate ( a b -- cert )
    a b extended-gcd :> ( s t g )
    a b s t g gcd-cert boa ;

: gcd-cert-valid? ( cert -- ? )
    dup [ [ a>> ] [ s>> ] bi * ] [ [ b>> ] [ t>> ] bi * ] bi +
    [ g>> ] dip = ;

TUPLE: inv-cert a m inv ;
:: inv-certificate ( a m -- cert )
    a m mod-inverse :> i
    a m i inv-cert boa ;

: inv-cert-valid? ( cert -- ? )
    dup [ a>> ] [ inv>> ] bi * swap m>> rem 1 = ;
