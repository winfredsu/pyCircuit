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

1. Select a small open-source RTL slice, preferably 100-500 lines.
2. Record upstream project, URL, commit/release, license, module path, and
   interface summary.
3. Read the RTL interface, state, timing, and testbench or README.
4. Write a V5 translation attempt or pseudo-code.
5. For every translation friction, record:
   - original RTL pattern
   - current V5 expression
   - pain point
   - proposed V5 improvement
   - whether this needs syntax, helper APIs, diagnostics, docs, or examples
6. If feasible, compile the V5 prototype and inspect generated MLIR/Verilog.
7. Suggest backlog updates to conductor.

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
- RTL module path:
- Approximate size:

## Selected Slice

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

Choose a license-clear module such as FIFO, UART TX/RX, SPI master,
round-robin arbiter, ready/valid skid buffer, or simple pipeline stage.

Produce:
- docs/v5-lab/lanes/rtl-porting.md
- docs/v5-lab/iterations/001-open-rtl-porting.md
- proposed backlog changes for syntax/API/testbench gaps
```
