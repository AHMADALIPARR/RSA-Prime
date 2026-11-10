# The research document is now part of this repository

`docs/README-original.md` (the README shipped in the original upload, kept
byte-identical) says that the original pasted attachment was missing from
disk when the tree was first built, and that `SPEC.md` was reconstructed
from the task brief. That note is now out of date:

* The research document is included verbatim at
  `research/RSA-OMEGA-RESEARCH.md` (46,922 bytes, 826 lines,
  sha256 `7a7edb15bd80364a4ee07ab2b7cc9b2505d309e970fedfe88b73ea537c719610`).
  It is the author's own work and is not edited in any way. Its hash is
  listed in `MANIFEST.sha256` and checked by `make verify`.
* `SPEC.md` and `SPEC-original.txt` are kept unchanged as the
  implementation brief the engine was written against.
* The numeric claims that are not the BQN or J programs (154 checks)
  are tested against the Factor engine. The 8 disagreements are in
  `docs/RESEARCH-CONFORMANCE.md`.
* The author's BQN and J programs are extracted verbatim into `bqn/` and
  `j/` and run with CBQN and J. Logs are in `results/box-run/bqn/` and
  `results/box-run/j/`. They are not reimplemented in Factor.

The original README text is not edited. The root `README.md` replaces it
as the entry point.
