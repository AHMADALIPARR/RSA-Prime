# BQN programs from the research document

Each file is the author's program, copied verbatim from
`research/RSA-OMEGA-RESEARCH.md`. The only lines added are the
`AGPL-3.0-only` header comments. `scripts/run-array-langs.sh` runs them
with CBQN (`BQN`). Factor does not reimplement them.

| File | Research document lines |
|---|---|
| `fused-kernel.bqn` | 417–442, under "Corrected BQN Fused Kernel". This is also the program described by "II. BQN ADVERSARIAL EXECUTION LOOP (PREDICATE HOP)" (lines 477–478), which has no second code block. |
| `mobius-bridge.bqn` | 600–837, the file introduced by "# BQN: Wick Rotation & Braid Word Generation for Möbius Bridge". |

"IV. ARRAY KERNEL MAPPING (J / BQN SPECIFICATION)" (lines 381–384) is a
LaTeX formula, not a BQN program, so it is not a file here.
