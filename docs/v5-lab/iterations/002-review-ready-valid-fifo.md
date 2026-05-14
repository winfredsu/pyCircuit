# Wave 002 Review: Ready/Valid FIFO Helper and Example

Reviewer: `worker-2`
Proposal: `docs/v5-lab/proposals/ready-valid-fifo-helpers.md`
Inputs:

- `docs/development/v5-improvement-agent-workflows.md`
- `docs/development/v5-improvement-agent-lanes/review.md`
- `docs/v5-lab/proposals/ready-valid-fifo-helpers.md`
- `docs/v5-lab/rtl-source-inventory.md`
- `docs/v5-lab/lanes/rtl-porting.md`
- `docs/v5-lab/iterations/001-open-rtl-porting.md`

## Review Summary

The proposal is grounded in the Wave 001 RTL-porting study and is valuable, but
it should be split before Wave 003 implementation. The first branch should be an
example-and-tests prototype that proves current V5 can express a tiny FIFO and
captures concrete friction. A helper API should wait until that prototype shows
a specific repeated authoring problem that cannot be handled cleanly by an
example, documentation, or local test fixture.

## Evidence Check

| Review item | Finding |
| --- | --- |
| V5 scope | Pass. The proposal stays on V5 authoring, examples, testbench traces, generated artifacts, and no backend-only semantic fix. |
| Source/license boundary | Pass with a required gate. The selected OpenTitan `prim_fifo_sync` source is recorded as Apache-2.0 at commit `d7237495dea39d79ccfabeece84c1ab376804ad7`; Wave 003 must continue using metadata/summaries or independently written code only. |
| Current evidence | Adequate for scheduling a prototype. Evidence is still pseudo-code/docs-level; no compileable FIFO slice or generated artifacts were produced in Wave 001. |
| Acceptance tests | Good coverage targets are listed: reset, clear, write/read, simultaneous push/pop, pass-through, status outputs, invalid transactions, and generated names. They need to be bound to the first PR as executable tests, not just future criteria. |
| Scope control | Needs split. The title and motivation mention helper APIs, but the implementation plan correctly says to start docs/examples-only. Keep helper API out of the first PR. |
| Overlap | Intentional overlap with testbench ergonomics and source correlation is useful, but those should remain observation outputs, not bundled implementation changes. |

## Blocking Issues Before Helper API

- The Wave 001 pseudo-code uses placeholder shapes such as `RegArray`, `Reg`,
  `Mux`, and a class-style module shell. A helper API cannot be reviewed until a
  tiny implementation confirms the existing accepted V5 spelling or identifies
  the smallest missing surface.
- Generated artifact naming observations are explicitly deferred. A helper that
  hides storage, pointers, or transaction terms could make source-correlation
  worse unless the prototype records MLIR/Verilog names first.
- Reset versus explicit clear priority and empty pass-through behavior must be
  executable tests in the first branch because they define the semantics users
  will copy.
- License/source gates must remain visible. Do not import OpenTitan RTL or copy
  assertion code into the repo without a fresh conductor-approved source review.

## Suggested Focused Proposal Edits

No proposal file edit is required to proceed, because the existing
implementation plan already says to start with a docs/examples-only prototype.
For clarity, the conductor may later retitle the queue entry as a FIFO example
and regression slice, then schedule any helper API as a separate follow-up after
prototype evidence exists.

## Minimal PR Slice

Branch candidate: `codex/v5-ready-valid-fifo-example-tests`

First PR contents should be limited to:

1. add one tiny, independently written V5 FIFO example or fixture using existing
   accepted V5 constructs;
2. add focused tests for reset, clear, write-only, read-only, simultaneous
   write/read, full/depth/status outputs, and invalid overflow/underflow
   handling;
3. add pass-through coverage only if it can be expressed without inventing new
   public API;
4. record generated MLIR/Verilog/C++ naming observations for queue storage,
   read/write pointers, occupancy, and handshake terms;
5. update docs with the observed example workflow and known limitations.

Out of scope for the first PR:

- new public FIFO helper API;
- compiler internals or syntax changes;
- imported OpenTitan source files or copied assertion packages;
- source-map, C++ performance, or broad CycleAwareTb diagnostics changes.

## Required Gates

- Re-check the selected source metadata before implementation: upstream URL,
  commit/tag, license, and module path; keep any third-party source out of the
  repo unless separately approved.
- Run the new FIFO tests plus the closest existing V5 test subset.
- Verify reset/clear precedence, empty pass-through enabled/disabled behavior,
  simultaneous push/pop occupancy, `full`, `rvalid`, `wready`, `depth`, and
  invalid transaction reporting.
- Compile the example far enough to inspect generated MLIR/Verilog, and record
  naming observations for storage, pointers, occupancy, and handshake terms.
- Run repository formatting/lint gates for changed files and the relevant Python
  test suite; if full-repo gates fail on pre-existing issues, record the failing
  commands and why they are outside the branch scope.

## Risks

| Risk | Mitigation |
| --- | --- |
| The proposal becomes a premature helper API. | Split example/tests first; require prototype evidence before helper design. |
| Placeholder pseudo-code hides current V5 limitations. | Start by writing the smallest compileable V5 FIFO and document any blockers. |
| Third-party RTL is accidentally copied. | Keep OpenTitan as study evidence only and re-run the source/license gate. |
| Pass-through semantics are subtle and off-by-one prone. | Make enabled and disabled pass-through modes explicit acceptance tests. |
| Generated names become harder to debug. | Record artifact names before abstracting storage or handshake helpers. |

## Wave 003 Handoff

Schedule an implementation worker for the example-and-tests slice only. The
worker should produce executable evidence first, then report whether a helper API
is still needed. If a helper is needed, open a new proposal or follow-up PR slice
with concrete friction from the prototype instead of widening the Wave 003
example branch.

Review Handoff:
- Verdict: split
- Blocking issues: helper API must wait for a compileable V5 FIFO prototype, generated artifact naming observations, and executable reset/clear/pass-through tests.
- Suggested edits: queue the first branch as an example-and-tests slice; keep helper API, compiler syntax, source-correlation, and C++ performance work as follow-ups.
- Missing evidence: compileable V5 FIFO, generated MLIR/Verilog/C++ names, and passing reset/clear/pass-through/status regression tests.
- Next task: implement `codex/v5-ready-valid-fifo-example-tests` with independently written code and source/license gate evidence.

Review verdict: split
Minimal PR slice: example-only V5 FIFO plus focused tests and generated-artifact observations; no helper API or compiler internals in the first PR.
Required gates: source/license re-check, new FIFO regression tests, V5 subset tests, MLIR/Verilog artifact inspection, and formatting/lint/test commands for changed files.
Risks: premature API design, placeholder pseudo-code mismatch with real V5, accidental third-party source copying, subtle pass-through/reset semantics, and debug-name regression.
Wave 003 handoff: schedule the example-and-tests branch first; decide on helper API only after executable prototype evidence exists.
