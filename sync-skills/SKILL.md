---
name: sync-skills
description: >-
  Sync this skills repository across Codex and Claude Code by generating Claude
  commands from the source skills and installing or pruning the managed links.
  Use when the user wants to sync skills, regenerate Claude commands, install
  updated skills, or check what would change.
---

# Sync Skills

Use this skill from the root of the skills repository. Treat the top-level Codex skill folders as the source of truth.

## What to do

1. Confirm you are in the skills repo that contains `scripts/create_claude_skills.sh`.
2. If the user asked for a dry run or check, run:
   - `./scripts/create_claude_skills.sh --check`
   - `./scripts/install_codex_skills.sh --check`
   - `./scripts/install_claude_skills.sh --check`
3. Otherwise run:
   - `./scripts/create_claude_skills.sh`
   - `./scripts/install_codex_skills.sh`
   - `./scripts/install_claude_skills.sh`
4. If the user asked to clean up deleted skills or commands, add `--prune` to both install scripts.
5. Summarize what changed, what was skipped, and any follow-up such as restarting Codex or Claude Code.

## Rules

- Do not edit generated Claude command files by hand unless the user explicitly asks.
- Prefer changing the source `SKILL.md` files or `claude.override.md` files, then rerun sync.
- If a script fails, stop and report the exact failing step.
