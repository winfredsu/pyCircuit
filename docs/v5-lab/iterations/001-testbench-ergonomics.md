# Iteration 001 — Testbench Ergonomics

Owner: worker-4
Date: 2026-05-12
Wave: 001

## Inputs

- Total workflow: `docs/development/v5-improvement-agent-workflows.md`
- Lane workflow: `docs/development/v5-improvement-agent-lanes/testbench-ergonomics.md`
- Lane ownership: `docs/v5-lab/claims.md`

## Scope applied

Only lane-owned documents were edited:

- `docs/v5-lab/lanes/testbench-ergonomics.md`
- `docs/v5-lab/iterations/001-testbench-ergonomics.md`
- `docs/v5-lab/proposals/cycleawaretb-ergonomics.md`

No shared compiler/API/code/example/test files were edited.

## Workflows reviewed

| Workflow | Evidence path | Why selected |
| --- | --- | --- |
| Counter smoke | `designs/examples/counter/tb_counter.py` | Smallest linear `drive` / `expect` / `next` pattern. |
| Pipeline valid | `designs/examples/pipeline_builder/tb_pipeline_builder.py` | Shows latency intent that will become harder to review as rows increase. |
| Ready/valid bypass | `designs/BypassUnit/tb_bypass_unit.py` | Shows helper-heavy port matrices and manual diagnostic messages. |
| Multi-clock smoke | `designs/examples/multiclock_regs/tb_multiclock_regs.py` | Shows multiple clocks with one implicit cycle counter. |

## Findings

1. `CycleAwareTb` is already a good minimal wrapper for short tests. It removes
   explicit `at=` arguments and mirrors V5 design-side `domain.next()`.
2. The current API does not preserve enough diagnostic structure for larger
   tests. Complex tests manually add cycle/lane/source details to `msg` strings.
3. The current docs explain low-level phases, but V5 authors do not get a
   documented failure-localization workflow with watched signals and recent
   cycles.
4. Evidence is not rooted in the normal `tests/` suite today. The strongest
   coverage examples live under `designs/`, so future implementation should add
   focused root tests before changing backend output.

## Proposal decision

A proposal is warranted because the same failure-locality issue appears across
small examples, pipeline timelines, ready/valid matrices, and multi-clock smoke
patterns. The proposal intentionally splits diagnostics from syntax sugar:

- First: failure context labels and watch/history support.
- Later: tabular stimulus helpers.

This keeps the first implementation branch testable and avoids widening into a
full testbench DSL redesign.

## Verification notes

- Markdown only; no generated code behavior changed.
- Required follow-up implementation gates are captured as acceptance tests in the
  proposal instead of editing shared test files in this wave.

Handoff:

- Evidence: current `CycleAwareTb` API and docs were compared against counter, pipeline, ready/valid, and multi-clock workflows; helper-heavy ready/valid tests already duplicate `tb.cycle` information in custom messages; root `tests/` currently have no direct `CycleAwareTb` usage in the local scan.
- Proposed backlog changes: create a high-priority backlog item for `CycleAwareTb` failure context/history diagnostics, followed by a lower-priority tabular stimulus helper and reset/multi-clock documentation update.
- Risks: implementing history at the wrong layer could couple Python frontend state to backend assertion generation; snapshotting backend failure text may be brittle unless tests assert stable semantic fields.
- Next task: review and refine `docs/v5-lab/proposals/cycleawaretb-ergonomics.md`; if accepted, open a dedicated branch for diagnostics-only tests and plumbing.
