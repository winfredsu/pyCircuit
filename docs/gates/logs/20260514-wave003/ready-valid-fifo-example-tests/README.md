# Ready/Valid FIFO Example Tests Gate Evidence

Run ID: `20260514-wave003`
Lane: `ready-valid-fifo-example-tests`
Date: 2026-05-14

## Scope

- Added/updated an independently written V5 ready/valid FIFO fixture under `designs/examples/fifo_loopback/ready_valid_fifo.py`.
- Added focused unit coverage in `tests/unit/test_ready_valid_fifo_example.py` for reset/clear visibility, push/pop, simultaneous push/pop, optional empty pass-through, status outputs, overflow, and underflow.
- Did not add a public FIFO helper API, compiler syntax, compiler internals, or copied OpenTitan RTL/assertions.


## Affected files, contracts, and planned gates

Affected files:

- `designs/examples/fifo_loopback/ready_valid_fifo.py`
- `tests/unit/test_ready_valid_fifo_example.py`
- `docs/gates/logs/20260514-wave003/ready-valid-fifo-example-tests/`

Contract/decision impact:

- V5 examples/testbench behavior only: reset and clear visibility, ready/valid push/pop, simultaneous push/pop, optional empty pass-through, status outputs, overflow, and underflow.
- Related to the proposal contract in `docs/v5-lab/proposals/ready-valid-fifo-helpers.md` and review split in `docs/v5-lab/iterations/002-review-ready-valid-fifo.md`.
- No hardware semantic decision status changes, no compiler internals, no public FIFO helper API, no source-correlation-map, and no third-party RTL import.

Planned gates before handoff:

- source/license re-check for the OpenTitan study metadata while confirming independent authorship;
- focused FIFO unit tests;
- closest V5 unit subset;
- changed-file type check and syntax check;
- API hygiene and changed-file pre-commit;
- generated MLIR naming observation;
- `mkdocs build` because evidence docs changed.

## Source/license re-check

See `source-license-recheck.log`.

Result: raw upstream OpenTitan `LICENSE` and `hw/ip/prim/rtl/prim_fifo_sync.sv` at commit `d7237495dea39d79ccfabeece84c1ab376804ad7` were fetchable on 2026-05-14 and identify Apache-2.0 licensing. The implementation in this lane is independently written and does not copy upstream RTL or assertions.

## Generated artifact naming observation

See `generated-artifacts.log` and `ready_valid_fifo.mlir`.

Observed MLIR names include `rvfifo_data0`, `rvfifo_data1`, `rvfifo_count`, `wready`, `rvalid`, `rdata`, `depth`, `full`, `empty`, `overflow`, and `underflow`.

Verilog/C++ naming observation is blocked in this worker environment because `pycc` is not available on `PATH`.

## Gate logs

Command logs in this directory:

- `focused-pytest.log`
- `unit-subset.log`
- `compileall.log`
- `type-check.log`
- `api-hygiene.log`
- `precommit-files.log`
- `mkdocs-build.log`
- `examples-subset.log`
- `source-license-recheck.log`
- `generated-artifacts.log`
