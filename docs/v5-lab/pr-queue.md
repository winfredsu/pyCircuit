# PyCircuit V5 Improvement Lab PR Queue

Wave 002 converted reviewed Wave 001 proposals into local branch/PR candidates.
These entries are for user review only; do not submit public upstream PRs until
the user approves the branch contents and PR body.

| Priority | Proposal | Branch | PR title | Scope and non-goals | Required gates | Evidence path | Review status | User-review status |
| ---: | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `proposals/cycleawaretb-ergonomics.md` | `codex/v5-cycleawaretb-context-diagnostics` | V5 CycleAwareTb context diagnostics | Add stable context labels/failure fields for `CycleAwareTb.expect`; preserve `msg=`; do not implement watch/history or timeline helper. | Focused root regression tests for failing expectations and label/message composition; existing V5 `CycleAwareTb` smoke/examples; docs update; pre-commit; `mkdocs build`; API hygiene. | `docs/gates/logs/<run-id>/v5-cycleawaretb-context-diagnostics/` | accepted: diagnostics-only first slice | pending-user-review |
| 2 | `proposals/ready-valid-fifo-helpers.md` | `codex/v5-ready-valid-fifo-example-tests` | V5 ready/valid FIFO example and tests | Independently written tiny V5 FIFO example/fixture plus focused tests and generated-artifact observations; no helper API, compiler internals, or third-party RTL import. | Source/license re-check; FIFO reset/clear/push/pop/pass-through/status tests; closest V5 unit/system subset; generated MLIR/Verilog/C++ naming observation; pre-commit; `mkdocs build`; API hygiene. | `docs/gates/logs/<run-id>/v5-ready-valid-fifo-example-tests/` | split: example/tests before helper API | pending-user-review |
| 3 | `proposals/source-correlation.md` | `codex/v5-source-correlation-map` | V5 source map named-register spike | Define opt-in `source_map.json` schema and named `domain.cycle(..., name=...)` provenance; do not include balance registers, hierarchy, arithmetic temporaries, CLI lookup, or timing-report ingestion. | Gate-first source-map unit coverage around `compile_cycle_aware()`/`CycleAwareDomain.cycle()`; generated artifact equivalence unchanged unless opt-in; pre-commit; `pytest tests/unit -m unit`; `mkdocs build`; API hygiene. | `docs/gates/logs/<run-id>/v5-source-correlation-map/` | split: schema + named-register spike | pending-user-review |
| 4 | `proposals/cpp-sim-performance.md` | `codex/v5-cpp-sim-benchmark-contract` | V5 C++ simulation benchmark contract | Docs-only benchmark contract/schema/evidence-path tightening; no runner, generated C++ runtime, emitter, or optimization changes. | `pre-commit run --files` on changed docs; `mkdocs build`; API hygiene. Later runner PR must add correctness-before-timing and JSON result validation. | `docs/gates/logs/<run-id>/v5-cpp-sim-benchmark-contract/` | revise/split: contract PR before implementation | pending-user-review |

## Deferred Follow-ups

- `CycleAwareTb` watch/history diagnostics after context-label failure fields are stable.
- `CycleAwareTb` timeline/table helper after emitted operation equivalence can be tested.
- Ready/valid FIFO helper API only after the example-and-tests branch proves a
  repeated missing surface.
- Source correlation for auto balance registers, hierarchy callsites,
  arithmetic temporaries, CLI lookup, and timing-report ingestion.
- C++ benchmark runner/targets/results after the contract/schema PR is reviewed.
- C++ runtime/emitter optimization only after baseline data exists.
