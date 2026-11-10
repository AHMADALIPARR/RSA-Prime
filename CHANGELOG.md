# Changelog

## 1.0.0 - 2026-11-10

Production layout of RSA-CRYPTANALYSIS-OMEGA. No original source file was
edited; all 37 preserved files are verified by `MANIFEST.sha256`.

### Added
- `research/RSA-OMEGA-RESEARCH.md`: the author's research document, verbatim.
- `tests/factor/rsa-omega/research/`: vocabulary `rsa-omega.research`, 180
  checks of the concrete claims in the research document against the engine,
  plus 38 unit tests. The author's BQN and J programs are in `bqn/` and `j/`
  and are run by CBQN and J, not reimplemented in Factor.
- `tests/lean/`: Lake package `rsa-omega-research` (depends on `lean/`),
  kernel-checked `decide` proofs of the document's numbers and its errata.
- `scripts/run-unit-tests-strict.sh`: the nine engine test vocabularies,
  exiting non-zero on any failure.
- `scripts/run-research-tests.sh`, `scripts/run-research-report.sh`.
- `scripts/run-bench-repo.sh`: runs the unchanged harness, writes JSON inside
  the repository.
- `scripts/capture-box-run.sh`, `scripts/summarize-bench.py`.
- `results/box-run/`: logs, exit codes and benchmark JSON from three runs on
  the build machine.
- `Makefile`, `LICENSE` (AGPL-3.0-only / GNU Affero General Public License v3.0), `.gitignore`,
  `.gitattributes`, `docs/`.

### Moved (content unchanged)
- `README.md` to `docs/README-original.md`.

### Known issues carried over unchanged
- `rsa-omega.smoke` does not load: it calls `pollard-p1-factor`, which no
  vocabulary defines (the factoring vocabulary exports `pollard-p-1`).
- `gnfs-partial` is setup only (polynomial selection and factor bases).
