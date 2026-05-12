# Source Correlation Lane — Wave 001

Status: in progress
Worker: worker-1
Scope: preserve source, cycle, signal, and hierarchy provenance from Python through MLIR into generated Verilog.

## Evidence base

- `docs/development/v5-improvement-agent-workflows.md`
- `docs/development/v5-improvement-agent-lanes/source-correlation.md`
- `docs/v5-lab/claims.md`

## Migration hazards

- Source provenance can be lost at the Python → MLIR → Verilog boundary unless file, line, and V5 name are carried explicitly.
- Cycle provenance can become ambiguous when auto-inserted balance registers hide the original signal and cycle delta.
- Hierarchy provenance can be flattened if generated instance paths are not preserved in a meaningful form.
- Generated signal names may churn under non-semantic edits, breaking timing/debug stability.
- V5 syntax redesign is out of scope for this lane; syntax friction should be deferred to `rtl-porting`.

## Minimal next-step slices

- Inspect one minimal V5 example end-to-end and record where provenance is preserved or lost.
- Trace one user-visible signal through Python, MLIR, and Verilog names.
- Record how any balance register metadata would need to name source signal and cycle delta.
- Capture whether hierarchical instance paths remain readable for debug.

## Proposal posture

Evidence is not sufficient yet for a concrete proposal draft. The next step is a single example trace, after which a `source_map.json` shape can be justified or explicitly deferred.

## Handoff

- Evidence:
  - The three workflow/ownership docs confirm the lane scope, write boundaries, and required handoff format.
  - The lane is documentation-first in wave 001 and should not edit shared compiler/code files.
- Proposed backlog changes:
  - Later backlog candidates only: source-map schema, balance-register provenance metadata, hierarchy/path retention, and name-stability checks.
- Risks:
  - Proposal would be premature without one concrete Python → MLIR → Verilog trace.
  - Shared compiler/code edits remain off-limits in this wave.
- Next task:
  - Inspect one minimal V5 example and its generated artifacts, then decide whether to draft `docs/v5-lab/proposals/source-correlation.md`.
