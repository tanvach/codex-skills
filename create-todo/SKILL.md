---
name: create-todo
description: >-
  Create a high-quality root TODO.md, roadmap, backlog, or prioritized task
  list when a repository has no useful todo list or the existing one is too
  weak. Use when the user asks to create a todo list, make a roadmap, seed a
  backlog, or organize future work.
---

# Create Todo

Create a repository-root `TODO.md` that is prioritized, sequenced, and grounded in the current repo.

## Workflow

1. Read `../references/todo-list-rubric.md` from this skills repo.
2. Inspect the target repo before writing:
   - existing `TODO.md` or TODO-like files
   - `README.md`, `ARCHITECTURE.md`, `PLANS.md`, `.agent/`, and recent completed plans when present
   - lightweight code search for visible defects, TODO comments, brittle areas, and shipped work
3. Decide whether to preserve an existing useful structure or create the recommended structure from the rubric.
4. If a useful `TODO.md` already exists and no substantive changes are needed, leave it unchanged and report that it is already in good shape.
5. Create or replace the root `TODO.md` only when the repo lacks a useful todo list or the current file needs substantive restructuring, with:
   - one clear `Next Up`
   - priority buckets
   - confirmed defects and design debt when supported by repo evidence
   - refactors that unlock concrete fixes
   - shipped/no-longer-active context only when useful
   - open questions for uncertain decisions
6. Run a brief `$double-check-work` pass before finishing.

## Quality Rules

- Do not invent tasks unsupported by the repo, user request, or existing docs.
- Record assumptions when context is thin.
- Prefer fewer, better-ranked items over a long undifferentiated list.
- Explain sequencing where order matters.
- If the repo already has a strong todo format, improve within that format instead of forcing the template.
- Be idempotent: do not rewrite for formatting-only, wording-only, or review-date-only changes unless the user asks for cleanup.
