# PyCircuit V5 Improvement Lab Backlog

Wave 002 backlog after independent proposal review. Priority is based on
user-facing impact, implementation difficulty, semantic risk, and evidence
maturity.

| Priority | Topic | Lane | Impact | Difficulty | Risk | Status | Evidence |
| ---: | --- | --- | --- | --- | --- | --- | --- |
| 1 | CycleAwareTb context-label failure diagnostics | testbench-ergonomics | high | medium | medium | queued-for-user-review | `proposals/cycleawaretb-ergonomics.md`, `iterations/002-review-cycleawaretb-ergonomics.md`, `pr-queue.md` |
| 2 | Ready/valid FIFO example and tests | rtl-porting/testbench | high | medium | high-semantic | queued-for-user-review | `proposals/ready-valid-fifo-helpers.md`, `iterations/002-review-ready-valid-fifo.md`, `rtl-source-inventory.md`, `pr-queue.md` |
| 3 | Source correlation map named-register spike | source-correlation | high | high | high-semantic | queued-for-user-review | `proposals/source-correlation.md`, `iterations/002-review-source-correlation.md`, `pr-queue.md` |
| 4 | C++ simulation benchmark contract/schema | cpp-sim-perf | high | low | medium | queued-for-user-review | `proposals/cpp-sim-performance.md`, `iterations/002-review-cpp-sim-performance.md`, `benchmarks.md`, `pr-queue.md` |
| 5 | C++ simulation benchmark runner and tiny baseline | cpp-sim-perf | high | medium | medium | deferred-until-contract | `iterations/002-review-cpp-sim-performance.md` |
| 6 | CycleAwareTb watch/history diagnostics | testbench-ergonomics | medium | medium | medium | deferred | `proposals/cycleawaretb-ergonomics.md` |
| 7 | Ready/valid FIFO helper API | rtl-porting/testbench | medium | medium | high-semantic | deferred-until-example-evidence | `iterations/002-review-ready-valid-fifo.md` |
| 8 | Source correlation balance/hierarchy/arithmetic coverage | source-correlation | high | high | high-semantic | deferred-until-schema-spike | `iterations/002-review-source-correlation.md` |
| 9 | Stable generated names | source-correlation | medium | medium | medium | seed | workflow backlog seed |
| 10 | Width and signedness diagnostics | rtl-porting/testbench | medium | medium | high-semantic | seed | RTL friction category |
| 11 | FSM and case DSL | rtl-porting | medium | high | high-semantic | seed | RTL friction category |
| 12 | Memory/regfile V5 wrappers | rtl-porting/cpp-sim-perf | medium | high | high-semantic | seed | workflow backlog seed |

## Next Review Tasks

- User-review the four `pr-queue.md` local branch candidates before implementation.
- Keep implementation branches separate and gate-first.
- For semantic branches, identify affected pyc4.0 decision IDs and archive gate
  evidence under `docs/gates/logs/<run-id>/`.
