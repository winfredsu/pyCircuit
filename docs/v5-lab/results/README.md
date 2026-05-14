# V5 Lab Benchmark Results

This directory is the reserved evidence location for reviewed V5 lab benchmark
outputs. The Wave 003 benchmark-contract slice defines the result shape only; it
does not add a benchmark runner or publish measured baseline numbers.

## Directory Contract

Future benchmark result runs must use:

```text
docs/v5-lab/results/<run-id>/
```

Each run directory should contain:

- `cpp-tiny-counter.json` for the first fixed tiny-target result
- optional Markdown summary generated from the same JSON
- repo-relative links to command logs under
  `docs/gates/logs/<run-id>/cpp-sim-benchmark-contract/` or the later runner
  lane evidence directory
- correctness logs for every measured variant

Result JSON must follow the schema documented in
`docs/v5-lab/benchmarks.md`.

## Current Status

No measured results are committed yet. Timing numbers remain invalid until a
follow-up reviewed runner implements correctness-before-timing validation and
writes schema-compatible JSON for every measured variant.
