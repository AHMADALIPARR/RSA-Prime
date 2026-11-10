# RSA-CRYPTANALYSIS-OMEGA - build, test and benchmark entry points.
# FACTOR_BIN must point at a Factor 0.102 VM binary (the image must sit
# next to it). Lean 4.35.0 / Lake are found on PATH or in ~/.elan/bin.

FACTOR_BIN ?= /home/box/factor/factor/factor
export FACTOR_BIN
export PATH := $(HOME)/.elan/bin:$(PATH)

.PHONY: all test test-engine test-original test-research report bench \
        lean lean-research verify box-run clean help

all: verify test lean lean-research

help:
	@echo "make verify         sha256 check of every preserved original file"
	@echo "make test           engine unit tests (strict) + research conformance tests"
	@echo "make test-original  scripts/run-tests.sh exactly as shipped"
	@echo "make report         claim-by-claim research conformance report"
	@echo "make bench          benchmark harness -> results/box-run/results.json"
	@echo "make lean           lake build of the original Lean package (lean/)"
	@echo "make lean-research  lake build of tests/lean (research conformance proofs)"
	@echo "make box-run        run everything and capture logs into results/box-run/"
	@echo "make clean          remove Lean build directories"

verify:
	sha256sum -c MANIFEST.sha256

test: test-engine test-research

test-engine:
	./scripts/run-unit-tests-strict.sh

test-original:
	./scripts/run-tests.sh

test-research:
	./scripts/run-research-tests.sh

report:
	./scripts/run-research-report.sh

bench:
	./scripts/run-bench-repo.sh

lean:
	cd lean && lake build

lean-research:
	cd tests/lean && lake build

box-run:
	./scripts/capture-box-run.sh

clean:
	rm -rf lean/.lake tests/lean/.lake
