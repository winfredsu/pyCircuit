# Iteration 001 — C++ Simulation Performance

## Inputs

- Worker: `worker-3`
- Lane: `cpp-sim-perf`
- pyCircuit revision: `f89bd2f`
- Reference checkout: `/Users/sufang/Projects/hisi-contest-2025-pyc`
- Reference revision: `60823c4`
- Allowed writes: lane log, iteration note, optional benchmarks file, optional
  C++ sim performance proposal under `docs/v5-lab/`.

## Question

Using the hisi contest checkout as a reference, what benchmark method and first
optimization hypotheses should pyCircuit V5 use for generated C++ model
simulation performance?

## Observations

1. The lane workflow requires benchmark-driven conclusions and explicitly says
   not to infer C++ model performance from generated Verilog alone.
2. The reference project separates build timing, run timing, and correctness
   checking. Its benchmark shell compares C++ simulation and Verilator runtime,
   while its Python verifier checks expected vs received packets using a
   deterministic traffic model.
3. pyCircuit already has C++-simulation-oriented primitives and generated model
   controls that should be measured before new runtime changes:
   - generated `_pyc_sim_stats` counters for instance/primitive eval calls and
     cache skips;
   - macros to disable instance, primitive, or versioned input caches;
   - testbench stepping helpers including fast single-clock paths;
   - trace/VCD registration paths whose overhead should be measured.
4. Existing system smoke coverage builds a counter for both C++ and Verilator,
   which is a good tiny correctness anchor but not yet a throughput benchmark.

## Benchmark Methodology

Wave 001 should land no shared scripts. The proposed follow-up benchmark harness
should:

- generate or build the target C++ model in a fresh output directory;
- compile with a fixed compiler command and optimization level;
- run deterministic stimulus for a fixed cycle count;
- run a correctness checker before reporting timing;
- record compile time, run time, cycles/sec, binary size or memory, cache stats,
  host/toolchain, pyCircuit revision, and benchmark target revision;
- support A/B dimensions for cache-on/off and trace-on/off.

## Candidate Targets

| Target | Status | Why first |
| --- | --- | --- |
| Counter/FSM tiny target | ready as follow-up | Existing C++/Verilator smoke path can anchor correctness and stepping overhead. |
| Register file/FIFO medium target | ready as follow-up candidate | Exercises memory/primitive eval and wider wires without requiring external RTL intake. |
| hisi-style NoC/router or future ported RTL slice | defer until harness exists | Useful for hierarchy and traffic, but too large to introduce before tiny/medium baselines. |

## Candidate Optimizations

1. **Benchmark harness first**: create a reproducible runner before changing
   emitter/runtime code.
2. **Eval-cache A/B**: use existing generated stats and disable macros to find
   redundant eval opportunities.
3. **Testbench fast stepping**: ensure generated/simple C++ tests can use the
   single-clock fast path when safe.
4. **Trace/probe overhead controls**: measure bounded tracing against trace-off
   runs with identical scoreboards.
5. **Compile-time/TU-size tracking**: record build latency and binary size so
   runtime wins do not regress developer iteration time.

## Deferrals

- No compiler/runtime/shared test files were edited in this wave.
- No measured baseline numbers were recorded because the assigned stop condition
  is methodology plus optimization hypotheses; measurement should happen in the
  next task with an approved harness.

## Handoff

- Evidence:
  - `docs/development/v5-improvement-agent-lanes/cpp-sim-perf.md` requires
    C++-specific metrics, benchmark commands, host/toolchain, and correctness
    gates.
  - `/Users/sufang/Projects/hisi-contest-2025-pyc` at `60823c4` demonstrates a
    build/run timing split and independent packet-log verifier methodology.
  - pyCircuit revision `f89bd2f` has existing C++ smoke coverage, generated sim
    stats/cache controls, testbench stepping helpers, and trace paths to use as
    first benchmark dimensions.
- Proposed backlog changes:
  - Promote “C++ sim benchmark harness” ahead of runtime optimization work.
  - Add follow-up items for eval-cache A/B, single-clock fast stepping,
    trace/probe overhead, and C++ compile-time/TU-size tracking.
- Risks:
  - Methodology without measured numbers can be overconfident; the next task
    must record real baselines before implementation.
  - The reference checkout path is local and may not exist on CI or other
    developers' machines.
  - Cache or fast-step optimizations can introduce stale outputs or edge-order
    bugs unless every timing run is scoreboard-gated.
- Next task:
  - Add a lane-approved benchmark harness and run tiny + medium baselines,
    recording JSON/Markdown results in `docs/v5-lab/benchmarks.md`.
