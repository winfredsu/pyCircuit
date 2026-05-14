# V5 C++ Simulation Benchmarks

This file records the V5 C++ simulation benchmark contract. Measured results
remain intentionally deferred until a follow-up task adds an approved runner;
this contract PR is docs-only and must not edit the generated C++ runtime,
emitter, scripts, or tests.

## Contract Status

- Contract branch: `codex/v5-cpp-sim-benchmark-contract`
- First implementation branch after review: benchmark runner plus one tiny
  target, not an optimization branch
- Result evidence root: `docs/v5-lab/results/<run-id>/`
- Gate evidence root:
  `docs/gates/logs/<run-id>/cpp-sim-benchmark-contract/`
- First fixed result file:
  `docs/v5-lab/results/<run-id>/cpp-tiny-counter.json`
- First fixed target: `cpp-tiny-counter`
- Fixed seed: `1`
- Fixed cycle count: `100000` timed cycles after the reset/checker warm-up
- Reset/warm-up contract: two reset cycles, one untimed checker alignment
  cycle, then the fixed timed cycle window
- Required initial variants: `default`, `disable-instance-cache`,
  `disable-primitive-cache`, and `stats-on`
- Deferred variants: `trace-window`, `disable-versioned-input-cache`, and any
  large-target or optimization-specific dimension

Timing output is publishable only when all variants pass the same correctness
scoreboard for the same seed and stimulus transcript.

## Measurement Contract

Every benchmark result must include:

- `schema_version`
- `benchmark_id`
- `run_id`
- pyCircuit git revision and clean/dirty tree status
- benchmark target revision or source path
- host, OS, CPU model when available, compiler, compiler flags, and Python
  version
- generated C++ build command and run command
- stimulus description, deterministic seed, reset cycles, warm-up cycles, and
  timed cycle count
- variant name and variant compile/runtime environment
- generated C++ compile time in seconds
- simulation runtime in seconds and cycles/sec
- at least one overhead metric: binary size, peak memory, stats-output size, or
  trace/probe overhead
- correctness log path and pass/fail status
- evidence paths for stdout/stderr and generated JSON/Markdown summaries

Timing output is invalid unless the correctness gate passes first for every
reported variant.

## Result JSON Schema

The first runner must write a JSON object with these required top-level fields:

| Field | Type | Required contract |
| --- | --- | --- |
| `schema_version` | string | Start at `v5-cpp-bench-result-v1`. |
| `run_id` | string | Matches the result directory name under `docs/v5-lab/results/`. |
| `benchmark_id` | string | For the first runner, exactly `cpp-tiny-counter`. |
| `target` | object | Contains `name`, `source`, and `revision`. |
| `environment` | object | Contains host, OS, CPU if known, Python, compiler, and flags. |
| `stimulus` | object | Contains `seed`, `reset_cycles`, `warmup_cycles`, `timed_cycles`, and description. |
| `variants` | array | One object per measured variant; all variants use the same stimulus. |
| `correctness` | object | Contains aggregate pass/fail and repo-relative log paths. |
| `evidence` | object | Contains repo-relative paths to command logs and summaries. |

Each `variants[]` entry must include:

| Field | Type | Required contract |
| --- | --- | --- |
| `name` | string | One of the approved variant names for the run. |
| `build_command` | array/string | Reproducible generated C++ build command. |
| `run_command` | array/string | Reproducible generated C++ run command. |
| `compile_time_s` | number | Wall-clock generated C++ compile time. |
| `runtime_s` | number | Timed simulation runtime. |
| `cycles_per_s` | number | Derived from `timed_cycles / runtime_s`. |
| `overheads` | object | At least one of binary bytes, peak RSS bytes, stats bytes, or trace bytes. |
| `correctness_log` | string | Repo-relative log path for this variant. |
| `passed` | boolean | Must be true before timing is considered valid. |

## Reference Method Borrowed

| Source | Borrowed idea | Adaptation for pyCircuit V5 |
| --- | --- | --- |
| `/Users/sufang/Projects/hisi-contest-2025-pyc/flow/analysis/benchmark_cpp_vs_verilator.sh` at `60823c4` | Time C++ build, Verilator build, C++ run, and Verilator run separately. | Use generated V5 C++ output as the primary benchmark and Verilator/reference runs only as correctness/comparison evidence. |
| `/Users/sufang/Projects/hisi-contest-2025-pyc/flow/analysis/verify_perf.py` at `60823c4` | Check logs with a deterministic expected-output model before trusting performance results. | Require tiny/medium target scoreboards and deterministic seeds before reporting cycles/sec. |

## Planned Targets

| ID | Size | Design/example | Stimulus | Cycle count | Required metrics | Correctness gate | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `cpp-tiny-counter` | tiny | V5 counter/FSM smoke target | seed `1`, two reset cycles, one warm-up cycle, deterministic increment/check sequence | `100000` timed cycles | compile time, runtime, cycles/sec, binary size, optional stats-output size | generated C++ output log matches the independent counter scoreboard for every variant before timing is accepted | contract-ready |
| `cpp-medium-regfile` | medium | register-file or FIFO-style V5 example | deterministic reads/writes with hazards and idle periods | fixed by later contract update | compile time, cycles/sec, cache stats, binary size | cycle-by-cycle scoreboard for read/write or enqueue/dequeue outputs | planned after tiny target |
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
| Schema version | `v5-cpp-bench-result-v1` |
| Run ID | |
| Benchmark ID | `cpp-tiny-counter` |
| pyCircuit revision / tree status | |
| Target source / revision | |
| Host / OS / CPU / Python / compiler / flags | |
| Build command | |
| Run command | |
| Stimulus / seed | `seed=1` |
| Reset / warm-up / timed cycles | `2 / 1 / 100000` |
| Variant | |
| Correctness gate | |
| Generated C++ compile time | |
| Simulation runtime | |
| Throughput | |
| Binary size / memory / stats / trace overhead | |
| Stats counters | |
| Evidence paths | |
| Notes | |

## Wave 003 Contract Impact

This contract changes documentation only. It defines how future C++ simulation
benchmark evidence must be produced and reviewed, but it does not change V5
semantics, MLIR lowering, generated C++ behavior, runtime caches, public APIs,
or gate status for any existing decision.
