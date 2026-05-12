# Proposal: CycleAwareTb Failure Context and Timeline Ergonomics

Lane: testbench-ergonomics
Wave: 001
Status: draft for review

## Problem

`CycleAwareTb` makes short V5 testbenches readable by hiding explicit `at=` cycle
arguments behind `tb.next()`. Larger tests still need custom helper layers and
manual diagnostic strings to explain what failed. Ready/valid and matrix-style
workflows already encode `cycle`, `lane`, and source metadata in ad hoc
`msg=...` strings, while pipeline and multi-clock tests lack a standard way to
show nearby stimulus history when an expectation fails.

## Evidence

- `compiler/frontend/pycircuit/v5.py` exposes `CycleAwareTb.expect(port, value,
  *, phase="post", msg=None)` and forwards directly to `Tb.expect` with the
  current cycle.
- `docs/PyCircuit_V5_Spec.md` documents the V5 testbench simulation pipeline,
  but not a watch/history or context-label failure workflow.
- `docs/TESTBENCH.md` documents `pre` and `post` phases for `Tb.expect`, but it
  is generic and not enough for V5 cycle-aware failure triage.
- `designs/BypassUnit/tb_bypass_unit.py` manually includes lane/source/cycle in
  expectation messages for many generated port names.
- `designs/examples/counter/tb_counter.py` and
  `designs/examples/pipeline_builder/tb_pipeline_builder.py` show the concise
  path that should remain unchanged.
- `designs/examples/multiclock_regs/tb_multiclock_regs.py` shows multiple clocks
  configured through the wrapper while `tb.cycle` remains global.

## Proposed change

Add an opt-in diagnostics layer over the existing `CycleAwareTb` operations.
Keep default behavior backward-compatible.

### Phase 1: context labels

Provide a structured way to attach metadata to expectations:

```python
with tb.context(lane=i, src=src):
    tb.expect("i20_srcL_data", exp_data)
```

or, if a context manager is too large for the first slice:

```python
tb.expect("i20_srcL_data", exp_data, labels={"lane": i, "src": src})
```

Failure output should include:

- port name
- expected value
- actual value
- cycle
- phase
- context labels

### Phase 2: watch/history

Add opt-in watched signals and recent-cycle history:

```python
tb.watch("i20_srcL_data")
tb.history(depth=3)
```

On failure, include nearby watched values and/or recent drives/expects. Keep this
opt-in to avoid large generated payloads.

### Phase 3: tabular stimulus helper

After diagnostic behavior is tested, add sugar that expands to existing calls:

```python
tb.timeline([
    {"drive": {"enable": 1}, "expect": {"count": 1}},
    {"expect": {"count": 2}},
])
```

This helper should not change backend semantics. It should be validated by
comparing emitted low-level operations with equivalent imperative calls.

## Acceptance tests

- A failing expectation includes stable semantic fields: port, expected, actual,
  cycle, phase, and labels.
- Existing `tb.expect(port, value, msg=...)` behavior remains backward-compatible.
- Context labels compose with explicit `msg` without dropping either field.
- Watch/history output is absent by default and present only when enabled.
- A table/timeline helper emits the same drive/expect operation sequence as the
  imperative API.
- A ready/valid regression can remove manual `cycle={cyc}` message construction
  while preserving equivalent failure detail.

## Non-goals

- Do not redesign V5 hardware authoring syntax.
- Do not change `domain.next()` or signal occurrence semantics.
- Do not require all testbenches to adopt a tabular DSL.
- Do not enable full waveform dumping by default.
- Do not solve generated C++ versus SystemVerilog mismatch analysis beyond
  providing better failure context and an artifact handoff point.

## Implementation slice

1. Add focused root tests for failure message fields around `CycleAwareTb.expect`.
2. Add context-label plumbing with no behavior change for existing tests.
3. Add opt-in history only after the stable failure fields are covered.
4. Add table helper in a separate branch or follow-up PR.

## Required gates

- Python unit tests for new `CycleAwareTb` diagnostics.
- Existing V5 example smoke tests that use `CycleAwareTb` continue to compile.
- Backend-specific assertions check semantic fields rather than exact full-line
  formatting when possible.
- Documentation update for the V5 spec and/or `docs/TESTBENCH.md` after the API
  is accepted.

## Risks and mitigations

| Risk | Mitigation |
| --- | --- |
| Backend output formatting is brittle. | Test stable fields, not entire output lines. |
| History payload becomes too large. | Keep watch/history opt-in and bounded by depth. |
| Context API grows into a broad DSL. | Land diagnostics first; keep timeline helper separate. |
| Multi-clock semantics are ambiguous. | Treat clock/domain labels as metadata until a domain-aware stepping design is reviewed. |
