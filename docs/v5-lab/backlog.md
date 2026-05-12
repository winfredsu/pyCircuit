# PyCircuit V5 Improvement Lab Backlog

Wave 001 backlog after lane handoffs. Priority is based on user-facing impact,
implementation difficulty, semantic risk, and evidence maturity.

| Priority | Topic | Lane | Impact | Difficulty | Risk | Status | Evidence |
| ---: | --- | --- | --- | --- | --- | --- | --- |
| 1 | CycleAwareTb failure context/history diagnostics | testbench-ergonomics | high | medium | medium | proposal-needs-review | `proposals/cycleawaretb-ergonomics.md` |
| 2 | Ready/valid FIFO helpers/example and tests | rtl-porting/testbench | high | medium | high-semantic | proposal-needs-review | `proposals/ready-valid-fifo-helpers.md`, `iterations/001-open-rtl-porting.md` |
| 3 | Source correlation map for generated artifacts | source-correlation | high | high | high-semantic | proposal-needs-review | `proposals/source-correlation.md`, `iterations/001-source-correlation.md` |
| 4 | C++ simulation benchmark baseline | cpp-sim-perf | high | medium | medium | proposal-needs-review | `proposals/cpp-sim-performance.md`, `benchmarks.md` |
| 5 | Stable generated names | source-correlation | medium | medium | medium | seed | workflow backlog seed |
| 6 | Width and signedness diagnostics | rtl-porting/testbench | medium | medium | high-semantic | seed | RTL friction category |
| 7 | FSM and case DSL | rtl-porting | medium | high | high-semantic | seed | RTL friction category |
| 8 | Memory/regfile V5 wrappers | rtl-porting/cpp-sim-perf | medium | high | high-semantic | seed | workflow backlog seed |

## Next Review Tasks

- Run review lane on the four Wave 001 proposal drafts.
- Add accepted proposals to `docs/v5-lab/pr-queue.md` one branch/PR candidate at a time.
- Keep implementation branches separate and gate-first.
