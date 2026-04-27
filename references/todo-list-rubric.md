# Todo List Rubric

Use this rubric when creating or updating a repository `TODO.md`.

## Core Principles

- Treat `TODO.md` as a prioritized decision document, not a dumping ground.
- Inspect the repo before editing: read the existing `TODO.md` if present, then sample `README.md`, `ARCHITECTURE.md`, `PLANS.md`, `.agent/`, recent completed plans, tests, and relevant code paths.
- Keep one clear `Next Up` recommendation with the reasoning needed to trust it.
- Rank by user impact, reliability risk, dependency order, unblock value, reversibility, and implementation risk.
- Merge overlapping items instead of duplicating them.
- Preserve useful detail when rewriting, especially rationale, constraints, file paths, and evidence.
- Prune shipped, obsolete, or contradicted items. If shipped work remains useful as context, move it to a brief completed/shipped section instead of leaving it in the active backlog.
- If an item is uncertain, stale, or not validated by the repo, either lower its priority, move it to open questions, or label the assumption plainly.
- Never silently delete a meaningful user request unless the repo proves it is already done or no longer relevant.
- Be idempotent: if a second pass finds no substantive todo changes, leave `TODO.md` unchanged and say that no update was needed.
- Do not churn the file for formatting-only, wording-only, or review-date-only changes unless the user explicitly asks for that cleanup.

## Priority Rules

- `P0`: trust, data safety, broken core flows, security/privacy, severe regressions, or work that blocks most other progress.
- `P1`: high-value product capability, important reliability work, or architectural separation that unlocks multiple fixes.
- `P2`: localized defects, polish, cleanup, or speculative improvements with limited blast radius.
- `Shipped` or `Completed`: work that is already implemented and only remains as context.
- `Open Questions`: decisions that should not be forced without missing product or architecture input.

## Sequencing Rules

- Prefer fixes that protect user data and core workflows before speculative features.
- Prefer foundational refactors only when they unlock concrete fixes or reduce risk in imminent work.
- Put dependency work before features that rely on it.
- Call out conflicts, such as two items changing the same subsystem in incompatible ways.
- If a new request overlaps an existing item, fold it into the stronger item and update the wording.
- If a new request changes the best next step, update `Next Up` and explain why.

## Recommended Structure

Preserve a repo's existing useful structure when it is already strong. If creating a new `TODO.md`, or when the existing list is too weak, use this shape:

```markdown
# TODO

This file was last reviewed against the current codebase on YYYY-MM-DD.

## Next Up

- Implement or investigate the single best next item.
  - Why this is next:
    - [reason grounded in repo state]
  - Expected implementation shape:
    - [concrete shape or boundaries]
  - Immediate follow-up after this:
    - [next dependent item]

## High-Priority Work

### P0

- [Item]
  - Evidence:
    - [repo evidence, user request, or observed behavior]
  - Sequencing:
    - [dependencies or conflicts]

### P1

- [Item]

### P2

- [Item]

## Confirmed Defects

- [Bug or regression grounded in files, tests, or observed behavior]

## Confirmed Design Debt

- [Debt that increases risk or slows upcoming work]

## Refactors That Unlock Fixes

- [Refactor tied to concrete future fixes]

## Shipped or No Longer Active

- [Only keep completed items when useful as context]

## Open Questions

- [Decision or ambiguity that needs input]
```

## Update Checklist

Before finishing an update:

- Every active item belongs in exactly one best section.
- `Next Up` names one item and explains why it outranks the rest.
- New user requests were checked against existing items for overlap and conflict.
- Completed work was pruned or moved out of active sections.
- Priority labels reflect current repo reality, not historical urgency.
- No change was written if the current `TODO.md` was already accurate and well ordered.
- The final document is easier to act on than the previous one.
