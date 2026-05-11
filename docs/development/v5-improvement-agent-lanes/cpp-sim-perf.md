# C++ Simulation Performance Lane

This lane studies how to get faster generated C++ model simulation for
PyCircuit V5. It should be benchmark-driven: establish reproducible baselines,
identify bottleneck hypotheses, and propose small optimizations with correctness
gates.

## Scope

Focus on:

- generated C++ model simulation path
- generated C++ compile time
- simulation throughput in cycles/sec
- runtime value representation, scheduling, tracing, reset/commit bookkeeping
- benchmark methodology and A/B measurement

Do not infer C++ model performance from generated Verilog alone.

## Reference Repository

Use `/Users/sufang/Projects/hisi-contest-2025-pyc` when available as a reference
source for contest flow, C++ simulation, benchmark scripts, profiling patterns,
and performance recording methods.

When using it, record:

- reference repo path
- reference repo commit
- relevant files or scripts
- what methodology was borrowed
- equivalent pyCircuit V5 command or benchmark generated from that method

Do not copy large code blocks from the reference repo into pyCircuit.

## Workflow

1. Inspect `hisi-contest-2025-pyc` if present.
2. Select benchmark targets:
   - tiny: counter/FSM/FIFO
   - medium: pipeline/regfile/arbiter/crossbar
   - large: existing V5 example or ported RTL slice
3. Record build command, run command, stimulus, cycle count, git revision,
   host/toolchain, and environment limitations.
4. Measure at least:
   - generated C++ compile time
   - simulation throughput, cycles/sec
   - one of binary size, memory use, trace/probe overhead
5. Inspect generated C++ and runtime for bottleneck hypotheses:
   - redundant eval
   - excessive value copies
   - wide value representation
   - branch-heavy scheduling
   - missed inlining or over-inlining
   - trace/probe overhead
   - reset/commit bookkeeping
   - avoidable hierarchy calls
6. Propose 2-4 optimizations with expected win, risk, affected files,
   acceptance benchmark, and correctness gate.
7. If prototyping, change one optimization only and keep A/B benchmark results.

## Required Outputs

Write only lane-owned files:

- `docs/v5-lab/lanes/cpp-sim-perf.md`
- `docs/v5-lab/benchmarks.md` if conductor assigned it to this lane
- `docs/v5-lab/iterations/<NNN-cpp-sim-perf>.md`
- `docs/v5-lab/proposals/cpp-sim-performance.md`

End each iteration with:

```text
Handoff:
- Evidence:
- Proposed backlog changes:
- Risks:
- Next task:
```

## Performance Study Template

````markdown
# <Benchmark> C++ Simulation Performance Study

## Target

- Design/example:
- Git revision:
- Reference repo:
- Reference repo revision:
- Reference paths:
- Build command:
- Run command:
- Stimulus:
- Cycle count:
- Host/toolchain:

## Baseline Metrics

| Metric | Value | Notes |
| --- | --- | --- |
| Generated C++ compile time | | |
| Simulation throughput | | cycles/sec |
| Binary size | | optional |
| Memory use | | optional |
| Trace/probe overhead | | optional |

## Bottleneck Hypotheses

## Candidate Optimizations

| Optimization | Expected win | Risk | Affected files | Correctness gate |
| --- | --- | --- | --- | --- |

## A/B Result

## Follow-up Backlog Items
````

## Starting Prompt

```text
Run the cpp-sim-perf lane.

Question: Using hisi-contest-2025-pyc as reference, define baseline C++ sim
benchmark methodology and first optimization hypotheses.

Read:
- /Users/sufang/Projects/hisi-contest-2025-pyc README/scripts/benchmark files
  if present
- pyCircuit generated C++ or runtime files relevant to V5 examples

Produce:
- docs/v5-lab/lanes/cpp-sim-perf.md
- docs/v5-lab/benchmarks.md if assigned by conductor
- docs/v5-lab/iterations/001-cpp-sim-perf.md
- candidate perf proposals with correctness gates
```
