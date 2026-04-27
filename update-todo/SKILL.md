---
name: update-todo
description: >-
  Update, prune, refresh, add to, stack-rank, or resequence an existing
  repository TODO.md. Use when the user asks to update todos, add a todo item,
  clean up the backlog, prune completed work, rerank priorities, or integrate a
  new request into the todo list.
---

# Update Todo

Maintain an existing repository-root `TODO.md` as a current, prioritized decision document.

## Workflow

1. Read the existing root `TODO.md`. If it is missing or unusable, follow the `create-todo` workflow instead.
2. Read `../references/todo-list-rubric.md` from this skills repo.
3. Inspect enough repo context to validate the list:
   - current docs and architecture notes
   - recent plans or completed work
   - relevant files for items being changed
   - lightweight code search for shipped, stale, or conflicting work
4. Choose the correct mode:
   - Maintenance mode: if the user only asked to update/prune/refresh, prune completed or obsolete items, update stale wording, rerank priorities, and improve `Next Up`.
   - Integration mode: if the user included a new request, merge it into the best existing item or add it in the right section and priority.
5. Check for overlap, dependency order, conflicts, and whether the new state changes `Next Up`.
6. If the current `TODO.md` is already accurate, well ordered, and unchanged by the request, leave it untouched and report that no update was needed.
7. Edit `TODO.md` in place only when there is a substantive change.
8. Run a brief `$double-check-work` pass before finishing.

## Quality Rules

- Do not append blindly.
- Do not silently delete uncertain user requests; move them to open questions or lower priority when needed.
- Preserve useful rationale, file paths, evidence, and sequencing notes.
- Remove active items only when they are shipped, obsolete, duplicated, or contradicted by repo evidence.
- If a new request conflicts with existing planned work, name the conflict and sequence the safer path.
- Keep the todo list shorter, sharper, and more actionable after every update.
- Be idempotent: do not rewrite for formatting-only, wording-only, or review-date-only changes unless the user asks for cleanup.
