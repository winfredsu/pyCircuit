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
