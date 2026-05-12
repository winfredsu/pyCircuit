# RTL Porting Lane

This lane ports small slices of real open-source RTL to PyCircuit V5 and uses
the porting friction to discover missing or awkward V5 syntax, APIs, examples,
diagnostics, and testbench workflows.

## Scope

Focus on translating small, license-clear RTL modules such as:

- FIFO
- UART TX/RX
- SPI master
- round-robin arbiter
- ready/valid skid buffer
- simple pipeline stage
- small cache slice or crossbar fragment

Avoid copying large third-party source files into this repo. Record source URL,
commit/release, license, and short excerpts or summaries only.

## Workflow

1. Update or read `docs/v5-lab/rtl-source-inventory.md`.
2. Select a small open-source RTL slice, preferably 100-500 lines.
3. Reject GPL/LGPL, unclear, missing, or custom-license candidates as
   study-only unless the conductor explicitly assigns legal review.
4. Record upstream project, URL, commit/release, license, module path, and
   interface summary.
5. Read the RTL interface, state, timing, and testbench or README.
6. Write a V5 translation attempt or pseudo-code.
7. For every translation friction, record:
   - original RTL pattern
   - current V5 expression
   - pain point
   - proposed V5 improvement
   - whether this needs syntax, helper APIs, diagnostics, docs, or examples
8. If feasible, compile the V5 prototype and inspect generated MLIR/Verilog.
9. Suggest backlog updates to conductor.

## Required Outputs

Write only lane-owned files:

- `docs/v5-lab/lanes/rtl-porting.md`
- `docs/v5-lab/iterations/<NNN-open-rtl-porting>.md`
- `docs/v5-lab/proposals/<syntax-or-api-topic>.md`

End each iteration with:

```text
Handoff:
- Evidence:
- Proposed backlog changes:
- Risks:
- Next task:
```

## Porting Study Template

````markdown
# <Design Or Module> Porting Study

## Source

- Project:
- URL:
- Commit or release:
- License:
- License decision: porting-ok / study-only
- RTL module path:
- Approximate size:
- Interface family:
- Upstream testbench or reference:
- Why this slice was selected:

## Selected Slice

## Behavior Sketch

- State:
- Timing:
- Reset:
- Handshake or memory semantics:

## Original RTL Patterns

```systemverilog
// short excerpt or summarized pattern only
```

## V5 Translation Attempt

```python
# current V5 code or pseudo-code
```

## Translation Friction

| RTL pattern | Current V5 expression | Pain | Proposed V5 improvement |
| --- | --- | --- | --- |

## Generated Artifact Observations

## Backlog Updates
````

## Candidate Intake Policy

Prefer candidates that are small, well-tested, and permissively licensed:

- Apache-2.0, BSD, MIT, ISC, or Solderpad-style permissive licenses are good
  first choices.
- GPL/LGPL, unclear, missing, or custom licenses are study-only by default.
- SystemVerilog-heavy sources are useful when the goal is to expose pyCircuit V5
  gaps around packed/unpacked arrays, structs, ready/valid wiring, generate-like
  patterns, or debug naming.
- Do not copy large third-party files into pyCircuit. Keep the study to source
  metadata, short excerpts, behavior summaries, V5 pseudo-code, and friction
  tables.

Good first source pools:

- OpenTitan primitives or small IP fragments for FIFO, SRAM wrapper, CDC and
  primitive wrapper behavior.
- lowRISC Ibex small modules for decode/control/CSR-style hardware patterns.
- PULP Platform common cells or AXI fragments for arbiters, streams, FIFOs,
  AXI-Lite cuts and demuxes.
- PicoRV32 small control or interface slices for Verilog-only CPU-flavored
  patterns.
- FuseSoC Package Directory, FreeCores, and OpenCores-derived mirrors only after
  checking license, maintenance status and testbench quality per repository.

## Porting Ladder

Use this order for every selected slice:

1. Source record.
2. Behavior sketch.
3. Reference evidence from upstream docs or tests.
4. V5 pseudo-code or tiny prototype.
5. Translation friction table.
6. Generated MLIR/Verilog/C++ observations when compilation is feasible.
7. Proposal or backlog update with acceptance tests.

## Good Friction Categories

- FSM/state encoding
- `case` / priority mux / one-hot mux
- signedness and width inference
- packed/unpacked arrays
- multi-register update patterns
- ready/valid flow control
- memory/regfile wrappers
- module/interface wiring
- testbench stimulus and expect behavior
- generated Verilog debug naming

## Starting Prompt

```text
Run the rtl-porting lane.

Question: Port one small open RTL module to V5 pseudo-code/prototype and
identify missing syntax/API patterns.

First update docs/v5-lab/rtl-source-inventory.md. Choose a license-clear module
such as FIFO, UART TX/RX, SPI master, round-robin arbiter, ready/valid skid
buffer, or simple pipeline stage.

Produce:
- docs/v5-lab/lanes/rtl-porting.md
- docs/v5-lab/iterations/001-open-rtl-porting.md
- proposed backlog changes for syntax/API/testbench gaps
```
