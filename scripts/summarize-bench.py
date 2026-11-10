#!/usr/bin/env python3
"""Summarise one or more benchmark JSON files written by the harness.

Usage: scripts/summarize-bench.py RUN1.json [RUN2.json ...]

Prints a Markdown table with one row per harness row, the wall time (ms)
of every run given, and the median. Rows are matched by position and the
script refuses to combine runs whose name/bits/outcome/detail/iterations
differ (the harness uses fixed seeds, so they should be identical).
"""
import json
import statistics
import sys


def main(paths):
    if not paths:
        sys.exit("usage: summarize-bench.py RESULTS.json [MORE.json ...]")
    runs = [json.load(open(p)) for p in paths]
    if len({len(r) for r in runs}) != 1:
        sys.exit("runs have different row counts")
    key = ("name", "bits", "outcome", "detail", "iterations")
    heads = " | ".join(f"run {i + 1} ms" for i in range(len(runs)))  # in argument order
    print(f"| algorithm | bits | outcome | iterations | detail | {heads} | median ms |")
    print("|" + "---|" * (6 + len(runs)))
    for rows in zip(*runs):
        first = rows[0]
        for r in rows[1:]:
            if tuple(r[k] for k in key) != tuple(first[k] for k in key):
                sys.exit(f"mismatched rows: {first} vs {r}")
        ms = [r["ms"] for r in rows]
        cells = " | ".join(f"{m:.3f}" for m in ms)
        print(f"| {first['name']} | {first['bits']} | {first['outcome']} | "
              f"{first['iterations']} | {first['detail']} | {cells} | "
              f"{statistics.median(ms):.3f} |")
    print()
    print("Runs (in column order): " + ", ".join(paths))


if __name__ == "__main__":
    main(sys.argv[1:])
