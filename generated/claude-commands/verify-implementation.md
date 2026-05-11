---
description: "Verify an implemented ExecPlan by triangulating the plan against the actual git diff and validation runs. Use after implement-execplan completes — ideally in a fresh session, or on a stronger model — to catch silent deviations, missing edits, scope creep, and validation failures the implementer may have glossed over. Especially valuable after a cross-model handoff where the implementer was a cheaper or weaker model."
---

<!-- Generated from verify-implementation. Do not edit directly. -->


# Verify Implementation

Triangulate three sources of truth — the plan (intent), `git diff` (reality), validation runs (behavior) — and report any mismatch.

## Critical rule

The plan's `Progress` checkboxes and `Outcomes & Retrospective` paragraph are implementer self-reports. Treat them as hints, not evidence. The reliable inputs are `git diff` and `bash` validation output. When those contradict the self-report, the self-report is wrong.

## Resolve the plan

Same priority order as `execplan-improve`, plus the post-implementation location:

1. Explicit plan path supplied by the user.
2. The most recently dated file under `.agent/done/`, since `implement-execplan` archives completed plans there.
3. `.agent/execplan-pending.md`, if the user is verifying mid-implementation.
4. The most recently updated work item under `.agent/work/` with `stage="implementation"` and `state="completed"` or `state="blocked"`.

If no plan exists in any supported location, tell the user and stop.

## Identify the commit range to verify

Resolve in this order:

1. **Per-step commits.** Run `git log --grep="Implements step" --oneline -n 100`. If matches exist, the verification range is `<first-such-commit>^..<last-such-commit>`. Record which step each commit claims to implement.
2. **Plan-archive marker.** Find the commit that added the plan to `.agent/done/` with `git log --diff-filter=A --format=%H -- <plan-path>`. The verification range is from that commit's parent back to the most recent unrelated commit (the planning boundary). If the plan was committed at creation, use `git log --diff-filter=A --format=%H -- <original-plan-path>`'s parent as the lower bound.
3. **User-supplied range.** If neither resolves cleanly, ask the user for `<base>..<head>` and stop until they provide it.

Save the resolved range as `/range` for the rest of the skill.

## Workflow

1. Read the plan in full. Extract:
   - Every Implementation Plan step, with its prescribed file paths and edit shapes.
   - Every Validation criterion.
   - Every entry in `Surprises & Discoveries` and `Decision Log`.

2. Identify `/range` per the section above.

3. Read the reality inputs:
   - `git log /range --oneline` — the commits.
   - `git diff --stat /range` — the files-touched summary.
   - `git diff /range` for each file you need to inspect in depth.

4. **Implementation step coverage.** For each Implementation Plan step:
   - Locate the prescribed file path in the diff.
   - Check the change type matches (created / modified / deleted).
   - Check the prescribed edit (or its equivalent intent) appears in the patch hunks.
   - Record the step as `MATCHED`, `NO MATCHING DIFF`, or `PARTIAL MATCH` with evidence.

5. **Reverse coverage.** For each file changed in the diff:
   - Is the change explained by an Implementation Plan step? (Check by file path and edit shape.)
   - If not, is it explained by an entry in `Surprises & Discoveries`? (The entry must cite the file and explain why the deviation was necessary.)
   - If neither: record as an `UNEXPLAINED CHANGE`. Scope creep, drift, or implementer freelancing.

6. **Validation runs.** For each Validation step in the plan:
   - If the step is a shell command with stated expected output, run the command. Compare stdout/stderr/exit-code against the expectation. Record `PASS`, `FAIL`, or `UNEXPECTED OUTPUT` with a diff.
   - If the step is a file-state check, run `ls`, `test`, `readlink`, etc. and record the result.
   - If the step is non-mechanical ("open the IDE and confirm…"), skip with `[REQUIRES_HUMAN]` and defer to the user.
   - If the step contains a judgment verb ("verify the refactor is clean"), skip with `[NON-MECHANICAL]` and note that the plan failed `execplan-portability-check` category D — flag for follow-up.

7. Score and report.

## Verdict

The verdict has four levels. Report the most severe that applies:

- **`matches plan`** — every Implementation Plan step has a matching diff, no unexplained changes, every mechanical Validation passes.
- **`deviates with explanation`** — some prescribed edits do not appear exactly as written, but every deviation is documented in `Surprises & Discoveries` or `Decision Log` with a coherent reason, and mechanical Validation passes.
- **`silently deviates`** — at least one step has no matching diff, OR at least one diff hunk is unexplained, AND the plan's living sections do not account for the gap. The implementer did the wrong thing or freelanced; the plan didn't catch it.
- **`fails validation`** — any mechanical Validation step returned FAIL or UNEXPECTED OUTPUT. Severity trumps every other category. The system doesn't work regardless of what the implementer claimed.

Severity order: `fails validation` > `silently deviates` > `deviates with explanation` > `matches plan`.

## Output

Report in this exact shape:

    Verdict: <one of the four>

    Plan: <path>
    Range: <base>..<head>  (<N> commits, <M> files changed)

    Implementation step coverage (<X>/<Y> matched):
    - Step 1: <prescribed change> → MATCHED
      Commit: <sha> <subject>
      Files: <paths>
    - Step 2: <prescribed change> → NO MATCHING DIFF
      Expected: <file path + edit shape>
      Found: <what was in the diff for that area, or "nothing">
    - Step 3: <prescribed change> → PARTIAL MATCH
      Matched: <which parts>
      Missing: <which parts>
    - ...

    Unexplained changes (<N>):
    - <file path>:<lines> — <one-line summary of what changed>
      Not covered by any Implementation Plan step.
      Not mentioned in Surprises & Discoveries.
    - ...

    Validation:
    - Step 1: `<command>` → PASS
    - Step 2: `<command>` → FAIL
      Expected: <expected output>
      Got: <actual output>
    - Step 3: <description> → [REQUIRES_HUMAN], deferred
    - Step 4: <description> → [NON-MECHANICAL], plan needs execplan-portability-check follow-up
    - ...

    Recommended next step: ship | revise | re-run with stronger model | run execplan-portability-check on this plan

## When to ship vs revise

- `matches plan` and all mechanical Validation passes → **ship**.
- `deviates with explanation` and all mechanical Validation passes → **review each explanation**. Ship if the deviations are sound; revise if any explanation is post-hoc rationalization for a bad call.
- `silently deviates` → **revise**. Send the punch list back to the implementer (or to a stronger model in a fresh session) and re-verify.
- `fails validation` → **revise**. The system doesn't work. Diagnose the failure, fix, re-verify.

## What this skill does NOT do

- Does not fix the implementation. Hand findings back to `implement-execplan` in a new session, ideally on a stronger model.
- Does not re-implement steps that were skipped or wrong. Only diagnoses.
- Does not run validation if the criteria are non-mechanical — flags them for the user to either run manually or rewrite the plan's validation section.
- Does not edit the plan. If the plan needs more `Surprises & Discoveries` content or a fixed validation step, that is `execplan-improve`'s job on the next iteration.

## Anti-patterns

- Trusting the implementer's `Progress` checkboxes when the diff disagrees with them.
- Skipping mechanical Validation steps because the plan says they passed. Always re-run.
- Counting unexplained refactors as "code quality improvements." They're either covered by `Surprises & Discoveries` or they're scope creep, regardless of how clean they look.
- Issuing `matches plan` while any Validation step failed. Validation wins, always.
- Reading the implementer's session transcript to "understand what they meant." If the plan + diff + validation don't tell you, that is the finding — the implementer left an incomplete record.
