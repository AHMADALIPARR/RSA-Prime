! RSA-OMEGA research-document conformance checks.
!
! Every claim below is a concrete numeric statement taken from
! research/RSA-OMEGA-RESEARCH.md. For each claim we record:
!   doc    - the value printed in the research document
!   engine - the value computed here with the rsa-omega engine
!            (rsa-omega.arithmetic / numtheory / factoring / symbolic)
!            or, for the matrix and floating-point sections, with exact
!            rationals or IEEE-754 doubles in plain Factor
!   ok?    - whether the two agree (exactly, or within the precision the
!            document itself printed)
! The research document is never modified; disagreements are reported.
USING: accessors arrays assocs io io.encodings.utf8 io.files
       json kernel math math.functions math.matrices math.order
       math.parser math.vectors namespaces prettyprint ranges sequences
       sequences.generalizations
       rsa-omega.arithmetic rsa-omega.numtheory rsa-omega.factoring
       rsa-omega.symbolic ;
IN: rsa-omega.research

SYMBOL: claims

TUPLE: claim id section statement doc engine ok? ;

:: record ( id section statement doc engine ok? -- )
    id section statement doc engine ok? >boolean claim boa
    claims get push ;

:: exact ( id section statement doc engine -- )
    id section statement doc engine doc engine = record ;

:: approx ( id section statement doc engine tol -- )
    id section statement doc engine doc engine - abs tol <= record ;

:: truncated ( id section statement doc engine step -- )
    ! the document value is the engine value truncated (not rounded)
    ! to the printed precision: doc <= engine < doc + step
    id section statement doc engine
    doc engine <= engine doc step + < and record ;

:: approx-matrix ( id section statement doc engine tol -- )
    doc engine [ v- [ abs ] map supremum ] 2map supremum :> err
    id section statement doc engine err tol <= record ;

! ------------------------------------------------------------------
! Section I: the N = 3233 worked example
! ------------------------------------------------------------------
:: check-toy-key ( -- )
    61 :> p
    53 :> q
    p q * :> n
    "I.01" "I" "N = 61 * 53" 3233 n exact
    "I.02" "I" "61 and 53 are prime (Baillie-PSW)" { t t }
        p baillie-psw? q baillie-psw? 2array exact
    "I.03" "I" "phi(N) = 60 * 52" 3120
        { { 61 1 } { 53 1 } } totient-from-factors exact
    "I.04" "I" "lambda(N) = lcm(60, 52)" 780 p q carmichael-pq exact
    "I.05" "I" "gcd(17, 780) = 1" 1 17 780 gcd nip exact
    "I.06" "I" "780 = 45(17) + 15" { 45 15 } 780 17 /mod 2array exact
    "I.07" "I" "17 = 1(15) + 2" { 1 2 } 17 15 /mod 2array exact
    "I.08" "I" "15 = 7(2) + 1" { 7 1 } 15 2 /mod 2array exact
    "I.09" "I" "1 = 8(780) - 367(17)" 1 8 780 * 367 17 * - exact
    "I.10" "I" "extended-gcd(780, 17) coefficients = (8, -367, 1)"
        { 8 -367 1 } 780 17 extended-gcd 3array exact
    "I.11" "I" "d = -367 mod 780 = 413" 413 17 780 mod-inverse exact
    "I.12" "I" "17 * 413 = 7021" 7021 17 413 * exact
    "I.13" "I" "7021 = 9(780) + 1" { 9 1 } 7021 780 /mod 2array exact
    "I.14" "I" "inverse certificate 17 * 413 = 1 (mod 780) validates" t
        17 780 inv-certificate inv-cert-valid? exact
    "I.15" "I" "c = 65^17 mod 3233 = 2790" 2790 65 17 n modexp exact
    "I.16" "I" "m' = 2790^413 mod 3233 = 65" 65 2790 413 n modexp exact
    "I.17" "I" "engine rsa-key-consistent? (3233, 17, 413, 61, 53)" t
        n 17 413 p q rsa-key-consistent? exact ;

! ------------------------------------------------------------------
! Results(N) table and the per-n worked derivations
! ------------------------------------------------------------------
CONSTANT: doc-table {
    { 15 3 5 8 4 3 3 }
    { 21 3 7 12 6 5 5 }
    { 77 7 11 60 30 7 13 }
    { 143 11 13 120 60 7 43 }
    { 323 17 19 288 144 5 29 }
    { 899 29 31 840 420 11 191 }
    { 1763 41 43 1680 840 11 611 }
    { 10403 101 103 10200 5100 7 3643 }
}

:: roundtrip-failures ( n e d -- count )
    ! number of messages m in [0, n) for which (m^e)^d mod n != m
    n [0..b) [| m | m e n modexp d n modexp m = not ] count ;

:: check-table-row ( row -- )
    row 7 firstn :> ( n p q phi lam e d )
    n number>string "n=" prepend :> tag
    "T." tag append :> id
    id ".pq" append "Results" tag " : p * q = n" append n p q * exact
    id ".prime" append "Results" tag " : p, q prime (Miller-Rabin)" append
        { t t } p miller-rabin? q miller-rabin? 2array exact
    id ".trial" append "Results" tag " : trial division up to isqrt(n) finds p" append
        p n n isqrt trial-division factor>> exact
    id ".phi" append "Results" tag " : phi(n) = (p-1)(q-1)" append
        phi { { p 1 } { q 1 } } totient-from-factors exact
    id ".lambda" append "Results" tag " : lambda(n) = lcm(p-1, q-1)" append
        lam p q carmichael-pq exact
    id ".e" append "Results" tag " : 1 < e < lambda and gcd(e, lambda) = 1" append
        t e 1 > e lam < and e lam gcd nip 1 = and exact
    id ".d" append "Results" tag " : d = e^-1 mod lambda" append
        d e lam mod-inverse exact
    id ".ed" append "Results" tag " : e*d = 1 (mod lambda)" append
        1 e d * lam rem exact
    id ".gcdcert" append "Results" tag " : gcd certificate for (e, lambda) validates" append
        t e lam gcd-certificate gcd-cert-valid? exact
    id ".roundtrip" append "Results" tag " : (m^e)^d = m mod n for every m in [0, n)" append
        0 n e d roundtrip-failures exact ;

:: check-table ( -- )
    doc-table [ check-table-row ] each ;

:: check-euclid-traces ( -- )
    ! n = 899
    "E.899.1" "I (n=899)" "30^2 - 1 = 899" 899 30 sq 1 - exact
    "E.899.2" "I (n=899)" "Fermat engine factors 899 -> 29" 29
        899 100 fermat factor>> exact
    "E.899.3" "I (n=899)" "420 = 38(11) + 2" { 38 2 } 420 11 /mod 2array exact
    "E.899.4" "I (n=899)" "11 = 5(2) + 1" { 5 1 } 11 2 /mod 2array exact
    "E.899.5" "I (n=899)" "1 = 191(11) - 5(420)" 1 191 11 * 5 420 * - exact
    "E.899.6" "I (n=899)" "11 * 191 = 2101 = 5(420) + 1" { 2101 5 1 }
        11 191 * dup 420 /mod 3array exact
    ! n = 1763
    "E.1763.1" "I (n=1763)" "42^2 - 1 = 1763" 1763 42 sq 1 - exact
    "E.1763.2" "I (n=1763)" "Fermat engine factors 1763 -> 41" 41
        1763 100 fermat factor>> exact
    "E.1763.3" "I (n=1763)" "840 = 76(11) + 4" { 76 4 } 840 11 /mod 2array exact
    "E.1763.4" "I (n=1763)" "11 = 2(4) + 3" { 2 3 } 11 4 /mod 2array exact
    "E.1763.5" "I (n=1763)" "4 = 1(3) + 1" { 1 1 } 4 3 /mod 2array exact
    "E.1763.6" "I (n=1763)" "1 = 3(840) - 229(11)" 1 3 840 * 229 11 * - exact
    "E.1763.7" "I (n=1763)" "-229 = 611 (mod 840)" 611 -229 840 rem exact
    "E.1763.8" "I (n=1763)" "11 * 611 = 6721 = 8(840) + 1" { 6721 8 1 }
        11 611 * dup 840 /mod 3array exact
    ! n = 10403
    "E.10403.1" "I (n=10403)" "sqrt(10403) ~ 101.99 (as a 2 d.p. truncation)" 101.99
        10403 sqrt 0.01 truncated
    "E.10403.2" "I (n=10403)" "5100 = 728(7) + 4" { 728 4 } 5100 7 /mod 2array exact
    "E.10403.3" "I (n=10403)" "7 = 1(4) + 3" { 1 3 } 7 4 /mod 2array exact
    "E.10403.4" "I (n=10403)" "4 = 1(3) + 1" { 1 1 } 4 3 /mod 2array exact
    "E.10403.5" "I (n=10403)" "1 = 2(5100) - 1457(7)" 1 2 5100 * 1457 7 * - exact
    "E.10403.6" "I (n=10403)" "-1457 = 3643 (mod 5100)" 3643 -1457 5100 rem exact
    "E.10403.7" "I (n=10403)" "7 * 3643 = 25501 = 5(5100) + 1" { 25501 5 1 }
        7 3643 * dup 5100 /mod 3array exact ;

! ------------------------------------------------------------------
! n = 65537^2 (the document's p = q counterexample)
! ------------------------------------------------------------------
:: check-p-squared ( -- )
    65537 :> p
    p sq :> n
    { { 65537 2 } } totient-from-factors :> phi
    { { 65537 2 } } carmichael-from-factors :> lam
    "P.01" "65537^2" "65537^2 = 4295098369" 4295098369 n exact
    "P.02" "65537^2" "65537 is prime (Baillie-PSW)" t p baillie-psw? exact
    "P.03" "65537^2" "65537 = 2^16 + 1 (Fermat prime F4)" 65537 2 16 ^ 1 + exact
    "P.04" "65537^2" "trial division finds p = 65537" 65537
        n n isqrt trial-division factor>> exact
    "P.05" "65537^2" "engine perfect-power detects 65537^2" { 65537 2 }
        n perfect-power 2array exact
    "P.06" "65537^2" "table/proof: phi(p^2) = p(p-1) = 4294967296"
        4294967296 phi exact
    "P.07" "65537^2" "table/proof: lambda(p^2) = 4294967296" 4294967296 lam exact
    "P.08" "65537^2" "counterexample section: corrected phi(p^2) = p(p-1) = 4294901760"
        4294901760 phi exact
    "P.09" "65537^2" "65537 * 65536 = 4294967296 (product as printed in table/proof)" 4294967296
        65537 65536 * exact
    "P.10" "65537^2" "counterexample section: (p-1)(q-1) = 65536^2 = 4294836225"
        4294836225 65536 sq exact
    "P.10b" "65537^2" "4294967296 printed as phi/lambda equals (p-1)^2 = 65536^2" 4294967296
        p 1 - sq exact
    "P.10c" "65537^2" "4294901760 equals 65536 * 65535 (not p(p-1))" 4294901760
        65536 65535 * exact
    "P.10d" "65537^2" "4294836225 equals 65535^2 (not 65536^2)" 4294836225
        65535 sq exact
    "P.11" "65537^2" "gcd(3, 4294967296) = 1" 1 3 4294967296 gcd nip exact
    "P.12" "65537^2" "4294967296 = 1431655765(3) + 1" { 1431655765 1 }
        4294967296 3 /mod 2array exact
    "P.13" "65537^2" "3 * 2863311531 = 8589934593 = 2(4294967296) + 1"
        { 8589934593 2 1 } 3 2863311531 * dup 4294967296 /mod 3array exact
    "P.14" "65537^2" "d = 2863311531 satisfies 3d = 1 (mod lambda(p^2))" 1
        3 2863311531 * lam rem exact
    "P.15" "65537^2" "d = 3^-1 mod lambda(p^2): doc prints 2863311531, engine computes the true inverse"
        2863311531 3 lam mod-inverse exact
    "P.16" "65537^2" "doc key (e=3, d=2863311531) decrypts m=42 on n=65537^2" 42
        42 3 n modexp 2863311531 n modexp exact
    "P.16b" "65537^2" "engine inverse d = 3^-1 mod lambda(p^2) decrypts m=42" 42
        42 3 n modexp 3 lam mod-inverse n modexp exact
    "P.16c" "65537^2" "engine inverse: 3 * d = 1 (mod lambda(p^2))" 1
        3 3 lam mod-inverse * lam rem exact
    "P.17" "65537^2" "engine check-rsa-key rejects p = q (p-ne-q slot)" f
        n 3 3 lam mod-inverse p p check-rsa-key p-ne-q>> exact ;

! ------------------------------------------------------------------
! Newton-Schulz inversion section (exact rational arithmetic)
! ------------------------------------------------------------------
CONSTANT: ns-A { { 4 1 } { 2 3 } }

: identity2 ( -- I ) 2 <identity-matrix> ;

:: ns-step ( T -- T' )
    T 2 identity2 n*m ns-A T mdot m- mdot ;

:: ns-residual ( T -- E )
    identity2 ns-A T mdot m- ;

:: ns-iterates ( -- seq )
    1/20 ns-A flip n*m :> T0
    T0 1array :> acc!
    5 [ acc dup last ns-step suffix acc! ] times
    acc ;

: mfloat ( M -- M' ) [ [ >float ] map ] map ;

: frob ( M -- x ) [ [ sq ] map-sum ] map-sum sqrt ;

:: check-newton-schulz ( -- )
    ns-A first2 [ first2 ] bi@ :> ( a b c d )
    a d * b c * - :> det
    det recip d b neg 2array c neg a 2array 2array n*m :> Ainv
    ns-iterates :> Ts
    Ts [ ns-residual ] map :> Es
    "N.01" "Newton-Schulz" "det(A) = 10" 10 det exact
    "N.02" "Newton-Schulz" "A^-1 = [[0.3, -0.1], [-0.2, 0.4]]"
        { { 3/10 -1/10 } { -1/5 2/5 } } Ainv exact
    "N.03" "Newton-Schulz" "A * A^-1 = I" identity2 ns-A Ainv mdot exact
    "N.04" "Newton-Schulz" "T0 = 0.05 A^T = [[0.2, 0.1], [0.05, 0.15]]"
        { { 1/5 1/10 } { 1/20 3/20 } } Ts first exact
    "N.05" "Newton-Schulz" "E0 = I - A T0 = [[0.15, -0.55], [-0.55, 0.35]]"
        { { 3/20 -11/20 } { -11/20 7/20 } } Es first exact
    "N.06" "Newton-Schulz" "||E0||_inf = 0.9" 9/10 Es first matrix-l-infinity-norm exact
    "N.07" "Newton-Schulz" "E_{n+1} = E_n^2 for n = 0..4 (exact rationals)" t
        Es 5 head Es rest [ [ dup mdot ] dip = ] 2all? exact
    "N.08" "Newton-Schulz" "(0.9)^32 ~ 0.0343" 0.0343 0.9 32 ^ 0.00005 approx
    "N.09" "Newton-Schulz" "||E5||_inf <= (0.9)^32" t
        Es last matrix-l-infinity-norm 9/10 32 ^ <= exact
    "N.10" "Newton-Schulz" "T5 ~ [[0.297, -0.093], [-0.194, 0.386]] (3 d.p.)"
        { { 0.297 -0.093 } { -0.194 0.386 } } Ts last mfloat 0.0005 approx-matrix
    "N.11" "Newton-Schulz" "T5 = [[0.29980453, -0.09976578], [-0.19968372, 0.39962103]] (8 d.p.)"
        { { 0.29980453 -0.09976578 } { -0.19968372 0.39962103 } } Ts last mfloat
        0.000000005 approx-matrix
    { 1.118034 0.661438 0.428478 0.183511 0.033676 0.001134 } :> table
    table Es zip [| pair i |
        pair first2 :> ( doc E )
        "N.12." i number>string append "Newton-Schulz"
        "iteration table row " i number>string append
        " vs Frobenius ||E_n||_F" append
        doc E frob 0.0000005 approx
    ] each-index ;

! ------------------------------------------------------------------
! Floating point / softmax / attention-gradient section (IEEE doubles)
! ------------------------------------------------------------------
: f32 ( x -- y ) float>bits bits>float ;

:: softmax-row ( s -- p )
    s supremum :> mx
    s [ mx - e^ ] map :> ex
    ex sum :> z
    ex [ z / ] map ;

: softmax-rows ( S -- P ) [ softmax-row ] map ;

:: attn-S ( Q K -- S )
    Q K flip mdot Q first length sqrt recip m*n ;

:: attn-forward ( Q K V -- A )
    Q K attn-S softmax-rows V mdot ;

:: attn-loss ( Q K V G -- L )
    Q K V attn-forward G m* [ sum ] map-sum ;

:: softmax-vjp ( p v -- g )
    ! nabla_s L = p (.) (v - <p, v> 1)
    p v v* sum :> dd
    p v [ dd - ] map v* ;

:: attn-grads ( Q K V G -- dQ dK dV )
    Q first length sqrt recip :> c
    Q K attn-S softmax-rows :> P
    P flip G mdot :> dV
    G V flip mdot :> dP
    P dP [ softmax-vjp ] 2map :> dS
    dS K mdot c m*n :> dQ
    dS flip Q mdot c m*n :> dK
    dQ dK dV ;

:: perturb ( M i j h -- M' )
    M [ clone ] map :> M2
    i M2 nth :> row
    j row nth h + j row set-nth
    M2 ;

:: fd-grad ( M quot: ( M -- L ) h -- G )
    M [| row i |
        row [| x j |
            M i j h perturb quot call( M -- L )
            M i j h neg perturb quot call( M -- L ) -
            2 h * /
        ] map-index
    ] map-index ;

: max-abs-diff ( M1 M2 -- x ) [ v- [ abs ] map supremum ] 2map supremum ;

CONSTANT: fd-Q { { 0.1 -0.3 } { 0.7 0.2 } { -0.5 0.4 } }
CONSTANT: fd-K { { 0.3 0.8 } { -0.2 0.1 } { 0.6 -0.7 } }
CONSTANT: fd-V { { 1.0 -0.5 } { 0.25 0.75 } { -1.5 0.5 } }
CONSTANT: fd-G { { 0.2 -0.1 } { 0.4 0.3 } { -0.6 0.9 } }

: fd-h ( -- h ) 2 -52 ^ 1/3 ^ ;

:: attention-fd-delta ( -- delta )
    fd-Q fd-K fd-V fd-G attn-grads :> ( dQ dK dV )
    fd-Q [ fd-K fd-V fd-G attn-loss ] fd-h fd-grad :> nQ
    fd-K [ fd-Q swap fd-V fd-G attn-loss ] fd-h fd-grad :> nK
    fd-V [ fd-Q fd-K rot fd-G attn-loss ] fd-h fd-grad :> nV
    dQ nQ max-abs-diff dK nK max-abs-diff dV nV max-abs-diff max max ;

:: matmul-fd-delta ( -- delta )
    fd-Q fd-K flip :> ( A B )
    { { 0.2 -0.4 0.1 } { 0.5 0.3 -0.2 } { -0.1 0.6 0.4 } } :> G
    G B flip mdot :> dA
    A flip G mdot :> dB
    A [ B mdot G m* [ sum ] map-sum ] fd-h fd-grad :> nA
    B [ A swap mdot G m* [ sum ] map-sum ] fd-h fd-grad :> nB
    dA nA max-abs-diff dB nB max-abs-diff max ;

:: jacobian-vjp-delta ( -- delta )
    { 0.5 -1.25 2.0 0.0 } softmax-row :> p
    { 0.3 -0.7 1.1 0.25 } :> v
    p length [0..b) [| i |
        p length [0..b) [| j |
            i j = [ i p nth 1 i p nth - * ] [ i p nth j p nth * neg ] if
        ] map
    ] map :> J
    J flip v mdotv :> jv
    p v softmax-vjp :> vjp
    J J flip max-abs-diff
    jv vjp v- [ abs ] map supremum max ;

:: check-floating-point ( -- )
    2 -23 ^ :> eps32
    2 -52 ^ :> eps64
    "F.01" "FP bounds" "FP32 machine epsilon ~ 1.19e-7" 1.19e-7 eps32 0.005e-7 approx
    "F.02" "FP bounds" "FP32 bound eps^(2/3) ~ 2.4e-5" 2.4e-5 eps32 2/3 ^ 0.05e-5 approx
    "F.03" "FP bounds" "FP64 machine epsilon ~ 2.22e-16" 2.22e-16 eps64 0.005e-16 approx
    "F.04" "FP bounds" "FP64 bound eps^(2/3) ~ 3.6e-11 (as a 2 s.f. truncation)" 3.6e-11
        eps64 2/3 ^ 0.1e-11 truncated
    "F.05" "Softmax" "softmax(<10, -10>) second entry ~ 2e-9" 2e-9
        { 10.0 -10.0 } softmax-row second 0.5e-9 approx
    "F.06" "Softmax" "softmax(<100, -100>) second entry flushes to 0.0 in FP32" 0.0
        { 100.0 -100.0 } softmax-row second f32 exact
    "F.07" "Softmax" "softmax(<100, -100>) second entry is NOT 0.0 in FP64" t
        { 100.0 -100.0 } softmax-row second 0.0 > exact
    "F.08" "IEEE 754" "0.0 * +inf = NaN" t 0.0 1/0. * fp-nan? exact
    "F.09" "IEEE 754" "1.0 + NaN = NaN" t 1.0 0/0. + fp-nan? exact
    "F.10" "IEEE 754" "D = <1.0, 0.0> . <1.0, inf> is NaN" t
        { 1.0 0.0 } { 1.0 1/0. } v* sum fp-nan? exact
    "F.11" "Softmax" "J_s symmetric and J_s^T v = p (.) (v - <p,v>) (max |diff| <= 1e-15)"
        1e-15 jacobian-vjp-delta dup 1e-15 <= record
    attention-fd-delta :> dattn
    "F.12" "Attention" "analytic dQ, dK, dV vs central differences (h = eps^(1/3)), max |diff| <= 1e-6"
        1e-6 dattn dup 1e-6 <= record
    "F.13" "Attention" "same check against the document's FP64 bound eps ~ 3.6e-11"
        3.6e-11 dattn dup 3.6e-11 <= record
    "F.14" "MatMul" "C = AB: dA = G B^T, dB = A^T G vs central differences, max |diff| <= 1e-6"
        1e-6 matmul-fd-delta dup 1e-6 <= record ;

! ------------------------------------------------------------------
! BQN N = 15 section
! ------------------------------------------------------------------
:: check-n15 ( -- )
    15 :> N
    N [0..b) [ N gcd nip 1 = ] filter :> units
    "B.01" "BQN N=15" "units of (Z/15Z)^x" { 1 2 4 7 8 11 13 14 } units >array exact
    "B.02" "BQN N=15" "number of units = phi(15) = 8" 8 units length exact
    "B.03" "BQN N=15" "phi(15) = 8 (engine)" 8 { { 3 1 } { 5 1 } } totient-from-factors exact
    "B.04" "BQN N=15" "lambda(15) = lcm(2, 4) = 4 (engine)" 4 3 5 carmichael-pq exact
    "B.05" "BQN N=15" "squares mod 15 of 2, 7, 8, 11, 13, 14 = 4, 4, 4, 1, 4, 1"
        { 4 4 4 1 4 1 } { 2 7 8 11 13 14 } [ sq N rem ] map exact
    "B.06" "BQN N=15" "no x with x^2 = 14 (mod 15)" f
        N [0..b) [ sq N rem 14 = ] any? exact
    "B.07" "BQN N=15" "e * d mod lambda = 7 * 3 mod 4 = 1" 1 7 3 * 4 rem exact
    "B.08" "BQN N=15" "d = 7^-1 mod 4 = 3 (engine)" 3 7 4 mod-inverse exact
    "B.09" "BQN N=15" "theta = arctan(7 / sqrt 15) ~ 1.062 rad" 1.062
        7 15 sqrt / atan 0.0005 approx ;

! ------------------------------------------------------------------
! Driver and report
! ------------------------------------------------------------------
: run-research-checks ( -- seq )
    V{ } clone claims set
    check-toy-key
    check-table
    check-euclid-traces
    check-p-squared
    check-newton-schulz
    check-floating-point
    check-n15
    claims get ;

: failing-claim-ids ( -- ids )
    run-research-checks [ ok?>> not ] filter [ id>> ] map >array ;

: claim>assoc ( claim -- assoc )
    H{ } clone
    over id>> "id" pick set-at
    over section>> "section" pick set-at
    over statement>> "statement" pick set-at
    over doc>> unparse "doc" pick set-at
    over engine>> unparse "engine" pick set-at
    swap ok?>> "ok" pick set-at ;

:: print-claim ( c -- )
    c ok?>> "PASS " "FAIL " ? write
    c id>> write " | " write c statement>> write nl
    "      doc    = " write c doc>> unparse print
    "      engine = " write c engine>> unparse print ;

:: research-report ( -- )
    run-research-checks :> cs
    cs [ print-claim ] each
    cs [ ok?>> ] count :> pass
    cs length pass - :> fail
    "CLAIMS CHECKED: " write cs length pprint nl
    "PASS: " write pass pprint nl
    "FAIL: " write fail pprint nl
    "FAILING IDS: " write cs [ ok?>> not ] filter [ id>> ] map >array pprint nl ;

:: write-research-json ( path -- )
    run-research-checks [ claim>assoc ] map >array >json
    path utf8 set-file-contents ;

: research-main ( -- ) research-report ;

MAIN: research-main
