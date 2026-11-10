# SPDX-License-Identifier: AGPL-3.0-only
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, version 3.
# See the LICENSE file.

# <<<< init  
  Tolerance ← 1e¯7  
  MaxIter   ← 1000  
  
# Predicate: Detect IEEE 754 NaN via non-reflexivity (x ≠ x)  
  IsNaN ← { 𝕩 ≢ 𝕩 }  
  
# VJP Kernel mapping  
  VJP ← { 𝕩 × 𝕨 - +´ 𝕩 × 𝕨 }  
  
# recurse predicate Hop ?¿  
  Hop ← {  
      S  ← 𝕩                 # Logits  
      P  ← (⋆S) ÷ +´⋆S       # Softmax forward  
      ∇P ← 1.0 ‿ (1.0 ÷ 1e¯45 **⌈** P⊑1) # Simulate Cross-Entropy derivative -Y/P  
        
      ∇S ← ∇P VJP P          # Execute array kernel  
        
      # ¿ Evaluation Gate  
      (IsNaN ∇S⊑0) ?   
          ⟨ "BROKEN", S, ∇P, ∇S ⟩ ;   
          𝕊 S + 10.0 ‿ ¯10.0 # back init ———>>>>>>  
  }  
  
# Trigger loop sequence  
  Result ← Hop 10.0 ‿ ¯10.0  
