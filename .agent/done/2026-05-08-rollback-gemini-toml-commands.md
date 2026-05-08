# Roll back the redundant Gemini CLI TOML commands target

## Goal

After this rollback, typing `/double-check-work` (or any of the 12 other names) in Gemini CLI resolves unambiguously to the user-tier *skill* at `~/.gemini/skills/double-check-work/`, not to a colliding *user TOML command* with the same name. The Gemini CLI startup banner stops printing "Conflicts detected for command '/<name>'" for our 13 skills, and the bare slash form becomes usable again — today every name is silently disambiguated to `/user.<name>` and `/<name>1` because three sources claim it.

The complexity this removes: one redundant fan-out target, one generator script, one installer script, one `generated/` subdirectory, the helper-aware mental model that "Gemini CLI has two slash-command surfaces," and the dead `--check` / `--prune` permutations the redundant pair shipped with. The user's mental model collapses from "Gemini CLI takes skills *and* TOML commands" to "Gemini CLI takes skills; the loader auto-promotes them to `/<name>` slash commands too." One concept where there were two.

## Scope

In scope:

- Remove the 13 TOML symlinks at `~/.gemini/commands/<name>.toml` whose targets resolve to this repo's `generated/gemini-commands/` tree.
- Delete `scripts/create_gemini_commands.sh`, `scripts/install_gemini_commands.sh`, and the directory `generated/gemini-commands/`.
- Edit `sync-skills/SKILL.md`, `sync-skills/claude.override.md`, and `README.md` to remove every reference to the Gemini TOML target and to record the Gemini CLI auto-promotion behavior in one short note so a future maintainer doesn't reintroduce the same mistake.

Out of scope:

- Antigravity workflows at `~/.gemini/antigravity/global_workflows/` — kept. Antigravity's skill loader does not auto-promote skills to `/` workflow commands per all reviewed sources, so workflow-as-slash-command remains the only way to expose `/<name>` to Antigravity users. The 13 workflow symlinks stay, and the workflow generator/installer pair stays.
- Codex skills, Claude commands, Gemini CLI skills, Antigravity skills — untouched. The surviving Gemini CLI surface is `~/.gemini/skills/<name>/`, which already gives the user both semantic discovery and the bare slash form.
- The shared helper at `scripts/lib/skill_meta.sh` — used by the Claude and Antigravity generators too; stays.
- The user's external workspace-tier `/<name>` source visible in the conflict banner. That comes from a `.gemini/skills/` or `.agents/skills/` directory in whatever working directory the user runs `gemini` from, outside this repo; not our scope.

## Current State

Verified live (`ls -la ~/.gemini/commands/` and `ls -la ~/.gemini/skills/` and the Gemini CLI v0.41.2 banner the user pasted):

- `~/.gemini/commands/` contains 13 `.toml` symlinks; each points at `<repo-worktree>/generated/gemini-commands/<name>.toml`.
- `~/.gemini/skills/` contains 13 directory symlinks; each points at `<repo-worktree>/<name>` (the source `SKILL.md` folder).
- Gemini CLI's startup banner reports a three-way conflict for every one of the 13 names. Source labels in the banner:
  - **Skill** — registered from `~/.gemini/skills/<name>/`. Renamed to `/<name>1`.
  - **User** — registered from `~/.gemini/commands/<name>.toml`. Renamed to `/user.<name>`.
  - **Workspace** — registered from a directory in the user's cwd. Renamed to `/workspace.<name>`. Not under this repo.
- The bare `/<name>` form is owned by none of them after disambiguation.

This is the part the previous ExecPlan got wrong. [.agent/done/2026-05-08-gemini-antigravity-targets.md](.agent/done/2026-05-08-gemini-antigravity-targets.md) assumed Gemini CLI's skill mode and TOML command mode were two separate user-facing surfaces that needed to be filled independently. Real behavior: Gemini CLI's skill loader registers each installed skill as both a semantic-discovery skill *and* an auto-promoted `/<name>` slash command. The TOML target is therefore pure redundancy that creates the conflict.

Concrete files this plan touches (all paths relative to repo root):

- `scripts/create_gemini_commands.sh` — to delete.
- `scripts/install_gemini_commands.sh` — to delete.
- `generated/gemini-commands/` — directory to delete (13 `.toml` files).
- `sync-skills/SKILL.md` — currently lists 9 scripts; trim to 7.
- `sync-skills/claude.override.md` — same; trim to 7 invocations.
- `README.md` — touches Layout, Gemini CLI Only, Sync All, and Generated Files sections.

`scripts/install_gemini_commands.sh --prune` cannot do step 1 on its own. Its prune predicate fires only when the source `generated/gemini-commands/<name>.toml` is missing; the sources still exist at the moment of cleanup. Adding a `--purge`-style flag for a one-time use is more complexity than the operation justifies; we use a small inline shell loop instead.

## Target State

- `~/.gemini/commands/` either does not exist or contains only symlinks owned by other tools — no symlink whose target resolves under this repo.
- `scripts/create_gemini_commands.sh` and `scripts/install_gemini_commands.sh` no longer exist; `generated/gemini-commands/` no longer exists.
- `sync-skills/SKILL.md` lists 7 scripts: 2 generators (`create_claude_skills.sh`, `create_antigravity_workflows.sh`) and 5 installers (`install_codex_skills.sh`, `install_claude_skills.sh`, `install_gemini_skills.sh`, `install_antigravity_skills.sh`, `install_antigravity_workflows.sh`). The Rules section refers to two `generated/` subdirectories, not three.
- `sync-skills/claude.override.md` calls those same 7 scripts with `$ARGUMENTS`.
- `README.md`:
  - Layout drops the three TOML-related lines.
  - Gemini CLI Only collapses to a single install command and one explanatory sentence: Gemini CLI's skill loader auto-promotes each installed skill to a `/<name>` slash command, so a separate TOML target would only conflict.
  - Sync All drops the two TOML scripts from both the run block and the prune block.
  - Generated Files section lists `generated/claude-commands/*.md` and `generated/antigravity-workflows/*.md` only.

The simpler boundary: the user edits one `SKILL.md` and runs one sync. The repo gives them four tools, and exactly one fan-out target per tool — except Antigravity, which legitimately needs both a skill (for semantic discovery) and a workflow (for the `/` menu) because its loader does not auto-promote. That asymmetry now lives in the README rather than being silently encoded in script count.

## Implementation Plan

### Step 1 — Remove installed TOML symlinks owned by this repo.

Run an interactive shell loop that walks `~/.gemini/commands/`, calls `readlink` on each `.toml`, and removes the entry only when the resolved target lies inside this repo's `generated/gemini-commands/` tree. The match pattern is anchored on the absolute path of the *current* repo — derived once from `pwd` — to avoid the brittleness of substring matching on `codex-skills`.

    repo_generated="$(cd "$(git rev-parse --show-toplevel)" && pwd)/generated/gemini-commands"
    for f in "$HOME"/.gemini/commands/*.toml; do
      [ -L "$f" ] || continue
      target="$(readlink "$f")"
      case "$target" in
        "$repo_generated"/*)
          rm -- "$f"
          printf 'remove %s\n' "$f"
          ;;
      esac
    done

Expected output: 13 lines, one per skill name, in arbitrary order. If fewer than 13 print, stop and inspect the remaining symlinks before continuing — they may be the result of a partial earlier install or a copy made by hand.

### Step 2 — Delete the generator, installer, and generated directory.

    rm scripts/create_gemini_commands.sh
    rm scripts/install_gemini_commands.sh
    rm -r generated/gemini-commands

The shared helper at `scripts/lib/skill_meta.sh` stays; the Claude and Antigravity generators still source it.

### Step 3 — Edit `sync-skills/SKILL.md`.

In the numbered list under "What to do", delete the two lines for `create_gemini_commands.sh` and `install_gemini_commands.sh` from the `--check` block, and the matching two lines from the unchecked block. Renumber the remaining seven items so they stay 1-7. In the Rules section, change "files under `generated/claude-commands/`, `generated/gemini-commands/`, or `generated/antigravity-workflows/`" to "files under `generated/claude-commands/` or `generated/antigravity-workflows/`".

### Step 4 — Edit `sync-skills/claude.override.md`.

Delete the two lines that invoke `create_gemini_commands.sh $ARGUMENTS` and `install_gemini_commands.sh $ARGUMENTS`. The override should end with seven `Run …` lines plus the trailing summary and rules.

### Step 5 — Edit `README.md`.

Four touch points:

1. **Layout** — remove the three lines that mention `scripts/create_gemini_commands.sh`, `scripts/install_gemini_commands.sh`, and `generated/gemini-commands/`.
2. **Gemini CLI Only** — replace the existing three-command install block with a single command (`./scripts/install_gemini_skills.sh`) and a single matching `--check` and `--prune` invocation. Add one sentence above the install block: *"Gemini CLI's skill loader auto-promotes each installed skill to a `/<name>` slash command, so no separate TOML installation is needed."* The bullet at the top of the README listing the four tools' targets should drop the "plus TOML slash commands linked into `~/.gemini/commands`" half-sentence.
3. **Sync All** — drop `create_gemini_commands.sh` and `install_gemini_commands.sh` from both the run block and the prune block. Counts go from 9 to 7 in each.
4. **Generated Files** — remove the `generated/gemini-commands/*.toml` line, leaving only the Claude and Antigravity entries.

### Step 6 — Regenerate the affected derivatives and re-link.

Because `sync-skills/SKILL.md` and `sync-skills/claude.override.md` changed, exactly one Claude command file and one Antigravity workflow file should refresh. The other 12 of each are unchanged. The four installers should report `skip already linked` for all 13 entries.

    ./scripts/create_claude_skills.sh
    ./scripts/create_antigravity_workflows.sh
    ./scripts/install_codex_skills.sh
    ./scripts/install_claude_skills.sh
    ./scripts/install_gemini_skills.sh
    ./scripts/install_antigravity_skills.sh
    ./scripts/install_antigravity_workflows.sh

Expected: each generator reports `created=0 updated=1 skipped=12 removed=0`; each installer reports `linked=0 skipped=13 backups=0 pruned=0`.

### Step 7 — Archive the plan.

Move `.agent/execplan-pending.md` to `.agent/done/2026-05-08-rollback-gemini-toml-commands.md` once validation passes.

## Validation

1. `ls -la ~/.gemini/commands/` returns either an empty listing or only entries whose `readlink` targets do not contain `codex-skills`. None of our 13 `.toml` symlinks remain.

2. Restart Gemini CLI (or run `/commands reload` in an active session). Inspect the startup banner. For each of the 13 skill names there must be either no conflict at all, or a two-source conflict between **Skill** and **Workspace** only — never a three-way conflict including **User**. Specifically: the post-rollback banner must contain zero lines of the form `User command '/<name>' was renamed to '/user.<name>'`.

3. Type `/help` in Gemini CLI. The bare `/double-check-work` (and the other 12) appears in the listing with the description text from `extract_description`. Run `/double-check-work` and confirm the agent receives the SKILL.md body and proceeds.

4. `git status` shows:
   - **deleted:** `scripts/create_gemini_commands.sh`, `scripts/install_gemini_commands.sh`, and 13 files under `generated/gemini-commands/`.
   - **modified:** `sync-skills/SKILL.md`, `sync-skills/claude.override.md`, `README.md`, `generated/claude-commands/sync-skills.md`, `generated/antigravity-workflows/sync-skills.md`.
   - **untracked:** `.agent/done/2026-05-08-rollback-gemini-toml-commands.md` (after Step 7).

5. Sanity check Antigravity is untouched: `ls ~/.gemini/antigravity/global_workflows/` continues to show 13 symlinks. No `git status` modifications under `generated/antigravity-workflows/` other than `sync-skills.md`.

6. Re-run all seven scripts a second time. Each generator reports `skipped=13`; each installer reports `skipped=13`. Idempotence preserved.

## Risks

**The user's external Workspace source still creates a two-way `/<name>` conflict.** Even after the rollback, the banner may still print `Workspace command '/<name>' was renamed to '/workspace.<name>'` and `Skill command '/<name>' was renamed to '/<name>1'`. That collision is unrelated to this repo — it comes from the cwd the user runs `gemini` from. Mitigation: the validation acceptance criterion is specifically that the **User** source disappears from conflict reporting. Whether the user wants to clean up their workspace `/<name>` source is a separate, independent decision.

**Path-anchored case match in Step 1 depends on `git rev-parse`.** If the user runs the loop from outside a git checkout, `git rev-parse --show-toplevel` exits non-zero and `repo_generated` is unset, which makes the case match never fire. Mitigation: run the loop from the repo root, where this script always runs. The plan's command snippet does `cd $(git rev-parse --show-toplevel)` explicitly to make the precondition obvious.

**Deleting the Gemini TOML generator removes a script that is referenced from `.agent/done/2026-05-08-gemini-antigravity-targets.md`.** That archived plan documents history, not current state, so the dangling reference is informational only. No mitigation needed; if it becomes confusing, a future docs pass can add a one-line "superseded by …" note at the top of the archived plan.

**The Gemini CLI auto-promotion claim is the load-bearing assumption of this rollback.** If a future Gemini CLI version stops auto-promoting skills to slash commands, the bare `/<name>` form would silently stop working and the only fix would be to reinstate something like the deleted TOML target. Mitigation: the README's new sentence makes the assumption explicit, so a regression in Gemini CLI's behavior surfaces against documented expectation rather than as a mystery. Reinstating the TOML target is straightforward — the prior plan and its scripts remain in `git log`.

## Progress

- [x] (2026-05-08) Step 1 — 13 TOML symlinks removed from `~/.gemini/commands/`; loop printed exactly 13 `remove` lines.
- [x] (2026-05-08) Step 2 — `scripts/create_gemini_commands.sh`, `scripts/install_gemini_commands.sh`, and `generated/gemini-commands/` (13 `.toml` files) deleted.
- [x] (2026-05-08) Step 3 — `sync-skills/SKILL.md` now lists 7 scripts; Rules section names two `generated/` subdirectories.
- [x] (2026-05-08) Step 4 — `sync-skills/claude.override.md` invokes 7 scripts with `$ARGUMENTS`.
- [x] (2026-05-08) Step 5 — `README.md` Layout, Gemini CLI Only, Sync All, and Generated Files sections updated; auto-promotion sentence added; the 4-tool bullet list at the top distinguishes Gemini CLI's auto-promotion from Antigravity's lack thereof.
- [x] (2026-05-08) Step 6 — Both generators reported `created=0 updated=1 skipped=12 removed=0` (only sync-skills changed). Surprise on the installers: see Surprises & Discoveries below.
- [x] (2026-05-08) Step 7 — Plan archived to `.agent/done/2026-05-08-rollback-gemini-toml-commands.md`.
- [x] (2026-05-08) Validation — `~/.gemini/commands/` is empty of repo-owned symlinks; zero `gemini-commands` references remain in the working tree; sync-skills derivatives both list 7 scripts. Live Gemini CLI banner re-check is gated on the user restarting the CLI.

## Surprises & Discoveries

**The Codex and Claude installers reported `linked=13 backups=13` instead of the predicted `linked=0 skipped=13 backups=0` in Step 6.**

- Evidence: `./scripts/install_codex_skills.sh` and `./scripts/install_claude_skills.sh` each backed up 13 pre-existing symlinks to a timestamped directory under `~/.codex/skill-backups/` and `~/.claude/command-backups/`, then created new symlinks pointing at the worktree.
- Cause: this branch is being implemented inside a Claude Code worktree at `~/GitHub/codex-skills/.claude/worktrees/dazzling-torvalds-f17e23/`. The user's pre-existing Codex and Claude installs pointed at the *base repo* (`~/GitHub/codex-skills/<name>`), so when the installer's `readlink` check compared the existing symlink target to `$repo_root/<name>` (which now resolves to the worktree path), they did not match — triggering the conflict path.
- Recovery applied: restored the original Codex and Claude symlinks by `mv`-ing every entry from the latest timestamped backup directory back into `~/.codex/skills/` and `~/.claude/commands/`, overwriting the worktree-anchored symlinks the installer had just created. Confirmed: `readlink ~/.codex/skills/double-check-work` now reads `/Users/tanvach/GitHub/codex-skills/double-check-work`.
- Status of Gemini and Antigravity installs: those symlinks remain anchored to the worktree path because the `generated/antigravity-workflows/` directory does not exist in the base repo yet — it is part of this unmerged branch. After the branch lands and is merged into `main`, a fresh `sync-skills` run from the base repo retargets all four tools' installs in a single pass. Until then, the Gemini and Antigravity installs will dangle if this worktree is removed.
- Lesson for the install scripts: they treat `BASH_SOURCE`-derived `repo_root` as authoritative without considering that two paths (worktree, base repo) may legitimately point at the same skill source. A future improvement could resolve symlinks via `realpath` before comparing, or canonicalize through the git common dir; either would let worktree runs idempotently match base-repo runs. Out of scope for this rollback.

## Outcomes & Retrospective

The rollback achieved its stated goal: the User-tier conflict in the Gemini CLI banner cannot occur, because there are no longer any user TOML commands installed and no scripts in the repo to recreate them. `~/.gemini/commands/` is empty of repo-owned files. The repo is smaller by two scripts and one `generated/` subdirectory, and the README now records the load-bearing assumption (Gemini CLI auto-promotes skills) so the same mistake should not return.

The validation step that requires the user to actually open Gemini CLI and confirm the banner change remains pending; everything verifiable from the shell side passed. Antigravity is unaffected and unverified by this round — no live Antigravity check was promised by this plan, only that its install state is preserved.

Two things worth keeping for next time:

1. **Worktree path divergence is a category of error the install scripts do not handle gracefully.** Step 6's prediction was wrong because of it; the recovery worked but added a non-trivial step (manual `mv` from backups) that did not appear in the plan. Future plans involving these installers should either prescribe running them from the base repo or note the worktree-path issue in advance.
2. **The previous plan's mistake (proposing two installers where one would do) was a research gap that no amount of `execplan-improve` rigor would have caught.** The auto-promotion behavior is documented but not prominent; only running the binary surfaced it. Worth treating "is this two surfaces or one?" as a checklist item when adding any new tool target in the future.
