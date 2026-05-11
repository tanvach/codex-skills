---
description: "Execute an ExecPlan from a work item under `.agent/work/` or, when necessary, from `.agent/execplan-pending.md`. Use when the user asks to implement a plan, execute the pending plan, or resume blocked implementation work."
---

<!-- Generated from implement-execplan. Do not edit directly. -->


# Implement ExecPlan

Use the ExecPlan as the implementation contract for delivering both the
intended behavior and the intended simplification of the system.

## Preferred Input Resolution

Use this resolution order:

1. Explicit work-item path supplied by the user.
2. Explicit `execplan.md` path supplied by the user.
3. `.agent/active` when it points to a work item with:
   - `stage="plan"` and `state="completed"`, or
   - `stage="implementation"` and `state="blocked"`.
4. The most recently updated work item under `.agent/work/` matching those
   same rules.
5. Legacy fallback: `.agent/execplan-pending.md`.

If no supported plan exists, stop and tell the user.

## Work Item Responsibilities

If operating on a work item, read:

- `meta.json`
- `decision.md` when present
- `execplan.md`

This skill owns implementation-state transitions in `meta.json`:

- when starting work: `stage="implementation"` and `state="active"`
- when blocked or only partially complete: `stage="implementation"` and
  `state="blocked"`
- when implementation completes: `stage="implementation"` and
  `state="completed"`

Do not rename plans or move work-item directories to represent lifecycle state.

Legacy singleton plans remain supported. When implementing
`.agent/execplan-pending.md`, complete the plan and then move it into
`.agent/done/` with a descriptive filename.

## Design Lens

When the plan leaves room for judgment:

- prefer deep modules over shallow wrappers
- prefer interfaces that hide sequencing and policy
- prefer fewer concepts, fewer knobs, and fewer special cases
- prefer simple mental models over clever decomposition

## Workflow

1. Read the ExecPlan in full, then read `.agent/PLANS.md` when it exists.
2. Reconstruct the intended behavior, target boundary, and complexity dividend.
3. If available, read `decision.md` so implementation stays aligned with the
   original decision rationale.
4. For work items, update `meta.json` to `stage="implementation"` and
   `state="active"` before coding.
5. Inspect relevant code paths before editing.
6. Implement step by step. After each completed step:
   - Commit with `git commit -m "Implements step N: <one-line description>"`
     where N is the step number from the plan's Implementation Plan section.
     Per-step commits let a later `/verify-implementation` pass map every
     diff hunk back to a plan step.
   - Resolve that step's checkbox in `Progress`.
   - If you hit anything the plan did not predict, append a one-paragraph
     entry to `Surprises & Discoveries` citing the file and line.
   - If you resolved an ambiguity the plan left open, append a
     `Decision Log` entry with the rationale.
7. After each meaningful slice, run the plan's validation steps or the
   nearest targeted verification.
8. Before archiving the plan to `.agent/done/` (or marking the work item
   `state="completed"`), the plan must reflect what actually happened:
   - Every step in `Progress` is either checked or marked deferred with a
     one-line reason.
   - `Outcomes & Retrospective` contains a paragraph summarizing what
     shipped, any open follow-ups, and any lesson worth carrying forward.
   - If `Surprises & Discoveries`, `Decision Log`, or
     `Outcomes & Retrospective` is missing from the plan's structure but
     applies to what happened, add the section before archiving.
   These sections are how a downstream verification pass — especially one
   run by a different model in a fresh session — understands what you did.
   Skipping them defeats the verification loop.
9. If you finish a work-item implementation, set `state="completed"`.
10. If you cannot finish safely in the current turn, record the blocker in
    the plan, set work-item state to `blocked` when applicable, and stop
    cleanly.
11. Before your final response, run a brief `/double-check-work` pass over
    the implementation, diff, and verification.

## Implementation-First Rule

This skill is for execution, not more planning.

You may update the ExecPlan during implementation only to:

- record progress actually made
- record discoveries from code already inspected
- tighten milestones or acceptance criteria to match current repo reality
- document design decisions that unblock the next implementation step

Do not turn an implementation turn into another plan-improvement pass.

## Decision Making

If a step is ambiguous or has multiple valid approaches, proceed with your best
judgment rather than stopping to ask.

## Anti-Patterns

- satisfying the letter of the plan while preserving the same interface burden
- adding wrappers, adapters, or helper layers that hide little
- pushing sequencing or policy outward to callers
- finishing with only ExecPlan edits when implementation work remains
- using file moves or renames as the primary state transition for work items
