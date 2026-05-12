# Iteration 001 — Source Correlation

Worker: worker-1
Lane: source-correlation

## What I checked

- `docs/development/v5-improvement-agent-workflows.md`
- `docs/development/v5-improvement-agent-lanes/source-correlation.md`
- `docs/v5-lab/claims.md`

## Observations

- Wave 001 ownership is docs-only for worker-1: lane log + iteration note + optional proposal.
- The source-correlation lane is explicitly about preserving source, cycle, hierarchy, and signal provenance across Python → MLIR → Verilog.
- The lane must not redesign V5 syntax; syntax friction belongs to `rtl-porting`.
- Shared compiler/API/code/example/test files remain off-limits in this wave.

## Hazards recorded

- Python → MLIR → Verilog trace loss.
- Balance-register provenance loss.
- Instance-path flattening.
- Non-semantic name churn.

## Output status

- No proposal drafted yet.
- Reason: insufficient evidence from a concrete example trace.

## Handoff

- Evidence:
  - The lane workflow and claims file agree on allowed writes and the required handoff block.
  - The workflow emphasizes source/debug mapping and acceptance tests, but this iteration only has policy-level evidence.
- Proposed backlog changes:
  - Defer until a minimal example trace identifies a stable source-map shape.
- Risks:
  - Any proposal made now would be speculative and could miss actual MLIR/Verilog naming behavior.
- Next task:
  - Inspect one simple V5 example and its generated MLIR/Verilog; then decide whether to add `docs/v5-lab/proposals/source-correlation.md`.
