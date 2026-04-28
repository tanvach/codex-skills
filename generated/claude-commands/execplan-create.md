---
description: "Create an ExecPlan from a locked refactor decision, PRD, RFC, voice note, brainstorming blurb, or detailed problem statement, following the repo's PLANS.md. Use when the user asks for an exec plan, execution plan, or ExecPlan, or wants a decided refactor turned into a step-by-step plan."
---

<!-- Generated from execplan-create. Do not edit directly. -->


# ExecPlan Authoring

Write plans as paths to working behavior and simpler boundaries, not merely as
task lists for rearranging files.

## Preferred Inputs

Prefer a decided work item produced by `/select-refactor`.

Supported inputs, in priority order:

1. Explicit work-item path.
2. Explicit `decision.md` path.
3. `.agent/active` when it points at a work item with `stage="decision"` and
   `state="completed"`.
4. The most recently updated work item under `.agent/work/` with
   `stage="decision"` and `state="completed"`.
5. A user-supplied PRD, RFC, voice note, brainstorming blurb, or detailed
   problem statement.

If no input is available or the raw request is unclear, ask for clarification
before writing the plan. If using a decided work item, do not silently reopen
candidate search unless `decision.md` is clearly incomplete.

## Work Item Model

For the richer workflow, plans live inside work-item directories:

`.agent/work/<id-slug>/execplan.md`

Each work item has a small `meta.json` file with lifecycle state and relative
artifact paths. Update `.agent/active` as a convenience symlink when practical,
but treat `meta.json` as authoritative.

Legacy compatibility remains supported. If no work-item input is available and
the user supplies a raw brief, write `.agent/execplan-pending.md`.

## Source of truth

- Read `{baseDir}/.agent/PLANS.md` in full before drafting.
- If `{baseDir}/.agent/PLANS.md` is missing, copy this skill's `PLANS.md` to
  `{baseDir}/.agent/PLANS.md`, then read that copy as the source of truth.
- Follow PLANS.md exactly. If any instruction conflicts with this skill, PLANS.md wins.

## Output location

- Work-item input: write `.agent/work/<id-slug>/execplan.md`.
- Legacy raw brief: write `.agent/execplan-pending.md`.
- If `.agent/` or `.agent/work/` does not exist, create the needed
  directories before writing the file.

## Format rules

- Because the saved plan file contains only the ExecPlan, do not wrap it in
  outer triple backticks.

## Design lens

Use John Ousterhout's design philosophy when shaping the plan:

- prefer deep modules over shallow wrappers
- prefer interfaces that hide sequencing and policy details
- prefer fewer concepts, fewer knobs, and fewer special cases
- prefer simple mental models over tidy-looking decomposition
- prefer moving complexity behind a stable boundary over redistributing it

Every plan should explain what complexity exists today, who pays for it, what
boundary becomes simpler, what knowledge moves out of callers, and what future
change becomes easier.

## Authoring workflow

1. Resolve the input source.
   - For a decided work item, read `meta.json` and `decision.md`.
   - For a raw brief, identify concrete outcomes and acceptance criteria.
2. Inspect the repo to understand relevant files and flows. Note paths
   explicitly in the plan.
3. Draft the ExecPlan using the skeleton and rules from PLANS.md.
   - Preserve hard constraints from `decision.md` when present.
   - Name exact files and boundaries.
   - Describe the current pain and intended complexity dividend.
   - Keep the plan self-contained, novice-friendly, and behavior-focused.
4. Save the ExecPlan.
   - Work item: write `execplan.md` in the same work-item directory and update
     `meta.json` to `stage="plan"`, `state="completed"`, and
     `artifacts.execplan="execplan.md"`.
   - Legacy: write `.agent/execplan-pending.md`.
5. Run a brief `/double-check-work` pass on the plan draft. Fix any clear gap
   before finishing.

## Anti-Patterns

- reopening candidate search during planning without strong evidence
- writing a mechanically correct plan that preserves the same complexity under new names
- proposing thin wrappers or pass-through modules unless they clearly hide detail
- leaving key design choices to the implementer when repo evidence is already strong
