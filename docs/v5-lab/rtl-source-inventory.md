# RTL Source Inventory — V5 Improvement Lab

License gate: worker-2 must verify source URL, commit/tag, and license before using any candidate for porting evidence. GPL/LGPL/unclear/custom licenses are study-only unless user explicitly approves legal review.

## Candidate Intake Table

| Candidate | URL | Commit/tag | License | Module path | Approx LOC | Interface family | Reference quality | V5 friction target | License decision | Status |
| --- | --- | --- | --- | --- | ---: | --- | --- | --- | --- | --- |
| OpenTitan `prim_fifo_sync` | <https://github.com/lowRISC/opentitan> | `d7237495dea39d79ccfabeece84c1ab376804ad7` | Apache-2.0 (`LICENSE`, SPDX in file) | `hw/ip/prim/rtl/prim_fifo_sync.sv` | 242 | synchronous FIFO, ready/valid, reset/clear, optional pass-through | Good: source includes primitive assertions via `prim_fifo_assert.svh`; upstream tree has project-level build/test infrastructure | reset/clear semantics, ready/valid flow control, width/depth parameters, generated names for queue storage | porting-ok | **selected** |
| lowRISC Ibex `ibex_counter` | <https://github.com/lowRISC/ibex> | `9742d89f54fc297bed026841c8e68454ddfd7cc0` | Apache-2.0 (`LICENSE`, SPDX in file) | `rtl/ibex_counter.sv` | 111 | parameterized counter/control datapath | Medium: small self-contained module, covered by Ibex verification context rather than a narrow standalone testbench | width inference, optional generated output, enable/clear priority, synthesis-oriented parameterization | porting-ok | candidate |
| PULP common_cells `rr_arb_tree` | <https://github.com/pulp-platform/common_cells> | `63e1b679a70eca3a1d60d686bc1fa170ec08e1ab` | Solderpad Hardware License 0.51, Apache-2.0 option in license text | `src/rr_arb_tree.sv` | 321 | round-robin arbiter, request/grant, data muxing | Good: reusable common cell with package context; larger and more SystemVerilog-heavy than the first slice | priority mux/case structure, arrays, generate-like parameterization, one-hot grant diagnostics | porting-ok | candidate |

## Selected Slice

Selected for Wave 001: OpenTitan `prim_fifo_sync.sv` at commit `d7237495dea39d79ccfabeece84c1ab376804ad7`.

Reasons:

- It is inside the requested first-wave size target (242 lines) and has an Apache-2.0 license decision.
- Its public interface stresses V5-visible user ergonomics without requiring a whole subsystem: `clk_i`, `rst_ni`, `clr_i`, write-side `wvalid_i/wready_o/wdata_i`, read-side `rvalid_o/rready_i/rdata_o`, plus `full_o`, `depth_o`, and `err_o`.
- It exercises reset/clear behavior, depth/width parameters, a ready/valid queue, optional pass-through for empty FIFO behavior, and generated artifact naming for internal storage/pointers.
- It can be studied without copying upstream RTL into this repo; this wave records only metadata, behavior summary, pseudo-code, and friction.

Expected V5 surface stressed:

- reusable FIFO module authoring pattern,
- parameterized bit widths and depth counters,
- ready/valid testbench stimulus and expectations,
- clear-vs-reset precedence,
- generated Verilog/MLIR naming for queue storage and handshake logic.

## Intake Notes

- Do not copy large external RTL. Summarize behavior and use short excerpts only when necessary.
- Candidate metadata was verified with `git ls-remote` and raw upstream `LICENSE`/module headers on 2026-05-12.
- GPL/LGPL/unclear/custom-license candidates remain excluded from Wave 001 porting evidence unless the conductor schedules explicit legal review.
