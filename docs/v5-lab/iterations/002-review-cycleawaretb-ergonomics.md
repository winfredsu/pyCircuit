# Iteration 002 — Review CycleAwareTb Ergonomics Proposal

Owner: worker-1
Date: 2026-05-14
Wave: 002
Lane: review

## Inputs

- `docs/development/v5-improvement-agent-workflows.md`
- `docs/development/v5-improvement-agent-lanes/review.md`
- `docs/v5-lab/proposals/cycleawaretb-ergonomics.md`
- `docs/v5-lab/lanes/testbench-ergonomics.md`
- `docs/v5-lab/iterations/001-testbench-ergonomics.md`

## Scope applied

Only review-owned documentation was edited:

- `docs/v5-lab/proposals/cycleawaretb-ergonomics.md`
- `docs/v5-lab/iterations/002-review-cycleawaretb-ergonomics.md`

No compiler, API, example, root test, backlog, integration, PR queue, or claims
files were edited.

## Evidence reviewed

The proposal is grounded in existing V5 testbench ergonomics evidence:

- `docs/v5-lab/lanes/testbench-ergonomics.md` records current `CycleAwareTb`
  usage patterns across counter, pipeline, ready/valid, and multi-clock examples.
- `docs/v5-lab/iterations/001-testbench-ergonomics.md` records that complex
  ready/valid tests manually encode `cycle`, `lane`, and source labels in
  expectation messages, while root tests currently lack direct `CycleAwareTb`
  coverage.
- `docs/v5-lab/proposals/cycleawaretb-ergonomics.md` already separates context
  labels, watch/history, and tabular timeline helpers into phases with
  acceptance tests and non-goals.

## Review findings

### Grounding

The proposal is sufficiently grounded for a first implementation branch. The
problem statement cites actual V5 examples and describes a concrete user pain:
when a cycle-aware expectation fails, larger tests need stable semantic context
without manually composing diagnostic strings.

### Scope

The proposal should be accepted only as a split implementation. The safe first
branch is context-label diagnostics for `CycleAwareTb.expect`; watch/history and
tabular timeline helpers should not be bundled because they introduce additional
state retention and a new authoring DSL.

### Acceptance tests

The acceptance tests are directionally correct, but Wave 003 should make the
first diagnostics slice gate-first:

1. add root regression coverage around an intentionally failing
   `CycleAwareTb.expect`;
2. assert stable semantic fields rather than snapshotting full backend text;
3. prove `msg=` compatibility and label composition;
4. keep watch/history absent by default.

### Overlap

The diagnostics slice complements, but should not depend on, the source
correlation proposal. Labels can later carry source-map identifiers, but the
first branch should not require MLIR, Verilog, or C++ source-map changes.

### Contract risks

The review found no blocker, provided the first PR avoids broad DSL design and
backend-specific formatting promises. Exact public API shape (`with tb.context`
versus `labels={...}`) can be finalized during implementation review, but the
semantic contract should remain stable-field diagnostics only.

## Suggested proposal edit

The proposal now records the Wave 002 review decision: accept a
diagnostics-only first slice, defer watch/history and timeline helpers, and keep
existing testbench behavior backward-compatible.

Review Handoff:
- Verdict: accept
- Blocking issues: none for the diagnostics-only first slice
- Suggested edits: keep the Wave 003 PR limited to context labels/failure fields; document watch/history and timeline as follow-ups
- Missing evidence: direct root regression coverage for failing `CycleAwareTb.expect` output; this belongs in the implementation PR
- Next task: open `codex/v5-cycleawaretb-context-diagnostics` for the minimal diagnostics slice

## Required output

- Review verdict: accept
- Minimal PR slice: add context labels or equivalent labels metadata to `CycleAwareTb.expect` diagnostics, preserving existing `msg=` behavior and simulation semantics; do not implement watch/history or timeline in this PR
- Required gates: focused root regression tests for failing expectations and label/message composition; existing V5 example smoke tests continue to compile; docs update for accepted diagnostics workflow; backend assertions check stable fields instead of exact full-line formatting
- Risks: brittle backend text snapshots, accidental growth into a broad testbench DSL, ambiguous multi-clock/domain semantics, and coupling to future source-correlation metadata too early
- Wave 003 handoff: implement the diagnostics-only branch `codex/v5-cycleawaretb-context-diagnostics`, then schedule watch/history and timeline helpers as separate reviewed proposals after the failure-field contract is stable
