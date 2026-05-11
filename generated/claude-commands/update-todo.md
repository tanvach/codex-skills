---
description: "Update, prune, refresh, add to, stack-rank, or resequence an existing repository TODO.md. Use when the user asks to update todos, add a todo item, clean up the backlog, prune completed work, rerank priorities, or integrate a new request into the todo list."
---

<!-- Generated from update-todo. Do not edit directly. -->

Maintain an existing repository-root `TODO.md` as a current, prioritized decision document.

Workflow:
- Read the existing root `TODO.md`. If it is missing or unusable, create one instead.
- Inspect enough repo context to validate the list: docs, architecture notes, the most recent completed plans under `.agent/done/` (their `Surprises & Discoveries` and `Outcomes & Retrospective` sections carry follow-up work surfaced during execution), relevant files, and lightweight code search results.
- If the user only asked to update, prune, or refresh, prune completed or obsolete items, update stale wording, rerank priorities, and improve `Next Up`.
- If the user included a new request, merge it into the best existing item or add it in the right section and priority.
- Check for overlap, dependency order, conflicts, and whether the new state changes `Next Up`.
- If the current `TODO.md` is already accurate, well ordered, and unchanged by the request, leave it untouched and report that no update was needed.
- Edit `TODO.md` in place only when there is a substantive change.

Rules:
- Do not append blindly.
- Do not silently delete uncertain user requests; move them to open questions or lower priority when needed.
- Preserve useful rationale, file paths, evidence, and sequencing notes.
- Remove active items only when they are shipped, obsolete, duplicated, or contradicted by repo evidence.
- If a new request conflicts with existing planned work, name the conflict and sequence the safer path.
- Keep the todo list shorter, sharper, and more actionable after every update.
- Do not rewrite for formatting-only, wording-only, or review-date-only changes unless explicitly asked.
