# Source Correlation For Generated Verilog

## User Scenario

A V5 user runs synthesis, timing analysis, or waveform debug on generated
Verilog and sees a generated net such as `_v5_bal_1` or `pyc_add_3`. They need to
map that object back to the Python source expression, V5 signal name, logical
cycle, and hierarchy path that created it.

## Current V5 Code

```python
from pycircuit import CycleAwareCircuit, CycleAwareDomain, cas, wire_of


def build(m: CycleAwareCircuit, domain: CycleAwareDomain, width: int = 8):
    x = cas(domain, m.input("x", width=width), cycle=0)
    y = cas(domain, domain.cycle(x, name="pipe_reg"), cycle=domain.cycle_index + 1)
    domain.next()
    z = x + y
    m.output("y", wire_of(y))
    m.output("z", wire_of(z))
```

Current MLIR preserves some names:

```mlir
%v5 = pyc.alias %v4 {pyc.name = "pipe_reg"} : i8
%v10 = pyc.alias %v9 {pyc.name = "_v5_bal_1"} : i8
%v11 = pyc.add %v10, %v5 : i8
```

## Pain Point

The existing path provides partial name correlation but not source/cycle
provenance:

- explicit V5 names can become `pyc.name`, but there is no Python file/line map;
- auto balance registers expose `_v5_bal_<n>` without explaining source signal or
  cycle delta;
- arithmetic temporaries fall back to op-derived names;
- eager V5 compiled modules currently record `source_loc: 0`;
- Verilog emitter comments are human hints, not a machine-readable debug
  contract.

## Proposed V5 Code

The user-facing V5 code should not need to change for the first implementation.
Instead, compilation should gain an opt-in source map output:

```python
circ = compile_cycle_aware(build, name="source_corr_probe", eager=True, width=8)
mlir = circ.emit_mlir()
# Future CLI/API option emits source_map.json next to MLIR/Verilog artifacts.
```

A later ergonomic layer can expose a helper for locating a generated object:

```bash
pycircuit source-map lookup --artifact build/source_map.json --verilog-net _v5_bal_1
```

## Semantics

The source map should describe debug provenance only. It must not change V5
hardware semantics, MLIR lowering semantics, Verilog netlist behavior, or cycle
alignment rules.

Each entry should carry:

- stable logical ID;
- kind (`input`, `output`, `register`, `balance_register`, `comb`, `instance`);
- Python source location and optional source expression/name;
- V5 domain, cycle, and hierarchy path;
- MLIR symbol/op/name;
- Verilog module/net/instance when backend artifacts are emitted;
- balance-specific fields: source signal, from cycle, to cycle, and delta.

## MLIR/Verilog Impact

Minimal MLIR additions:

- preserve current `arg_names`, `result_names`, and `pyc.name` behavior;
- add structured attributes such as `pyc.provenance_id`, `pyc.source`, and
  `pyc.cycle` where enough data exists;
- start with explicit `domain.cycle()` registers and auto balance registers.

Minimal Verilog/backend additions:

- keep existing short comments unchanged or additive;
- emit a sidecar `source_map.json` from MLIR/backend metadata;
- avoid relying on comments as the only machine-readable interface.

## Simulation And Testbench Impact

No simulation behavior should change. The source map can improve testbench
failures later by linking observed waveform names and cycle mismatches to V5
source locations, but that should be a follow-up after the sidecar schema is
stable.

## Compatibility

- Backward compatible for existing V5 code: no required syntax changes.
- Existing generated Verilog should remain equivalent unless source-map emission
  is explicitly requested.
- Existing `pyc.name` naming behavior should remain the first correlation layer.
- If source metadata is unavailable, entries should degrade gracefully to names,
  hierarchy, and MLIR/Verilog anchors.

## Minimal Implementation Path

1. Add internal provenance metadata to `CycleAwareSignal`/wire-producing helpers
   without changing public API semantics.
2. Capture source locations at selected eager V5 public API boundaries using
   Python frame inspection, starting with `CycleAwareDomain.cycle()`.
3. Extend `CycleAwareDomain.delay_to()` to record balance reason metadata:
   source signal, from cycle, to cycle, and delta.
4. Thread metadata into MLIR attributes next to existing `pyc.name`.
5. Add backend or frontend source-map JSON emission behind an opt-in flag.
6. Add tests before broadening to arithmetic temporaries and hierarchy.

## Acceptance Tests

- Compile a small eager V5 design and assert the source map contains entries for
  input `x`, output `z`, and named register `pipe_reg`.
- Verify `pipe_reg` maps to a Python file/line/name, MLIR `pyc.name`, and
  generated Verilog net name.
- Verify `_v5_bal_1` maps to `kind = balance_register`, `source_signal = x`,
  `from_cycle = 0`, `to_cycle = 1`, and `delta = 1`.
- Compile a hierarchical design and verify a `domain.call()` instance entry maps
  parent callsite, child module symbol, and instance name.
- Re-run after a non-semantic Python edit outside the relevant expression and
  assert stable logical IDs for the same logical objects.

## Risks And Non-goals

Risks:

- Python frame-based source capture can be fragile under decorators, wrappers,
  generated functions, or interactive sessions.
- Stable logical IDs need a reviewed contract to avoid churn in downstream debug
  tools.
- Metadata threading crosses frontend, MLIR, and backend boundaries, so the first
  PR should be intentionally small.

Non-goals:

- Do not redesign V5 syntax.
- Do not change cycle-balancing semantics.
- Do not require Verilog comments for machine-readable correlation.
- Do not implement broad timing-report ingestion in the first source-map PR.
