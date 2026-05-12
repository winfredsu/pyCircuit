# C++ Simulation Performance Baseline

## User Scenario

A PyCircuit V5 user wants generated C++ simulation to be fast enough for local
cycle-accurate iteration while still matching Verilator/reference behavior. The
user needs a repeatable way to answer: did a runtime/emitter change make the C++
model faster without changing simulation results?

## Current V5 Code

```python
# Current user workflow shape: build a V5/CycleAware testbench to C++
# and run the generated model or system smoke target.
python -m pycircuit.cli build path/to/tb.py --target cpp --out-dir build/cpp
```

Current C++ surfaces already include useful measurement hooks and controls:

- generated simulation stats counters for instance and primitive eval/cache
  behavior;
- cache-disabling compile macros for A/B runs;
- `Testbench` stepping helpers, including fast single-clock stepping;
- trace/VCD/probe paths that can be measured as optional overhead.

## Pain Point

C++ simulation performance work is not yet anchored by a standard benchmark
contract. Without fixed targets, correctness gates, environment metadata, and
A/B dimensions, optimization proposals can become anecdotal or regress
simulation semantics while improving wall-clock time on one machine.

## Proposed V5 Code

```bash
# Proposed follow-up user/developer workflow shape, not implemented in Wave 001.
python -m pycircuit.cli build designs/examples/counter/tb_counter.py \
  --target cpp \
  --out-dir build/v5-cpp-bench/counter

python tools/run_v5_cpp_bench.py \
  --target counter \
  --cycles 100000 \
  --seed 1 \
  --variant default \
  --variant disable-instance-cache \
  --variant trace-window \
  --out docs/v5-lab/results/cpp-tiny-counter.json
```

The exact CLI/script location should be decided in a follow-up implementation
proposal. Wave 001 only records the methodology and acceptance contract.

## Semantics

The benchmark harness must not change design semantics. It should:

1. build the selected generated C++ model;
2. run deterministic stimulus for a fixed cycle count;
3. run an independent correctness checker;
4. record timing only after the correctness checker passes;
5. compare A/B variants against the same stimulus and expected-output log.

## MLIR/Verilog Impact

No MLIR or Verilog semantics change is proposed for the first step. Verilator or
reference RTL runs may be used as a comparison/correctness anchor, but the lane
must not infer generated C++ model speed from Verilog-only observations.

## Simulation And Testbench Impact

The proposal formalizes simulation measurement around three benchmark sizes:

- tiny counter/FSM for reset, commit, and stepping overhead;
- medium regfile/FIFO-style target for value copies, memory/FIFO primitives, and
  cache behavior;
- large traffic/router or future ported RTL slice for hierarchy, trace/probe,
  and compile-time pressure.

Benchmark variants should include default cache behavior, disabled cache
macros, runtime stats on/off, and bounded trace/probe on/off.

## Compatibility

The first implementation can be additive: a benchmark runner and documentation
only. Runtime/emitter optimizations should be separate follow-up PRs after the
baseline records real numbers.

## Minimal Implementation Path

1. Add a small benchmark runner that writes JSON and Markdown result summaries.
2. Add a tiny counter/FSM target with a deterministic checker.
3. Add a medium regfile/FIFO-style target with hazards and idle cycles.
4. Wire A/B variants to existing cache macros and `PYC_SIM_STATS` controls.
5. Record the first baseline in `docs/v5-lab/benchmarks.md` or a conductor-
   approved results location.
6. Only then prototype one optimization at a time.

## Acceptance Tests

- Tiny and medium benchmark targets pass their correctness scoreboards before
  timing is reported.
- Cache-on/cache-off variants produce identical output logs for the same seed.
- Trace-off and bounded trace-on variants produce identical functional outputs.
- Benchmark output records pyCircuit revision, host/toolchain, build/run
  command, cycle count, compile time, runtime, cycles/sec, and one overhead
  metric.
- Existing C++/Verilator smoke/system gate still passes for the touched target.

## Risks And Non-goals

Risks:

- A benchmark can reward unrealistic static stimulus unless seeds include input
  changes, idle periods, and hazards.
- Fast stepping and eval-cache changes can introduce stale outputs or edge-order
  bugs.
- Local absolute reference paths are not portable to CI.

Non-goals:

- No runtime/emitter optimization is implemented in Wave 001.
- No public API change is proposed yet.
- No large external design is copied into pyCircuit.
