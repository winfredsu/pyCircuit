# Wave 003 Integration Verifier

Run ID: `20260514-wave003`
Evidence path: `docs/gates/logs/20260514-wave003/integration-verifier/`

## Verifier Scope

This lane verifies the first three Wave 003 user-review candidates from
`docs/v5-lab/pr-queue.md` and keeps the source-correlation candidate deferred.
It does not implement feature work for the three implementation lanes.

| Lane | Branch candidate | Verifier expectation | Status |
| --- | --- | --- | --- |
| CycleAwareTb context diagnostics | `codex/v5-cycleawaretb-context-diagnostics` | Diagnostics-only change to `CycleAwareTb.expect`; preserve `msg=`; no watch/history, timeline helper, or source-map work. | Waiting for lane output. |
| Ready/valid FIFO example/tests | `codex/v5-ready-valid-fifo-example-tests` | Independently written tiny V5 FIFO example/tests; no helper API, compiler internals, or third-party RTL import. | Waiting for lane output. |
| C++ sim benchmark contract | `codex/v5-cpp-sim-benchmark-contract` | Docs-only benchmark contract/schema/evidence-path tightening; no runner, runtime, emitter, or optimization change. | Waiting for lane output. |
| Source correlation | `codex/v5-source-correlation-map` | Explicitly deferred for Wave 003; no source-correlation implementation should appear. | Deferred; verify unchanged. |

## Contract and Decision Checkpoints

- CycleAwareTb lane may mention cycle/phase diagnostics and V5 testbench
  behavior, but it should not change hardware semantics or decision status.
- FIFO lane may exercise reset/cycle simulation behavior through examples and
  tests, but it should not change compiler semantics unless it stops for review.
- C++ benchmark lane is a documentation/workflow contract only; later runner
  work must add correctness-before-timing and JSON result validation.
- Source-correlation decisions and source-map schema work remain out of scope for
  this wave.

## Evidence Review Checklist

For each implementation lane, verify before final integration:

1. **Ownership:** changed files stay inside the worker-owned paths in
   `docs/v5-lab/claims.md`.
2. **Contracts:** affected decision IDs or contracts are named in the lane
   result, with an explicit statement when no decision status changes.
3. **Gates:** commands match `docs/development/testing-and-gates.md` for the
   change type, including API hygiene for docs/examples/API-facing changes.
4. **Evidence:** bounded logs exist under the lane evidence root in
   `docs/gates/logs/20260514-wave003/` and include command/output summaries.
5. **Deferrals:** no watch/history, timeline helper, helper FIFO API, benchmark
   runner, runtime/emitter optimization, third-party RTL import, or source-map
   implementation was added.
6. **Integration:** `docs/v5-lab/pr-queue.md` status notes remain accurate for
   user review and do not imply public upstream submission.

## Initial Baseline Review

Before lane outputs were integrated, the verifier confirmed the Wave 003 claims
and PR queue name these implementation lanes and defer source correlation. The
initial task snapshot is archived in the evidence directory. Final pass/fail
status remains pending until lane artifacts or commits are available for review.

## Final Integration Result

Pending lane completion.

