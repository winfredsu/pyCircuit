# OpenTitan `prim_fifo_sync` Porting Study

## Source

- Project: OpenTitan
- URL: <https://github.com/lowRISC/opentitan>
- Commit or release: `d7237495dea39d79ccfabeece84c1ab376804ad7`
- License: Apache-2.0
- License decision: porting-ok for metadata, summaries, and small pseudo-code study
- RTL module path: `hw/ip/prim/rtl/prim_fifo_sync.sv`
- Approximate size: 242 lines
- Interface family: synchronous FIFO, ready/valid write and read channels, reset/clear, status outputs
- Upstream testbench or reference: upstream source includes primitive FIFO assertion support via `prim_fifo_assert.svh`; full upstream RTL/test infrastructure was not imported
- Why this slice was selected: it is small, license-clear, realistic, and stresses V5 reset, handshake, parameter width, testbench, and generated artifact ergonomics.

## Selected Slice

The selected slice is the public FIFO shell and behavior of OpenTitan `prim_fifo_sync`:

- parameters: data width, FIFO depth, optional pass-through on empty FIFO, optional zero output when empty, and secure pointer/count behavior;
- inputs: clock, active-low reset, explicit clear, write valid/data, read ready;
- outputs: write ready, read valid/data, full, depth, and error.

No third-party RTL source file was copied into this repository. The study uses source metadata, interface summary, behavior sketch, and V5 pseudo-code.

## Behavior Sketch

- State: queue storage, read/write pointer or equivalent occupancy state, depth counter, and status flags.
- Timing: on each clock, accepted writes occur when write valid and write ready; accepted reads occur when read valid and read ready; simultaneous read/write preserves occupancy when both sides fire.
- Reset: reset initializes queue state and status outputs; explicit clear has reset-like queue emptying semantics during normal operation.
- Handshake semantics: `wready` deasserts when full; `rvalid` asserts when data is available or when pass-through allows empty-FIFO read-side visibility from an incoming write; `rdata` may be zeroed while empty depending on the parameter.
- Error semantics: overflow/underflow or inconsistent transaction conditions should be representable as an explicit status or assertion target.

## Original RTL Patterns

Summarized patterns only:

- parameterized module with derived depth width;
- active-low reset plus explicit clear input;
- two ready/valid interfaces with simultaneous push/pop handling;
- optional pass-through datapath from write data to read data when empty;
- status outputs derived from occupancy and transaction conditions;
- assertion hooks for FIFO protocol invariants.

## V5 Translation Attempt

```python
# Pseudo-code only: Wave 001 does not edit shared examples/tests/compiler files.

class SyncFifoV5(Module):
    def __init__(self, width: int = 16, depth: int = 4, pass_through: bool = True):
        self.clk = Clock()
        self.rst_n = Input(Bits(1))
        self.clear = Input(Bits(1))

        self.wvalid = Input(Bits(1))
        self.wready = Output(Bits(1))
        self.wdata = Input(Bits(width))

        self.rvalid = Output(Bits(1))
        self.rready = Input(Bits(1))
        self.rdata = Output(Bits(width))

        self.full = Output(Bits(1))
        self.depth = Output(Bits(depth.bit_length()))
        self.err = Output(Bits(1))

        # Desired authoring shape: declare queue storage and occupancy once,
        # then express push/pop/pass-through behavior in cycle-aware form.
        queue = RegArray(Bits(width), depth)      # proposed/placeholder shape
        rd_ptr = Reg(Bits(depth.bit_length()))
        wr_ptr = Reg(Bits(depth.bit_length()))
        used = Reg(Bits((depth + 1).bit_length()))

        push = self.wvalid & self.wready
        pop = self.rvalid & self.rready
        empty = used == 0

        self.wready <<= used != depth
        self.rvalid <<= (used != 0) | (pass_through & self.wvalid)
        self.full <<= used == depth
        self.depth <<= used

        with self.cycle():
            if ~self.rst_n | self.clear:
                used.next = 0
                rd_ptr.next = 0
                wr_ptr.next = 0
            elif push & ~pop:
                queue[wr_ptr].next = self.wdata
                wr_ptr.next = wr_ptr + 1
                used.next = used + 1
            elif pop & ~push:
                rd_ptr.next = rd_ptr + 1
                used.next = used - 1
            elif push & pop:
                queue[wr_ptr].next = self.wdata
                wr_ptr.next = wr_ptr + 1
                rd_ptr.next = rd_ptr + 1

        self.rdata <<= Mux(empty & pass_through, self.wdata, queue[rd_ptr])
        self.err <<= (self.wvalid & ~self.wready) | (self.rready & ~self.rvalid)
```

The pseudo-code intentionally uses placeholder names such as `RegArray`, `cycle`, and `Mux` where the exact accepted V5 API should be confirmed in a follow-up prototype branch.

## Translation Friction

| RTL pattern | Current V5 expression | Pain | Proposed V5 improvement |
| --- | --- | --- | --- |
| Ready/valid transaction pair (`valid & ready`) on both sides | Manual intermediate signals in pseudo-code | Easy to duplicate or misname transaction conditions in examples/tests | Provide a small documented ready/valid helper idiom or example fixture |
| Reset and explicit clear both empty queue state | Repeated branch in each register update | Reset-vs-clear priority must be hand-audited | Add a FIFO example that demonstrates reset/clear precedence and expected waveform behavior |
| Derived `DepthW` and `depth + 1` occupancy width | Manual Python width math in pseudo-code | Width mistakes are likely when `Depth` is not a power of two | Add diagnostics/docs for derived counter widths in parameterized modules |
| Queue storage indexed by read/write pointers | Placeholder `RegArray`/manual array shape | Need to confirm ergonomic V5 syntax for register arrays or memory-like storage | Prototype a minimal register-array/storage example before compiler edits |
| Optional empty pass-through datapath | Explicit mux and TB special cases | This is behaviorally subtle and should be tested cycle-by-cycle | Add acceptance tests covering empty FIFO pass-through and non-pass-through modes |
| Status outputs and protocol errors | Manual invariants in pseudo-code | Error output semantics and assertions need a clean TB idiom | Add CycleAwareTb-style invariant examples for `full`, `depth`, and `err` |

## Generated Artifact Observations

Not generated in Wave 001. The claims file forbids shared compiler/API/code/example/test edits in this wave, and the V5 pseudo-code includes placeholder shapes that need a follow-up prototype before generated MLIR/Verilog/C++ observations would be meaningful.

Expected follow-up observations once a tiny prototype is scheduled:

- generated names for queue storage, read/write pointers, and occupancy counter;
- Verilog readability for ready/valid transaction terms;
- compile-time diagnostics for width/depth mismatches;
- whether C++ simulation preserves easy cycle-level debugging for FIFO state.

## Backlog Updates

Suggested for conductor application:

1. Ready/valid FIFO example/helper backlog item with OpenTitan `prim_fifo_sync` as evidence.
2. Reset/clear precedence acceptance tests for a tiny FIFO prototype.
3. Derived width/depth diagnostics or documentation task.
4. Generated artifact naming review for queue storage and handshake terms.

Handoff:
- Evidence: verified three upstream candidates in `docs/v5-lab/rtl-source-inventory.md`; selected Apache-2.0 OpenTitan `prim_fifo_sync` at commit `d7237495dea39d79ccfabeece84c1ab376804ad7`; recorded source record, behavior sketch, reference evidence, pseudo-code, friction table, and generated-artifact deferral.
- Proposed backlog changes: add ready/valid FIFO helper/example, reset/clear precedence tests, derived width/depth diagnostics/docs, and generated artifact naming review for FIFO internals.
- Risks: pseudo-code includes placeholder V5 API forms and was not compiled; upstream assertion details are summarized only; legal/license decision is based on upstream metadata observed on 2026-05-12 and should be rechecked before any source import.
- Next task: schedule a reviewed follow-up prototype that implements the smallest compileable V5 FIFO slice and targeted CycleAwareTb tests without broad compiler changes.
