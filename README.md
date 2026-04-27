# codex-skills

Personal agent skills tracked in git, with Codex `SKILL.md` folders as the source of truth.

This repo can now drive both:

- Codex skills linked into `~/.codex/skills`
- Claude Code custom slash commands linked into `~/.claude/commands`

Claude commands are generated from the source skill folders and should not be edited by hand.

## Layout

- Top-level skill folders such as `double-check-work/` and `sync-skills/` are the canonical source.
- `scripts/create_claude_skills.sh` generates derived Claude command files under `generated/claude-commands/`.
- `scripts/install_codex_skills.sh` links source skill folders into Codex.
- `scripts/install_claude_skills.sh` links generated Claude command files into Claude Code.
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

## Sync Both

From the repo root, either run the scripts directly:

```bash
./scripts/create_claude_skills.sh
./scripts/install_codex_skills.sh
./scripts/install_claude_skills.sh
```

Or invoke the `sync-skills` skill or Claude `/sync-skills` command from inside this repo.

If you deleted a source skill and want the old links cleaned up too:

```bash
./scripts/install_codex_skills.sh --prune
./scripts/install_claude_skills.sh --prune
```

## Adding or Updating Skills

1. Add or edit a top-level source skill folder with `SKILL.md`.
2. If Claude needs different wording, add `claude.override.md` inside that skill folder.
3. Run the generator and installers again.
4. Restart Codex or Claude Code if the new command or skill does not appear immediately.

When a new skill is added, rerunning sync will generate a new Claude command file and link it into both tools. When a skill is removed, run the prune variants of the install scripts to remove stale repo-managed links.

## Included Workflow Skills

- `create-todo` creates a carefully ranked root `TODO.md` when a repo has no strong todo list yet.
- `update-todo` prunes, reranks, and integrates new requests into an existing root `TODO.md`.
- `sync-skills` regenerates Claude commands and installs managed links for both tools.

## Generated Files

- `generated/claude-commands/*.md` are derived artifacts.
- Do not edit generated files directly unless you intentionally want a one-off local change.
- Prefer editing the source `SKILL.md` or `claude.override.md` and regenerating.
