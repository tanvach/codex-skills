# Add Source-of-Truth Todo Skills

## Goal

Create two reusable skills, `create-todo` and `update-todo`, that help maintain a high-quality root `TODO.md` for a repository. The skills should do more than append items: they should create or update a carefully sequenced, stack-ranked todo list that accounts for priority, dependencies, conflicts, shipped work, design debt, and the current codebase state. The intended outcome is that a user can ask for todo maintenance once and get a coherent roadmap-style `TODO.md` like the existing `/Users/tanvach/GitHub/toddler_learning/TODO.md`, without needing repeated follow-up prompts to rank, prune, and sequence the work.

## Scope

In scope are two new Codex skills in `/Users/tanvach/GitHub/codex-skills`: `create-todo` for creating a root `TODO.md` when one is missing or clearly inadequate, and `update-todo` for maintaining an existing todo list. Also in scope is a shared reference file that both skills use for the preferred document shape, ranking rules, pruning rules, and sequencing rubric. The skills should be source-of-truth Codex skills that participate in the existing `sync-skills` workflow so generated Claude commands are produced automatically.

Out of scope are building a deterministic todo parser or separate CLI tool, introducing external task-management integrations, or making the skills rewrite project issue trackers. The first version should stay instruction-driven because the judgment required is editorial and repository-specific. If the skills later become repetitive or fragile, a script can be added in a follow-up.

This plan assumes `TODO.md` usually lives at the target repository root and that the toddler-learning `TODO.md` is the current best example of the desired style.

## Current State

The skills repo currently stores top-level source skill folders such as `/Users/tanvach/GitHub/codex-skills/double-check-work`, `/Users/tanvach/GitHub/codex-skills/execplan-create`, and `/Users/tanvach/GitHub/codex-skills/sync-skills`. The repo also has a sync pipeline: `/Users/tanvach/GitHub/codex-skills/scripts/create_claude_skills.sh` generates Claude commands into `/Users/tanvach/GitHub/codex-skills/generated/claude-commands`, `/Users/tanvach/GitHub/codex-skills/scripts/install_codex_skills.sh` installs Codex symlinks, and `/Users/tanvach/GitHub/codex-skills/scripts/install_claude_skills.sh` installs Claude command symlinks.

There is no todo-specific skill yet. In `/Users/tanvach/GitHub/toddler_learning/TODO.md`, the desired output style is visible: a dated cleanup note, a `Next Up` section, priority groupings such as `High-Priority Reliability Features`, defect and design-debt sections, P0/P1/P2 ranking, explicit reasoning under major items, shipped-work separation, and careful notes about dependencies and sequencing. The important behavior is not the exact headings alone; it is the habit of comparing new work against existing todo items and keeping the document useful as a decision tool.

## Target State

`create-todo` should trigger when a user asks to create a todo list, roadmap, backlog, or root `TODO.md`, especially when the repository does not already have a useful one. It should inspect the repository, read available planning and architecture docs such as `README.md`, `ARCHITECTURE.md`, `PLANS.md`, `.agent/done`, open TODO-like files, and lightweight code search results. Then it should create a root `TODO.md` with a strong initial structure: `Next Up`, priority buckets, defects, design debt, refactors that unlock fixes, shipped or completed items if applicable, and open questions. It should explicitly choose the next item and explain why.

`update-todo` should trigger when a user asks to update, prune, refresh, re-rank, add to, or maintain a todo list. With no extra request, it should read the existing `TODO.md`, compare it against the current repo state, prune completed or obsolete items, update stale descriptions, re-rank work, and improve sequencing. When the user includes a specific new request, it should integrate that request into the existing todo list instead of simply appending it. It should check for conflicts, dependencies, overlap with existing items, and whether the new request should change `Next Up` or priority ordering.

Both skills should share a concise reference file, for example `/Users/tanvach/GitHub/codex-skills/references/todo-list-rubric.md`, that defines the preferred TODO shape and the ranking rules. Each skill should keep its own `SKILL.md` short and point to the shared reference only when needed. Both skills should include `agents/openai.yaml` metadata so they are easy to invoke from the Codex UI. Running `sync-skills` after implementation should generate Claude commands for both skills and install them into both tools.

## Implementation Plan

First, add a shared reference folder and rubric. Create `/Users/tanvach/GitHub/codex-skills/references/todo-list-rubric.md`. This file should capture the reusable editorial rules: inspect the repo before editing, treat the todo as a prioritized decision document, keep one clear `Next Up`, rank work by user impact and dependency order, avoid duplicate items, merge overlapping work, prune shipped work into a completed section only when it remains useful, and preserve useful detail when rewriting. Include a recommended `TODO.md` skeleton based on `/Users/tanvach/GitHub/toddler_learning/TODO.md`, but state that existing project structure wins when the repo already has a good todo format.

Next, create `/Users/tanvach/GitHub/codex-skills/create-todo/SKILL.md`. Its frontmatter description should mention creating a root `TODO.md`, roadmap, backlog, or prioritized task list when none exists or the existing one is too weak. The workflow should require reading the shared todo rubric, inspecting the target repo, identifying existing shipped work and current architecture constraints, creating `TODO.md` at the repository root, and running a short final consistency check. The skill should avoid inventing tasks unsupported by the repo and should record assumptions when the repo context is thin.

Then, create `/Users/tanvach/GitHub/codex-skills/update-todo/SKILL.md`. Its frontmatter description should mention updating, pruning, refreshing, adding to, stack-ranking, or sequencing an existing todo list. The workflow should require reading the current `TODO.md`, reading the shared rubric, inspecting enough repo context to validate the list, and then editing the file. It should have two explicit modes: maintenance mode when the user gives no new request, and integration mode when the user gives a new item or command. In maintenance mode, prune stale/completed items, update priorities, and improve `Next Up`. In integration mode, place the new request where it belongs, merge with overlapping items, identify conflicts, and adjust sequencing.

After the two source skills are in place, add UI metadata. Create `/Users/tanvach/GitHub/codex-skills/create-todo/agents/openai.yaml` and `/Users/tanvach/GitHub/codex-skills/update-todo/agents/openai.yaml`. Use short display names like `Create Todo` and `Update Todo`, short descriptions within the existing style, and default prompts that explicitly mention `$create-todo` or `$update-todo`.

Then, run the existing sync workflow from `/Users/tanvach/GitHub/codex-skills`: `./scripts/create_claude_skills.sh`, `./scripts/install_codex_skills.sh`, and `./scripts/install_claude_skills.sh`. This should generate `/Users/tanvach/GitHub/codex-skills/generated/claude-commands/create-todo.md` and `/Users/tanvach/GitHub/codex-skills/generated/claude-commands/update-todo.md`, then install the new Codex and Claude links. Do not hand-edit generated Claude command files.

Finally, update `/Users/tanvach/GitHub/codex-skills/README.md` if needed to mention the new todo skills in a short examples section. Keep the README brief; the skill bodies and shared reference should carry the behavior.

## Validation

Run `bash -n` on the existing scripts after implementation to make sure no sync script was accidentally broken. Run `./scripts/create_claude_skills.sh --check` before generation if generated files already exist, then run `./scripts/create_claude_skills.sh` and confirm the generated Claude commands for `create-todo` and `update-todo` appear under `/Users/tanvach/GitHub/codex-skills/generated/claude-commands/`.

Run `./scripts/install_codex_skills.sh --check` and confirm it would link or skip `create-todo` and `update-todo` correctly. Then run the real installer if the check output looks right. Repeat with `./scripts/install_claude_skills.sh --check` and the real Claude installer.

Validate skill quality by reading the final `SKILL.md` files and the shared rubric. Confirm that `create-todo` clearly handles missing or weak `TODO.md`, while `update-todo` clearly handles both maintenance mode and integration mode. Confirm that both skills instruct the agent to inspect repo context before editing and to preserve or improve sequencing rather than appending blindly.

For a practical smoke test, use a temporary copy of a small repo or a throwaway directory with a minimal `README.md`. Invoke the planned behavior mentally or with a dry-run prompt if available: `create-todo` should produce a structured root `TODO.md`, and `update-todo` with a sample new item should place the item in a priority bucket with dependency reasoning. If testing against `/Users/tanvach/GitHub/toddler_learning/TODO.md`, do not mutate it during validation unless explicitly requested; inspect it only as the style reference.

## Risks

The main risk is making the skills too generic, so they become glorified checklist appenders. Mitigate this by putting the ranking, pruning, conflict-checking, and `Next Up` rules directly in the shared rubric and keeping both skill workflows explicit about repo inspection. Another risk is making the skills too rigid around the toddler-learning TODO structure. Mitigate this by treating that file as a strong example while still preserving a repo’s existing good structure when present. A third risk is over-editing user-owned todo lists. Mitigate this by instructing `update-todo` to preserve useful detail, avoid deleting uncertain items, and move questionable items into open questions or lower-priority sections rather than dropping them silently.

## Progress

- [x] Add a shared todo-list rubric reference with structure, ranking, sequencing, pruning, and conflict-checking rules.
- [x] Add the `create-todo` source skill and UI metadata.
- [x] Add the `update-todo` source skill and UI metadata.
- [x] Regenerate Claude commands and install/sync the new skills through the existing scripts.
- [x] Validate generated files, installed links, and the skills’ behavior against the toddler-learning `TODO.md` style.
