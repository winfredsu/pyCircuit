# PyCircuit V5 Improvement Lab Claims

## Wave 002 Status

PHASE 2 READY: proposal review and PR queue slicing may begin.

## Scope

Wave 002 is docs-only and limited to the current pyc5/V5 authoring surface. The
wave reviews Wave 001 proposals and turns accepted/revision-ready suggestions
into narrow Wave 003 branch/PR candidates for user review.

## Hard Write Boundary

Allowed repository writes are limited to `docs/v5-lab/` proposal, backlog,
integration, PR-queue, claims, lane review, and iteration review files. Workers
must not edit:

- `compiler/`
- `tests/`
- `designs/`
- `flows/`
- `README.md`
- generated artifacts outside `docs/v5-lab/`

Shared implementation/code changes are out of scope. If a worker believes code
or tests are needed, it must record a Wave 003 handoff only.

## Conductor-Owned Files

Only the leader/conductor applies final edits to:

- `docs/v5-lab/claims.md`
- `docs/v5-lab/backlog.md`
- `docs/v5-lab/integration.md`
- `docs/v5-lab/pr-queue.md`

Workers may propose exact text for those files in their handoff, but should not
edit them unless explicitly delegated by the conductor.

## Worker Ownership

| Worker | Lane review topic | Primary proposal | Allowed worker-owned outputs |
| --- | --- | --- | --- |
| worker-1 | testbench ergonomics | `docs/v5-lab/proposals/cycleawaretb-ergonomics.md` | proposal-focused edits if needed; `docs/v5-lab/iterations/002-review-cycleawaretb-ergonomics.md`; optional append/update to `docs/v5-lab/lanes/review.md` |
| worker-2 | RTL/FIFO slicing | `docs/v5-lab/proposals/ready-valid-fifo-helpers.md` | proposal-focused edits if needed; `docs/v5-lab/iterations/002-review-ready-valid-fifo.md`; optional append/update to `docs/v5-lab/lanes/review.md` |
| worker-3 | source correlation slicing | `docs/v5-lab/proposals/source-correlation.md` | proposal-focused edits if needed; `docs/v5-lab/iterations/002-review-source-correlation.md`; optional append/update to `docs/v5-lab/lanes/review.md` |
| worker-4 | C++ sim perf slicing | `docs/v5-lab/proposals/cpp-sim-performance.md` and `docs/v5-lab/benchmarks.md` | proposal-focused edits if needed; `docs/v5-lab/iterations/002-review-cpp-sim-performance.md`; optional append/update to `docs/v5-lab/lanes/review.md` |

If workers update `docs/v5-lab/lanes/review.md`, they must append a clearly
scoped section for their assigned proposal to reduce merge conflicts.

## Required Review Output Shape

Each worker must end its iteration note and leader mailbox report with:

- Review verdict: accept / revise / split / reject
- Minimal PR slice
- Required gates
- Risks
- Wave 003 handoff

## Acceptance Criteria

Wave 002 is complete when:

1. Each of the four proposal reviews has a review iteration note.
2. Each review includes the required output shape.
3. The conductor updates `backlog.md`, `integration.md`, and `pr-queue.md` based
   on accepted/revision-ready slices.
4. `pr-queue.md` contains only user-review-ready local branch/PR candidates; if
   any proposal is not ready, it is explicitly marked for revision rather than
   queued for implementation.
5. Changed docs pass docs-only gates: `pre-commit run --files ...`, API hygiene
   as included in pre-commit, and `mkdocs build`.

## Stop Conditions

Stop and ask the user if review shows a proposal requires semantic changes that
conflict with the decision corpus, needs external legal approval, or cannot be
safely sliced without touching shared code in Wave 002.
