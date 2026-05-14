# Iteration 002 — Review Source Correlation

## Goal

Review `docs/v5-lab/proposals/source-correlation.md` for evidence, scope,
acceptance gates, implementation risk, and Wave 003 readiness.

## Inputs Reviewed

- `docs/development/v5-improvement-agent-workflows.md`
- `docs/development/v5-improvement-agent-lanes/review.md`
- `docs/v5-lab/proposals/source-correlation.md`
- `docs/v5-lab/lanes/source-correlation.md`
- `docs/v5-lab/iterations/001-source-correlation.md`

## Review Findings

The proposal is grounded in concrete V5 evidence: eager V5 preserves explicit
`pyc.name` names and auto balance register names, while the lane notes show that
eager compiled modules lack Python source metadata and that the current Verilog
path has name/comment correlation but no structured source map. The direction is
valuable for timing and waveform debug.

The original implementation path was too broad for a first PR because it mixed
schema design, eager source capture, balance-register reasoning, hierarchy
callsites, backend source-map emission, and future CLI lookup. That crosses the
frontend/MLIR/backend boundary before a stable debug-metadata contract exists.

The proposal was tightened to make Wave 003 a gate-first spike:

- define the sidecar schema and opt-in emission contract;
- capture explicit named `domain.cycle(..., name=...)` provenance in eager V5;
- thread debug metadata next to existing `pyc.name` for that named-register
  slice;
- prove stable logical ID behavior for a named register;
- defer balance registers, hierarchy, arithmetic temporaries, timing-report
  ingestion, and CLI lookup.

## Required Gates

- `pre-commit run --files docs/v5-lab/proposals/source-correlation.md docs/v5-lab/iterations/002-review-source-correlation.md`
- `mkdocs build`
- `python3 flows/tools/check_api_hygiene.py compiler/frontend/pycircuit designs/examples docs README.md`
- For the follow-up implementation PR: add focused unit coverage around
  `compile_cycle_aware()`/`CycleAwareDomain.cycle()` source-map emission before
  running `pytest tests/unit -m unit`.

## Review Handoff

- Verdict: split
- Blocking issues: first PR scope must not promise balance-register,
  hierarchical, arithmetic-temporary, timing-report, or CLI lookup behavior.
- Suggested edits: keep the new Wave 002 review decision in the proposal and use
  it as the Wave 003 branch boundary.
- Missing evidence: no implementation evidence exists yet for stable logical IDs
  or backend artifact anchoring; those are first-spike gates, not review blockers.
- Next task: schedule `codex/v5-source-correlation-map` as a tiny schema +
  named-register provenance PR.

Review verdict: split
Minimal PR slice: opt-in `source_map.json` schema plus eager provenance for named `domain.cycle(..., name=...)` registers, threaded to MLIR/debug metadata without changing RTL semantics.
Required gates: docs pre-commit on changed files, `mkdocs build`, API hygiene, and follow-up implementation unit tests for `compile_cycle_aware()` named-register source-map emission.
Risks: Python frame capture brittleness, stable logical ID churn, and frontend/MLIR/backend metadata boundary coupling.
Wave 003 handoff: implement only the schema + named-register spike; defer balance registers, hierarchy, arithmetic temporaries, timing-report ingestion, and CLI lookup.
