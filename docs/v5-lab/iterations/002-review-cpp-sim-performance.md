# Iteration 002 — Review C++ Simulation Performance Proposal

Owner: worker-4 / conductor reconciliation
Date: 2026-05-14
Wave: 002
Lane: review

## Inputs

- `docs/development/v5-improvement-agent-workflows.md`
- `docs/development/v5-improvement-agent-lanes/review.md`
- `docs/v5-lab/proposals/cpp-sim-performance.md`
- `docs/v5-lab/benchmarks.md`
- `docs/v5-lab/lanes/cpp-sim-perf.md`
- `docs/v5-lab/iterations/001-cpp-sim-perf.md`

## Review Summary

The proposal is valuable but should not proceed directly to runtime or emitter
optimization. The next safe slice is a contract-tightening documentation PR that
turns the Wave 001 methodology into a strict, portable benchmark contract. Only
after that contract is reviewed should Wave 003 schedule implementation of a
runner, tiny target, and first baseline result.

## Findings

- The user scenario is grounded: V5 users need repeatable generated C++
  simulation measurements that cannot regress correctness.
- The proposal already requires correctness before timing and compares A/B
  variants against shared stimulus and output logs.
- The current draft is still under-specified for implementation because it lacks
  a strict JSON schema, a concrete tiny-counter baseline definition, and a
  portable evidence path independent of local absolute paths.
- No optimization hypothesis should enter `pr-queue.md` before a baseline result
  exists.

## Minimal PR Slice

Branch candidate: `codex/v5-cpp-sim-benchmark-contract`

First PR contents should be docs-only and limited to:

1. tighten `docs/v5-lab/proposals/cpp-sim-performance.md` around a benchmark
   contract rather than optimization;
2. define the required JSON result fields for the future benchmark runner;
3. choose the first tiny target and fixed run dimensions, for example counter or
   FSM with fixed seed/cycles/variant names;
4. define the evidence path, for example `docs/v5-lab/results/<run-id>/`, before
   any result-producing implementation exists;
5. leave runner code, generated C++ changes, and optimization experiments for a
   later implementation PR.

## Required Gates

For the contract PR:

- `pre-commit run --files docs/v5-lab/proposals/cpp-sim-performance.md docs/v5-lab/benchmarks.md docs/v5-lab/iterations/002-review-cpp-sim-performance.md docs/v5-lab/pr-queue.md docs/v5-lab/backlog.md docs/v5-lab/integration.md`
- `mkdocs build`
- API hygiene as included in the docs pre-commit/API sweep.

For the later implementation PR:

- tiny benchmark correctness scoreboard passes before timing is reported;
- cache-on/cache-off variants produce identical output logs for the same seed;
- trace/probe variants preserve functional outputs;
- JSON output records revision, host/toolchain, build/run commands, cycle count,
  compile time, runtime, cycles/sec, and one overhead metric;
- existing C++/Verilator smoke/system gate for the touched target remains green
  or the skip/blocker is recorded with evidence.

## Risks

| Risk | Mitigation |
| --- | --- |
| Under-specified schema allows non-reproducible measurements. | Land the schema/contract before runner code. |
| Local paths leak into evidence. | Require repo-relative evidence directories and explicit environment metadata. |
| Optimization begins without a baseline. | Queue only the contract PR first; implementation and optimization stay separate. |
| Timing noise hides regressions. | Require correctness-before-timing and stable command/variant metadata. |

## Review Handoff

- Verdict: revise / split
- Blocking issues: strict JSON schema, tiny target selection, and portable evidence path must be written before implementation work.
- Suggested edits: queue a docs-only benchmark-contract PR first; do not queue runtime/emitter optimization yet.
- Missing evidence: no baseline numbers or implementation evidence exist yet; those belong after the contract PR.
- Next task: open `codex/v5-cpp-sim-benchmark-contract` as a docs-only contract branch, then schedule runner implementation only after user review.

Review verdict: revise / split
Minimal PR slice: docs-only benchmark contract/schema/evidence-path PR; no runner, runtime, emitter, or optimization changes in the first slice.
Required gates: docs pre-commit/API hygiene and `mkdocs build` for the contract PR; later implementation gates must include correctness-before-timing and JSON result validation.
Risks: non-reproducible local benchmark data, premature optimization, noisy timing, and accidental semantic regressions in fast stepping/cache experiments.
Wave 003 handoff: prepare `codex/v5-cpp-sim-benchmark-contract` first; use it to authorize a later tiny-counter benchmark runner branch.
