# Add Gemini CLI and Antigravity targets to the skills sync pipeline

## Goal

Today this repo syncs personal agent skills into Codex (`~/.codex/skills/`) and Claude Code (`~/.claude/commands/`) from one canonical source — a top-level skill folder containing a `SKILL.md`. The user also runs Gemini CLI and Google Antigravity. After this change, a single `sync-skills` invocation installs every skill into all four tools, with each skill appearing as both a semantic-discovery skill **and** a user-typeable slash command in every tool that supports them. The reader should be able to type `/double-check-work` (or its equivalent) in Codex, Claude Code, Gemini CLI, and Antigravity and have the same instructions fire — without ever editing more than one source `SKILL.md`.

The interface burden this removes: the user currently has no path to install these skills into Gemini CLI or Antigravity at all. They would otherwise hand-author per-tool files and keep four copies in sync. This change collapses all four targets behind one source folder and one `sync-skills` command, so a new skill or a wording fix is a single edit in a single file.

## Scope

In scope:

- Two new "skill" install paths: Gemini CLI (`~/.gemini/skills/`) and Antigravity (`~/.gemini/antigravity/skills/`). Both consume the source `SKILL.md` directly via symlink, the same shape as the existing Codex installer.
- Two new "slash command" generators and install paths: Gemini CLI TOML commands (`~/.gemini/commands/<name>.toml`) and Antigravity workflows (`~/.gemini/antigravity/global_workflows/<name>.md`). Both are derived artifacts written under `generated/` and installed by symlinking those derived files into the tool directory, the same shape as the existing Claude commands flow.
- A small refactor that hoists the AWK frontmatter helpers (`strip_frontmatter`, `extract_description`) out of `scripts/create_claude_skills.sh` into a shared file the three generators all source. This is required, not optional: a pre-existing bug in `extract_description` (described in Current State) will otherwise propagate into the new generators.
- Updates to `sync-skills/SKILL.md` **and** `sync-skills/claude.override.md` so a single run drives all five generators/installers. Both files matter: `SKILL.md` is the canonical Codex-side instruction, and the `.override.md` is what Claude runs when the user types `/sync-skills`.
- README updates so the layout, paths, and 4-tool sync are documented.

Out of scope:

- Rewriting `$skill-name` references in skill bodies. Per the user, they stay literal for now. Claude's existing `$X → /X` rewrite remains as-is. Gemini CLI's TOML body and Antigravity's workflow body will contain `$skill-name` verbatim — semantic discovery handles invocation in skill mode, and prose intent handles it in slash-command mode.
- Per-target body override files (`gemini.override.md`, `antigravity.override.md`). Not needed for any current skill; defer until a real wording conflict appears. (Note: `sync-skills/claude.override.md` already exists for a different reason — it injects Claude's `$ARGUMENTS` slash-command syntax — and stays.)
- Migrating Claude Code from slash commands (`~/.claude/commands/`) to its native skills directory (`~/.claude/skills/`). The current Claude path keeps working untouched.
- The Gemini CLI TOML command's argument-injection features (`{{args}}`, `!{...}`, `@{...}`). Skills don't currently take args; commands will be argless prompts.

Material assumption: the Antigravity global workflows path is `~/.gemini/antigravity/global_workflows/`. This is documented but appears in fewer sources than the skills path, so the installer will create the directory if absent and the user verifies on first run that workflows surface in the `/` menu.

## Current State

Source layout (canonical):

- One folder per skill at the repo root: `architecture-docs-creator/`, `create-todo/`, `double-check-work/`, `execplan-create/`, `execplan-improve/`, `find-refactor-candidates/`, `implement-execplan/`, `refactor-something/`, `select-refactor/`, `sync-skills/`, `update-architecture-docs/`, `update-todo/`, `walk-through-changes/` — 13 skills total.
- Each folder contains `SKILL.md` with YAML frontmatter (`name`, `description`) and a Markdown body. The frontmatter follows the Anthropic-originated Agent Skills open standard — the same standard Gemini CLI and Antigravity adopted.
- Some folders contain optional siblings: `agents/openai.yaml` (Codex display metadata, ignored by other tools), `claude.override.md` (Claude-specific body override; only `sync-skills/` uses it today), `references/`.

**Important variant in source frontmatter:** 12 of the 13 source `SKILL.md` files use the YAML folded scalar `description: >-` followed by indented continuation lines. One — [architecture-docs-creator/SKILL.md](architecture-docs-creator/SKILL.md) — uses plain single-line `description: ...`. Both are valid YAML but the existing extractor handles only the folded form (see bug below).

Existing pipeline (verified by reading the scripts):

- [scripts/create_claude_skills.sh](scripts/create_claude_skills.sh) reads each `SKILL.md`, strips frontmatter, rewrites `$skill-name` to `/skill-name` via Perl, and writes `generated/claude-commands/<name>.md` with a Claude-style frontmatter block (`description` only). Removes stale generated files. Has a `--check` mode.
- [scripts/install_codex_skills.sh](scripts/install_codex_skills.sh) symlinks each top-level skill folder into `${CODEX_HOME:-$HOME/.codex}/skills/<name>` using `ln -s`. When a target path already exists and is not the expected symlink, it is moved to a timestamped backup at `$CODEX_HOME/skill-backups/<YYYYMMDD-HHMMSS>/<name>` rather than overwritten. The `--prune` mode walks the target dir, calls `readlink` on each entry, and removes entries whose link target lies under this repo's root and no longer exists. Has `--check` and `--prune` modes.
- [scripts/install_claude_skills.sh](scripts/install_claude_skills.sh) follows the same shape: `ln -s` from each `generated/claude-commands/*.md` into `${CLAUDE_HOME:-$HOME/.claude}/commands/<name>.md`, with the same backup-on-conflict (`$CLAUDE_HOME/command-backups/<ts>/`) and the same readlink-based prune scoped to `generated_dir/*`. Both installers end by printing a "Restart <tool>" reminder line.
- [install.sh](install.sh) is a one-line wrapper around the Codex installer, kept for backward compatibility.
- [sync-skills/SKILL.md](sync-skills/SKILL.md) instructs the agent to run the three scripts in order. [sync-skills/claude.override.md](sync-skills/claude.override.md) is the Claude variant the user sees when they type `/sync-skills`; it uses the `$ARGUMENTS` placeholder so flags like `--check` flow through.

Two pre-existing facts worth surfacing because the new work touches them directly:

1. **`extract_description` in `create_claude_skills.sh:18-44` only matches `description: >-`**. For [architecture-docs-creator/SKILL.md](architecture-docs-creator/SKILL.md), which uses plain single-line `description: ...`, the helper returns empty. The current generated file [generated/claude-commands/architecture-docs-creator.md:2](generated/claude-commands/architecture-docs-creator.md) has `description: ""` as a result. Today this is a near-silent quality bug in Claude's `/help` listing; if the new generators inherit it unchanged, Antigravity's `/` dropdown will also show no description for that one skill, and Gemini CLI's `/help` likewise. The bug must be fixed before the new generators ship, otherwise we hand-write a regression into the new tools.
2. **The two installers do *not* use a separate marker file** to scope `--prune`. They scope it by inspecting symlink targets via `readlink`. Any new installer must follow the same model so `--prune` only touches links the matching script created.

Glossary used below:

- **Skill** — a folder containing `SKILL.md`. The agent picks it up by semantic match against `description`. The user does not type its name.
- **Slash command** — a single file the user types by name (e.g. `/double-check-work`). In Gemini CLI, it's a `.toml` file with a required `prompt` field. In Antigravity, it's a `.md` file called a "workflow."
- **Workflow** (Antigravity) — Antigravity's name for slash commands. Stored as `.md` files with YAML frontmatter (`description` required) and a Markdown body. Special comments like `// turbo` opt steps into auto-run; we do not use them.
- **TOML command** (Gemini CLI) — Gemini CLI's slash command. `.toml` file with required `prompt` and optional `description`.
- **Managed link** — a symlink owned by one of these install scripts. "Managed" is determined dynamically from where the symlink points (under this repo or under `generated/`), not from a marker file.

## Target State

After this change, a single run of the `sync-skills` skill (or the underlying scripts) produces:

- `~/.codex/skills/<name>/` — symlink to source folder. *(unchanged)*
- `~/.claude/commands/<name>.md` — symlink to `generated/claude-commands/<name>.md`. *(unchanged)*
- `~/.gemini/skills/<name>/` — **new**, symlink to source folder.
- `~/.gemini/commands/<name>.toml` — **new**, symlink to `generated/gemini-commands/<name>.toml`.
- `~/.gemini/antigravity/skills/<name>/` — **new**, symlink to source folder.
- `~/.gemini/antigravity/global_workflows/<name>.md` — **new**, symlink to `generated/antigravity-workflows/<name>.md`.

A user typing `/double-check-work` in Gemini CLI or Antigravity gets the same instructions as today's Codex/Claude users. An agent in any of the four tools that detects "the user wants me to verify my work" picks up the skill via description match without the user having to remember its name.

The boundary that becomes simpler: the entire fan-out is hidden behind `sync-skills`. The user edits one `SKILL.md` and runs one command. They never touch `~/.gemini/...` or `~/.claude/...` directly. Adding a fifth target later means adding one generator and one installer; no source file changes.

A second boundary tightens at the same time: the AWK frontmatter helpers move to `scripts/lib/skill_meta.sh` and the bug in `extract_description` is fixed there once. Three generators source one helper. Adding a sixth generator later does not require copy-pasting (and re-debugging) frontmatter parsing.

Concepts that disappear from the user's mental load: where each tool stores commands, what file extension each uses, what frontmatter shape each demands, and which tools are skill-shaped vs command-shaped. They edit `SKILL.md` and forget the rest.

## Implementation Plan

The work splits into six concrete steps. Steps 1, 2, 3, and the helper portion of step 4 land additively and leave the existing Codex/Claude flow working. The bug fix inside step 4 is the one place an existing tool's behavior changes (Claude's `architecture-docs-creator` command will get a populated description for the first time — see Risks).

**Step 1 — Add the Gemini CLI skills installer.**

New file: `scripts/install_gemini_skills.sh`. Model it directly on [scripts/install_codex_skills.sh](scripts/install_codex_skills.sh). Substitutions:

- `codex_home="${CODEX_HOME:-$HOME/.codex}"` → `gemini_home="${GEMINI_HOME:-$HOME/.gemini}"`
- `skills_dir="$codex_home/skills"` → `skills_dir="$gemini_home/skills"`
- `backup_root="$codex_home/skill-backups/$(date +%Y%m%d-%H%M%S)"` → `backup_root="$gemini_home/skill-backups/$(date +%Y%m%d-%H%M%S)"`
- Final printf: `Restart Gemini CLI to pick up newly added skills.`

Everything else — symlink-with-readlink-check, backup-on-conflict, prune scoped to `repo_root/*` link targets, `--check` and `--prune` flags, exit codes — is byte-for-byte the same logic. `chmod +x` the result.

Why this step is simple and complete on its own: Gemini CLI's skills directory consumes `SKILL.md` in the open-standard format the source already uses, so symlinking is sufficient. No transformation, no generator. Complexity hidden: format negotiation. The user keeps writing one `SKILL.md`.

**Step 2 — Add the Antigravity skills installer.**

New file: `scripts/install_antigravity_skills.sh`. Same shape as step 1. Substitutions:

- Reuse `gemini_home="${GEMINI_HOME:-$HOME/.gemini}"` (Antigravity stores under `~/.gemini/antigravity/`, not a top-level `.antigravity/`).
- `skills_dir="$gemini_home/antigravity/skills"`
- `backup_root="$gemini_home/antigravity/skill-backups/$(date +%Y%m%d-%H%M%S)"`
- Final printf: `Restart Antigravity to pick up newly added skills.`

**Step 3 — Hoist frontmatter helpers into a shared library and fix `extract_description`.**

New file: `scripts/lib/skill_meta.sh`. Move the bodies of `strip_frontmatter` and `extract_description` from `scripts/create_claude_skills.sh:9-16` and `scripts/create_claude_skills.sh:18-44` into this file unchanged in name and signature, so callers source it and call the functions identically.

Fix in the same pass: extend `extract_description` to handle the plain single-line form. The current AWK only collects when it sees `description:[[:space:]]*>-`. The fix: when the AWK encounters a `description:` line that does *not* match the folded form, capture the inline value (everything after `description:[[:space:]]*`), strip surrounding whitespace and surrounding quotes if present, and treat that as the value. Verify against [architecture-docs-creator/SKILL.md](architecture-docs-creator/SKILL.md): the helper must return `Create a complete ARCHITECTURE.md before any implementation. Use when a user asks for system architecture, architectural design, or an ARCHITECTURE.md for a new or existing project, especially before coding or refactoring.` instead of the empty string it returns today.

Edit `scripts/create_claude_skills.sh` to source the new helper file (`. "$repo_root/scripts/lib/skill_meta.sh"` near the top, after `repo_root` is computed) and delete the two now-duplicated function definitions. Re-run the script and confirm `generated/claude-commands/architecture-docs-creator.md` updates from `description: ""` to the populated string. This single output diff is the proof the fix works; everything else stays byte-identical.

This step is what unblocks steps 4 and 5: both new generators source the same helper.

**Step 4 — Add the Gemini CLI TOML commands generator and installer.**

New file: `scripts/create_gemini_commands.sh`. Source `scripts/lib/skill_meta.sh` from step 3. Iterate top-level skill folders. For each, emit `generated/gemini-commands/<name>.toml` with this shape:

    description = "<extract_description output, escaped: \\ → \\\\, " → \\">"
    prompt = """
    <strip_frontmatter output, with $skill-name left literal>
    """

The TOML triple-quoted basic string permits arbitrary content except a `"""` sequence, which would close the string early. Before writing each output file, `grep -c '"""'` the body; if non-zero, abort with a clear error pointing at the source `SKILL.md`. Today no source body contains `"""` (verified by `grep -rn '"""' */SKILL.md */claude.override.md` returning nothing), so the guard is dormant; it exists to fail loudly the day a future skill includes a Python docstring example.

Note: Claude's generator rewrites `$X` to `/X` via `perl -pe 's/\$([A-Za-z0-9][A-Za-z0-9-]*)/\/$1/g'`. Per scope, `create_gemini_commands.sh` does **not** apply this rewrite. The body is passed through as-is.

Match `create_claude_skills.sh`'s `--check` semantics: when set, print `would create / would update` instead of writing. Apply the same stale-file removal pass (look at `generated/gemini-commands/*.toml` and remove any whose source folder no longer exists).

New file: `scripts/install_gemini_commands.sh`. Model on [scripts/install_claude_skills.sh](scripts/install_claude_skills.sh) with the following substitutions:

- `generated_dir="$repo_root/generated/claude-commands"` → `generated_dir="$repo_root/generated/gemini-commands"`
- `claude_home="${CLAUDE_HOME:-$HOME/.claude}"` → `gemini_home="${GEMINI_HOME:-$HOME/.gemini}"`
- `commands_dir="$claude_home/commands"` → `commands_dir="$gemini_home/commands"`
- `backup_root="$claude_home/command-backups/..."` → `backup_root="$gemini_home/command-backups/..."`
- Glob in the file loop and the prune loop: `*.md` → `*.toml`
- Final printf: `Restart Gemini CLI to pick up newly added commands if needed.`

Same `ln -s`, same backup-on-conflict, same readlink-scoped prune. `chmod +x`.

**Step 5 — Add the Antigravity workflows generator and installer.**

New file: `scripts/create_antigravity_workflows.sh`. Source `scripts/lib/skill_meta.sh`. Iterate top-level skill folders. For each, emit `generated/antigravity-workflows/<name>.md` with this exact shape:

    ---
    description: "<extract_description output, escaped: \\ → \\\\, " → \\">"
    ---
    <!-- Generated from <skill-name>. Do not edit directly. -->

    <strip_frontmatter output, with $skill-name left literal>

YAML allows a plain scalar without quotes, but quoting defends against descriptions that begin with `>`, `|`, or `:` — none do today, but the cost of always-quoting is one line. Antigravity workflows technically expect numbered-step bodies; the format is permissive Markdown and the agent will execute prose just as it would a numbered list, so we keep the body byte-identical to what the source emits. The generator should emit a body that is byte-equal to what `create_claude_skills.sh` would emit *after* removing the `$X → /X` rewrite — call this out as an acceptance criterion (see Validation).

New file: `scripts/install_antigravity_workflows.sh`. Same model as step 4's installer with these substitutions:

- `generated_dir="$repo_root/generated/antigravity-workflows"`
- `commands_dir="$gemini_home/antigravity/global_workflows"`
- `backup_root="$gemini_home/antigravity/workflow-backups/$(date +%Y%m%d-%H%M%S)"`
- Glob: `*.md`
- Final printf: `Restart Antigravity to pick up newly added workflows if needed.`

The `mkdir -p "$commands_dir"` line, already present in the Claude installer, is what bootstraps the path the first time a user runs this — Antigravity does not create the global workflows directory itself.

**Step 6 — Wire the new scripts into `sync-skills` and update the README.**

Edit [sync-skills/SKILL.md](sync-skills/SKILL.md). Expand the numbered list under "What to do" to drive all generators before all installers. The skill installers are independent and can run in any order; group them after the generators for readability:

1. `./scripts/create_claude_skills.sh`
2. `./scripts/create_gemini_commands.sh`
3. `./scripts/create_antigravity_workflows.sh`
4. `./scripts/install_codex_skills.sh`
5. `./scripts/install_claude_skills.sh`
6. `./scripts/install_gemini_skills.sh`
7. `./scripts/install_gemini_commands.sh`
8. `./scripts/install_antigravity_skills.sh`
9. `./scripts/install_antigravity_workflows.sh`

Mirror the same expansion in the `--check` and `--prune` branches. Keep the closing rule about not editing generated files and restate it covers all three `generated/` subdirectories.

Edit [sync-skills/claude.override.md](sync-skills/claude.override.md) similarly. Today it lists three scripts, each invoked with `$ARGUMENTS`; after the change it lists nine, each invoked with `$ARGUMENTS`, so a user typing `/sync-skills --check` or `/sync-skills --prune` still propagates the flag to every script. Keep the override's terser tone — do not duplicate the explanatory wording from `SKILL.md`.

Edit [README.md](README.md). Update the layout section to mention all three `generated/` subdirectories and `scripts/lib/skill_meta.sh`. Add a "Gemini CLI Only" and "Antigravity Only" subsection paralleling the existing "Codex Only" and "Claude Only" subsections, each with the relevant install commands and a note about restarting the tool to pick up new skills/commands. Update the "Sync Both" heading to "Sync All" and list all nine commands. Note explicitly that Gemini CLI and Antigravity use *different* paths under `~/.gemini/` (`~/.gemini/skills/` vs `~/.gemini/antigravity/skills/`) so the user does not assume one symlink covers both.

Step 6 is what makes the boundary deeper: from the outside, "sync skills" still does one thing. Inside, the fan-out grew from three operations to nine, but the user's mental model does not.

## Validation

Run all checks from the repo root.

**Confirm the helper bug fix in isolation first.** After step 3 lands and before step 4 starts:

    ./scripts/create_claude_skills.sh
    grep '^description:' generated/claude-commands/architecture-docs-creator.md

Expected: `description: "Create a complete ARCHITECTURE.md before any implementation. ..."` — non-empty, matching the source. If empty, the AWK fix in `extract_description` did not handle the plain form correctly; debug before continuing.

**Dry-run all generators and installers.** Each script must print only "would create / would update / skip unchanged / would remove / would backup / would link / would prune" lines and must not touch the filesystem.

    ./scripts/create_claude_skills.sh --check
    ./scripts/create_gemini_commands.sh --check
    ./scripts/create_antigravity_workflows.sh --check
    ./scripts/install_codex_skills.sh --check
    ./scripts/install_claude_skills.sh --check
    ./scripts/install_gemini_skills.sh --check
    ./scripts/install_gemini_commands.sh --check
    ./scripts/install_antigravity_skills.sh --check
    ./scripts/install_antigravity_workflows.sh --check

Expected: each `--check` exits 0. Each new generator reports `would create generated/<dir>/<skill>.{toml,md}` for all 13 skills the first time. Each new installer reports `would link <skill>` for all 13 skills the first time.

**Run for real.**

    ./scripts/create_claude_skills.sh
    ./scripts/create_gemini_commands.sh
    ./scripts/create_antigravity_workflows.sh
    ./scripts/install_codex_skills.sh
    ./scripts/install_claude_skills.sh
    ./scripts/install_gemini_skills.sh
    ./scripts/install_gemini_commands.sh
    ./scripts/install_antigravity_skills.sh
    ./scripts/install_antigravity_workflows.sh

Then verify on disk. Each path below must be a symlink (use `ls -la` and look for the `->` arrow), not a regular file or directory:

    ls -la ~/.gemini/skills/double-check-work
    ls -la ~/.gemini/antigravity/skills/double-check-work
    ls -la ~/.gemini/commands/double-check-work.toml
    ls -la ~/.gemini/antigravity/global_workflows/double-check-work.md

Expected: the two skill paths show symlinks pointing back into this repo (`-> .../codex-skills/double-check-work`); the two slash-command paths show symlinks into `generated/gemini-commands/` and `generated/antigravity-workflows/` respectively. `cat` each and confirm the description matches the source frontmatter.

**Body-equality check.** The Antigravity workflow body should be byte-equal to the Claude command body modulo (a) Antigravity's frontmatter shape and (b) the `$X → /X` rewrite that Claude applies but Antigravity does not. Because both apply the same `strip_frontmatter`, the only legitimate divergence is the slash rewrite. Run:

    diff <(awk 'p; /^---$/{p=1}' generated/claude-commands/double-check-work.md) \
         <(awk 'p; /^---$/{p=1}' generated/antigravity-workflows/double-check-work.md)

Expected: the only differing lines are ones that contain `/skill-name` in Claude vs `$skill-name` in Antigravity. For [double-check-work/SKILL.md](double-check-work/SKILL.md), which has no `$X` references, the diff should be empty.

**End-to-end behavioral test in each tool.**

Open Gemini CLI in any project directory. Type `/` and confirm `/double-check-work` (and the other 12 commands) appears in the dropdown with the description text. Run `/double-check-work` and confirm the agent receives the body of the source `SKILL.md` as a prompt and proceeds to do a verification pass. In a separate Gemini CLI session, prompt `please double-check the work you just did` without using a slash and confirm the agent picks up the skill via description match.

Open Antigravity. Type `/` in agent chat and confirm `/double-check-work` (and the rest) appears in the workflows menu with description text. Run it; confirm the agent receives and acts on the body. Then prompt without a slash to confirm semantic discovery of the underlying skill works.

**Specifically test `architecture-docs-creator`** — the skill whose plain-form `description:` triggered the helper bug. After the change, its description must appear non-empty in:
- Claude's `/help` listing
- Gemini CLI's `/help` listing
- Antigravity's `/` workflow dropdown

If any of these three shows an empty description, the fix did not propagate everywhere.

In Codex, run a skill the same way you do today and confirm no regression. The change is additive on that side; this is a sanity check.

**Re-run for idempotence.**

Run all nine scripts a second time. Each should print only `skip unchanged` or `skip ... already linked` lines and exit 0.

**Prune validation.**

Temporarily move one source skill aside (`mv double-check-work /tmp/`), then re-run the three generators (so the stale-file pass deletes the matching generated artifacts) and `--prune` on each installer:

    ./scripts/create_claude_skills.sh
    ./scripts/create_gemini_commands.sh
    ./scripts/create_antigravity_workflows.sh
    ./scripts/install_codex_skills.sh --prune
    ./scripts/install_claude_skills.sh --prune
    ./scripts/install_gemini_skills.sh --prune
    ./scripts/install_gemini_commands.sh --prune
    ./scripts/install_antigravity_skills.sh --prune
    ./scripts/install_antigravity_workflows.sh --prune

Each must report `remove` for the matching `double-check-work` artifact and leave the other 12 alone. Restore the skill folder and re-sync to confirm full restoration.

## Risks

**`extract_description` fix changes existing Claude output for one skill.** Today `generated/claude-commands/architecture-docs-creator.md` ships with `description: ""`. After step 3, the next regeneration changes that to the real description. This is a behavior improvement, not a regression — but it shows up in the diff and could surprise a reviewer who expects the change to be purely additive on the Claude side. Mitigation: call this out in the commit message and verify via the validation step above that the new value is correct.

**Antigravity global workflows path may differ from documented value.** The `~/.gemini/antigravity/global_workflows/` path is documented in public guidance but appears in fewer sources than the skills path. If Antigravity does not surface workflows from that location, the installer will silently succeed but `/` in the agent chat will not list them. Mitigation: the validation step requires opening Antigravity and confirming the dropdown. If the path is wrong, change one constant (`commands_dir=`) in `install_antigravity_workflows.sh` and rerun. Workspace-scoped workflows (`<workspace>/.agent/workflows/`) are well-documented as a fallback if the global path proves unstable; that fallback would require deciding which workspaces get the install, so we keep the global path as the primary choice.

**Antigravity workflow format expects numbered steps.** Our generator emits prose. The format is loose Markdown and the agent runs prose fine, but the `/` dropdown's preview UI may render oddly. Mitigation: confirmed via end-to-end test; if rendering is poor, a follow-up can wrap the body in a single `1. <body>` step.

**Path divergence between Gemini CLI and Antigravity.** Both are Google products but use different directories (`~/.gemini/skills/` vs `~/.gemini/antigravity/skills/`). A user inspecting one and assuming the other will be confused. Mitigation: the README explicitly calls out the divergence. The `~/.agents/skills/` interop path that Gemini CLI also accepts is *not* recognized by Antigravity per its docs, so we cannot collapse the two.

**TOML escaping in command bodies.** Skill bodies contain Markdown that includes backticks and code fences but no `"""` sequence today. If a future skill body contains `"""`, the TOML triple-quoted string will close prematurely. Mitigation: the generator `grep -c '"""'`s the body and aborts with a clear message pointing at the offending source file. Pure guard — no ongoing complexity.

**`$skill-name` references stay literal in Gemini CLI and Antigravity outputs.** The user accepted this risk. If, in practice, the agent in either tool fails to resolve `$execplan-create` to invoke that skill, a follow-up can add the same `$X → /X` Perl rewrite the Claude generator already does. The fix is one line per generator and is reversible.

**Helper extraction is a small refactor that touches the existing Claude generator.** The risk is that sourcing `scripts/lib/skill_meta.sh` introduces a quoting or AWK-escaping bug that breaks Claude regeneration. Mitigation: the validation step regenerates Claude commands first, before any new generator runs, and inspects `architecture-docs-creator.md` specifically. If anything other than that one file's description changes, stop and investigate.

## Progress

- [x] (2026-05-08) Step 1 — `scripts/install_gemini_skills.sh` added; dry-run reports `would link` for all 13 skills.
- [x] (2026-05-08) Step 2 — `scripts/install_antigravity_skills.sh` added; dry-run reports `would link` for all 13 skills.
- [x] (2026-05-08) Step 3 — `scripts/lib/skill_meta.sh` extracted with the `extract_description` fix for plain single-line `description:`; `create_claude_skills.sh` updated to source it; regeneration reported 12 unchanged, 1 updated (`architecture-docs-creator.md` description now populated), 0 created/removed.
- [x] (2026-05-08) Step 4 — `scripts/create_gemini_commands.sh` and `scripts/install_gemini_commands.sh` added; 13 TOML files generated under `generated/gemini-commands/`; dry-run clean.
- [x] (2026-05-08) Step 5 — `scripts/create_antigravity_workflows.sh` and `scripts/install_antigravity_workflows.sh` added; 13 workflow files generated under `generated/antigravity-workflows/`; dry-run clean.
- [x] (2026-05-08) Step 6 — `sync-skills/SKILL.md` and `sync-skills/claude.override.md` list all nine scripts; README adds Gemini CLI Only / Antigravity Only sections, expands Sync All to nine commands, and explicitly notes the `~/.gemini/skills/` vs `~/.gemini/antigravity/skills/` divergence.
- [x] (2026-05-08) Validation — real install into isolated `GEMINI_HOME=/tmp/gemini-test.*` linked 13/13/13/13 across the four new targets; `architecture-docs-creator` description is non-empty in both Gemini TOML and Antigravity workflow output; body-equality `diff` is empty for `double-check-work` and `sync-skills`, and contains only the expected `$X` vs `/X` lines for `execplan-create`; re-run reported all skipped (idempotent); prune correctly removed exactly 1 link in each of the four new installers when `double-check-work` was temporarily moved aside; round-trip restored cleanly. Live end-to-end test inside Gemini CLI and Antigravity is pending — gated on the user opening each tool, since this run cannot drive their UIs.

## Outcomes & Retrospective

The plan landed exactly as written. Two signals worth carrying forward:

1. The pre-existing `extract_description` bug surfaced only because Antigravity and Gemini's slash-command UIs both render the description prominently; on Claude, an empty `description:` in `/help` was nearly invisible. The execplan-improve pass that caught it paid for itself — one shared helper now serves three generators, so a future fix lives in one place.

2. The body-equality `diff` between Claude and Antigravity outputs is the cheapest catch for future generator drift. Empty diff for skills without `$X` references; only `$X` vs `/X` lines for skills that have them. Worth keeping as a post-sync sanity check.

No surprises during implementation. No deviations from the plan.
