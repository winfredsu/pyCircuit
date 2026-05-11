# Testbench Ergonomics Lane

This lane studies how `CycleAwareTb` and V5 testing workflows can become easier
to write, easier to read, and much easier to debug when expectations fail.

## Scope

Focus on:

- `CycleAwareTb`
- `Tb`
- V5 examples with testbenches
- cycle-accurate drive/expect ergonomics
- reset, clock enable, multi-domain testing
- failure diagnostics and signal history
- generated C++/Verilog sim mismatch handoff

Do not redesign the V5 hardware authoring syntax in this lane. Record syntax
friction for conductor or the RTL porting lane.

## Workflow

1. Inspect V5 testbench docs, tests, and examples.
2. Pick 2-3 representative workflows:
   - counter/FSM
   - pipeline
   - ready/valid
   - memory/regfile
   - multi-clock if available
3. Write current V5 testbench code snippets.
4. Describe pain points:
   - too much boilerplate
   - unclear cycle semantics
   - weak failure messages
   - hard-to-read stimulus
   - missing signal history or watch support
   - C++/Verilog mismatch difficult to localize
5. Propose APIs or workflows with acceptance tests.
6. If prototyping, prefer failing tests or small examples before implementation.

## Required Outputs

Write only lane-owned files:

- `docs/v5-lab/lanes/testbench-ergonomics.md`
- `docs/v5-lab/iterations/<NNN-testbench-ergonomics>.md`
- `docs/v5-lab/proposals/cycleawaretb-ergonomics.md`

End each iteration with:

```text
Handoff:
- Evidence:
- Proposed backlog changes:
- Risks:
- Next task:
```

## Proposal Ideas

- tabular cycle stimulus and expectations
- signal watch/history API
- failure output with nearby cycles
- reset helper improvements
- multi-domain testbench helpers
- waveform/probe dump on failed expectation
- C++/Verilog mismatch artifact bundle

## Acceptance Tests

Good proposals should include tests or future tests such as:

- a failed expectation prints signal name, expected/actual value, cycle, phase,
  and recent history
- tabular stimulus compiles to the same low-level drive/expect operations
- reset helper produces deterministic state across generated backends
- a ready/valid example uses concise testbench syntax without hidden timing
  assumptions

## Starting Prompt

```text
Run the testbench-ergonomics lane.

Question: What CycleAwareTb improvements would make cycle-accurate tests easier
to write and failures easier to diagnose?

Read:
- docs/PyCircuit_V5_Spec.md testbench sections
- docs/TESTBENCH.md
- tests and examples using CycleAwareTb or Tb

Produce:
- docs/v5-lab/lanes/testbench-ergonomics.md
- docs/v5-lab/iterations/001-testbench-ergonomics.md
- proposal draft if enough evidence exists
```
