# PyCircuit V5 Improvement Agent Workflows

本文档是 PyCircuit V5 improvement lab 的总控入口。它定义 conductor 如何
启动多 agent 并行探索、各 lane 如何隔离输出、以及每个 lane 应读取哪份独立
workflow。具体研究方法放在 lane 文件中，避免每个 agent 读取不相关流程。

## Scope

本工作流只面向当前 pyc5/V5 authoring surface：

- `docs/PyCircuit_V5_Spec.md`
- `compiler/frontend/pycircuit/v5.py`
- V5 examples under `designs/examples/`
- V5 tests, especially `CycleAwareSignal`, `CycleAwareDomain`,
  `compile_cycle_aware()`, and `CycleAwareTb` coverage
- Generated MLIR/Verilog behavior that affects V5 user experience
- Generated C++ model simulation behavior and performance

除非用户明确要求，不要把本工作流变成旧版路线讨论。改进建议可以引用现有
compiler/gate 约束，但 user-facing 分析应围绕 V5 的实际 API、examples、
testbench、debug workflow 和 C++ sim workflow。

## Persistent Workspace

建议让 agent 在仓库内维护一个研究空间：

```text
docs/v5-lab/
  backlog.md
  findings.md
  decision-log.md
  rtl-source-inventory.md
  pr-queue.md
  benchmarks.md
  claims.md
  integration.md
  lanes/
    source-correlation.md
    rtl-porting.md
    cpp-sim-perf.md
    testbench-ergonomics.md
    review.md
  iterations/
    001-source-correlation.md
    001-open-rtl-porting.md
    001-cpp-sim-perf.md
  proposals/
    source-correlation.md
    cycleawaretb-ergonomics.md
    cpp-sim-performance.md
```

| File | Purpose |
| --- | --- |
| `backlog.md` | V5 改进候选池，按影响力、实现难度、风险排序 |
| `findings.md` | 从代码、文档、examples、tests 中审计出的事实与缺口 |
| `decision-log.md` | 每轮为什么选择某个主题，以及为什么推迟其他主题 |
| `rtl-source-inventory.md` | 候选开源 RTL 清单、license gate、porting 适配性和选择理由 |
| `pr-queue.md` | 已通过 review 的改进建议到 branch/PR 的排队、状态和审阅记录 |
| `benchmarks.md` | C++ sim benchmark targets、命令、指标、环境和趋势 |
| `claims.md` | 多 agent 并行时的 lane ownership、当前任务、文件写入范围 |
| `integration.md` | conductor 汇总的跨 lane 结论、冲突、去重和优先级调整 |
| `lanes/*.md` | 每个方向的独立研究日志和当前状态 |
| `iterations/*.md` | 每轮工作记录：输入、观察、产物、验证、下一步 |
| `proposals/*.md` | 可以拿去讨论或拆 issue/PR 的正式 proposal |

不要把临时脚本或 scratch examples 放在 repo root。需要验证时优先使用现有
tests/examples；如果只是研究记录，放在 `docs/v5-lab/`。

## Lane Workflow Index

每个 lane agent 应只读取总控文档和自己的 lane workflow。

| Lane | Workflow | Primary question |
| --- | --- | --- |
| source-correlation | [source-correlation.md](v5-improvement-agent-lanes/source-correlation.md) | Python -> MLIR -> Verilog 如何保留 source/cycle provenance 以支持 timing/debug |
| rtl-porting | [rtl-porting.md](v5-improvement-agent-lanes/rtl-porting.md) | 真实开源 RTL porting 会暴露哪些 V5 语法/API/testbench 缺口 |
| cpp-sim-perf | [cpp-sim-perf.md](v5-improvement-agent-lanes/cpp-sim-perf.md) | 如何建立 benchmark 并提高 generated C++ model 仿真速度 |
| testbench-ergonomics | [testbench-ergonomics.md](v5-improvement-agent-lanes/testbench-ergonomics.md) | `CycleAwareTb` 如何更好写、更好失败、更好定位 |
| review | [review.md](v5-improvement-agent-lanes/review.md) | 如何独立审查 proposals，避免空泛、重复或不可验证 |

## Parallel Multi-Agent Loop

当目标是同时探索多个改进方向时，使用 conductor + lane agents 的并行模式。
conductor 不做深挖，负责分配 lane、维护共享 backlog、合并发现、避免多个
agent 写同一文件。每个 lane agent 只负责一个方向，独立迭代并写自己的 lane
日志、iteration note 和 proposal。

### Pre-wave Gates

每一轮 wave 开始前，conductor 必须先完成轻量 gate，避免 agents 直接进入
宽泛改写：

1. **Contract intake**: 读取 `AGENTS.md`、`docs/development/testing-and-gates.md`
   和本 workflow，确认当前任务仍然只面向 pyc5/V5 surface。
2. **Ownership intake**: 在 `claims.md` 中列出每个 lane 的写入范围、禁止触碰
   的 shared files、handoff 格式和本轮 stop condition。
3. **RTL source intake**: 如果本轮包含 `rtl-porting`，先维护
   `rtl-source-inventory.md`，再选择单个 100-500 行左右的 RTL slice。
4. **Review cadence**: 每一轮至少安排一次 review pass。若本轮产出 proposal，
   review lane 必须在下一轮实现前审查 evidence、scope、acceptance tests 和
   license/porting 风险。

### pycc-backed Gates In Team Workers

OMX team workers normally run from per-worker git worktrees under
`.omx/team/<team>/worktrees/<worker>/`. Those worktrees do not contain the
leader checkout's ignored build output directories, so a plain
`command -v pycc` is not a valid readiness check for pycc-backed gates.

When a lane needs Verilog/C++ generation, examples, or simulation evidence,
agents should resolve `pycc` through the repository helper instead of testing
`PATH` directly:

```bash
bash -lc 'source flows/scripts/lib.sh; pyc_find_pycc; echo "${PYCC}"'
```

`pyc_find_pycc` first checks the current worktree and explicit `PYCC` /
`PYC_TOOLCHAIN_ROOT` values. For OMX team worktrees it may also use the
canonical leader checkout root, such as `~/projects/pyCircuit`, via
`OMX_TEAM_LEADER_CWD` or the `.omx/team/.../worktrees/...` path prefix. This
locates the staged `pycc` without copying toolchain artifacts into worker
worktrees.

Conductor expectations:

- Prefer setting `OMX_TEAM_LEADER_CWD` to the repository root when launching
  long-running team waves.
- For final pycc-backed proof, run the gate from the merged leader checkout or
  from a worker worktree that has built its own toolchain with
  `bash flows/scripts/pyc build`.
- If `pyc_find_pycc` still fails, record the gate as blocked and include the
  missing `PYCC` / `PYC_TOOLCHAIN_ROOT` state in the evidence log.
- Do not copy `.so` files, staged toolchains, or generated artifacts between
  worktrees. Rebuild in the current worktree when validating changes to MLIR,
  codegen, runtime, or the `pycc` executable itself.

### RTL Source Intake Gate

`rtl-porting` 的目的不是把外部 RTL 大量复制进仓库，而是用真实 RTL 暴露 V5
表达、诊断、testbench 和 generated artifact 的缺口。因此 conductor 应维护
`docs/v5-lab/rtl-source-inventory.md`，每个候选项至少记录：

- upstream project、URL、commit/tag、license、module path
- approximate line count、interface family、testbench/reference quality
- why it is useful for V5 friction discovery
- whether the license is acceptable for porting or study-only
- selected slice and the expected V5 surface it stresses

License policy:

- Prefer permissive and hardware-friendly licenses such as Apache-2.0, BSD,
  MIT, ISC, or Solderpad-style permissive licenses.
- GPL/LGPL, unclear, missing, or custom licenses are **study-only** unless the
  user explicitly approves a legal review path.
- Do not copy large third-party source files into this repo. Keep short excerpts
  only when needed for explanation, and otherwise summarize patterns.

Good first candidate pools:

- OpenTitan primitives and small IP fragments: FIFOs, SRAM wrappers, CDC and
  ready/valid-style infrastructure.
- lowRISC Ibex small modules: decode/control/CSR/FIFO-style slices, not the
  whole core.
- PULP Platform common cells or AXI fragments: arbiters, stream/FIFO blocks,
  AXI-Lite cuts, demuxes and width converters.
- PicoRV32 small interface/control slices: memory interface, trace/debug, simple
  state machine patterns, not the whole CPU.
- FuseSoC Package Directory, FreeCores, and OpenCores-derived mirrors only after
  license, maintenance status and testbench quality are checked per repository.

### RTL Porting Ladder

When a candidate passes intake, use this ladder instead of jumping directly to
compiler changes:

1. **Source record**: record source URL, commit/tag, license, module path and
   interface summary.
2. **Behavior sketch**: summarize state, timing, handshake and reset behavior.
3. **Reference evidence**: note upstream testbench, docs or simple sim command
   when available.
4. **V5 pseudo-code**: write the smallest V5 translation attempt or pseudo-code
   that exposes the friction.
5. **Friction table**: map RTL patterns to current V5 expression, pain point and
   proposed improvement.
6. **Tiny compile prototype**: only if feasible, compile the V5 slice and inspect
   generated MLIR/Verilog/C++ artifacts.
7. **Proposal or backlog**: convert repeated friction into a proposal with
   acceptance tests; otherwise record it as backlog evidence.

The first wave should prefer documentation/prototype artifacts under
`docs/v5-lab/` over shared compiler changes. Shared implementation edits require
an explicit follow-up plan and review pass.

### Branch And Pull Request Policy

Every accepted improvement proposal should become its own branch and pull
request. Do not bundle unrelated improvement suggestions into one PR just
because they were discovered in the same agent wave.

Lifecycle:

1. A lane writes a proposal under `docs/v5-lab/proposals/<topic>.md`.
2. The review lane accepts it or requests revisions.
3. The conductor records the proposal in `docs/v5-lab/pr-queue.md` with:
   - proposal path
   - intended branch name, usually `codex/v5-<topic>`
   - PR title
   - scope and non-goals
   - required gates and expected evidence path
   - user-review status
4. Implementation happens on the dedicated branch only.
5. The agent may prepare a local PR summary, draft body, evidence list, and fork
   branch, but must not submit a public pyCircuit pull request before the user
   has reviewed and approved the branch/PR contents.
6. After user approval, submit the pull request to the public pyCircuit
   repository with links to the proposal, gate evidence, and any RTL source
   intake records.

Branch rules:

- Use one branch per improvement suggestion.
- Keep branch names stable and descriptive, for example
  `codex/v5-source-correlation-map` or `codex/v5-cycleawaretb-history`.
- If two proposals share implementation files, keep separate PRs unless the
  conductor records why they must land together.
- If an implementation uncovers a larger semantic change, stop the branch at the
  smallest safe point and create a follow-up proposal instead of widening the PR.

### Agent Roles

| Role | Ownership | Primary outputs |
| --- | --- | --- |
| Conductor | `backlog.md`, `claims.md`, `integration.md`, cross-lane priority | lane assignment, merge summary, conflict resolution |
| Source/debug agent | Python -> MLIR -> Verilog mapping, naming, source map | `lanes/source-correlation.md`, source/debug proposals |
| RTL porting agent | open-source RTL porting studies and syntax friction | `lanes/rtl-porting.md`, porting studies, syntax backlog |
| C++ perf agent | generated C++ model benchmarks and optimization candidates | `lanes/cpp-sim-perf.md`, `benchmarks.md`, perf proposals |
| Testbench agent | `CycleAwareTb`, failure diagnostics, stimulus/expect ergonomics | `lanes/testbench-ergonomics.md`, TB proposals |
| Review agent | independent critique of completed lane proposals | review notes and proposal edits |

Use 3-5 lane agents per wave. More agents usually create coordination overhead
unless each lane has a disjoint output file set.

### Shared-State Rules

- Only conductor edits `docs/v5-lab/backlog.md`, `claims.md`, and
  `integration.md` during a parallel wave.
- Only conductor edits `docs/v5-lab/rtl-source-inventory.md` unless it explicitly
  delegates a bounded inventory update to `rtl-porting`.
- Only conductor edits `docs/v5-lab/pr-queue.md` unless a review or implementation
  lane is explicitly assigned to update one PR entry.
- Lane agents write only:
  - their `docs/v5-lab/lanes/<lane>.md`
  - their `docs/v5-lab/iterations/<NNN-lane-topic>.md`
  - their `docs/v5-lab/proposals/<topic>.md`
  - lane-specific examples/tests only if explicitly assigned
- Lane agents may suggest backlog changes in their lane log, but conductor
  applies the final priority edits.
- If a lane needs to touch shared code, it must record the proposed file list in
  its lane log first. Conductor decides whether to schedule a tiny prototype.
- Every lane must end with a handoff block: evidence, proposed backlog changes,
  risks, and next task.

### Parallel Wave Cadence

Run work in waves rather than letting agents wander indefinitely:

1. **Plan wave**: conductor creates `claims.md`, assigns lanes, file ownership,
   success criteria, and timebox.
2. **Explore in parallel**: lane agents run their lane workflow.
3. **Handoff**: each lane writes an iteration note and lane handoff block.
4. **Integrate**: conductor reads lane outputs, de-duplicates findings, updates
   backlog, writes `integration.md`, and chooses the next wave.
5. **Review**: optional review agent critiques the top 1-2 proposals before any
   implementation work.

## Conductor Prompt

```text
You are the PyCircuit V5 Improvement Lab conductor.

Set up one parallel exploration wave.

Scope:
- Focus only on PyCircuit V5 user-facing improvement directions.
- Use docs/PyCircuit_V5_Spec.md, compiler/frontend/pycircuit/v5.py,
  V5 examples/tests, generated MLIR/Verilog, and C++ sim artifacts.
- Do not do deep research yourself. Assign independent lanes and integrate
  their outputs.

Tasks:
1. Create or update docs/v5-lab/claims.md.
2. Choose 3-5 lane agents from:
   source-correlation, rtl-porting, cpp-sim-perf, testbench-ergonomics,
   review.
3. For each lane, specify:
   - lane workflow file to read
   - research question
   - input files/repos
   - allowed write files
   - expected artifact
   - success criteria
   - what not to touch
4. After lane agents finish, read their outputs, update backlog.md and
   integration.md, and select the next wave.

Conductor-only files:
- docs/v5-lab/backlog.md
- docs/v5-lab/claims.md
- docs/v5-lab/integration.md
```

## Lane Agent Prompt Template

```text
You are a PyCircuit V5 Improvement Lab lane agent.

Lane:
<source-correlation | rtl-porting | cpp-sim-perf | testbench-ergonomics |
review>

Read:
- docs/development/v5-improvement-agent-workflows.md
- docs/development/v5-improvement-agent-lanes/<lane>.md

Research question:
<one concrete question assigned by conductor>

Allowed writes:
- docs/v5-lab/lanes/<lane>.md
- docs/v5-lab/iterations/<NNN-lane-topic>.md
- docs/v5-lab/proposals/<topic>.md

Rules:
- Stay within your lane.
- Do not edit backlog.md, claims.md, or integration.md.
- Base conclusions on real V5 docs, implementation, examples, tests, generated
  artifacts, or benchmark data.
- If you need code changes, first write a tiny prototype plan instead of editing
  shared implementation files.
- End with a handoff block:
  Evidence, proposed backlog changes, risks, next task.
```

## Recommended First Parallel Wave

```text
Start a PyCircuit V5 Improvement Lab parallel wave with four lane agents:

1. source-correlation
   Workflow: docs/development/v5-improvement-agent-lanes/source-correlation.md
   Question: How can V5 generated Verilog preserve Python source and cycle
   provenance well enough for timing/debug?

2. rtl-porting
   Workflow: docs/development/v5-improvement-agent-lanes/rtl-porting.md
   Question: Build a license-gated RTL source inventory, then port one small
   open RTL module to V5 pseudo-code/prototype and identify missing syntax/API
   patterns.

3. cpp-sim-perf
   Workflow: docs/development/v5-improvement-agent-lanes/cpp-sim-perf.md
   Question: Using hisi-contest-2025-pyc as reference, define baseline C++ sim
   benchmark methodology and first optimization hypotheses.

4. testbench-ergonomics
   Workflow: docs/development/v5-improvement-agent-lanes/testbench-ergonomics.md
   Question: What CycleAwareTb improvements would make cycle-accurate tests
   easier to write and failures easier to diagnose?

Conductor should assign disjoint output files, wait for lane handoffs, then
write docs/v5-lab/integration.md and update backlog priority. If any lane
produces a proposal, run the review lane before scheduling implementation. Each
accepted proposal should then be added to docs/v5-lab/pr-queue.md as a separate
branch/PR candidate for user review.
```

## Single-Agent Mode

如果只有一个 agent，它仍可使用本工作流：选择一个 lane workflow，执行 3-5 轮，
每轮只处理一个主题，写入 `docs/v5-lab/iterations/` 和对应 proposal。单 agent
可以编辑 `backlog.md`，但仍应记录 `decision-log.md`。

## Backlog Seeds

初始 backlog 可以从这些主题开始。每项都应在后续迭代中补齐证据、代码样例
和验收测试。

| Topic | Suggested lane | First artifact |
| --- | --- | --- |
| Source correlation for generated Verilog | source-correlation | `proposals/source-correlation.md` |
| Cycle balance explainability | source-correlation | `proposals/cycle-balance-explainability.md` |
| CycleAwareTb ergonomics | testbench-ergonomics | `proposals/cycleawaretb-ergonomics.md` |
| Open RTL porting studies | rtl-porting | `iterations/001-open-rtl-porting.md` |
| C++ simulation performance | cpp-sim-perf | `proposals/cpp-sim-performance.md` |
| Stable generated names | source-correlation | `proposals/stable-generated-names.md` |
| Width and signedness diagnostics | rtl-porting or testbench-ergonomics | `proposals/width-signedness-diagnostics.md` |
| FSM and case DSL | rtl-porting | `proposals/fsm-case-dsl.md` |
| Memory/regfile V5 wrappers | rtl-porting or cpp-sim-perf | `proposals/memory-regfile-wrappers.md` |

## Shared Proposal Template

Lane proposal files should use this structure:

````markdown
# <Proposal Title>

## User Scenario

## Current V5 Code

```python
# current recommended or observed V5 code
```

## Pain Point

## Proposed V5 Code

```python
# proposed API or workflow
```

## Semantics

## MLIR/Verilog Impact

## Simulation And Testbench Impact

## Compatibility

## Minimal Implementation Path

## Acceptance Tests

## Risks And Non-goals
````

## Skill Skeleton

如果要把总控流程沉淀为 Codex skill，可以创建
`pycircuit-v5-improvement-lab/SKILL.md`：

```markdown
---
name: pycircuit-v5-improvement-lab
description: Use when coordinating parallel PyCircuit V5 improvement agents. Dispatches lane agents for source correlation, RTL porting, C++ sim performance, testbench ergonomics, and review.
---

# PyCircuit V5 Improvement Lab

Read docs/development/v5-improvement-agent-workflows.md first.

For lane-specific work, read exactly one lane file:
- docs/development/v5-improvement-agent-lanes/source-correlation.md
- docs/development/v5-improvement-agent-lanes/rtl-porting.md
- docs/development/v5-improvement-agent-lanes/cpp-sim-perf.md
- docs/development/v5-improvement-agent-lanes/testbench-ergonomics.md
- docs/development/v5-improvement-agent-lanes/review.md

Use conductor + lane agents for parallel waves. Conductor owns backlog.md,
claims.md, and integration.md. Lane agents own their lane log, iteration note,
and proposal files.
```
