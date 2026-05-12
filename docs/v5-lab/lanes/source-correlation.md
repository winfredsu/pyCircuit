# Source Correlation Lane — Wave 001

## Question

How can V5 generated Verilog preserve Python source and cycle provenance well
enough for timing/debug?

## Inputs Reviewed

- `docs/development/v5-improvement-agent-workflows.md`
- `docs/development/v5-improvement-agent-lanes/source-correlation.md`
- `docs/PyCircuit_V5_Spec.md`
- `compiler/frontend/pycircuit/v5.py`
- `compiler/frontend/pycircuit/jit.py`
- `compiler/frontend/pycircuit/jit_cache.py`
- `compiler/mlir/lib/Emit/VerilogEmitter.cpp`
- `designs/examples/arith/arith.py`
- `tests/unit/test_v5_state_signal.py`

## Current Provenance Path

| Stage | Evidence | What survives | What is lost |
| --- | --- | --- | --- |
| V5 eager frontend | `compiler/frontend/pycircuit/v5.py:125-140`, `:297-311` | Explicit register names and auto balance register names become circuit-scoped names. | No Python file, line, expression, source variable, source cycle, or balance reason metadata is recorded. |
| V5 hierarchy | `compiler/frontend/pycircuit/v5.py:215-295` | `domain.call(..., prefix=...)` preserves a submodule boundary as `pyc.instance` in hierarchical mode. | Instance outputs preserve cycle attributes in Python, but emitted MLIR has no source map for the callsite or returned dict key. |
| JIT frontend | `compiler/frontend/pycircuit/jit.py:449-497` and `compiler/frontend/pycircuit/jit_cache.py:270-310` | JIT already tracks `source_file`, `source_text`, `source_stem`, and absolute line numbers for diagnostics and generated names. | Eager V5 path does not reuse this machinery; `_make_compiled_module()` currently records `source_loc: 0`. |
| MLIR | Local probe below | Function `arg_names`, `result_names`, and `pyc.name` survive for ports, aliases, and named wires. | MLIR lacks a structured mapping from `pyc.name` or SSA values back to Python source/cycle metadata. |
| Verilog | `compiler/mlir/lib/Emit/VerilogEmitter.cpp:90-130`, `:503-560` | Port/result names are emitted from `arg_names`/`result_names`; `pyc.name` becomes net names and comments. | Comments only include `pyc.name` or op kind; no source/cycle/instance/source-map sidecar is emitted. |

## Local Artifact Probe

A temporary V5 probe compiled through `PYTHONPATH=compiler/frontend python`:

```python
from pycircuit import CycleAwareCircuit, CycleAwareDomain, cas, wire_of, compile_cycle_aware


def build(m: CycleAwareCircuit, domain: CycleAwareDomain, width: int = 8):
    x = cas(domain, m.input("x", width=width), cycle=0)
    y = cas(domain, domain.cycle(x, name="pipe_reg"), cycle=domain.cycle_index + 1)
    domain.next()
    z = x + y
    m.output("y", wire_of(y))
    m.output("z", wire_of(z))


print(compile_cycle_aware(build, name="source_corr_probe", eager=True, width=8).emit_mlir())
```

Observed MLIR excerpt:

```mlir
func.func @source_corr_probe(%clk: !pyc.clock, %rst: !pyc.reset, %x: i8) -> (i8, i8)
    attributes {arg_names = ["clk", "rst", "x"], result_names = ["y", "z"]} {
  %v1 = pyc.wire {pyc.name = "pipe_reg__next"} : i8
  %v4 = pyc.reg %clk, %rst, %v2, %v1, %v3 : i8
  %v5 = pyc.alias %v4 {pyc.name = "pipe_reg"} : i8
  %v6 = pyc.wire {pyc.name = "_v5_bal_1__next"} : i8
  %v9 = pyc.reg %clk, %rst, %v7, %v6, %v8 : i8
  %v10 = pyc.alias %v9 {pyc.name = "_v5_bal_1"} : i8
  %v11 = pyc.add %v10, %v5 : i8
  func.return %v5, %v11 : i8, i8
}
```

Interpretation:

- User ports and output names are stable enough for first-step correlation.
- Explicit `domain.cycle(..., name="pipe_reg")` preserves a meaningful register
  name in MLIR and should become a Verilog net/comment via the emitter.
- Auto balance registers expose only `_v5_bal_<n>`, which confirms that cycle
  alignment is visible but not explainable.
- Arithmetic results fall back to op-derived names such as `pyc_add_*` in
  Verilog unless they receive `pyc.name` metadata.

## Proposed Source Map Shape

A future `source_map.json` sidecar should be generated next to MLIR/Verilog and
keyed by stable logical IDs, not raw SSA numbers. Suggested entry shape:

```json
{
  "schema": "pycircuit.v5.source_map.v1",
  "top": "source_corr_probe",
  "entries": [
    {
      "id": "source_corr_probe.pipe_reg",
      "kind": "register",
      "python": {"file": "...", "line": 6, "name": "pipe_reg"},
      "v5": {"domain": "clk", "cycle": 1, "source_cycle": 0},
      "mlir": {"symbol": "source_corr_probe", "op": "pyc.reg", "name": "pipe_reg"},
      "verilog": {"module": "source_corr_probe", "net": "pipe_reg"}
    },
    {
      "id": "source_corr_probe._v5_bal_1",
      "kind": "balance_register",
      "python": {"file": "...", "line": 8, "expression": "x + y"},
      "v5": {"domain": "clk", "source_signal": "x", "from_cycle": 0, "to_cycle": 1, "delta": 1},
      "mlir": {"symbol": "source_corr_probe", "op": "pyc.reg", "name": "_v5_bal_1"},
      "verilog": {"module": "source_corr_probe", "net": "_v5_bal_1"}
    }
  ]
}
```

## Minimal Implementation Path

1. Add a small provenance object to V5 eager objects that records optional
   `source_file`, `line`, `user_name`, `domain`, `cycle`, and `reason`.
2. Capture source locations in eager mode via `inspect` frame lookup at public
   V5 API boundaries, starting with `CycleAwareDomain.cycle()` and
   `CycleAwareSignal._align()` balance insertion.
3. Attach structured metadata to MLIR ops as JSON-like attributes such as
   `pyc.source`, `pyc.cycle`, and `pyc.provenance_id` while keeping current
   `pyc.name` behavior unchanged.
4. Teach the Verilog/backend path to emit a source-map sidecar; keep Verilog
   comments short and optional so RTL remains readable.
5. Add regression tests that assert source-map entries are stable for named
   ports, explicit registers, balance registers, and hierarchical instances.

## Acceptance Tests For A Follow-Up PR

- Compile a minimal eager V5 design and assert `source_map.json` contains entries
  for an input, output, named `domain.cycle()` register, and auto balance
  register.
- Verify the named register entry links Python file/line/name, MLIR `pyc.name`,
  and Verilog net name.
- Verify a balance register entry records `source_signal`, `from_cycle`,
  `to_cycle`, and `delta`.
- Compile a hierarchical design and assert a `domain.call()` entry records the
  parent callsite, child module symbol, and instance name.
- Apply a non-semantic Python edit outside the probed expression and verify
  stable logical IDs do not churn.

## Handoff

- Evidence:
  - `docs/PyCircuit_V5_Spec.md:956-1024` documents hierarchical MLIR and
    `pyc.instance` boundaries.
  - `compiler/frontend/pycircuit/v5.py:125-140` names explicit cycle registers;
    `:297-311` creates `_v5_bal_<n>` auto balance registers without reason
    metadata; `:404-460` sets eager compiled-module `source_loc` to `0`.
  - `compiler/frontend/pycircuit/jit.py:449-497` and
    `compiler/frontend/pycircuit/jit_cache.py:270-310` show existing source
    file/line machinery that eager V5 can model after.
  - `compiler/mlir/lib/Emit/VerilogEmitter.cpp:90-130` and `:503-560` preserve
    port/result/`pyc.name` names but emit no structured source map.
  - Temporary probe showed `pipe_reg` and `_v5_bal_1` in generated MLIR, proving
    name-level correlation exists while cycle/source provenance is missing.
- Proposed backlog changes:
  - Promote “Source correlation for generated Verilog” to a reviewed proposal.
  - Add “Cycle balance explainability” as the first implementation slice under
    the same source-map schema.
  - Keep “Stable generated names” as a follow-up after the logical ID contract is
    reviewed.
- Risks:
  - Eager source-location capture via Python frames can be brittle; tests must
    lock down decorators, nested helpers, and generated/synthetic functions.
  - Raw line numbers may churn under harmless edits, so stable logical IDs must
    not depend only on line numbers.
  - Verilog comments are insufficient for tools; a sidecar is the safer contract.
- Next task:
  - Review `docs/v5-lab/proposals/source-correlation.md`, then schedule a tiny
    prototype that emits source-map entries for explicit and balance registers
    without changing shared compiler behavior in Wave 001.
