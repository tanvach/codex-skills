---
description: "Read an existing ExecPlan, deeply analyze every referenced file and code path, and rewrite the plan with concrete, code-grounded improvements. Prefer work-item plans under `.agent/work/`, while preserving compatibility with `.agent/execplan-pending.md`."
---

<!-- Generated from execplan-improve. Do not edit directly. -->


# Improve ExecPlan

Every improvement must trace back to something found in the actual code. No
speculative additions. No surface-level rewording.

## Design Lens

Use John Ousterhout's design philosophy as the design-quality lens:

- prefer deep modules over shallow wrappers
- prefer interfaces that hide sequencing and policy details
- prefer fewer concepts, fewer knobs, and fewer special cases
- prefer simpler mental models over visually tidy decomposition
- prefer moving complexity behind a stable boundary over redistributing it

Treat these as the main forms of complexity: change amplification, cognitive
load, and unknown unknowns.

## Resolve the Base Repo

You may be running from a Codex worktree such as
`~/.codex/worktrees/<id>/<repo>/`.

1. If the current path contains `/.codex/worktrees/`, infer the base repo from
   the repo name and check both the worktree `.agent/` and base repo `.agent/`.
2. Otherwise treat the current working directory as the base repo.
3. Prefer the worktree copy when both worktree and base repo artifacts exist.

## Input Resolution

Preferred target resolution order:

1. Explicit plan path supplied by the user.
2. Explicit work-item path supplied by the user.
3. `.agent/active` when it points to a work item with `stage="plan"` and
   `state="completed"`.
4. The most recently updated work item under `.agent/work/` with
   `stage="plan"` and `state="completed"`.
5. Legacy fallback: `.agent/execplan-pending.md`.
6. Explicit legacy fallback: `.agent/potential-bugs/<plan-name>.md`.

If no ExecPlan exists in any supported location, tell the user and stop.

## Workflow

0. Short-circuit low-value repeats.
   - Before doing repo work, inspect only the immediately previous assistant
     turn.
   - If the previous `execplan-improve` result was exactly `skip`, return
     exactly `skip`.
   - If it ended with `Usefulness score: N/10 - ...` and `N <= 3`, return
     exactly `skip`.
1. Understand the plan contract.
   - Read `.agent/PLANS.md` from the base repo or worktree before modifying
     the plan.
2. Resolve the plan path and metadata.
   - If operating on a work item, read `meta.json`, `decision.md` when present,
     and `execplan.md`.
   - Otherwise read the legacy plan path directly.
3. Parse the ExecPlan.
   - Extract file paths, symbols, commands, milestones, acceptance criteria,
     and assumptions.
4. Deep-read referenced and adjacent code.
   - Read referenced files and nearby importers or importees.
   - Look for wrong paths or signatures, missing tests or dependencies, project
     conventions the plan misses, leaked sequencing or policy, shallow
     abstractions the plan preserves without reason, and duplicate concepts or
     special-case branches the plan could absorb.
5. Audit the plan.
   - Check accuracy, completeness, self-containment, feasibility, testability,
     safety, and design quality.
6. Rewrite the plan in place.
   - Work-item format: rewrite `execplan.md`.
   - Legacy format: rewrite the original singleton path.
   - Preserve existing `Progress`, `Surprises & Discoveries`, `Decision Log`,
     and `Outcomes & Retrospective` content.
   - Apply only code-grounded improvements: fix inaccuracies, add missing
     files or tests, split oversized milestones, define jargon, make acceptance
     criteria observable, add recovery guidance, and strengthen the intended
     simplicity boundary.
   - Do not change the plan's intent.
7. Finalize metadata when using a work item.
   - Keep `stage="plan"`, `state="completed"`, and update `updated_at=<now>`.
8. Score usefulness and summarize.
   - Report `Fixed`, `Added`, `Strengthened`, and `Flagged`.
   - End with `Usefulness score: X/10 - <specific reason>`.
   - If a real pass found no material improvements, return exactly `skip`.

## Anti-Patterns

- surface-level rewording without code evidence
- speculative additions
- changing the plan's goal
- ignoring existing progress
- preserving shallow or leaky abstractions just because they were already in the draft
