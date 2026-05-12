# V5 C++ Simulation Benchmarks

This file records the Wave 001 cpp-sim-perf benchmark methodology. Measured
results are intentionally deferred until a follow-up task adds an approved
runner; Wave 001 did not edit shared scripts or tests.

## Measurement Contract

Every benchmark result must include:

- pyCircuit git revision and benchmark target revision
- host, OS, compiler, compiler flags, and Python version
- generated C++ build command and run command
- stimulus description and deterministic seed when applicable
- cycle count or equivalent operation count
- generated C++ compile time
- simulation runtime and cycles/sec
- at least one overhead metric: binary size, peak memory, or trace/probe
  overhead
- correctness log path and pass/fail status

Timing output is invalid unless the correctness gate passes first.

## Reference Method Borrowed

| Source | Borrowed idea | Adaptation for pyCircuit V5 |
| --- | --- | --- |
| `/Users/sufang/Projects/hisi-contest-2025-pyc/flow/analysis/benchmark_cpp_vs_verilator.sh` at `60823c4` | Time C++ build, Verilator build, C++ run, and Verilator run separately. | Use generated V5 C++ output as the primary benchmark and Verilator/reference runs only as correctness/comparison evidence. |
| `/Users/sufang/Projects/hisi-contest-2025-pyc/flow/analysis/verify_perf.py` at `60823c4` | Check logs with a deterministic expected-output model before trusting performance results. | Require tiny/medium target scoreboards and deterministic seeds before reporting cycles/sec. |

## Planned Targets

| ID | Size | Design/example | Stimulus | Cycle count | Required metrics | Correctness gate | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `cpp-tiny-counter` | tiny | V5 counter/FSM smoke target | deterministic reset and increment sequence | TBD by harness | compile time, cycles/sec, binary size | existing expected counter behavior plus generated C++ vs Verilator smoke parity | planned |
| `cpp-medium-regfile` | medium | register-file or FIFO-style V5 example | deterministic reads/writes with hazards and idle periods | TBD by harness | compile time, cycles/sec, cache stats, binary size | cycle-by-cycle scoreboard for read/write or enqueue/dequeue outputs | planned |
| `cpp-large-traffic` | large | hisi-style traffic/router slice or later ported RTL slice | deterministic all-to-all or ready/valid traffic | TBD after harness | compile time, cycles/sec, trace overhead, cache stats | independent multiset/packet scoreboard and optional Verilator comparison | deferred |

## A/B Dimensions

| Dimension | Variant A | Variant B | Purpose |
| --- | --- | --- | --- |
| Instance eval cache | default | `-DPYC_DISABLE_INSTANCE_EVAL_CACHE` | Quantify hierarchy cache benefit and stale-output risk. |
| Primitive eval cache | default | `-DPYC_DISABLE_PRIMITIVE_EVAL_CACHE` | Quantify FIFO/memory primitive cache benefit. |
| Versioned input cache | default | `-DPYC_DISABLE_VERSIONED_INPUT_CACHE` | Compare per-port version tracking with direct value comparison. |
| Runtime stats | stats off | `PYC_SIM_STATS=1` plus stats output | Measure instrumentation overhead and collect eval/cache counters. |
| Trace/probe | trace off | bounded trace/probe on | Quantify debug overhead and verify trace parity. |

## Result Template

| Field | Value |
| --- | --- |
| Benchmark ID | |
| pyCircuit revision | |
| Target revision | |
| Host/toolchain | |
| Build command | |
| Run command | |
| Stimulus/seed | |
| Cycle count | |
| Correctness gate | |
| Generated C++ compile time | |
| Simulation runtime | |
| Throughput | |
| Binary size / memory / trace overhead | |
| Stats counters | |
| Notes | |
