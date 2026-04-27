Create a repository-root `TODO.md` that is prioritized, sequenced, and grounded in the current repo.

Workflow:
- Inspect the repo before writing: existing TODO-like files, `README.md`, `ARCHITECTURE.md`, `PLANS.md`, `.agent/`, recent completed plans, and lightweight code search results.
- Treat `TODO.md` as a decision document, not a dumping ground.
- Create one clear `Next Up` recommendation with reasoning.
- Rank work by user impact, reliability risk, dependency order, unblock value, reversibility, and implementation risk.
- Include priority buckets, confirmed defects, confirmed design debt, refactors that unlock fixes, shipped/no-longer-active context when useful, and open questions.
- Merge overlapping work and avoid duplicate items.
- Do not invent tasks unsupported by repo evidence, docs, or the user request.
- If the repo already has a strong todo format, improve within that format instead of forcing a template.
- If a useful `TODO.md` already exists and no substantive changes are needed, leave it unchanged and report that it is already in good shape.
- Do not rewrite for formatting-only, wording-only, or review-date-only changes unless explicitly asked.

Before finishing, double-check that the list is easier to act on than a plain checklist and that every major item has an appropriate priority and sequence.
