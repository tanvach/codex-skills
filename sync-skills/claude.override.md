Run this command from the root of the skills repository.

Tasks:
- Treat the top-level skill folders as the source of truth.
- Run `./scripts/create_claude_skills.sh $ARGUMENTS`.
- Run `./scripts/install_codex_skills.sh $ARGUMENTS`.
- Run `./scripts/install_claude_skills.sh $ARGUMENTS`.
- Run `./scripts/install_gemini_skills.sh $ARGUMENTS`.
- Run `./scripts/install_antigravity_skills.sh $ARGUMENTS`.
- Summarize what changed, what was skipped, and whether Codex, Claude Code, Gemini CLI, or Antigravity should be restarted.

Rules:
- Do not edit files under `generated/` by hand unless explicitly asked.
- If a script fails, stop and report the exact failing step.
