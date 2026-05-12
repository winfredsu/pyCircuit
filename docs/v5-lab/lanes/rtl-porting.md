# RTL Porting Lane — Wave 001

Worker: `worker-2`  
Workflow: `docs/development/v5-improvement-agent-lanes/rtl-porting.md`  
Iteration: `docs/v5-lab/iterations/001-open-rtl-porting.md`

## Scope Guard

This lane stayed inside Wave 001 documentation/prototype scope:

- wrote only `docs/v5-lab/rtl-source-inventory.md`, this lane log, the Wave 001 iteration note, and one proposal;
- did not edit compiler/API/code/example/test files;
- did not copy large third-party RTL into the repository;
- treated shared implementation changes as proposed follow-up work only.

## Selected Porting Slice

OpenTitan `prim_fifo_sync.sv` was selected from the inventory because it is small enough for a first porting study, permissively licensed, and representative of practical hardware authoring friction:

- Source: <https://github.com/lowRISC/opentitan>
- Commit: `d7237495dea39d79ccfabeece84c1ab376804ad7`
- License: Apache-2.0
- Module path: `hw/ip/prim/rtl/prim_fifo_sync.sv`
- Approximate size: 242 lines
- Interface family: synchronous FIFO with write/read ready-valid handshakes, reset, clear, depth/full/error outputs
- Reference evidence: upstream file includes primitive FIFO assertion support through `prim_fifo_assert.svh`; no upstream RTL was imported into this repo

## Porting Ladder Evidence

1. **Source record** — captured in `docs/v5-lab/rtl-source-inventory.md` with three candidates and one selected slice.
2. **Behavior sketch** — captured in the Wave 001 iteration note.
3. **Reference evidence** — upstream license/module metadata and assertion include were verified; exact commit and module path are recorded.
4. **V5 pseudo-code/prototype plan** — documented as pseudo-code only because Wave 001 forbids shared implementation edits.
5. **Friction table** — recorded in the iteration note and summarized below.
6. **Generated artifact observations** — deferred; no compile prototype was checked in because this wave is documentation/prototype-only.
7. **Proposal/backlog** — proposal recorded at `docs/v5-lab/proposals/ready-valid-fifo-helpers.md`.

## Friction Summary

| RTL pattern | Current V5 expression | Pain | Proposed V5 improvement |
| --- | --- | --- | --- |
| Ready/valid FIFO shell with mirrored write/read ports | User manually defines scalar signals, handshake conditions, queue registers, depth counter, and TB transactions | Easy to mis-order handshake updates or produce inconsistent `valid/ready` expectations | Add documented FIFO/stream helper pattern and acceptance tests for ready-valid transaction behavior |
| Reset plus explicit `clr_i` behavior | Pseudo-code must spell out reset and clear priority in every register update | Reset/clear precedence is a common source of off-by-one or stale-valid bugs | Add docs/examples showing reset-vs-clear precedence and generated signal names |
| Parameterized `Width`, `Depth`, derived `DepthW` | User must derive counter widths and storage element widths manually | Width/depth mistakes surface late in generated artifacts rather than at authoring time | Improve diagnostics or helper APIs for derived width/depth checks |
| Optional pass-through when FIFO is empty | User must encode bypass mux between incoming data and stored data | The behavior is compact in RTL but verbose in V5 pseudo-code and TB expectations | Provide an example and compile/test fixture for bypassing queue behavior |
| `full_o`, `depth_o`, and `err_o` status outputs | User must maintain consistent status outputs alongside queue updates | Invariants span several outputs and are hard to assert ergonomically | Add TB helpers for cycle-by-cycle expect blocks and invariant checks |

## Proposed Backlog Changes

For conductor application to `docs/v5-lab/backlog.md`:

1. Add a V5 ready/valid FIFO example or guide using the OpenTitan FIFO study as source evidence.
2. Add acceptance tests for reset/clear precedence and pass-through behavior in a small FIFO prototype.
3. Add diagnostics or documentation for derived counter widths (`DepthW`) and storage width consistency.
4. Track generated artifact naming for FIFO storage, depth, and handshake signals as a source/debug follow-up.

## Proposal

- `docs/v5-lab/proposals/ready-valid-fifo-helpers.md`

Handoff:
- Evidence: `docs/v5-lab/rtl-source-inventory.md` now records three verified candidates, selected OpenTitan `prim_fifo_sync`, license decisions, and expected V5 stress surface; `docs/v5-lab/iterations/001-open-rtl-porting.md` records source, behavior sketch, V5 pseudo-code, friction table, and deferral of generated artifact observations.
- Proposed backlog changes: prioritize a small ready/valid FIFO example/helper path, reset/clear precedence tests, derived width diagnostics/docs, and generated naming review for FIFO internals.
- Risks: pseudo-code was not compiled in Wave 001; upstream FIFO assertion behavior was summarized rather than imported; exact V5 API shape needs confirmation before implementation because shared code/tests were out of scope.
- Next task: conductor should review the proposal, then schedule a tiny follow-up prototype branch that compiles a minimal V5 FIFO slice and adds focused tests if accepted.
