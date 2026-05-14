# Wave 002 Review Probe — Ready/Valid FIFO

## Scope

Read-only verification sweep for the `ready-valid-fifo-helpers` proposal and
the docs-only review/update lane. No compiler/API/tests/examples files were
edited.

## Feasible Gates for a Docs-Only Update

- `pre-commit run --files <changed docs>`  
  Best fit for `docs/v5-lab/*` markdown edits.
- `mkdocs build`  
  Catches broken navigation, links, and anchors in the docs tree.
- `python3 flows/tools/check_api_hygiene.py compiler/frontend/pycircuit designs/examples docs README.md`  
  Useful when docs make claims about current API/example behavior.

## Expected Limitations

- No unit/system/typecheck gate is required for a pure docs/backlog/proposal
  update.
- `pytest tests/unit -m unit` and `pytest tests/system -m system` are
  implementation gates, not validation gates for this docs-only change.
- The proposal’s missing regression checks should remain follow-up acceptance
  tests rather than being treated as blockers for the documentation review.

## Missing Regression Checks Implied by the Four Lanes

- RTL porting: reset/clear precedence, simultaneous push/pop, empty pass-through,
  overflow/underflow reporting, stable generated names.
- Source correlation: stable source-map entries for named ports, explicit regs,
  balance regs, and hierarchical callsites.
- C++ sim perf: benchmark harness with correctness log, timing separation, and
  cache/trace A/B parity.
- CycleAwareTb ergonomics: failure context labels/history and clearer
  multi-clock diagnostics.

## Handoff

- Evidence: docs/development/testing-and-gates.md, .pre-commit-config.yaml,
  Makefile, and the v5-lab lane/proposal files.
- Proposed next step: keep the docs-only update limited to proposal/backlog/PR
  queue text; defer runtime regressions to follow-up implementation branches.
- Risks: over-claiming behavior in docs without a matching implementation gate;
  citing test/typecheck commands as required for a docs-only update.

Review verdict: revise
Minimal PR slice: docs-only proposal/backlog/PR-queue wording update
Required gates: pre-commit on changed docs, mkdocs build, API hygiene when docs
assert current behavior
Risks: no runtime regression evidence in this wave; keep acceptance tests as
follow-up items
Wave 003 handoff: example-only + tests before any helper API
