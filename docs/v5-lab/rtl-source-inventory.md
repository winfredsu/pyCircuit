# RTL Source Inventory — V5 Improvement Lab

License gate: worker-2 must verify source URL, commit/tag, and license before using any candidate for porting evidence. GPL/LGPL/unclear/custom licenses are study-only unless user explicitly approves legal review.

## Candidate Intake Table

| Candidate | URL | Commit/tag | License | Module path | Approx LOC | Interface family | Reference quality | V5 friction target | License decision | Status |
| --- | --- | --- | --- | --- | ---: | --- | --- | --- | --- | --- |
| OpenTitan primitive FIFO or small primitive | verify upstream | verify | verify | verify | 100-500 target | FIFO/ready-valid/reset | verify | reset, ready/valid, naming, testbench | pending | candidate |
| lowRISC Ibex small FIFO/control slice | verify upstream | verify | verify | verify | 100-500 target | control/FIFO/CSR-style | verify | FSM/control, width/signedness, diagnostics | pending | candidate |
| PULP common_cells small arbiter/FIFO/skid slice | verify upstream | verify | verify | verify | 100-500 target | arbiter/FIFO/stream | verify | case/priority mux, packed arrays, ready/valid | pending | candidate |

## Selected Slice

Pending worker-2 verification.

## Intake Notes

Do not copy large external RTL. Summarize behavior and use short excerpts only when necessary.
