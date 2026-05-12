# Proposal: Ready/Valid FIFO Authoring Helper and Example

## Summary

Add a small V5 ready/valid FIFO authoring path, either as documentation plus an example or as a narrowly scoped helper API, using the Wave 001 OpenTitan `prim_fifo_sync` porting study as evidence.

## Motivation

The RTL porting study exposed repeated friction around transaction naming, reset/clear precedence, derived widths, pass-through behavior, and cycle-by-cycle testbench expectations. A FIFO is a compact real-world design that can validate these authoring surfaces without importing external RTL.

## Scope

- Create a tiny V5 FIFO prototype that compiles and has focused tests.
- Demonstrate write/read ready-valid transactions, simultaneous push/pop, reset/clear, empty pass-through, `full`, `depth`, and error/invariant behavior.
- Record generated artifact naming observations for queue storage, pointers, occupancy, and handshake signals.

## Non-goals

- Do not port OpenTitan `prim_fifo_sync.sv` line-for-line.
- Do not import large third-party RTL into this repository.
- Do not change public V5 syntax unless the prototype shows a concrete missing capability and review accepts it.
- Do not bundle unrelated source-correlation, C++ performance, or broader testbench redesign work into this proposal.

## Acceptance Tests

A follow-up implementation should add or update tests that prove:

1. reset initializes FIFO state and clear empties an occupied FIFO;
2. write-only, read-only, and simultaneous write/read cycles update depth correctly;
3. empty pass-through behavior is deterministic when enabled and absent when disabled;
4. `full`, `rvalid`, `wready`, and `depth` match expected cycle traces;
5. invalid overflow/underflow attempts are reported by an explicit error signal or assertion-style expectation;
6. generated Verilog/MLIR signal names are stable enough to debug queue storage and handshake terms.

## Implementation Plan

1. Start with a docs/examples-only prototype branch; do not edit compiler internals.
2. Encode the minimal FIFO using existing V5 constructs; if register-array or derived-width ergonomics block the prototype, record the smallest missing API.
3. Add focused CycleAwareTb coverage for transaction traces.
4. Inspect generated MLIR/Verilog/C++ artifacts and record naming/diagnostic observations.
5. Return to review before scheduling any compiler/API changes.

## Evidence

- Inventory: `docs/v5-lab/rtl-source-inventory.md`
- Lane log: `docs/v5-lab/lanes/rtl-porting.md`
- Iteration note: `docs/v5-lab/iterations/001-open-rtl-porting.md`

## Risks

- The Wave 001 pseudo-code uses placeholder V5 API names and must be reconciled with existing V5 constructs.
- FIFO helper APIs could become too broad; the first branch should prefer example/test coverage before new abstractions.
- License remains porting-ok for summaries and independently written examples, but any source import must go through a fresh license/source review.
