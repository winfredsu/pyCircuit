# PyCircuit V5 Improvement Lab Integration — Wave 001

## Phase 1 Conductor Setup

- `docs/v5-lab/claims.md` created with `PHASE 1 READY`.
- Four lane workers assigned: source-correlation, rtl-porting, cpp-sim-perf, testbench-ergonomics.
- RTL source intake, license gate, porting ladder, and verification gate recorded in claims.

## Lane Handoff Summary

| Lane | Status | Handoff path | Key result |
| --- | --- | --- | --- |
| source-correlation | complete | `docs/v5-lab/iterations/001-source-correlation.md` | Identified current source/cycle provenance gaps and a source-map proposal direction; implementation deferred to a reviewed follow-up. |
| rtl-porting | complete | `docs/v5-lab/iterations/001-open-rtl-porting.md` | Built license-gated inventory, selected OpenTitan `prim_fifo_sync`, wrote V5 pseudo-code/friction table, and drafted a ready/valid FIFO helper proposal. |
| cpp-sim-perf | complete | `docs/v5-lab/iterations/001-cpp-sim-perf.md` | Defined benchmark methodology, fallback for missing reference repo, initial benchmark matrix, and optimization hypotheses with correctness gates. |
| testbench-ergonomics | complete | `docs/v5-lab/iterations/001-testbench-ergonomics.md` | Reviewed real `CycleAwareTb` workflows and drafted diagnostics/history ergonomics proposal. |

## Cross-Lane Findings

1. **Ready/valid FIFO is the strongest cross-lane seed.** RTL porting selected a FIFO slice; testbench ergonomics found ready/valid tests need better failure context; cpp-sim-perf can use FIFO as a tiny/medium benchmark target.
2. **Debug provenance and testbench diagnostics overlap.** Source correlation proposes Python/MLIR/Verilog mapping; testbench ergonomics needs failure labels/history that should align with future source-map fields.
3. **First implementation wave should stay narrow.** All lanes recommend proposal review before code changes because semantics may touch naming, reset, generated artifacts, or API ergonomics.
4. **Evidence remains docs/prototype-level.** No compiler/API files changed. Generated-artifact observations and benchmark numbers are intentionally deferred to follow-up branches.

## Proposal Review Queue

Proposal drafts produced in Wave 001 require review before entering `docs/v5-lab/pr-queue.md` as accepted branch/PR candidates:

- `docs/v5-lab/proposals/source-correlation.md`
- `docs/v5-lab/proposals/ready-valid-fifo-helpers.md`
- `docs/v5-lab/proposals/cpp-sim-performance.md`
- `docs/v5-lab/proposals/cycleawaretb-ergonomics.md`

## Priority Recommendation

1. Review `cycleawaretb-ergonomics.md` first: high user-facing value and likely docs/tests-first implementation path.
2. Review `ready-valid-fifo-helpers.md` second: strong RTL-porting evidence and useful benchmark/testbench target.
3. Review `source-correlation.md` third: high value, but needs a concrete generated-artifact prototype before implementation.
4. Review `cpp-sim-performance.md` fourth: requires baseline measurement before optimization work.

## Verification Notes

- Required handoff blocks are present in all lane and iteration files.
- RTL inventory records candidate/license decisions and a selected slice.
- `pr-queue.md` remains empty because no proposal has completed independent review yet.
- Recommended post-wave docs gates:

```bash
changed=$(git diff --name-only -- docs/v5-lab)
if [ -n "$changed" ]; then pre-commit run --files $changed; fi
mkdocs build
```

## PyCircuit V5 Improvement Lab Integration — Wave 002

## Phase 2 Conductor Setup

- `docs/v5-lab/claims.md` updated with `PHASE 2 READY` and docs-only ownership.
- Four proposal-review workers assigned: CycleAwareTb ergonomics, ready/valid
  FIFO, source correlation, and C++ sim performance.
- Write boundary remained limited to `docs/v5-lab/`; no compiler/API/tests were
  intentionally changed.

## Review Handoff Summary

| Proposal | Review status | Handoff path | Minimal PR slice |
| --- | --- | --- | --- |
| CycleAwareTb ergonomics | accepted/split | `docs/v5-lab/iterations/002-review-cycleawaretb-ergonomics.md` | `codex/v5-cycleawaretb-context-diagnostics`: context-label failure diagnostics only; defer watch/history and timeline. |
| Ready/valid FIFO | split | `docs/v5-lab/iterations/002-review-ready-valid-fifo.md` | `codex/v5-ready-valid-fifo-example-tests`: independently written FIFO example/tests before any helper API. |
| Source correlation | split | `docs/v5-lab/iterations/002-review-source-correlation.md` | `codex/v5-source-correlation-map`: opt-in schema plus named `domain.cycle(..., name=...)` provenance spike. |
| C++ sim performance | revise/split | `docs/v5-lab/iterations/002-review-cpp-sim-performance.md` | `codex/v5-cpp-sim-benchmark-contract`: docs-only benchmark schema/evidence contract before runner or optimization. |

## Cross-Lane Decisions

1. **Implementation must be branch-per-proposal.** `pr-queue.md` now contains
   four user-review candidates with distinct branch names, titles, non-goals,
   gates, and evidence roots.
2. **Diagnostics and source maps should align but not block each other.** The
   first CycleAwareTb branch can carry labels as metadata; source-map IDs are a
   later integration point, not a dependency.
3. **FIFO stays example-first.** The RTL-porting proposal should produce
   executable example/test evidence and generated-name observations before any
   public helper API is accepted.
4. **Performance work stays baseline-first.** The C++ lane must land a benchmark
   contract/schema before runner implementation and before any optimization.

## Lifecycle Notes

- Worker source-correlation review output was integrated, but task lifecycle
  recorded a stale failed status after a mistaken interpretation that docs-only
  edits were forbidden. The conductor treats this as an acknowledged failure path
  because the required `002-review-source-correlation.md` artifact is present and
  incorporated in `pr-queue.md`.
- Worker ready/valid lifecycle was reconciled by conductor after claim/delegation
  bookkeeping rejected the worker's own completion transition; the artifact was
  committed and integrated.
- Worker C++ review originally reported read-only; conductor materialized the
  required iteration artifact from the mailbox handoff and queue decision.

## Wave 003 Recommendation

Proceed only after user review of `docs/v5-lab/pr-queue.md`. Recommended order:

1. `codex/v5-cycleawaretb-context-diagnostics`
2. `codex/v5-ready-valid-fifo-example-tests`
3. `codex/v5-cpp-sim-benchmark-contract`
4. `codex/v5-source-correlation-map`

The source-correlation branch remains high-value but higher semantic risk, so it
should start after the lower-risk diagnostics/example/contract branches unless a
specific debug-provenance need becomes urgent.
