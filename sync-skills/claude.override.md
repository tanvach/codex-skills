Run this command from the root of the skills repository.

Tasks:
- Treat the top-level Codex skill folders as the source of truth.
- Run `./scripts/create_claude_skills.sh $ARGUMENTS`.
- Run `./scripts/install_codex_skills.sh $ARGUMENTS`.
- Run `./scripts/install_claude_skills.sh $ARGUMENTS`.
- Summarize what changed, what was skipped, and whether Codex or Claude Code should be restarted.

Rules:
- Do not edit generated Claude command files by hand unless explicitly asked.
- If a script fails, stop and report the exact failing step.
