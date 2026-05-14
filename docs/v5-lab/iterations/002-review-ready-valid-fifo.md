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

## Verdict

Split before implementation. The proposal is useful and grounded in the Wave 001
OpenTitan `prim_fifo_sync` study, but Wave 003 should first land an
independently written example plus tests. A public helper API should wait until
that prototype proves a concrete missing V5 surface.

## Evidence Review

| Item | Finding |
| --- | --- |
| V5 scope | Pass. Scope is V5 authoring, testbench traces, generated artifacts, and user-facing FIFO ergonomics. |
| Source/license gate | Pass with required re-check. Inventory records OpenTitan at commit `d7237495dea39d79ccfabeece84c1ab376804ad7`, Apache-2.0, module `hw/ip/prim/rtl/prim_fifo_sync.sv`; do not copy upstream RTL/assertions into this repo. |
| Evidence maturity | Prototype-needed. Wave 001 evidence is source metadata, behavior summary, and pseudo-code; no compileable FIFO slice or generated artifacts exist yet. |
| Acceptance tests | Strong targets are listed, but they must become executable gates in the first PR: reset, clear, write/read, simultaneous push/pop, pass-through, status outputs, invalid transactions, and generated names. |
| Scope control | Needs split. The title mentions helper APIs, while the implementation plan correctly starts docs/examples-only. Keep that as the first branch boundary. |
| Cross-lane overlap | Useful but not bundleable. Source-correlation, C++ perf, and CycleAwareTb findings should be observations or follow-ups, not first-PR implementation scope. |

## Blocking Issues Before Any Helper API

- The Wave 001 pseudo-code uses placeholder forms such as `RegArray`, `Reg`,
  `Mux`, and a class-style module shell; the accepted V5 spelling must be proven
  by a tiny compileable FIFO first.
- Generated artifact observations are explicitly deferred. A helper that hides
  queue storage, pointers, occupancy, or handshake terms could make debugging
  worse unless the prototype records names first.
- Reset/clear priority and empty pass-through behavior are semantic contracts,
  not documentation details; they must be covered by tests before abstraction.
- License/source boundaries must remain explicit: use metadata and independent
  reimplementation only unless the conductor schedules a fresh source review.

## Minimal PR Slice

Branch candidate: `codex/v5-ready-valid-fifo-example-tests`

First PR only:

1. add one tiny, independently written V5 FIFO example or fixture using existing
   accepted V5 constructs;
2. add focused tests for reset, clear, write-only, read-only, simultaneous
   write/read, full/depth/status outputs, and invalid overflow/underflow;
3. cover pass-through enabled/disabled only if expressible without inventing new
   public API;
4. compile far enough to inspect generated MLIR/Verilog/C++ names for queue
   storage, read/write pointers, occupancy, and handshake terms;
5. document observed workflow and limitations.

Out of scope for that PR: new public FIFO helper API, compiler syntax changes,
imported OpenTitan files, source-map work, C++ optimization, or broad
CycleAwareTb diagnostics.

## Required Gates

- Re-check upstream URL, commit/tag, license, and module path before using the
  OpenTitan study as implementation evidence.
- Run the new FIFO regressions and closest existing V5 test subset.
- Verify reset/clear precedence, empty pass-through enabled/disabled behavior,
  simultaneous push/pop occupancy, `full`, `rvalid`, `wready`, `depth`, and
  invalid transaction reporting.
- Inspect generated MLIR/Verilog/C++ artifacts and record names for FIFO storage
  and handshake terms.
- Run changed-file formatting/lint/docs gates; if full-repo gates fail on
  unrelated pre-existing issues, record command output and scope boundary.

## Risks

| Risk | Mitigation |
| --- | --- |
| Premature helper API design. | Land example/tests first; require concrete prototype friction before API design. |
| Placeholder pseudo-code does not match current V5. | Start with the smallest compileable FIFO and document blockers. |
| Third-party source accidentally enters the repo. | Keep OpenTitan as study evidence and re-run the source/license gate. |
| Pass-through/reset behavior has off-by-one bugs. | Make reset, clear, simultaneous push/pop, and pass-through modes executable tests. |
| Helper hides useful generated names. | Record artifact names before abstraction. |

## Verification Notes

- PASS: `uvx pre-commit run --files docs/v5-lab/iterations/002-review-ready-valid-fifo.md docs/v5-lab/lanes/review.md` passed merge-conflict, whitespace, markdownlint, and API-hygiene hooks.
- PASS: `uvx --from mkdocs-material --with mdx-gh-links mkdocs build` completed; existing nav/anchor warnings are outside this docs-only review slice.
- PASS: `PYTHONPATH=compiler/frontend pytest -q` reported 7 passed and 3 skipped.
- FAIL (pre-existing/out of scope): `uvx mypy compiler/frontend/pycircuit` reported 117 typing errors in existing Python files; this task changed no compiler/API/tests/examples files.
- No compiler/API/tests/examples files were modified.

Subagent spawn evidence: 3 children spawned (`019e247e-ad77` review probe, `019e247e-ad89` test/verification probe, `019e247e-adb8` PR-slicing probe); usable integrated finding was the verification probe's distinction between docs-only gates and follow-up runtime regressions, while the other two returned read-only/closure blockers rather than substantive review details.

Review Handoff:

- Verdict: split
- Blocking issues: helper API must wait for a compileable V5 FIFO prototype, generated artifact naming observations, and executable reset/clear/pass-through tests.
- Suggested edits: queue the first branch as an example-and-tests slice; keep helper API, compiler syntax, source-correlation, and C++ performance work as follow-ups.
- Missing evidence: compileable V5 FIFO, generated MLIR/Verilog/C++ names, and passing reset/clear/pass-through/status regression tests.
- Next task: implement `codex/v5-ready-valid-fifo-example-tests` with independently written code and source/license gate evidence.

Review verdict: split
Minimal PR slice: example-only V5 FIFO plus focused tests and generated-artifact observations; no helper API or compiler internals in the first PR.
Required gates: source/license re-check, new FIFO regression tests, V5 subset tests, MLIR/Verilog/C++ artifact inspection, and formatting/lint/docs commands for changed files.
Risks: premature API design, placeholder pseudo-code mismatch with real V5, accidental third-party source copying, subtle pass-through/reset semantics, and debug-name regression.
Wave 003 handoff: schedule the example-and-tests branch first; decide on helper API only after executable prototype evidence exists.
