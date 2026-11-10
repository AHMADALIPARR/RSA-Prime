# Provenance and the byte-identical guarantee

## Inputs

| Input | sha256 |
|---|---|
| Code upload (gzip tar, 26,583 bytes) | `a9912883cd9570d37057387ff0f56076050cc359965602e005f213d7c875dc8e` (file name of the upload) |
| Research document upload (46,922 bytes) | content sha256 `7a7edb15bd80364a4ee07ab2b7cc9b2505d309e970fedfe88b73ea537c719610` |

The code upload contains 36 files under `rsa-omega/` plus an empty
`lean/RsaOmega/` directory (git does not store empty directories, so it is
not in the repository).

## What was preserved

`MANIFEST.sha256` lists all 37 preserved files (the 36 files of the code
upload plus the research document) with their sha256 computed from the
uploads, at their path in this repository. Only two files moved:

| Upload path | Repository path |
|---|---|
| `README.md` | `docs/README-original.md` |
| (research document attachment) | `research/RSA-OMEGA-RESEARCH.md` |

Every other file keeps its original relative path, because
`scripts/run-tests.sh` and `scripts/run-bench.sh` locate the Factor
sources relative to the scripts directory. Check with:

```bash
sha256sum -c MANIFEST.sha256    # or: make verify
```

`.gitattributes` disables line-ending conversion so the hashes hold on
every platform.

## What is new

Everything not in `MANIFEST.sha256` was added and is new code or
documentation: `README.md`, `CHANGELOG.md`, `LICENSE`, `Makefile`,
`.gitignore`, `.gitattributes`, `.github/workflows/ci.yml`, `docs/*.md`
(except `README-original.md`), `scripts/run-unit-tests-strict.sh`,
`scripts/run-research-tests.sh`, `scripts/run-research-report.sh`,
`scripts/run-bench-repo.sh`, `scripts/capture-box-run.sh`,
`scripts/summarize-bench.py`, `tests/factor/rsa-omega/research/*`,
`tests/lean/*`, `bqn/*`, `j/*`, `scripts/require-tool.sh`,
`scripts/run-array-langs.sh`, and `results/box-run/*`.

## Fresh results do not overwrite the original results

`results/*.txt` and `results/results.json` are the files from the upload
and stay byte-identical. All fresh runs are written to `results/box-run/`.
`harness-main` hard-codes `/workspace/rsa-omega/results/results.json`;
`scripts/run-bench-repo.sh` calls the harness word `write-results` with a
path inside the repository instead, so the harness source does not have to
be edited.
