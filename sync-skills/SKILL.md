---
name: sync-skills
description: >-
  Sync this skills repository across Codex, Claude Code, Gemini CLI, and
  Antigravity by generating derived command files from the source skills and
  installing or pruning the managed links. Use when the user wants to sync
  skills, regenerate commands or workflows, install updated skills, or check
  what would change.
---

# Sync Skills

Use this skill from the root of the skills repository. Treat the top-level skill folders as the source of truth; everything under `generated/` is derived.

## What to do

1. Confirm you are in the skills repo that contains `scripts/create_claude_skills.sh`.
2. If the user asked for a dry run or check, run each script with `--check`:
   - `./scripts/create_claude_skills.sh --check`
   - `./scripts/install_codex_skills.sh --check`
   - `./scripts/install_claude_skills.sh --check`
   - `./scripts/install_gemini_skills.sh --check`
   - `./scripts/install_antigravity_skills.sh --check`
3. Otherwise run the same five scripts without `--check`. Run the generator before any installer; the four installers can run in any order after that.
4. If the user asked to clean up deleted skills or commands, add `--prune` to every install script (the generators handle their own stale cleanup).
5. Summarize what changed, what was skipped, and any follow-up such as restarting Codex, Claude Code, Gemini CLI, or Antigravity.

## Rules

- Do not edit files under `generated/claude-commands/` by hand unless the user explicitly asks.
- Prefer changing the source `SKILL.md` files (or `claude.override.md` files), then rerun sync.
- If a script fails, stop and report the exact failing step.
