-- SPDX-License-Identifier: AGPL-3.0-only
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as published by
-- the Free Software Foundation, version 3.
-- See the LICENSE file.

/-
RSA-CRYPTANALYSIS-OMEGA — Lean 4 proofs.
No `sorry`, `admit`, or custom axioms.

Theorems (general form, not only numeric examples):
* CRT reconstruction for two coprime moduli
* Extended-Euclid / Bezout identity
* RSA inversion under valid key conditions
-/

namespace RsaOmega

/-! ## Difference of squares -/

theorem fermat_diff_squares_int (a b : Int) :
    a * a - b * b = (a - b) * (a + b) := by
  simp [Int.sub_eq_add_neg, Int.mul_add, Int.add_mul, Int.neg_mul,
        Int.mul_comm b a, Int.add_assoc, Int.add_left_comm,
        Int.add_neg_cancel_left]

/-! ## Cast helper -/

theorem cast_div_mod (m n : Nat) :
    (n : Int) = (m : Int) * ↑(n / m) + ↑(n % m) := by
  have h : m * (n / m) + n % m = n := Nat.div_add_mod n m
  calc
    (n : Int) = ↑(m * (n / m) + n % m) := by rw [h]
    _ = ↑(m * (n / m)) + ↑(n % m) := by rw [Int.natCast_add]
    _ = ↑m * ↑(n / m) + ↑(n % m) := by rw [Int.natCast_mul]

/-! ## Bezout identity (extended Euclid) — general form -/

theorem bezout_identity (a b : Nat) :
    ∃ s t : Int, s * (a : Int) + t * (b : Int) = (Nat.gcd a b : Int) := by
  induction a, b using Nat.gcd.induction with
  | H0 n =>
      refine ⟨0, 1, ?_⟩
      simp [Nat.gcd_zero_left]
  | H1 m n hm ih =>
      obtain ⟨s, t, hst⟩ := ih
      refine ⟨t - s * (↑(n / m) : Int), s, ?_⟩
      have hgcd : Nat.gcd (n % m) m = Nat.gcd m n := (Nat.gcd_rec m n).symm
      have hq := cast_div_mod m n
      have hcomm : s * ↑(n / m) * ↑m = s * (↑m * ↑(n / m)) := by
        calc
          s * ↑(n / m) * ↑m
              = s * (↑(n / m) * ↑m) := by rw [Int.mul_assoc]
          _ = s * (↑m * ↑(n / m)) := by rw [Int.mul_comm (↑(n / m) : Int)]
      have hmain :
          (t - s * ↑(n / m)) * ↑m + s * ↑n
            = s * ↑(n % m) + t * ↑m := by
        rw [hq, Int.sub_mul, Int.mul_add, hcomm]
        omega
      calc
        (t - s * ↑(n / m)) * ↑m + s * ↑n
            = s * ↑(n % m) + t * ↑m := hmain
        _ = ↑(Nat.gcd (n % m) m) := hst
        _ = ↑(Nat.gcd m n) := by rw [hgcd]

theorem egcd_example_9_6 : ∃ s t : Int, s * 9 + t * 6 = 3 := by
  refine ⟨1, -1, ?_⟩; decide

/-! ## Modular inverse from Bezout -/

theorem exists_mod_inverse {a m : Nat} (hm : 1 < m) (hc : Nat.gcd a m = 1) :
    ∃ inv : Nat, (a * inv) % m = 1 := by
  obtain ⟨s, t, h⟩ := bezout_identity a m
  have h1 : s * (a : Int) + t * (m : Int) = 1 := by simpa [hc] using h
  have hmpos : (0 : Int) < ↑m := by exact_mod_cast (Nat.zero_lt_of_lt hm)
  have hne : (↑m : Int) ≠ 0 := by omega
  have hnonneg : 0 ≤ (s % ↑m + ↑m) % ↑m := Int.emod_nonneg _ hne
  have heq : (s % ↑m + ↑m) % ↑m = s % ↑m := by
    have : (s % ↑m + ↑m) % ↑m = (s % ↑m) % ↑m := by
      simp [Int.add_emod]
    simpa [Int.emod_emod] using this
  let inv : Nat := ((s % ↑m + ↑m) % ↑m).toNat
  have hcast : (inv : Int) = (s % ↑m + ↑m) % ↑m := Int.toNat_of_nonneg hnonneg
  have hone : (1 : Int) % ↑m = 1 :=
    Int.emod_eq_of_lt (by omega : (0 : Int) ≤ 1) (by exact_mod_cast hm)
  have ha_s : ((a : Int) * s) % ↑m = 1 := by
    have hsub : (a : Int) * s = 1 - t * ↑m := by
      have := congrArg (fun x => x + -(t * ↑m)) h1
      simp only [Int.add_neg_cancel_right] at this
      rw [Int.mul_comm, Int.sub_eq_add_neg]
      exact this
    rw [hsub]; simp [Int.sub_emod, hone]
  have ha_inv : ((a : Int) * ↑inv) % ↑m = 1 := by
    calc
      ((a : Int) * ↑inv) % ↑m
          = ((a : Int) * ((s % ↑m + ↑m) % ↑m)) % ↑m := by rw [hcast]
      _ = ((a : Int) * (s % ↑m)) % ↑m := by rw [heq]
      _ = ((a : Int) * s) % ↑m := by
            calc
              ((a : Int) * (s % ↑m)) % ↑m
                  = (a % ↑m * ((s % ↑m) % ↑m)) % ↑m := Int.mul_emod _ _ _
              _ = (a % ↑m * (s % ↑m)) % ↑m := by rw [Int.emod_emod]
              _ = ((a : Int) * s) % ↑m := (Int.mul_emod _ _ _).symm
      _ = 1 := ha_s
  refine ⟨inv, ?_⟩
  have hInt : (↑(a * inv) : Int) % ↑m = 1 := by
    rwa [Int.natCast_mul]
  have : (↑((a * inv) % m) : Int) = ↑(1 : Nat) := by
    rw [Int.natCast_emod, hInt]; rfl
  exact Int.ofNat_inj.mp this

/-! ## CRT reconstruction -/

def crtCombine (r1 m1 r2 m2 inv : Nat) : Nat :=
  let delta := (r2 + m2 - r1 % m2) % m2
  (r1 + m1 * ((delta * inv) % m2)) % (m1 * m2)

theorem crt_mod_left (r1 m1 r2 m2 inv : Nat) (_h1 : 0 < m1) :
    crtCombine r1 m1 r2 m2 inv % m1 = r1 % m1 := by
  unfold crtCombine
  rw [Nat.mod_mul_right_mod, Nat.add_mul_mod_self_left]

theorem crt_mod_right (r1 m1 r2 m2 inv : Nat)
    (h2 : 1 < m2) (hinv : (m1 * inv) % m2 = 1) :
    crtCombine r1 m1 r2 m2 inv % m2 = r2 % m2 := by
  unfold crtCombine
  have hreduce :
      (r1 + m1 * ((((r2 + m2 - r1 % m2) % m2) * inv) % m2)) % (m1 * m2) % m2
        = (r1 + m1 * ((((r2 + m2 - r1 % m2) % m2) * inv) % m2)) % m2 :=
    Nat.mod_mul_left_mod _ m1 m2
  rw [hreduce]
  have hle : r1 % m2 ≤ r2 + m2 := by
    have : r1 % m2 < m2 := Nat.mod_lt r1 (Nat.zero_lt_of_lt h2)
    omega
  let delta := (r2 + m2 - r1 % m2) % m2
  have hmk : (m1 * ((delta * inv) % m2)) % m2 = delta := by
    have h1 :
        (m1 * ((delta * inv) % m2)) % m2 = (m1 * (delta * inv)) % m2 := by
      simp [Nat.mul_mod]
    have h2a : m1 * (delta * inv) = delta * (m1 * inv) := by
      simp [Nat.mul_assoc, Nat.mul_comm]
    have h3 :
        (delta * (m1 * inv)) % m2 = (delta * ((m1 * inv) % m2)) % m2 := by
      simp [Nat.mul_mod]
    calc
      (m1 * ((delta * inv) % m2)) % m2
          = (m1 * (delta * inv)) % m2 := h1
      _ = (delta * (m1 * inv)) % m2 := by rw [h2a]
      _ = (delta * ((m1 * inv) % m2)) % m2 := h3
      _ = (delta * 1) % m2 := by rw [hinv]
      _ = delta % m2 := by simp
      _ = delta := Nat.mod_eq_of_lt (Nat.mod_lt _ (Nat.zero_lt_of_lt h2))
  have hsum : (r1 % m2 + delta) % m2 = r2 % m2 := by
    change (r1 % m2 + (r2 + m2 - r1 % m2) % m2) % m2 = r2 % m2
    calc
      (r1 % m2 + (r2 + m2 - r1 % m2) % m2) % m2
          = (r1 % m2 + (r2 + m2 - r1 % m2)) % m2 := by simp [Nat.add_mod]
      _ = (r2 + m2) % m2 := by rw [Nat.add_sub_of_le hle]
      _ = r2 % m2 := by simp [Nat.add_mod]
  calc
    (r1 + m1 * ((delta * inv) % m2)) % m2
        = (r1 % m2 + (m1 * ((delta * inv) % m2)) % m2) % m2 := by
          simp [Nat.add_mod]
    _ = (r1 % m2 + delta) % m2 := by rw [hmk]
    _ = r2 % m2 := hsum

/-- CRT reconstruction: for coprime moduli a simultaneous solution exists. -/
theorem crt_reconstruction (r1 m1 r2 m2 : Nat)
    (h1 : 0 < m1) (h2 : 1 < m2) (hc : Nat.gcd m1 m2 = 1) :
    ∃ x : Nat, x % m1 = r1 % m1 ∧ x % m2 = r2 % m2 := by
  obtain ⟨inv, hinv⟩ :=
    exists_mod_inverse (a := m1) (m := m2) h2 (by simpa [Nat.gcd_comm] using hc)
  exact ⟨crtCombine r1 m1 r2 m2 inv,
         crt_mod_left r1 m1 r2 m2 inv h1,
         crt_mod_right r1 m1 r2 m2 inv h2 hinv⟩

/-! ## RSA inversion under valid key conditions (general form) -/

structure ValidRSA (n e d lam : Nat) : Prop where
  n_gt : 1 < n
  ed : ∃ k : Nat, e * d = 1 + k * lam
  carmichael :
    ∀ msg : Nat, Nat.gcd msg n = 1 → Nat.powMod msg lam n = 1 % n

private theorem pow_one_mod (n k : Nat) (hn : 1 < n) :
    (1 % n) ^ k % n = 1 % n := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Nat.pow_succ, Nat.mul_mod, ih]
    have : 1 % n = 1 := Nat.mod_eq_of_lt hn
    simp [this]

/-- General RSA inversion: under a valid key, decryption recovers
any plaintext coprime to the modulus. -/
theorem rsa_inversion_general
    {n e d lam msg : Nat}
    (hv : ValidRSA n e d lam)
    (hcop : Nat.gcd msg n = 1) :
    Nat.powMod (Nat.powMod msg e n) d n = msg % n := by
  obtain ⟨k, hk⟩ := hv.ed
  have hlam := hv.carmichael msg hcop
  have hcomp :
      Nat.powMod (Nat.powMod msg e n) d n = Nat.powMod msg (e * d) n := by
    simp only [Nat.powMod_def]
    have h1 : (msg ^ e % n) ^ d % n = (msg ^ e) ^ d % n :=
      (Nat.pow_mod (msg ^ e) d n).symm
    rw [h1, ← Nat.pow_mul]
  rw [hcomp, hk]
  have hsplit :
      Nat.powMod msg (1 + k * lam) n
        = (msg * (Nat.powMod msg lam n) ^ k) % n := by
    simp only [Nat.powMod_def]
    rw [Nat.pow_add, Nat.pow_one, Nat.mul_comm k lam, Nat.pow_mul]
    calc
      msg * (msg ^ lam) ^ k % n
          = msg % n * ((msg ^ lam) ^ k % n) % n := Nat.mul_mod _ _ _
      _ = msg % n * ((msg ^ lam % n) ^ k % n) % n := by rw [Nat.pow_mod]
      _ = msg * (msg ^ lam % n) ^ k % n := (Nat.mul_mod _ _ _).symm
  rw [hsplit, hlam]
  have honek := pow_one_mod n k hv.n_gt
  have h1n : 1 % n = 1 := Nat.mod_eq_of_lt hv.n_gt
  calc
    (msg * (1 % n) ^ k) % n
        = (msg % n * ((1 % n) ^ k % n)) % n := by rw [Nat.mul_mod]
    _ = (msg % n * (1 % n)) % n := by rw [honek]
    _ = (msg % n * 1) % n := by rw [h1n]
    _ = msg % n := by simp

theorem demo_rsa_roundtrip :
    Nat.powMod (Nat.powMod 123 17 3233) 2753 3233 = 123 := by
  native_decide

theorem demo_factor_check : 3233 = 61 * 53 := by decide

theorem fifteen_has_factor_three : 15 % 3 = 0 := by decide

end RsaOmega
