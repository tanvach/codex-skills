# codex-skills

Personal agent skills tracked in git, with top-level `SKILL.md` folders as the source of truth.

This repo can drive four tools from one source:

- Codex skills linked into `~/.codex/skills`
- Claude Code custom slash commands linked into `~/.claude/commands`
- Gemini CLI skills linked into `~/.gemini/skills` (Gemini CLI auto-promotes each installed skill to a `/<name>` slash command, so no separate TOML install is needed)
- Antigravity skills linked into `~/.gemini/antigravity/skills` (Antigravity auto-promotes each installed skill to a `/<name>` slash command, same as Gemini CLI)

Note that Gemini CLI and Antigravity use *different* paths under `~/.gemini/`. One symlink does not cover both — they get separate installers.

Claude command files are generated from the source skill folders and should not be edited by hand.

## Layout

- Top-level skill folders such as `double-check-work/` and `sync-skills/` are the canonical source.
- `scripts/lib/skill_meta.sh` holds the shared frontmatter helpers (`strip_frontmatter`, `extract_description`) used by the generator.
- `scripts/create_claude_skills.sh` generates derived Claude command files under `generated/claude-commands/`.
- `scripts/install_codex_skills.sh` symlinks source skill folders into Codex.
- `scripts/install_claude_skills.sh` symlinks generated Claude command files into Claude Code.
- `scripts/install_gemini_skills.sh` symlinks source skill folders into Gemini CLI.
- `scripts/install_antigravity_skills.sh` symlinks source skill folders into Antigravity.
- `install.sh` is a backward-compatible wrapper for Codex installs only.

## Codex Only

Clone this repo and run:

```bash
./install.sh
```

To preview changes without mutating anything:

```bash
./scripts/install_codex_skills.sh --check
```

To remove stale repo-managed Codex links for deleted skills:

```bash
./scripts/install_codex_skills.sh --prune
```

## Claude Only

Generate the commands and install them:

```bash
./scripts/create_claude_skills.sh
./scripts/install_claude_skills.sh
```

To preview changes:

```bash
./scripts/create_claude_skills.sh --check
./scripts/install_claude_skills.sh --check
```

To remove stale repo-managed Claude command links after deletions:

```bash
./scripts/install_claude_skills.sh --prune
```

## Gemini CLI Only

Gemini CLI's skill loader auto-promotes each installed skill to a `/<name>` slash command, so a single install covers both semantic discovery and `/` invocation:

```bash
./scripts/install_gemini_skills.sh
```

To preview changes:

```bash
./scripts/install_gemini_skills.sh --check
```

To remove stale links:

```bash
./scripts/install_gemini_skills.sh --prune
```

Run `/commands reload` in an active Gemini CLI session to pick up new skills, or restart.

## Antigravity Only

Antigravity's skill loader auto-promotes each installed skill to a `/<name>` slash command, so a single install covers both semantic discovery and `/` invocation:

```bash
./scripts/install_antigravity_skills.sh
```

To preview changes:

```bash
./scripts/install_antigravity_skills.sh --check
```

To remove stale links:

```bash
./scripts/install_antigravity_skills.sh --prune
```

Restart Antigravity to pick up new skills.

## Sync All

From the repo root, either run the scripts directly:

```bash
./scripts/create_claude_skills.sh
./scripts/install_codex_skills.sh
./scripts/install_claude_skills.sh
./scripts/install_gemini_skills.sh
./scripts/install_antigravity_skills.sh
```

Or invoke the `sync-skills` skill or the `/sync-skills` command from inside this repo.

If you deleted a source skill and want the old links cleaned up too:

```bash
./scripts/install_codex_skills.sh --prune
./scripts/install_claude_skills.sh --prune
./scripts/install_gemini_skills.sh --prune
./scripts/install_antigravity_skills.sh --prune
```

## Adding or Updating Skills

1. Add or edit a top-level source skill folder with `SKILL.md`.
2. If Claude needs different wording, add `claude.override.md` inside that skill folder. The override is consumed only by the Claude command generator; it does not affect the other tools.
3. Run the generators and installers again (see "Sync All").
4. Restart the relevant tool if the new command, skill, or workflow does not appear immediately.

When a new skill is added, rerunning sync will generate new derived files and link them into every tool. When a skill is removed, run the prune variants of the install scripts to remove stale repo-managed links.

## Included Workflow Skills

- `create-todo` creates a carefully ranked root `TODO.md` when a repo has no strong todo list yet.
- `update-todo` prunes, reranks, and integrates new requests into an existing root `TODO.md`.
- `execplan-create` creates an ExecPlan from a brief, PRD, RFC, or locked refactor decision.
- `execplan-improve` audits an existing ExecPlan against real code and rewrites only code-grounded improvements.
- `execplan-portability-check` scores an ExecPlan for portability to a fresh implementer with no conversation history. Use before handing a plan off to a different model or session.
- `implement-execplan` executes a work-item ExecPlan or legacy singleton plan.
- `walk-through-changes` explains completed implementation work so a human can validate the structure.
- `find-refactor-candidates` creates a materially different refactor shortlist under `.agent/work/`.
- `select-refactor` challenges a shortlist and locks the final refactor decision before planning.
- `refactor-something` is the one-shot shortcut for a single consolidation refactor recommendation.
- `sync-skills` regenerates derived files and installs managed links for all four tools.

## ExecPlan Workflows

For small or direct implementation requests, use the legacy-compatible singleton flow:

```bash
$execplan-create
$implement-execplan
```

That flow writes `.agent/execplan-pending.md` and, after implementation, archives the completed plan under `.agent/done/`.

For larger refactors or architectural simplification work, use the staged workflow:

```bash
$find-refactor-candidates
$select-refactor
$execplan-create
$execplan-improve
$execplan-portability-check
$implement-execplan
```

`$execplan-portability-check` is optional but recommended if you plan to hand the plan off to a different model or run `$implement-execplan` in a fresh session. It audits the plan in isolation and reports where conversation context has leaked into prose.

That flow keeps initiative artifacts under `.agent/work/<id-slug>/`:

- `meta.json` tracks lifecycle state.
- `candidates.md` records the shortlist and assumption ledger.
- `decision.md` locks the chosen refactor.
- `execplan.md` is the executable plan.

`refactor-something` remains available as a one-shot shortcut when the user wants a decisive single recommendation without the staged candidate and decision artifacts.

## Generated Files

- `generated/claude-commands/*.md` — Claude Code slash commands.
- Do not edit generated files directly unless you intentionally want a one-off local change.
- Prefer editing the source `SKILL.md` or `claude.override.md` and regenerating.
