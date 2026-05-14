# Ready/Valid FIFO Example Tests Gate Evidence

Run ID: `20260514-wave003`
Lane: `ready-valid-fifo-example-tests`
Date: 2026-05-14

## Scope

- Added/updated an independently written V5 ready/valid FIFO fixture under `designs/examples/fifo_loopback/ready_valid_fifo.py`.
- Added focused unit coverage in `tests/unit/test_ready_valid_fifo_example.py` for reset/clear visibility, push/pop, simultaneous push/pop, optional empty pass-through, status outputs, overflow, and underflow.
- Did not add a public FIFO helper API, compiler syntax, compiler internals, or copied OpenTitan RTL/assertions.

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
