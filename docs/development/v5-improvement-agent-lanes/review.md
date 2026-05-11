# Review Lane

This lane independently critiques completed lane outputs and proposals. Its job
is to prevent vague recommendations, duplicate proposals, ungrounded claims,
and implementation plans without acceptance tests.

## Scope

Review:

- `docs/v5-lab/proposals/*.md`
- `docs/v5-lab/iterations/*.md`
- `docs/v5-lab/lanes/*.md`
- `docs/v5-lab/benchmarks.md`
- conductor summaries in `docs/v5-lab/integration.md`

Do not become a second implementation lane. Review should be concise,
evidence-based, and actionable.

## Workflow

1. Select one proposal or lane output assigned by conductor.
2. Check whether it is grounded in real V5 docs, code, examples, tests,
   generated artifacts, porting friction, or benchmark data.
3. Check whether it has:
   - user scenario
   - current V5 code/workflow
   - pain point
   - proposed V5 code/workflow
   - implementation impact
   - acceptance tests
   - risks and non-goals
4. Flag duplicates or overlaps with other proposals.
5. Tighten scope and suggest next concrete step.
6. If editing a proposal, keep changes focused and preserve lane ownership.

## Required Outputs

Write only files assigned by conductor, usually:

- `docs/v5-lab/lanes/review.md`
- `docs/v5-lab/iterations/<NNN-review-topic>.md`
- reviewed proposal files when explicitly assigned

End each review with:

```text
Review Handoff:
- Verdict: accept / revise / split / reject
- Blocking issues:
- Suggested edits:
- Missing evidence:
- Next task:
```

## Review Checklist

- Does the proposal stay within PyCircuit V5?
- Does it cite concrete files, examples, artifacts, or benchmark data?
- Does it avoid backend-only semantic fixes?
- Does it define acceptance tests?
- Does it avoid compatibility shims for removed V5 APIs?
- Does it have a minimal implementation path?
- Does it explain risk and non-goals?
- Is it distinct from existing backlog items?

## Starting Prompt

```text
Run the review lane.

Question: Critique the assigned V5 proposal for evidence, scope, overlap,
acceptance tests, and implementation risk.

Read:
- docs/development/v5-improvement-agent-workflows.md
- this review lane file
- the assigned proposal or lane output

Produce:
- docs/v5-lab/lanes/review.md or assigned review iteration
- concise actionable review notes
```
