# SPDX-License-Identifier: AGPL-3.0-only
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, version 3.
# See the LICENSE file.

# RSA-CRYPTANALYSIS-OMEGA - build, test and benchmark entry points.
# FACTOR_BIN must be the Factor VM (default /home/box/factor/factor/factor).
# lake and lean are taken from PATH, with ~/.elan/bin prepended.
# BQN and jconsole must be on PATH. A missing binary fails the target
# with "missing <tool>". Nothing is skipped or reimplemented elsewhere.

FACTOR_BIN ?= /home/box/factor/factor/factor
export FACTOR_BIN
export PATH := $(HOME)/.elan/bin:$(PATH)

.PHONY: all test test-engine test-original test-research report bench \
        lean lean-research verify box-run clean help array \
        require-factor require-lean require-bqn require-j

all: verify test lean lean-research array

help:
	@echo "make verify         sha256 check of every preserved original file"
	@echo "make test           engine unit tests (strict) + research conformance tests"
	@echo "make test-original  scripts/run-tests.sh exactly as shipped"
	@echo "make report         claim-by-claim research conformance report"
	@echo "make bench          benchmark harness -> results/box-run/results.json"
	@echo "make lean           lake build of the original Lean package (lean/)"
	@echo "make lean-research  lake build of tests/lean (research conformance proofs)"
	@echo "make array          run bqn/*.bqn and j/*.ijs with BQN and jconsole"
	@echo "make box-run        run everything and capture logs into results/box-run/"
	@echo "make clean          remove Lean build directories"

require-factor:
	@test -x "$(FACTOR_BIN)" || { echo "missing factor"; exit 1; }

require-lean:
	@command -v lean >/dev/null 2>&1 || { echo "missing lean"; exit 1; }
	@command -v lake >/dev/null 2>&1 || { echo "missing lake"; exit 1; }

require-bqn:
	@command -v BQN >/dev/null 2>&1 || { echo "missing BQN"; exit 1; }

require-j:
	@command -v jconsole >/dev/null 2>&1 || { echo "missing jconsole"; exit 1; }

verify:
	sha256sum -c MANIFEST.sha256

test: test-engine test-research

test-engine: require-factor
	./scripts/run-unit-tests-strict.sh

test-original: require-factor
	./scripts/run-tests.sh

test-research: require-factor
	./scripts/run-research-tests.sh

report: require-factor
	./scripts/run-research-report.sh

bench: require-factor
	./scripts/run-bench-repo.sh

lean: require-lean
	cd lean && lake build

lean-research: require-lean
	cd tests/lean && lake build

array: require-bqn require-j
	./scripts/run-array-langs.sh

box-run: require-factor require-lean require-bqn require-j
	./scripts/capture-box-run.sh

clean:
	rm -rf lean/.lake tests/lean/.lake
