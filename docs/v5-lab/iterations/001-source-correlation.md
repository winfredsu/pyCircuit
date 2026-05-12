# Iteration 001 — Source Correlation

## Goal

Audit the current Python → MLIR → Verilog path for source, signal, cycle, and
hierarchy provenance, then draft a bounded source-map proposal.

## Method

1. Reviewed the source-correlation lane workflow and Wave 001 ownership rules.
2. Inspected V5 eager frontend paths for named registers, balance registers, and
   hierarchical `domain.call()` handling.
3. Inspected existing JIT source-location helpers to identify reusable patterns.
4. Compiled a temporary eager V5 probe to MLIR without modifying repository
   compiler/API/example/test files.
5. Converted the evidence into a source-map schema and acceptance-test plan.

## Observations

### Ports and explicit names survive

The current MLIR includes `arg_names` and `result_names`, and the Verilog emitter
uses them for module ports. Explicit `domain.cycle(..., name="pipe_reg")` creates
`pyc.name = "pipe_reg"`, which the emitter also uses for net naming/comments.

### Cycle balancing is visible but not explainable

`CycleAwareSignal._align()` delegates to `CycleAwareDomain.delay_to()`, which
creates `_v5_bal_<n>` registers. These registers show up in MLIR, but there is no
metadata explaining which source operand was delayed, from which cycle, or why.

### Eager V5 lacks source metadata despite JIT support

The JIT path already tracks source file, source text, stem, and line offsets for
diagnostics and name generation. The eager V5 compiled-module helper currently
sets `source_loc` to `0`, so eager examples cannot produce source/cycle maps
without new metadata capture.

### Hierarchy has a useful anchor

The V5 spec and frontend preserve `domain.call()` boundaries as `pyc.instance` in
hierarchical mode. That gives the source map a natural place to connect parent
callsites, child module symbols, and instance names.

## Proposed Artifact

Drafted `docs/v5-lab/proposals/source-correlation.md` with:

- user scenario for timing/debug back-annotation,
- current observed V5 behavior,
- proposed `source_map.json` shape,
- MLIR/Verilog impact,
- minimal implementation path,
- acceptance tests,
- risks and non-goals.

## Verification Commands

```bash
PYTHONPATH=compiler/frontend python /tmp/source_corr_probe.py
```

Result: PASS. The probe emitted MLIR containing `arg_names`, `result_names`,
`pyc.name = "pipe_reg"`, and `_v5_bal_1` balance register names.

```bash
grep -n "source_loc\|_v5_bal\|pyc.name" compiler/frontend/pycircuit/v5.py compiler/mlir/lib/Emit/VerilogEmitter.cpp
```

Result: PASS. Confirmed eager `source_loc` placeholder, balance register naming,
and Verilog `pyc.name` handling.

## Handoff

- Evidence:
  - `compiler/frontend/pycircuit/v5.py:125-140`, `:297-311`, and `:404-460`
    identify current naming and eager source metadata gaps.
  - `compiler/frontend/pycircuit/jit.py:449-497` and
    `compiler/frontend/pycircuit/jit_cache.py:270-310` show reusable source-file
    and line-number infrastructure.
  - `compiler/mlir/lib/Emit/VerilogEmitter.cpp:90-130` and `:503-560` show the
    current port/result/`pyc.name` correlation path.
  - Temporary eager MLIR probe confirmed that explicit names and auto balance
    names survive into MLIR while source/cycle reasons do not.
- Proposed backlog changes:
  - Mark `Source correlation for generated Verilog` as proposal-ready pending
    review lane feedback.
  - Add first implementation slice: `source_map.json` for named registers and
    auto balance registers.
  - Track hierarchy callsite correlation as the second slice after the sidecar
    schema is accepted.
- Risks:
  - Source-location capture in eager Python may be noisy under wrappers or
    helper functions.
  - Stable IDs require a deliberate contract; using only file/line would churn.
  - Emitting source maps from pycc may require a cross-boundary metadata design
    between Python frontend, MLIR, and backend.
- Next task:
  - Have review lane validate the proposal and acceptance tests, then schedule a
    tiny prototype plan for metadata-only source-map emission.
