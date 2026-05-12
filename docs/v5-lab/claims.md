# PyCircuit V5 Improvement Lab — Wave 001 Claims

Status: **PHASE 1 READY**
Conductor: leader pane
Plan artifact: `.omx/plans/v5-improvement-lab-iteration-001.md`
Workflow: `docs/development/v5-improvement-agent-workflows.md`
Scope: only current pyc5/V5 authoring surface.

## Hard Scope Rules

- Write only under `docs/v5-lab/` for Wave 001 artifacts.
- Do not edit shared compiler/API/code/example/test files in this wave.
- If shared code changes appear necessary, write a prototype/implementation plan in the relevant lane file or proposal and stop.
- Do not copy large third-party RTL into the repo.
- Every lane must end with this handoff block:
  - Evidence
  - Proposed backlog changes
  - Risks
  - Next task

## Worker Assignments

| Worker | Lane | Workflow file | Allowed writes | Stop condition |
| --- | --- | --- | --- | --- |
| worker-1 | source-correlation | `docs/development/v5-improvement-agent-lanes/source-correlation.md` | `docs/v5-lab/lanes/source-correlation.md`, `docs/v5-lab/iterations/001-source-correlation.md`, optional `docs/v5-lab/proposals/source-correlation.md` | Handoff block complete with source/cycle provenance evidence and acceptance tests/proposal or deferral. |
| worker-2 | rtl-porting | `docs/development/v5-improvement-agent-lanes/rtl-porting.md` | `docs/v5-lab/lanes/rtl-porting.md`, `docs/v5-lab/iterations/001-open-rtl-porting.md`, optional `docs/v5-lab/proposals/<topic>.md`, bounded updates to `docs/v5-lab/rtl-source-inventory.md` | Inventory has license decisions, one selected slice, porting ladder evidence, friction table, and handoff. |
| worker-3 | cpp-sim-perf | `docs/development/v5-improvement-agent-lanes/cpp-sim-perf.md` | `docs/v5-lab/lanes/cpp-sim-perf.md`, `docs/v5-lab/iterations/001-cpp-sim-perf.md`, optional `docs/v5-lab/benchmarks.md`, optional `docs/v5-lab/proposals/cpp-sim-performance.md` | Benchmark methodology and optimization hypotheses complete with correctness gates and handoff. |
| worker-4 | testbench-ergonomics | `docs/development/v5-improvement-agent-lanes/testbench-ergonomics.md` | `docs/v5-lab/lanes/testbench-ergonomics.md`, `docs/v5-lab/iterations/001-testbench-ergonomics.md`, optional `docs/v5-lab/proposals/cycleawaretb-ergonomics.md` | 2-3 CycleAwareTb workflows reviewed, pain points/proposed workflow/tests recorded, and handoff complete. |

## Conductor-Owned Files

The leader/conductor owns:

- `docs/v5-lab/claims.md`
- `docs/v5-lab/backlog.md`
- `docs/v5-lab/integration.md`
- `docs/v5-lab/pr-queue.md`

Bounded lane updates are allowed only where listed above.

## RTL Source Intake / License Gate

Before worker-2 makes any RTL porting claim, it must update `docs/v5-lab/rtl-source-inventory.md` with at least three candidates and one selected slice. Each candidate must record:

- upstream project, URL, commit/tag, license, module path
- approximate line count, interface family, testbench/reference quality
- why useful for V5 friction discovery
- license decision: `porting-ok` or `study-only`
- selected slice and expected V5 surface it stresses

License policy:

- Prefer Apache-2.0, BSD, MIT, ISC, or Solderpad-style permissive licenses.
- GPL/LGPL, unclear, missing, or custom licenses are study-only unless the user explicitly approves legal review.
- Do not copy large third-party source files; summarize patterns and use only short excerpts if needed.

## RTL Porting Ladder

Worker-2 must follow this order:

1. Source record.
2. Behavior sketch.
3. Reference evidence.
4. V5 pseudo-code or tiny prototype plan.
5. Friction table.
6. Generated artifact observations only if feasible and isolated.
7. Proposal or backlog update with acceptance tests.

## Verification Gate Before Shutdown

Conductor verifies:

- `docs/v5-lab/claims.md` contains `PHASE 1 READY`.
- Each lane file and iteration file exists or deferral is explicit.
- Every lane handoff block has Evidence / Proposed backlog changes / Risks / Next task.
- `git diff --name-only -- docs/v5-lab` shows no writes outside allowed docs/v5-lab files.
- Any proposal follows the shared proposal template and includes acceptance tests/non-goals.
- Any proposal added to `pr-queue.md` has review notes.

Recommended docs gates after lane completion:

```bash
changed=$(git diff --name-only -- docs/v5-lab)
if [ -n "$changed" ]; then pre-commit run --files $changed; fi
mkdocs build
```
