---
name: walk-through-changes
description: >-
  Explain completed code changes in a clear, human-readable walkthrough after
  implementing an ExecPlan or other substantial coding task. Use when the user
  asks to walk through changes, explain what changed, validate the overall
  structure, review an implementation at a high level, or prepare a
  post-implementation summary for Codex or Claude Code.
---

# Walk Through Changes

Create a human validation walkthrough for completed implementation work.

The goal is not to repeat the diff. The goal is to help the user build a
confident mental model of what changed, why it changed, where to inspect, and
what risk remains.

## When To Use

Use this after:

- `$implement-execplan` finishes an implementation
- a substantial coding task changes multiple files or boundaries
- the user asks to validate the structure, understand the change, or review the
  implementation before commit or PR

## Inputs To Inspect

Use the context that exists in the repo and conversation:

1. Read the completed ExecPlan or work item when available:
   - explicit path from the user
   - `.agent/active`
   - most recent relevant `.agent/work/*/execplan.md`
   - legacy `.agent/execplan-pending.md` or `.agent/done/*`
2. Read `decision.md` or architecture notes when they explain the intended
   shape of the work.
3. Inspect `git status`, `git diff --stat`, and the relevant diffs.
4. Read changed files only as needed to explain behavior and structure.
5. Review validation evidence from this session, the ExecPlan, test output, or
   nearby project scripts.

If there is no diff because the work has already been committed, compare the
relevant commit or branch against its base when that is discoverable. If it is
not discoverable, explain that limitation and summarize from the available
plan, files, and git history.

## Workflow

1. Reconstruct the intended outcome from the ExecPlan, user request, or task
   context.
2. Group the actual changes by concept or system boundary, not by raw file
   order.
3. For each group, explain:
   - what changed
   - why it exists
   - how it connects to the rest of the implementation
   - what the user should inspect to validate it
4. Call out any mismatch between the intended plan and actual implementation.
5. Call out important non-changes: plan items intentionally deferred, removed
   scope, compatibility preserved, or behavior left untouched.
6. Include verification performed and verification still missing.
7. End with a short validation checklist the user can scan before approving.

## Output Shape

Use this structure unless the user asks for a different format:

```markdown
**Big Picture**
[2-4 sentences: the old shape, the new shape, and the main reason this change
exists.]

**Structural Walkthrough**
- `[area or boundary]`: what changed, why it matters, and how to inspect it.
- `[area or boundary]`: what changed, why it matters, and how to inspect it.

**Files To Inspect**
- `path/to/file`: why this file is important to the change.
- `path/to/file`: why this file is important to the change.

**Plan Alignment**
- Completed: [major intent or milestone now satisfied]
- Adjusted: [anything that changed from the plan and why]
- Deferred: [anything intentionally left for later]

**Validation**
- Ran: `[command]` - [result]
- Not run: `[command or check]` - [reason]

**Review Checklist**
- [ ] [concrete behavior or boundary the user should validate]
- [ ] [concrete behavior or boundary the user should validate]
- [ ] [risk, edge case, or migration concern to inspect]
```

## Style

- Write for the human owner of the change, not for a code reviewer already deep
  in the diff.
- Prefer plain language over implementation jargon.
- Be specific about files, boundaries, and behavior.
- Keep each bullet short enough to scan.
- Do not claim validation that did not happen.
- Do not hide uncertainty. Name it as a validation item or residual risk.
- Do not turn the walkthrough into a bug hunt unless you find a clear issue.

## For Claude Code

When generated as a Claude Code command, this skill should work as a local
post-implementation command. Use the same workflow with Claude Code's available
git, file-reading, and shell tools. If invoked after a Claude Code task, use the
conversation context plus the repository diff to explain the final structure.
