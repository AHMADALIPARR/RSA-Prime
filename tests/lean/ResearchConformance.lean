-- SPDX-License-Identifier: AGPL-3.0-only
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as published by
-- the Free Software Foundation, version 3.
-- See the LICENSE file.

/-
RSA-OMEGA: kernel-checked conformance of the concrete numbers in
research/RSA-OMEGA-RESEARCH.md.

Every theorem is closed by `decide` (kernel evaluation, no `native_decide`),
by a theorem of the original `RsaOmega` library, or by a short proof.
No `sorry`, no `admit`, no new axioms. The `#print axioms` lines at the
end put the axiom footprint of the key theorems into the build log.

Where the research document prints a value that is arithmetically wrong,
the theorem states the inequality explicitly (section "Errata").
-/
import RsaOmega

namespace RsaOmega.Research

/-! ## Section I: N = 3233, e = 17, d = 413, m = 65, c = 2790 -/

theorem n_3233 : 61 * 53 = 3233 := by decide
theorem n_3233_original : 3233 = 61 * 53 := RsaOmega.demo_factor_check
theorem phi_3233 : (61 - 1) * (53 - 1) = 3120 := by decide
theorem lambda_3233 : Nat.lcm 60 52 = 780 := by decide
theorem gcd_e_lambda : Nat.gcd 17 780 = 1 := by decide

theorem euclid_trace_3233 :
    780 = 45 * 17 + 15 ∧ 17 = 1 * 15 + 2 ∧ 15 = 7 * 2 + 1 := by decide

theorem back_substitution_3233 : (8 : Int) * 780 - 367 * 17 = 1 := by decide
theorem d_reduction_3233 : (-367 : Int) % 780 = 413 := by decide
theorem inverse_certificate_3233 : 17 * 413 = 9 * 780 + 1 := by decide
theorem ed_mod_lambda_3233 : 17 * 413 % 780 = 1 := by decide

/-- Existence of the inverse, obtained from the general theorem
`RsaOmega.exists_mod_inverse` in the original library. -/
theorem inverse_exists_3233 : ∃ inv : Nat, (17 * inv) % 780 = 1 :=
  RsaOmega.exists_mod_inverse (by decide) gcd_e_lambda

/-- The Bezout coefficients printed in the document, as an instance of the
statement proved in general by `RsaOmega.bezout_identity`. -/
theorem bezout_3233 : ∃ s t : Int, s * (780 : Nat) + t * (17 : Nat) = (Nat.gcd 780 17 : Nat) :=
  ⟨8, -367, by decide⟩

theorem encrypt_3233 : 65 ^ 17 % 3233 = 2790 := by decide
-- 413 is above the elaborator's default `exponentiation.threshold` (256);
-- raising it only lets the elaborator evaluate the power too. The kernel
-- check by `decide` is the same either way.
set_option exponentiation.threshold 500 in
theorem decrypt_3233 : 2790 ^ 413 % 3233 = 65 := by decide
set_option exponentiation.threshold 500 in
theorem roundtrip_3233 : (65 ^ 17 % 3233) ^ 413 % 3233 = 65 := by decide

/-! ## Trial-division primality (computational check with a soundness proof) -/

/-- `true` iff `p ≥ 2` and no `k` with `2 ≤ k < p` divides `p`. -/
def isPrimeTD (p : Nat) : Bool :=
  decide (2 ≤ p) && (List.range (p - 2)).all (fun k => p % (k + 2) != 0)

theorem isPrimeTD_sound {p : Nat} (h : isPrimeTD p = true) :
    2 ≤ p ∧ ∀ k, 2 ≤ k → k < p → p % k ≠ 0 := by
  simp only [isPrimeTD, Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true,
    List.mem_range, bne_iff_ne, ne_eq] at h
  refine ⟨h.1, fun k hk1 hk2 => ?_⟩
  have h2 := h.2 (k - 2) (by omega)
  rwa [Nat.sub_add_cancel hk1] at h2

/-! ## Results(N) table rows: n = p q, phi, lambda, gcd(e, lambda) = 1, e d = 1 mod lambda -/

/-- One row of the document's table, checked in full. -/
def rowOK (n p q phi lam e d : Nat) : Bool :=
  isPrimeTD p && isPrimeTD q && p * q == n && (p - 1) * (q - 1) == phi &&
  Nat.lcm (p - 1) (q - 1) == lam && Nat.gcd e lam == 1 &&
  decide (1 < e) && decide (e < lam) && e * d % lam == 1

theorem row_15    : rowOK 15 3 5 8 4 3 3 = true := by decide
theorem row_21    : rowOK 21 3 7 12 6 5 5 = true := by decide
theorem row_77    : rowOK 77 7 11 60 30 7 13 = true := by decide
theorem row_143   : rowOK 143 11 13 120 60 7 43 = true := by decide
theorem row_323   : rowOK 323 17 19 288 144 5 29 = true := by decide
theorem row_899   : rowOK 899 29 31 840 420 11 191 = true := by decide
theorem row_1763  : rowOK 1763 41 43 1680 840 11 611 = true := by decide
theorem row_10403 : rowOK 10403 101 103 10200 5100 7 3643 = true := by decide

/-- Every message round-trips for the smaller table keys. -/
def allRoundTrip (n e d : Nat) : Bool :=
  (List.range n).all (fun m => (m ^ e % n) ^ d % n == m)

theorem roundtrip_all_15  : allRoundTrip 15 3 3 = true := by decide
theorem roundtrip_all_21  : allRoundTrip 21 5 5 = true := by decide
theorem roundtrip_all_77  : allRoundTrip 77 7 13 = true := by decide
theorem roundtrip_all_143 : allRoundTrip 143 7 43 = true := by decide

/-! ## Extended-Euclid traces printed for n = 899, 1763, 10403 -/

theorem trace_899 :
    30 ^ 2 - 1 = 899 ∧ 420 = 38 * 11 + 2 ∧ 11 = 5 * 2 + 1 ∧
    (191 : Int) * 11 - 5 * 420 = 1 ∧ 11 * 191 = 5 * 420 + 1 := by decide

theorem trace_1763 :
    42 ^ 2 - 1 = 1763 ∧ 840 = 76 * 11 + 4 ∧ 11 = 2 * 4 + 3 ∧ 4 = 1 * 3 + 1 ∧
    (3 : Int) * 840 - 229 * 11 = 1 ∧ (-229 : Int) % 840 = 611 ∧
    11 * 611 = 8 * 840 + 1 := by decide

theorem trace_10403 :
    5100 = 728 * 7 + 4 ∧ 7 = 1 * 4 + 3 ∧ 4 = 1 * 3 + 1 ∧
    (2 : Int) * 5100 - 1457 * 7 = 1 ∧ (-1457 : Int) % 5100 = 3643 ∧
    7 * 3643 = 5 * 5100 + 1 ∧ 101 * 101 < 10403 ∧ 10403 < 102 * 102 := by decide

/-! ## n = 65537^2: what the document gets right -/

theorem p2_square : 65537 ^ 2 = 4295098369 := by decide
theorem p2_fermat : 65537 = 2 ^ 16 + 1 := by decide
theorem p2_gcd : Nat.gcd 3 4294967296 = 1 := by decide
theorem p2_division : 4294967296 = 1431655765 * 3 + 1 := by decide
theorem p2_doc_product : 3 * 2863311531 = 8589934593 ∧ 8589934593 = 2 * 4294967296 + 1 := by decide

/-! ## Errata: n = 65537^2 values printed in the document that are wrong -/

/-- True value: phi(p^2) = lambda(p^2) = p (p - 1) = 4295032832. -/
theorem p2_phi_true : 65537 * (65537 - 1) = 4295032832 := by decide

/-- Table / proof section prints 65537 × 65536 = 4294967296. -/
theorem erratum_table_phi : 65537 * 65536 ≠ 4294967296 := by decide

/-- 4294967296 is actually (p - 1)^2 = 65536^2. -/
theorem erratum_table_phi_is_square : 65536 ^ 2 = 4294967296 := by decide

/-- Counterexample section prints p (p - 1) = 4294901760. -/
theorem erratum_counterexample_phi : 65537 * 65536 ≠ 4294901760 := by decide
theorem erratum_counterexample_phi_is : 65536 * 65535 = 4294901760 := by decide

/-- Counterexample section prints (p - 1)(q - 1) = 65536^2 = 4294836225. -/
theorem erratum_square : 65536 ^ 2 ≠ 4294836225 := by decide
theorem erratum_square_is : 65535 ^ 2 = 4294836225 := by decide

/-- The printed d = 2863311531 is not an inverse of 3 modulo the true lambda. -/
theorem erratum_d : 3 * 2863311531 % 4295032832 ≠ 1 := by decide

/-- The true inverse of 3 modulo lambda(65537^2) = 4295032832. -/
theorem p2_true_d : 3 * 1431677611 % 4295032832 = 1 := by decide

/-! ## Arithmetic printed beside the BQN N = 15 program.
    The program itself is bqn/mobius-bridge.bqn and is run by CBQN,
    not by these proofs. -/

theorem units_15 :
    (List.range 15).filter (fun x => Nat.gcd x 15 == 1) = [1, 2, 4, 7, 8, 11, 13, 14] := by
  decide

theorem squares_15 :
    [2, 7, 8, 11, 13, 14].map (fun x => x * x % 15) = [4, 4, 4, 1, 4, 1] := by decide

theorem no_sqrt_minus_one_15 : (List.range 15).all (fun x => x * x % 15 != 14) = true := by
  decide

theorem lambda_15 : Nat.lcm 2 4 = 4 ∧ (3 - 1) * (5 - 1) = 8 ∧ 7 * 3 % 4 = 1 := by decide

end RsaOmega.Research

#print axioms RsaOmega.Research.roundtrip_3233
#print axioms RsaOmega.Research.inverse_exists_3233
#print axioms RsaOmega.Research.isPrimeTD_sound
#print axioms RsaOmega.Research.row_10403
#print axioms RsaOmega.Research.erratum_d
#print axioms RsaOmega.demo_rsa_roundtrip
#print axioms RsaOmega.rsa_inversion_general
