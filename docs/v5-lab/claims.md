# PyCircuit V5 Improvement Lab Claims

## Wave 003 Status

PHASE 3 READY: implementation slice work may begin after this claims file is
committed and the OMX team is launched.

Run ID: `20260514-wave003`

## Scope

Wave 003 implements the first three user-review candidates from
`docs/v5-lab/pr-queue.md` and assigns one verifier/integration lane. The
source-correlation candidate is explicitly deferred to a later wave.

## Global Rules

- Follow `AGENTS.md`, `docs/development/testing-and-gates.md`, and
  `docs/development/review-and-merge.md`.
- Identify affected decision IDs or contracts before changing files.
- Add or update tests before/with semantic behavior changes.
- Keep each lane scoped to its assigned branch candidate; do not combine
  unrelated proposals.
- Do not implement `codex/v5-source-correlation-map` in this wave.
- Do not import third-party RTL source. The OpenTitan FIFO remains study evidence
  only unless a separate source/legal review is approved.
- Commit worker changes before marking tasks complete.
- Each worker report must end with: Changed files / Decision or contract impact /
  Gates run / Evidence path / Risks / Next handoff.

## Worker Ownership

| Worker | Slice | Primary files | Required gates/evidence |
| --- | --- | --- | --- |
| worker-1 | `codex/v5-cycleawaretb-context-diagnostics` | `compiler/frontend/pycircuit/v5.py`; `compiler/frontend/pycircuit/tb.py` only if needed; focused tests under `tests/`; docs for accepted API | pre-commit on changed files; focused unit tests; API hygiene; docs build if docs changed; evidence under `docs/gates/logs/20260514-wave003/cycleawaretb-context-diagnostics/` |
| worker-2 | `codex/v5-ready-valid-fifo-example-tests` | `designs/examples/` and/or `tests/` for an independently written tiny FIFO example/tests; docs observations under `docs/v5-lab/` if needed | source/license re-check; new FIFO tests; closest V5 subset; generated artifact observation if feasible; pre-commit; docs build if docs changed; evidence under `docs/gates/logs/20260514-wave003/ready-valid-fifo-example-tests/` |
| worker-3 | `codex/v5-cpp-sim-benchmark-contract` | `docs/v5-lab/benchmarks.md`; `docs/v5-lab/proposals/cpp-sim-performance.md`; optional schema/result docs under `docs/v5-lab/` | docs pre-commit/API hygiene; `mkdocs build`; evidence under `docs/gates/logs/20260514-wave003/cpp-sim-benchmark-contract/` |
| worker-4 | verifier/integration | `docs/v5-lab/integration.md`; `docs/v5-lab/pr-queue.md`; gate/evidence review notes | verify lane scopes, gates, evidence paths, and no source-correlation implementation; evidence under `docs/gates/logs/20260514-wave003/integration-verifier/` |

## Stop Conditions

Stop and ask the user if:

- implementation requires changing documented semantics without a clear decision
  update path;
- source-correlation work becomes necessary to complete another lane;
- workers need to import third-party RTL source;
- unrelated user changes overlap the same files and merge strategy is ambiguous;
- required toolchain credentials or external infrastructure block validation.

## Wave 003 Completion Criteria

- Each lane reaches terminal task status or has an explicitly acknowledged
  failure path.
- Implemented slices have bounded evidence under `docs/gates/logs/20260514-wave003/`.
- Verifier confirms no source-correlation implementation occurred.
- Conductor integrates only scoped commits, updates `integration.md` and
  `pr-queue.md`, reruns appropriate final gates, then shuts down the team.
