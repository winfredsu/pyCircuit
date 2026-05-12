# OMX V5 Multi-Agent Quickstart

This page is the operator quickstart for launching the PyCircuit V5 improvement
workflow with oh-my-codex. It keeps command usage separate from the workflow
definition in `v5-improvement-agent-workflows.md`.

## When To Use This

Use this when you want agents to run the V5 Improvement Lab workflow:

- plan one or more pyc5/V5 improvement waves
- coordinate lane agents for source correlation, RTL porting, C++ simulation
  performance, testbench ergonomics, and review
- keep lane outputs under `docs/v5-lab/`
- avoid unbounded edits to shared compiler code before evidence exists

## Preconditions

Run from the pyCircuit checkout:

```bash
cd /Users/sufang/projects/pyCircuit
omx doctor
tmux -V
```

`$team` / `omx team` is a tmux-based runtime. Start it from an OMX leader session
inside a terminal, not from a plain Codex App shell. In Codex App, use native
subagents for short bounded parallelism or launch an OMX CLI session first.

If `omx doctor` reports stale setup, refresh the user/project setup before the
first wave:

```bash
omx setup --force --verbose
omx doctor
```

## Start An OMX Leader

Use the normal supervised launcher:

```bash
cd /Users/sufang/projects/pyCircuit
omx --tmux --yolo
```

For a more conservative session, omit `--yolo`:

```bash
omx --tmux
```

## Plan The First Wave

Inside the OMX leader, run consensus planning before execution:

```text
$ralplan --interactive "基于 docs/development/v5-improvement-agent-workflows.md 规划 PyCircuit V5 Improvement Lab 第一轮迭代。范围只限 pyc5/V5 authoring surface。第一轮包括 source-correlation、rtl-porting、cpp-sim-perf、testbench-ergonomics 四个 lane。开始执行前补充 RTL source intake/license gate/porting ladder/verification gate。输出可直接交给 $team 执行的 plan、agent staffing、文件 ownership、验收标准。"
```

The plan should produce:

- lane ownership and allowed writes
- `docs/v5-lab/claims.md` expectations
- source inventory and license gate expectations for `rtl-porting`
- `docs/v5-lab/pr-queue.md` expectations for one-branch-one-PR follow-up
- success criteria and stop conditions for the wave
- review and verification path before implementation work

## Execute With Team

After the plan is approved, launch a coordinated team wave:

```text
$team 4:executor "执行 PyCircuit V5 Improvement Lab wave 001。Leader 作为 conductor，严格按 docs/development/v5-improvement-agent-workflows.md 分配四个 lane：source-correlation、rtl-porting、cpp-sim-perf、testbench-ergonomics。只写 docs/v5-lab 下的 claims/backlog/integration/lane/iteration/proposal 文件；shared code 只能先写 prototype plan。每个 lane 必须以 Evidence / Proposed backlog changes / Risks / Next task handoff 结束。"
```

Expected outputs live under `docs/v5-lab/`:

- `claims.md`, `backlog.md`, `integration.md`
- `pr-queue.md` when proposals are accepted for follow-up implementation
- `rtl-source-inventory.md` when `rtl-porting` is active
- `lanes/*.md`
- `iterations/*.md`
- `proposals/*.md` when evidence is strong enough

## Single-Agent Fallback

If you are not ready to run tmux team mode, use Ralph for a narrower loop:

```text
$ralph "按 docs/development/v5-improvement-agent-workflows.md 的 Single-Agent Mode 执行 PyCircuit V5 Improvement Lab 第一轮：先做 rtl-porting lane 的 source intake 和一个小 RTL porting study，只产出 docs/v5-lab 研究文档，不改 compiler 实现。"
```

Use this path for one lane at a time. It is slower, but simpler to supervise.

## Monitor And Stop

Useful commands from the OMX leader or another terminal:

```bash
omx hud --watch
omx status
omx team status <team-name>
omx sidecar --watch
```

Stop cleanly when the wave is complete or clearly blocked:

```bash
omx cancel
```

For team mode, wait until there are no pending or in-progress tasks before
shutdown unless you intentionally want to abort the wave.

## Wave Completion Checklist

Before starting implementation from a proposal, confirm:

- every active lane wrote a handoff block
- conductor updated `integration.md` and backlog priority
- RTL candidates include URL, commit/tag, license and selected slice
- proposals include evidence, minimal implementation path, acceptance tests,
  risks and non-goals
- review lane accepted or requested revisions for top proposals
- every accepted proposal has a dedicated branch/PR entry in `pr-queue.md`
- no public pyCircuit pull request is submitted before user review and approval
- any code-changing follow-up maps to gates in `testing-and-gates.md`

## Branch And PR Follow-up

When a proposal is ready for implementation, start a separate branch for that
single improvement:

```bash
git switch -c codex/v5-<topic>
```

Then run the implementation workflow against only that proposal:

```text
$ralph "Implement docs/v5-lab/proposals/<topic>.md on branch codex/v5-<topic>. Keep this PR scoped to one improvement, run the required gates, update docs/v5-lab/pr-queue.md, and prepare PR text for user review. Do not submit a public pyCircuit PR before user approval."
```

After the branch passes gates, prepare the PR body and evidence summary for user
review. Submit the public pyCircuit pull request only after that review approves
the branch and PR contents.
