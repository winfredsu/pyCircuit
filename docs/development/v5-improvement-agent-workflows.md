# PyCircuit V5 Improvement Agent Workflows

本文档把 PyCircuit V5 改进建议工作整理成可交给 agent 自主迭代的
workflow。目标不是一次性头脑风暴，而是让 agent 每轮都能读取真实 V5
代码与文档、留下可审阅产物、更新 backlog，并选择下一轮最有价值的问题。

## Scope

本工作流只面向当前 pyc5/V5 authoring surface：

- `docs/PyCircuit_V5_Spec.md`
- `compiler/frontend/pycircuit/v5.py`
- V5 examples under `designs/examples/`
- V5 tests, especially `CycleAwareSignal`, `CycleAwareDomain`,
  `compile_cycle_aware()`, and `CycleAwareTb` coverage
- Generated MLIR/Verilog behavior that affects V5 user experience

除非用户明确要求，不要把本工作流变成旧版路线讨论。改进建议可以引用现有
compiler/gate 约束，但用户-facing 分析应围绕 V5 的实际 API、examples 和
debug workflow。

## Persistent Workspace

建议让 agent 在仓库内维护一个研究空间：

```text
docs/v5-lab/
  backlog.md
  findings.md
  decision-log.md
  benchmarks.md
  claims.md
  integration.md
  lanes/
    source-correlation.md
    rtl-porting.md
    cpp-sim-perf.md
    testbench-ergonomics.md
  iterations/
    001-source-correlation.md
    002-cycle-balance-explainability.md
  proposals/
    source-correlation.md
    cycle-balance-explainability.md
```

这些文件承担不同职责：

| File | Purpose |
| --- | --- |
| `backlog.md` | V5 改进候选池，按影响力、实现难度、风险排序 |
| `findings.md` | 从代码、文档、examples、tests 中审计出的事实与缺口 |
| `decision-log.md` | 每轮为什么选择某个主题，以及为什么推迟其他主题 |
| `benchmarks.md` | C++ sim benchmark targets、命令、指标、环境和趋势 |
| `claims.md` | 多 agent 并行时的 lane ownership、当前任务、文件写入范围 |
| `integration.md` | conductor 汇总的跨 lane 结论、冲突、去重和优先级调整 |
| `lanes/*.md` | 每个方向的独立研究日志和当前状态 |
| `iterations/*.md` | 每轮工作记录：输入、观察、产物、验证、下一步 |
| `proposals/*.md` | 可以拿去讨论或拆 issue/PR 的正式 proposal |

不要把临时脚本或 scratch examples 放在 repo root。需要验证时优先使用现有
tests/examples；如果只是研究记录，放在 `docs/v5-lab/`。

## Single-Agent Loop

如果只有一个 agent，把下面的 prompt 交给它，可以启动一个多轮自主迭代：

```text
启动 PyCircuit V5 autonomous improvement loop。

循环执行 5 轮。每轮：
1. 读取 docs/v5-lab/backlog.md、findings.md、decision-log.md；如果不存在则创建。
2. 选择当前最高价值且范围可控的一个 V5 主题。
3. 判断本轮模式：discovery / porting study / C++ sim perf study /
   proposal / tiny prototype / review。
4. 执行任务，只处理一个主题。
5. 写入 docs/v5-lab/iterations/<NNN-topic>.md。
6. 更新 backlog 优先级。
7. 在 decision-log.md 中明确下一轮推荐任务。

约束：
- 聚焦 PyCircuit V5：CycleAwareSignal、CycleAwareDomain、domain.signal()、
  domain.call()、compile_cycle_aware()、CycleAwareTb、V5 examples/tests。
- 不做大规模重构。
- 每轮必须留下可审阅文档产物。
- 如果写代码，运行最小相关测试，并记录命令与结果。
- 每个建议都必须包含：当前 V5 写法、痛点、理想写法、实现影响、验收测试。
- 最终输出 5 轮总结：最值得投入的 3 个改进方向、证据、风险、推荐下一步。
```

## Parallel Multi-Agent Loop

当目标是同时探索多个改进方向时，使用 conductor + lane agents 的并行模式。
conductor 不做深挖，负责分配 lane、维护共享 backlog、合并发现、避免多个
agent 写同一文件。每个 lane agent 只负责一个方向，独立迭代并写自己的 lane
日志、iteration note 和 proposal。

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
2. **Explore in parallel**: lane agents run discovery, porting study, perf
   study, proposal, or tiny prototype within their lane.
3. **Handoff**: each lane writes an iteration note and lane handoff block.
4. **Integrate**: conductor reads lane outputs, de-duplicates findings, updates
   backlog, writes `integration.md`, and chooses the next wave.
5. **Review**: optional review agent critiques the top 1-2 proposals before any
   implementation work.

### Conductor Prompt

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

### Lane Agent Prompt Template

```text
You are a PyCircuit V5 Improvement Lab lane agent.

Lane:
<source-correlation | rtl-porting | cpp-sim-perf | testbench-ergonomics |
review>

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

### Recommended First Parallel Wave

```text
Start a PyCircuit V5 Improvement Lab parallel wave with four lane agents:

1. source-correlation
   Question: How can V5 generated Verilog preserve Python source and cycle
   provenance well enough for timing/debug?

2. rtl-porting
   Question: Port one small open RTL module to V5 pseudo-code/prototype and
   identify missing syntax/API patterns.

3. cpp-sim-perf
   Question: Using hisi-contest-2025-pyc as reference, define baseline C++ sim
   benchmark methodology and first optimization hypotheses.

4. testbench-ergonomics
   Question: What CycleAwareTb improvements would make cycle-accurate tests
   easier to write and failures easier to diagnose?

Conductor should assign disjoint output files, wait for lane handoffs, then
write docs/v5-lab/integration.md and update backlog priority.
```

## Workflow Modes

### Discovery Sprint

用于发现问题、建立事实基础，不直接实现大改动。

```text
本轮执行 V5 discovery sprint。主题从以下选择一个：
RTL 表达能力 / Cycle-aware 仿真 / Verilog debug mapping /
Cycle balance explainability / testbench ergonomics / interface and bundle。

要求：
1. 读取相关 V5 文档、frontend 实现、tests、examples。
2. 找出 5-8 个具体痛点。
3. 每个痛点给出现有代码样例和理想代码样例。
4. 标记可能受影响的实现文件与测试位置。
5. 更新 docs/v5-lab/findings.md 和 backlog.md。

不要实现代码，除非是为了验证一个很小的事实。
```

### Proposal Deepening

用于把一个 backlog 项打磨成可以讨论、拆 issue 或拆 PR 的建议。

```text
从 docs/v5-lab/backlog.md 中选择优先级最高且尚未深化的一项，写成正式
PyCircuit V5 proposal。

proposal 必须包含：
- User scenario
- Current V5 code
- Pain point
- Proposed V5 code
- Semantics
- MLIR/Verilog impact
- Simulation/testbench impact
- Compatibility
- Minimal implementation path
- Acceptance tests
- Risks and non-goals

输出到 docs/v5-lab/proposals/<topic>.md，并更新 backlog 与 decision-log。
```

### Open RTL Porting Study

用于把真实开源 RTL 设计 port 到 PyCircuit V5，借 porting 过程观察 V5
语法表达、模块组合、testbench、debug workflow 的缺口。这个模式的重点是
“用真实设计反推语言改进”，不是追求一次 port 完整大项目。

```text
本轮执行 open RTL porting study。

输入：
- 选择一个开源 RTL 设计或其中一个小模块，例如 FIFO、UART、SPI、I2C、
  simple CPU stage、arbiter、cache slice、crossbar、ready/valid pipeline。
- 记录 upstream 项目、license、模块路径、模块规模、接口形态。

要求：
1. 阅读原始 RTL 的接口、状态、时序、testbench 或 README。
2. 选择一个可控 porting slice，目标是 100-500 行 RTL 规模以内。
3. 写出等价的 V5 草案或最小 prototype；如果暂不实现，写出 V5 pseudo-code。
4. 记录每个 translation friction：
   - 原 RTL 写法
   - 当前 V5 写法
   - 痛点
   - 理想 V5 表达
   - 是否需要新语法、新 helper、新 diagnostics 或更好 examples
5. 如能运行，生成 MLIR/Verilog 并记录可读性、命名、source correlation、
   hierarchy、testbench 体验。
6. 更新 docs/v5-lab/findings.md、backlog.md，并输出
   docs/v5-lab/iterations/<NNN-porting-topic>.md。

约束：
- 不要把大块第三方源码复制进仓库；只记录链接、commit、license 和必要摘要。
- 如添加 example，必须是可维护的、最小的、用户-facing 的 V5 example。
- 如果 license 或规模不适合纳入 repo，只写 porting study 文档。
```

### C++ Simulation Performance Study

用于系统化探索如何得到更快的 generated C++ model 仿真速度。这个模式的重点
是建立 benchmark、测量瓶颈、提出小步优化，而不是凭感觉改 emitter/runtime。

本地或相邻工作区中的 `hisi-contest-2025-pyc` 仓库可以作为参考来源。agent
应优先参考其中已有的 C++ simulation、benchmark、profiling、contest flow 或
性能记录方式，再把可复用的方法迁移成 pyCircuit V5 的可复现 study。不要直接
复制大块代码；记录参考仓库路径、commit、借鉴点和迁移后的 pyCircuit 命令。

```text
本轮执行 C++ simulation performance study。

要求：
1. 查找参考仓库：
   - 如果本地存在 /Users/sufang/Projects/hisi-contest-2025-pyc，读取其
     README、scripts、benchmark、C++ sim 或 profiling 相关文件。
   - 记录参考仓库 commit、相关路径、可复用 benchmark 方法。
2. 选择一个 pyCircuit V5 benchmark target：
   - tiny: counter/FSM/FIFO
   - medium: pipeline/regfile/arbiter/crossbar
   - large: existing V5 example or ported RTL slice
3. 记录 build command、run command、input stimulus、cycle count、host info。
4. 收集至少三个指标：
   - generated C++ compile time
   - simulation throughput, cycles/sec
   - binary size, memory use, or trace overhead if relevant
5. 对 generated C++/runtime 做只读审计，寻找瓶颈类别：
   - redundant eval
   - excessive value copies
   - wide value representation
   - branch-heavy scheduling
   - missed inlining or over-inlining
   - trace/probe overhead
   - reset/commit bookkeeping
   - avoidable hierarchy calls
6. 提出 2-4 个优化 proposal，每个包含 expected win、risk、affected files、
   acceptance benchmark、correctness gate。
7. 如做 tiny prototype，只改一个优化点，并保留 A/B benchmark 结果。
8. 输出 docs/v5-lab/iterations/<NNN-cpp-sim-perf>.md，并更新 backlog。

约束：
- 不接受只看 generated Verilog 的性能结论；必须围绕 C++ model 仿真路径。
- 不做会改变 V5 语义的优化，除非同时定义 correctness tests。
- benchmark 必须可复现，至少记录命令、参数、git rev 和环境限制。
- 如果参考了 `hisi-contest-2025-pyc`，必须记录参考路径、commit 和具体借鉴点。
```

### Tiny Prototype

用于验证一个 proposal 是否可行。tiny prototype 的价值是缩小不确定性，
不是把功能一次做完。

```text
选择一个 proposal，做最小 prototype。

规则：
- 优先增加 tests 或 examples 来表达目标用户体验。
- 只做最小代码改动，不做大重构。
- 如果实现风险高，改为写 failing test、pseudo-test 或生成输出审计。
- 运行相关最小测试。
- 在 docs/v5-lab/iterations/<NNN-topic>.md 记录：
  改了什么、验证结果、失败点、下一步。
```

### Review Pass

用于批判已有 proposal，防止 agent 自我确认。

```text
选择 docs/v5-lab/proposals/ 下一个 proposal，执行 review pass。

请重点检查：
- 是否真的基于 V5 当前 API 和 examples
- 是否包含可运行或可审计的验收测试
- 是否过度依赖 backend-only 行为
- 是否破坏 V5 hard-break API 纪律
- 是否能帮助用户调试 Python -> MLIR -> Verilog 问题

输出 review 结论并修改 proposal。
```

## Improvement Backlog Seeds

初始 backlog 可以从这些主题开始。每项都应在后续迭代中补齐证据、代码样例
和验收测试。

| Topic | Why it matters | First artifact |
| --- | --- | --- |
| Source correlation for generated Verilog | 让 timing/debug report 能反查 Python V5 信号与源码位置 | `proposals/source-correlation.md` |
| Cycle balance explainability | 自动插入 DFF 是 V5 核心特性，需要可解释、可审计 | `proposals/cycle-balance-explainability.md` |
| FSM and case DSL | 标准 RTL 控制逻辑需要比嵌套 mux 更自然的写法 | `proposals/fsm-case-dsl.md` |
| CycleAwareTb ergonomics | cycle-accurate 测试应更好写、更好失败、更好定位 | `proposals/cycleawaretb-ergonomics.md` |
| Interface and bundle authoring | 大模块需要稳定的结构化端口和 field path | `proposals/interface-bundle-authoring.md` |
| Ready/valid pipeline patterns | 常见微架构模式需要标准 V5 idiom | `proposals/ready-valid-pipeline.md` |
| Width and signedness diagnostics | 位宽/符号错误应指向 V5 表达式与推导过程 | `proposals/width-signedness-diagnostics.md` |
| Hierarchical compile UX | `domain.call()` 的 flat/hierarchical 行为需要可预测、可调试 | `proposals/hierarchical-compile-ux.md` |
| Memory/regfile V5 wrappers | 常用 stateful primitive 需要 V5-native API | `proposals/memory-regfile-wrappers.md` |
| Stable generated names | 非语义编辑不应导致波形与 Verilog 名称大漂移 | `proposals/stable-generated-names.md` |
| Open RTL porting studies | 用真实开源 RTL porting 发现 V5 语法、接口、testbench、debug 缺口 | `iterations/001-open-rtl-porting.md` |
| C++ simulation performance | 建立可复现 benchmark，探索 generated C++ model 更快仿真的优化路径 | `proposals/cpp-sim-performance.md` |

## Proposal Template

每个 proposal 使用同一结构，方便比较与 review：

````markdown
# <Proposal Title>

## User Scenario

谁在什么设计任务中遇到什么问题。

## Current V5 Code

```python
# 当前推荐或常见写法
```

## Pain Point

具体说明哪里难写、难懂、难测或难 debug。

## Proposed V5 Code

```python
# 理想写法或最小 API 草案
```

## Semantics

定义这个 API 或 workflow 在 cycle、domain、width、reset、hierarchy 上的规则。

## MLIR/Verilog Impact

说明是否影响 MLIR op、attributes、names、source location、Verilog emission、
source map、probe/debug metadata。

## Simulation And Testbench Impact

说明对 `CycleAwareTb`、Python/JIT sim、generated C++/Verilog sim 的影响。

## Compatibility

说明是否保持 V5 hard-break 纪律，是否需要迁移现有 examples/tests。

## Minimal Implementation Path

列出可能受影响文件、最小实现顺序、第一批测试。

## Acceptance Tests

列出必须通过的 tests/examples/gates。docs-only proposal 至少要有可审阅的
future acceptance tests。

## Risks And Non-goals

明确本 proposal 不解决什么，避免范围膨胀。
````

## Porting Study Template

Open RTL porting study 使用同一结构，方便横向比较不同开源设计暴露出的
V5 表达缺口：

````markdown
# <Design Or Module> Porting Study

## Source

- Project:
- URL:
- Commit or release:
- License:
- RTL module path:
- Approximate size:

## Selected Slice

说明本轮 port 哪一小块，以及为什么范围可控。

## Original RTL Patterns

```systemverilog
// 能说明问题的短片段或摘要；避免复制大块第三方源码
```

## V5 Translation Attempt

```python
# 当前 V5 写法或 pseudo-code
```

## Translation Friction

| RTL pattern | Current V5 expression | Pain | Proposed V5 improvement |
| --- | --- | --- | --- |

## Generated Artifact Observations

记录 MLIR/Verilog 命名、层次、source correlation、testbench 或 debug 观察。

## Backlog Updates

列出应新增或提升优先级的 V5 improvement items。
````

## C++ Sim Performance Study Template

C++ sim perf study 必须可复现，避免“感觉更快”的结论：

````markdown
# <Benchmark> C++ Simulation Performance Study

## Target

- Design/example:
- Git revision:
- Reference repo:
- Reference repo revision:
- Reference paths:
- Build command:
- Run command:
- Stimulus:
- Cycle count:
- Host/toolchain:

## Baseline Metrics

| Metric | Value | Notes |
| --- | --- | --- |
| Generated C++ compile time | | |
| Simulation throughput | | cycles/sec |
| Binary size | | optional |
| Memory use | | optional |
| Trace/probe overhead | | optional |

## Bottleneck Hypotheses

列出从 generated C++、runtime、profiling 或 logs 中看到的瓶颈。

## Candidate Optimizations

| Optimization | Expected win | Risk | Affected files | Correctness gate |
| --- | --- | --- | --- | --- |

## A/B Result

如果做了 tiny prototype，记录 baseline vs changed 的命令和结果。

## Follow-up Backlog Items

列出下一轮 proposal 或 prototype。
````

## Skill Skeleton

如果要把本流程沉淀为 Codex skill，可以创建
`pycircuit-v5-improvement-lab/SKILL.md`，核心内容如下：

```markdown
---
name: pycircuit-v5-improvement-lab
description: Use when researching, proposing, prototyping, or iterating on PyCircuit V5 improvements. Focus on CycleAware APIs, V5 examples/tests, generated MLIR/Verilog debuggability, and reusable improvement proposals.
---

# PyCircuit V5 Improvement Lab

## Scope

Focus on:
- docs/PyCircuit_V5_Spec.md
- compiler/frontend/pycircuit/v5.py
- V5 examples under designs/examples
- V5 tests
- CycleAwareCircuit, CycleAwareDomain, CycleAwareSignal
- domain.signal(), domain.call(), compile_cycle_aware(), CycleAwareTb

Avoid using old upgrade plans as product direction unless the user asks.

## Artifacts

Maintain:
- docs/v5-lab/backlog.md
- docs/v5-lab/findings.md
- docs/v5-lab/decision-log.md
- docs/v5-lab/benchmarks.md
- docs/v5-lab/claims.md
- docs/v5-lab/integration.md
- docs/v5-lab/lanes/<lane>.md
- docs/v5-lab/iterations/<NNN-topic>.md
- docs/v5-lab/proposals/<topic>.md

## Single-Agent Loop

1. Read current lab artifacts.
2. Pick one topic.
3. Choose mode: discovery, porting study, C++ sim perf study, proposal,
   tiny prototype, or review.
4. Produce or update one artifact.
5. Update backlog priority.
6. Record next recommended iteration.

## Parallel Loop

Use conductor + lane agents for parallel exploration.
- Conductor owns backlog.md, claims.md, and integration.md.
- Lane agents own only their lane log, iteration note, and proposal files.
- Lanes should be disjoint: source-correlation, rtl-porting, cpp-sim-perf,
  testbench-ergonomics, or review.
- Every lane ends with a handoff block: evidence, proposed backlog changes,
  risks, next task.

## Quality Bar

A useful recommendation must include at least one concrete V5 code sample and
at least one concrete acceptance test, implementation file, generated
MLIR/Verilog implication, testbench scenario, porting friction, or benchmark
metric.
```

## Recommended Runs

推荐第一轮从 source correlation 开始，因为它连接了 V5 用户体验、生成
Verilog、timing/debug、层次化命名和测试可审计性。

```text
使用 PyCircuit V5 Improvement Lab 工作流，创建 docs/v5-lab/ 初始研究空间。

第一轮主题：V5 generated Verilog source correlation。

请审计：
- docs/PyCircuit_V5_Spec.md
- compiler/frontend/pycircuit/v5.py
- compiler/mlir/lib/Emit/VerilogEmitter.cpp
- 一个简单 V5 example 的生成 Verilog

产出：
1. docs/v5-lab/findings.md：当前 Python -> MLIR -> Verilog 命名/定位链路现状。
2. docs/v5-lab/backlog.md：至少 10 个 V5 改进候选项。
3. docs/v5-lab/proposals/source-correlation.md：source map/debug mapping proposal 初稿。

不要实现大改动。可以运行一个最小 compile 来观察输出。
```

第二轮可从 `Cycle balance explainability` 或 `CycleAwareTb ergonomics` 中选择，
取决于第一轮发现 source correlation 最大缺口在 compiler metadata 还是测试失败
诊断。

如果目标是优先发现 V5 语法表达能力缺口，可以启动 porting study：

```text
使用 PyCircuit V5 Improvement Lab 工作流，执行 open RTL porting study。

第一轮主题：port 一个小型开源 RTL 模块到 V5。

候选模块：
- FIFO
- UART TX/RX
- SPI master
- round-robin arbiter
- ready/valid skid buffer
- simple pipeline stage

要求：
1. 选择一个 license 清晰、范围可控的开源 RTL 模块。
2. 记录 URL、commit/release、license、模块路径和接口摘要。
3. 写出 V5 translation attempt 或 pseudo-code。
4. 记录每个 translation friction：原 RTL 写法、当前 V5 写法、痛点、
   理想 V5 表达。
5. 输出 docs/v5-lab/iterations/001-open-rtl-porting.md。
6. 更新 docs/v5-lab/backlog.md，把真实 porting 暴露出的语法/API/testbench
   缺口提升优先级。

不要复制大块第三方源码进仓库；必要时只保留短片段和链接。
```

如果目标是优先提高 generated C++ model 仿真速度，可以启动 perf study：

```text
使用 PyCircuit V5 Improvement Lab 工作流，执行 C++ simulation performance study。

第一轮主题：建立 V5 C++ sim baseline benchmark。

要求：
1. 如本地存在 `/Users/sufang/Projects/hisi-contest-2025-pyc`，先读取其中
   README、scripts、benchmark、C++ sim 或 profiling 相关文件，记录参考
   commit 和可复用方法。
2. 选择 tiny/medium/large 三个 benchmark target，至少一个来自现有 V5 example。
3. 记录 build command、run command、stimulus、cycle count、git rev、host/toolchain。
4. 测量 generated C++ compile time 和 simulation throughput；可选记录 binary
   size、memory use、trace/probe overhead。
5. 只读审计 generated C++ 和 runtime，列出 2-4 个瓶颈假设。
6. 输出 docs/v5-lab/benchmarks.md 和
   docs/v5-lab/iterations/001-cpp-sim-perf.md。
7. 更新 docs/v5-lab/backlog.md，新增优化 proposal 候选项，每项必须包含
   expected win、risk、affected files、correctness gate。

不要做改变语义的优化。若做 tiny prototype，必须保留 A/B benchmark 结果。
```
