# Testbench Ergonomics Lane — Wave 001

Owner: worker-4
Lane workflow: `docs/development/v5-improvement-agent-lanes/testbench-ergonomics.md`
Scope: documentation/proposal only; no shared compiler, API, example, or test edits.

## Question

What `CycleAwareTb` improvements would make V5 cycle-accurate tests easier to
write, easier to read, and easier to debug when an expectation fails?

## Evidence base

- The V5 spec describes `CycleAwareTb` as the current-cycle wrapper around `Tb`:
  `tb.next()` advances an implicit cycle, and `drive` / `expect` lower to `Tb`
  calls with the current `at=` value.
- The implementation in `compiler/frontend/pycircuit/v5.py` exposes a compact API:
  `clock`, `reset`, `timeout`, `next`, `cycle`, `drive`, `expect`, `finish`,
  `print`, `sva_assert`, and `random`.
- `docs/TESTBENCH.md` documents low-level `Tb` observation phases (`pre` and
  `post`) and generic `@testbench` lowering, but it does not describe a V5
  history/watch workflow for failed cycle-aware expectations.
- Repository usage is example-driven: a local scan found `CycleAwareTb` in 65
  Python files, with 25 files under `designs/examples/` and no files under the
  repository root `tests/` tree.

## Representative workflows reviewed

### 1. Counter smoke workflow

File: `designs/examples/counter/tb_counter.py`

Current shape:

```python
tb = CycleAwareTb(t)
tb.clock("clk")
tb.reset("rst", cycles_asserted=2, cycles_deasserted=1)
tb.timeout(int(p["timeout"]))
tb.drive("enable", 1)
tb.expect("count", 1)
tb.next()
tb.expect("count", 2)
```

Observations:

- The implicit-cycle API is readable for short linear tests.
- Repeated comments such as `# --- cycle N ---` carry cycle narrative outside
  the API. If comments drift from `tb.next()`, the failure context becomes less
  reliable than the test author's intent.
- A failed `expect` can name the port and actual/expected value through backend
  output, but there is no first-class recent-cycle context or watched signal set.

### 2. Pipeline valid workflow

File: `designs/examples/pipeline_builder/tb_pipeline_builder.py`

Current shape:

```python
tb.drive("in_payload_word", 5)
tb.drive("in_ctrl_valid", 1)
tb.expect("out_ctrl_valid", 0)
tb.finish(at=int(p["finish"]))
```

Observations:

- The test is concise, but latency intent is implicit. A future multi-cycle
  pipeline check must manually sequence `tb.next()` and duplicate related drives
  and expects.
- There is no tabular stimulus/expectation form to show a pipeline timeline at a
  glance.
- A mismatch handoff to generated C++/Verilog is manual: the author must infer
  which cycle and neighboring inputs matter.

### 3. Ready/valid and bypass matrix workflow

File: `designs/BypassUnit/tb_bypass_unit.py`

Current shape:

- `_drive_cycle(tb, spec, *, lanes)` loops over many generated port names.
- `_expect_cycle(tb, cyc, spec, *, lanes)` loops over expected data/hit/select
  ports and manually adds messages such as `cycle={cyc}`.

Observations:

- The test already needs user-defined helpers to make port matrices manageable.
- The explicit `cyc` parameter in `_expect_cycle` duplicates `tb.cycle`; this is
  a symptom that current failure context is not rich enough by default.
- Manual message strings encode structured metadata (`lane`, `src`, `cycle`) that
  the API could carry as labels or context.

### 4. Multi-clock smoke workflow

File: `designs/examples/multiclock_regs/tb_multiclock_regs.py`

Current shape:

```python
tb.clock("clk_a")
tb.clock("clk_b")
tb.reset("rst_a", cycles_asserted=2, cycles_deasserted=1)
tb.drive("rst_b", 0)
tb.finish(at=int(p["finish"]))
```

Observations:

- `CycleAwareTb` can configure multiple clocks because it passes through to
  `Tb.clock`, but the implicit `tb.cycle` is global.
- There is no lane-specific helper for domain-relative steps or for explaining
  which clock/reset domain a failed expectation belongs to.

## Pain points

| Pain point | Evidence | Impact |
| --- | --- | --- |
| Repeated cycle boilerplate | Counter tests use comments plus `tb.next()` for the timeline. | Drift between comments and actual cycle can hide intent. |
| Weak failure locality | Ready/valid helpers manually add `cycle`, `lane`, and `src` to messages. | Every complex test reinvents diagnostic labels. |
| No watch/history API | Spec and implementation expose `print`, but no structured recent-cycle history. | Failures are harder to debug without nearby drives/expects. |
| No tabular workflow | Pipeline and bypass scenarios are natural tables but use imperative calls. | Longer tests become helper-heavy and less reviewable. |
| Multi-clock ambiguity | Multiple clocks can be configured, but cycle tracking is one global counter. | Domain-specific timing intent is not explicit in failures. |
| Backend mismatch handoff is ad hoc | The spec shows the C++/SV flow, but no failure artifact bundle. | C++/Verilog mismatches require manual reconstruction. |

## Proposed workflow improvements

1. **Expectation context labels**
   - Add an optional context mechanism, for example
     `with tb.context(lane=i, src=src): ...` or `tb.expect(..., labels={...})`.
   - Backend failure messages should include labels, current cycle, phase, port,
     expected value, and actual value.

2. **Watch/history capture**
   - Add a lightweight `tb.watch("port", label=None)` plus an opt-in history
     depth such as `tb.history(depth=3)`.
   - On failed `expect`, report recent watched drives/expects around the failing
     cycle.

3. **Tabular cycle stimulus**
   - Add a prototype helper that expands rows into the existing `drive`, `expect`,
     and `next` calls without changing backend semantics.
   - Keep it as sugar over current operations so acceptance tests can compare the
     emitted testbench payload against equivalent imperative calls.

4. **Reset/domain helper notes**
   - Document a V5 reset pattern that states what `cycles_asserted` and
     `cycles_deasserted` imply for cycle 0 observations.
   - For multi-clock tests, require explicit domain/clock labels in the proposed
     context API before attempting implementation.

## Proposed acceptance tests

- A failed `CycleAwareTb.expect` reports port name, expected value, actual value,
  cycle, phase, and any active context labels.
- When history is enabled, a failed expectation reports watched signal values for
  at least the previous, current, and next recorded cycle when available.
- A tabular stimulus helper emits the same low-level `Tb.drive` / `Tb.expect`
  payload as an equivalent imperative test.
- A ready/valid example can express lane/source labels without manually building
  `msg=f"... cycle={cyc}"` strings.
- A multi-clock example can label expectations with their intended clock/reset
  domain without changing generated hardware semantics.

## Prototype plan only

This wave should not edit `compiler/frontend/pycircuit/v5.py`, examples, or
root tests. The safe next implementation slice is:

1. Add a small unit test that constructs an intentionally failing `CycleAwareTb`
   expectation and snapshots the failure text or emitted backend assertion text.
2. Add the minimal context-label plumbing in `CycleAwareTb.expect` and `Tb.expect`
   lowering.
3. Add a separate sugar-only table helper once failure diagnostics are covered.

Handoff:

- Evidence: reviewed V5 spec `CycleAwareTb` API, low-level `docs/TESTBENCH.md`, implementation API in `compiler/frontend/pycircuit/v5.py`, and representative counter, pipeline, ready/valid, and multi-clock testbenches; local scan found 65 Python files with `CycleAwareTb`, 25 under `designs/examples/`, and none under root `tests/`.
- Proposed backlog changes: prioritize `CycleAwareTb` failure-context labels/history before tabular stimulus; add dedicated root regression tests for `CycleAwareTb` diagnostics; document reset and multi-clock expectation labeling.
- Risks: backend assertion text may differ between C++ and SystemVerilog; history capture can increase payload size if enabled by default; multi-clock semantics need explicit design before API changes.
- Next task: review `docs/v5-lab/proposals/cycleawaretb-ergonomics.md`, then schedule a tiny diagnostics-only implementation branch with acceptance tests before adding table helpers.
