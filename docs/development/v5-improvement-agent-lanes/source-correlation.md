# Source Correlation Lane

This lane studies how PyCircuit V5 can preserve source, signal, cycle, and
hierarchy provenance from Python through MLIR into generated Verilog so timing
and debug workflows can point back to user code.

## Scope

Focus on:

- `docs/PyCircuit_V5_Spec.md`
- `compiler/frontend/pycircuit/v5.py`
- `compiler/mlir/lib/Emit/VerilogEmitter.cpp`
- Generated MLIR/Verilog from simple V5 examples
- Naming, hierarchy, source locations, balance registers, instance paths

Do not redesign V5 syntax in this lane. If syntax friction appears, record it
for the `rtl-porting` lane.

## Workflow

1. Pick one V5 example or minimal design.
2. Generate or inspect Python -> MLIR -> Verilog artifacts.
3. Trace how a few user-visible V5 names survive or disappear.
4. Record where source, cycle, hierarchy, and generated signal names are lost.
5. Propose a source map/debug mapping shape.
6. Define acceptance tests that prove the mapping is stable and useful.

## Required Outputs

Write only lane-owned files:

- `docs/v5-lab/lanes/source-correlation.md`
- `docs/v5-lab/iterations/<NNN-source-correlation>.md`
- `docs/v5-lab/proposals/source-correlation.md` or related proposal files

End each iteration with:

```text
Handoff:
- Evidence:
- Proposed backlog changes:
- Risks:
- Next task:
```

## Study Questions

- Can generated Verilog signals be traced back to V5 Python file/line/name?
- Can auto-inserted balance registers explain which signal and cycle delta
  created them?
- Does hierarchical compile preserve meaningful instance paths?
- Are generated names stable under non-semantic Python edits?
- What should `source_map.json` contain?
- How should timing reports or waveform names map back to V5 concepts?

## Acceptance Tests

Good proposals from this lane should include tests or future tests such as:

- Compile a small V5 design and assert generated source map entries exist.
- Verify a named V5 signal maps to MLIR op and Verilog signal.
- Verify balance register metadata names source signal and cycle delta.
- Verify non-semantic edits do not churn stable generated names.

## Starting Prompt

```text
Run the source-correlation lane.

Question: How can V5 generated Verilog preserve Python source and cycle
provenance well enough for timing/debug?

Read:
- docs/PyCircuit_V5_Spec.md
- compiler/frontend/pycircuit/v5.py
- compiler/mlir/lib/Emit/VerilogEmitter.cpp
- one simple V5 example and its generated MLIR/Verilog if available

Produce:
- docs/v5-lab/lanes/source-correlation.md
- docs/v5-lab/iterations/001-source-correlation.md
- a proposal draft for source/debug mapping if evidence is sufficient
```
