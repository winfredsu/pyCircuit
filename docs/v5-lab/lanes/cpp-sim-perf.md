# C++ Simulation Performance Lane — Wave 001

## Assignment

- Worker: `worker-3`
- Lane workflow: `docs/development/v5-improvement-agent-lanes/cpp-sim-perf.md`
- Research question: using `hisi-contest-2025-pyc` as a reference, define a
  baseline C++ simulation benchmark methodology and first optimization
  hypotheses.
- Wave constraint: no shared compiler/runtime/API/example/test edits in this
  wave; shared changes are recorded as prototype plans only.

## Scope Boundaries

This lane studies generated C++ model simulation only. The workflow explicitly
requires C++-specific benchmark evidence, so Verilog/Verilator behavior can be
used as a correctness reference or comparison target but not as a substitute for
C++ model performance measurement.

Allowed Wave 001 outputs for this lane:

- `docs/v5-lab/lanes/cpp-sim-perf.md`
- `docs/v5-lab/iterations/001-cpp-sim-perf.md`
- `docs/v5-lab/benchmarks.md`
- `docs/v5-lab/proposals/cpp-sim-performance.md`

## Reference Intake

| Item | Value |
| --- | --- |
| pyCircuit revision | `f89bd2f` |
| Reference repo path | `/Users/sufang/Projects/hisi-contest-2025-pyc` |
| Reference repo revision | `60823c4` |
| Reference methodology observed | `flow/analysis/benchmark_cpp_vs_verilator.sh` times C++ build, Verilator build, C++ simulation, Verilator simulation, and prints a speed comparison. |
| Reference correctness style observed | `flow/analysis/verify_perf.py` parses simulation logs into expected/received packet multisets and reports missing, extra, and malformed outputs. |
| PyCircuit C++ surfaces observed | generated C++ emitter/runtime/testbench support includes `compiler/mlir/lib/Emit/CppEmitter.cpp`, `runtime/cpp/pyc_change_detect.hpp`, `runtime/cpp/pyc_tb.hpp`, and C++ smoke coverage in `tests/system/test_smoke_system.py`. |

Borrowed methodology, not code:

1. Use the same stimulus and scoreboard across C++ and Verilator/reference runs.
2. Separate build time from run time.
3. Record host/toolchain, git revisions, cycle count, and run command.
4. Keep correctness checking independent of wall-clock timing.
5. Report a speed comparison only after both outputs pass the same scoreboard.

## Benchmark Plan

The first C++ simulation benchmark suite should be committed as a follow-up
implementation task, not edited into shared scripts during Wave 001.

| Size | Target | Purpose | Baseline command shape | Correctness gate |
| --- | --- | --- | --- | --- |
| tiny | V5 counter / simple FSM | Exercise clock/reset/commit overhead and `Testbench` stepping overhead. | `python -m pycircuit.cli build designs/examples/counter/tb_counter.py --target cpp --out-dir <tmp>` followed by generated C++ compile/run timing. | Existing counter expected outputs and generated C++ vs Verilator smoke parity. |
| medium | register file or FIFO-style example | Exercise wider wires, memories/FIFOs, primitive cache, and repeated combinational eval. | Build generated C++ with cache on/off macro variants and `PYC_SIM_STATS=1`. | Cycle-by-cycle read/write scoreboard; same seed and operation trace across variants. |
| large | hisi-style NoC/router slice or later V5 ported RTL slice | Exercise hierarchy, many ports, trace/probe overhead, and compile-unit size. | Reference-style C++ vs Verilator timing harness with shared traffic generator. | Multiset scoreboard like the reference `verify_perf.py`; trace-off and trace-on parity. |

Required metrics per benchmark:

- generated C++ compile time
- simulation throughput in cycles/sec
- one overhead metric: binary size, peak memory, or trace/probe overhead
- cache/stat counters when available: instance eval calls, cache skips,
  primitive eval calls, primitive cache skips, fallback iterations

## First Optimization Hypotheses

| Hypothesis | Expected win | Risk | Affected files for future prototype | Correctness gate |
| --- | --- | --- | --- | --- |
| Add a reproducible C++ benchmark harness around existing generated C++ smoke/examples before changing runtime code. | Converts perf work from anecdotal to A/B comparable; no direct runtime win. | Harness can overfit one toy design or hide correctness failures behind timing output. | New docs/scripts/tests to be approved by conductor; no Wave 001 shared edits. | Scoreboard must pass before timing is reported; host/toolchain and revisions recorded. |
| Use generated `_pyc_sim_stats` plus cache-disabling macros to quantify instance and primitive eval-cache value. | Identifies redundant eval and cache-hit opportunities without semantic changes. | Cache counters can be misleading if stimulus is too static or if output copying dominates. | `compiler/mlir/lib/Emit/CppEmitter.cpp`, generated C++ compile flags in follow-up. | Run cache-on/cache-off variants with identical outputs and deterministic seeds. |
| Standardize single-clock fast stepping for simple generated testbenches. | Reduces two-edge/full-step overhead for common cycle tests. | Multi-clock, phase-shifted, or trace-observation tests may require conservative fallback. | `runtime/cpp/pyc_tb.hpp` and generated testbench glue in follow-up. | Single-clock fast path equals normal stepping on counter/FSM/regfile tests; multi-clock tests stay on fallback. |
| Measure trace/probe overhead as a first-class benchmark dimension. | Prevents debug features from silently dominating simulation time. | Turning traces off can mask bugs that only appear when probes are registered/dumped. | Trace/testbench harness only in follow-up. | Trace-off and bounded trace-on runs produce the same functional scoreboard. |
| Treat generated C++ compile time and TU size as performance outputs. | Reduces edit-compile-run latency for large generated models. | Inlining/cache policy changes can improve compile time but slow runtime or hide hierarchy debug names. | `compiler/mlir/tools/pycc.cpp`, `compiler/mlir/lib/Emit/CppEmitter.cpp` in follow-up. | Compile-time benchmark plus runtime throughput and source/probe-name stability checks. |

## Proposed Prototype Plan

1. Create a benchmark runner that emits a JSON/Markdown result per target with
   revision, host/toolchain, command, cycle count, compile time, run time,
   cycles/sec, binary size, and optional stats counters.
2. Add one tiny target and one medium target before any optimizer change.
3. Add cache-control A/B dimensions using existing macros/env knobs.
4. Require every timing result to reference a correctness log.
5. Only after the harness lands, prototype one optimization at a time.

## Handoff

- Evidence:
  - `docs/development/v5-improvement-agent-workflows.md` defines cpp-sim-perf
    ownership and requires lane-local outputs plus handoff evidence.
  - `docs/development/v5-improvement-agent-lanes/cpp-sim-perf.md` requires
    benchmark-driven C++ metrics: compile time, throughput, and one overhead
    metric.
  - Reference repo `/Users/sufang/Projects/hisi-contest-2025-pyc` at `60823c4`
    contains a C++ vs Verilator benchmark shape and independent log checker.
  - pyCircuit at `f89bd2f` already exposes generated simulation stats and cache
    toggles in generated C++ surfaces, plus `Testbench` stepping helpers.
- Proposed backlog changes:
  - Add a high-priority “C++ sim benchmark harness” item before runtime
    optimization PRs.
  - Track cache A/B, testbench fast stepping, trace/probe overhead, and compile
    time/TU-size as separate follow-up items.
- Risks:
  - The absolute reference checkout may be unavailable on other hosts.
  - Perf data is not yet measured in Wave 001; this is a methodology and
    prototype-plan artifact.
  - C++/Verilator comparisons must not conflate behavioral-model speed with RTL
    correctness unless both pass the same scoreboard.
- Next task:
  - Implement the benchmark harness and run tiny + medium baselines with
    cache-on/cache-off and trace-off/trace-on dimensions, then update
    `docs/v5-lab/benchmarks.md` with measured results.
