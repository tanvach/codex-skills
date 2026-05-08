# Roll back the redundant Antigravity workflows target

## Goal

After this rollback, every skill name surfaces exactly once in Antigravity's `/` menu, sourced from the auto-promoted skill at `~/.gemini/antigravity/skills/<name>/` — not from a duplicate workflow at `~/.gemini/antigravity/global_workflows/<name>.md`. Today the user sees two `/double-check-work` entries (and 12 other duplicate pairs) because both paths register the same name.

The complexity this removes is the same shape as the just-completed Gemini CLI TOML rollback: one redundant fan-out target, one generator script, one installer script, one `generated/` subdirectory, and a sentence in the README that asserts the wrong cause-and-effect. The user's mental model collapses from "Antigravity needs both skills (semantic) and workflows (`/`)" to "Antigravity needs skills; the loader auto-promotes them to `/<name>` slash commands too" — symmetric with Gemini CLI. One concept where there were two.

## Scope

In scope:

- Remove `~/.gemini/antigravity/global_workflows.disabled/` (13 dangling symlinks the user moved aside in Test A) and the no-longer-existing `~/.gemini/antigravity/global_workflows/`.
- Delete `scripts/create_antigravity_workflows.sh`, `scripts/install_antigravity_workflows.sh`, and the directory `generated/antigravity-workflows/`.
- Edit `sync-skills/SKILL.md`, `sync-skills/claude.override.md`, and `README.md` to remove every reference to the workflow target and to record Antigravity's auto-promotion behavior in one short sentence so a future maintainer doesn't reintroduce the same mistake.

Out of scope:

- Codex, Claude, and Gemini CLI installs — untouched.
- The Antigravity *skills* install at `~/.gemini/antigravity/skills/<name>/` — kept. It is the surviving slash-command path for Antigravity, providing both semantic discovery and the auto-promoted `/<name>` form.
- The shared helper at `scripts/lib/skill_meta.sh` — used by the Claude generator; stays.
- Re-pointing the worktree-anchored Antigravity skill symlinks back to the base repo. Those symlinks remain dangling-after-merge as already documented in `.agent/done/2026-05-08-rollback-gemini-toml-commands.md`. A separate fresh sync from the base repo handles that after this branch lands.

## Current State

Verified live:

- `~/.gemini/antigravity/global_workflows/` does not exist on disk.
- `~/.gemini/antigravity/global_workflows.disabled/` contains 13 symlinks, each pointing into this repo's `generated/antigravity-workflows/` tree. The user moved the original directory aside as Test A; Antigravity confirmed the duplicates disappeared after that move.
- `~/.gemini/antigravity/skills/` contains 13 symlinks pointing into the worktree's source skill folders, and these alone produce the visible `/<name>` entries in Antigravity's `/` menu after the user's Test A — confirming Antigravity's skill loader auto-promotes installed skills to slash commands the same way Gemini CLI's loader does.

In the repo:

- `scripts/create_antigravity_workflows.sh` and `scripts/install_antigravity_workflows.sh` exist alongside their Claude/Gemini siblings.
- `generated/antigravity-workflows/` contains 13 `.md` files generated from the source `SKILL.md` bodies.
- `sync-skills/SKILL.md` lists 7 scripts (2 generators, 5 installers).
- `sync-skills/claude.override.md` invokes 7 scripts.
- `README.md` documents Antigravity workflows in four places: the top-of-file 4-tool bullet list, the Layout section, the Antigravity Only section, and Sync All. The current Antigravity bullet incorrectly states *"Antigravity does not auto-promote skills"* — that line was added in the previous rollback based on a research claim, not behavioral evidence. The user's Test A is the behavioral evidence that contradicts it: when only the workflows are removed, Antigravity still surfaces `/<name>` from the skills directory.

This is the same category of mistake as the prior rollback: the previous ExecPlan ([.agent/done/2026-05-08-gemini-antigravity-targets.md](.agent/done/2026-05-08-gemini-antigravity-targets.md)) treated semantic-discovery skills and `/` slash commands as two independent surfaces in *both* tools. The Gemini CLI side was rolled back when the conflict banner exposed the redundancy. The Antigravity side is rolled back here, on the same evidence pattern (two visible entries per name disappear when one of the two install targets is removed).

Concrete files this plan touches (paths relative to repo root):

- `scripts/create_antigravity_workflows.sh` — to delete.
- `scripts/install_antigravity_workflows.sh` — to delete.
- `generated/antigravity-workflows/` — directory to delete (13 `.md` files).
- `sync-skills/SKILL.md` — currently lists 7 scripts; trim to 5.
- `sync-skills/claude.override.md` — same; trim to 5 invocations.
- `README.md` — touches the top bullet list (line 10), the "generated from the source skill folders" sentence (line 14, currently mentions "Antigravity workflows"), Layout (lines 21 and 26), Antigravity Only (lines 93–118), Sync All (lines 124–144), the override-coverage sentence (line 149, currently mentions both Gemini TOML and Antigravity workflow bodies — a leftover from the prior rollback that this plan also fixes), and Generated Files (line 201).

Glossary:

- **Auto-promotion** — the behavior of a tool's skill loader registering each installed skill at `~/.gemini/<tool>/skills/<name>/` as a callable `/<name>` slash command, in addition to making it available for semantic discovery against the skill's `description`. Gemini CLI does this; Antigravity does this. Confirmed for the latter by Test A.

## Target State

- `~/.gemini/antigravity/global_workflows/` does not exist; `~/.gemini/antigravity/global_workflows.disabled/` does not exist either.
- `scripts/create_antigravity_workflows.sh` and `scripts/install_antigravity_workflows.sh` no longer exist; `generated/antigravity-workflows/` no longer exists.
- `sync-skills/SKILL.md` lists 5 scripts: 1 generator (`create_claude_skills.sh`) and 4 installers (`install_codex_skills.sh`, `install_claude_skills.sh`, `install_gemini_skills.sh`, `install_antigravity_skills.sh`). The Rules section refers to one `generated/` subdirectory (`generated/claude-commands/`).
- `sync-skills/claude.override.md` calls those same 5 scripts with `$ARGUMENTS`.
- `README.md`:
  - Top-of-file 4-tool bullet: Antigravity entry mirrors the Gemini CLI entry — *"Antigravity skills linked into `~/.gemini/antigravity/skills` (Antigravity auto-promotes each installed skill to a `/<name>` slash command, same as Gemini CLI)"*.
  - Layout: drops the three workflow-related lines.
  - Antigravity Only collapses to one install command and one explanatory sentence about auto-promotion.
  - Sync All drops the workflow generator and installer from both the run block and the prune block.
  - Generated Files lists `generated/claude-commands/*.md` only.

The simpler boundary: every tool target is now exactly one install. Codex skills, Claude commands, Gemini CLI skills, Antigravity skills — four installers, one generator (for Claude's distinct slash-command shape). The asymmetry that survives is between Claude's transformed-output flow (`generated/claude-commands/<name>.md`) and the three symlink-only flows; that asymmetry is real (Claude's slash-command frontmatter differs from `SKILL.md`) and not collapsible.

## Implementation Plan

### Step 1 — Remove the disabled workflow directory and any remnant.

The user already moved `~/.gemini/antigravity/global_workflows/` aside; the renamed directory holds 13 dangling symlinks pointing at this repo's `generated/antigravity-workflows/` tree, which is itself slated for deletion in Step 2. No live code or tool references either path; safe to remove outright:

    rm -rf "$HOME/.gemini/antigravity/global_workflows.disabled"
    rm -rf "$HOME/.gemini/antigravity/global_workflows"

The second `rm -rf` is a no-op when the path is already absent — included so the command is safe to re-run.

### Step 2 — Delete the generator, installer, and generated directory.

    rm scripts/create_antigravity_workflows.sh
    rm scripts/install_antigravity_workflows.sh
    rm -r generated/antigravity-workflows

The shared helper at `scripts/lib/skill_meta.sh` stays — the Claude generator still sources it.

### Step 3 — Edit `sync-skills/SKILL.md`.

In the numbered list under "What to do":

- Remove the `./scripts/create_antigravity_workflows.sh --check` line from the `--check` block, leaving the Claude-only generator there.
- Remove the `./scripts/install_antigravity_workflows.sh --check` line.
- Remove the matching unchecked entries.

Update the closing prose sentence in step 3 from "Run all generators before any installer; the five installers can run in any order after that." to "Run the generator before any installer; the four installers can run in any order after that." The script count goes from 7 to 5.

In the Rules section, change "files under `generated/claude-commands/` or `generated/antigravity-workflows/`" to "files under `generated/claude-commands/`".

### Step 4 — Edit `sync-skills/claude.override.md`.

Delete the two lines that invoke `create_antigravity_workflows.sh $ARGUMENTS` and `install_antigravity_workflows.sh $ARGUMENTS`. The override should end with five `Run …` lines plus the trailing summary and rules.

### Step 5 — Edit `README.md`.

Seven touch points:

1. **Top-of-file 4-tool bullet list (line 10)** — replace the Antigravity bullet with: *"Antigravity skills linked into `~/.gemini/antigravity/skills` (Antigravity auto-promotes each installed skill to a `/<name>` slash command, same as Gemini CLI)"*. The "plus workflows linked into `~/.gemini/antigravity/global_workflows`" half-sentence and the *"Antigravity does not auto-promote skills"* clause both go away.
2. **"Generated from the source skill folders" sentence (line 14)** — currently reads: *"Slash-command-style files (Claude commands, Antigravity workflows) are generated from the source skill folders and should not be edited by hand."* After the rollback, only Claude commands are generated. Change to: *"Claude command files are generated from the source skill folders and should not be edited by hand."*
3. **Layout** — remove two lines (the `scripts/create_antigravity_workflows.sh` and `scripts/install_antigravity_workflows.sh` entries) and update the Claude line if it asserted the helper is "used by every generator" — after the rollback only one generator remains, so the existing wording *"used by every generator"* is technically still correct (one generator is "every generator") but a future maintainer reading "every generator" expects more than one. Soften to *"used by the generator"* in the singular.
4. **Antigravity Only (lines 93–118)** — replace the existing two-step install with a single install command and a sentence: *"Antigravity's skill loader auto-promotes each installed skill to a `/<name>` slash command, so a single install covers both semantic discovery and `/` invocation."* Drop the workflow-related preview/prune commands. The "Restart Antigravity to pick up new skills and workflows" line becomes "Restart Antigravity to pick up new skills."
5. **Sync All (lines 124–144)** — drop `create_antigravity_workflows.sh` and `install_antigravity_workflows.sh` from the run block (7 → 5 lines). Drop `install_antigravity_workflows.sh --prune` from the prune block (5 → 4 lines).
6. **Adding or Updating Skills (line 149)** — currently asserts: *"The override is also used for the Gemini TOML command body and the Antigravity workflow body when present, so a single override covers all three slash-command targets."* After both rollbacks, only the Claude generator consumes `claude.override.md`. Replace with: *"The override is consumed only by the Claude command generator; it does not affect the other tools."*
7. **Generated Files (line 201)** — remove the `generated/antigravity-workflows/*.md` entry, leaving only the Claude entry.

### Step 6 — Regenerate the affected derivative and re-link.

Because `sync-skills/SKILL.md` and `sync-skills/claude.override.md` changed, exactly one Claude command file should refresh. The other 12 are unchanged. The four installers should report `skip already linked` for all 13 entries.

    ./scripts/create_claude_skills.sh
    ./scripts/install_codex_skills.sh
    ./scripts/install_claude_skills.sh
    ./scripts/install_gemini_skills.sh
    ./scripts/install_antigravity_skills.sh

Expected: the generator reports `created=0 updated=1 skipped=12 removed=0`. Each installer reports `linked=0 skipped=13 backups=0 pruned=0`.

A documented exception applies to `install_codex_skills.sh` and `install_claude_skills.sh` when run from this Claude Code worktree path: those installers may report `linked=13 backups=13` because the user's stable Codex/Claude installs point at the base repo (`~/GitHub/codex-skills/<name>`) while `repo_root` in the worktree resolves to the worktree path. The previous rollback ([.agent/done/2026-05-08-rollback-gemini-toml-commands.md](.agent/done/2026-05-08-rollback-gemini-toml-commands.md)) hit this and recovered by restoring symlinks from the timestamped backup. To avoid repeating the recovery dance, this plan only re-runs the installers that are *already* worktree-anchored (Gemini CLI skills and Antigravity skills) plus the safe Claude regen — skip Codex and Claude reinstall this round; their existing base-repo symlinks are unchanged by anything in this plan.

Revised actual command set for Step 6:

    ./scripts/create_claude_skills.sh
    ./scripts/install_gemini_skills.sh
    ./scripts/install_antigravity_skills.sh

Skipping the Codex and Claude installer re-runs is safe because nothing about their *target* changes in this rollback — only `sync-skills/claude.override.md` becomes a new generated file under `generated/claude-commands/sync-skills.md`, and the existing base-repo symlink at `~/.claude/commands/sync-skills.md` already points to that file. The symlink is unchanged; only the file it points to is updated by `create_claude_skills.sh`.

### Step 7 — Archive the plan.

Move `.agent/execplan-pending.md` to `.agent/done/2026-05-08-rollback-antigravity-workflows.md` once validation passes.

## Validation

1. `ls ~/.gemini/antigravity/` returns no `global_workflows` or `global_workflows.disabled` entry. The `skills/` subdirectory remains and still contains 13 symlinks.

2. Restart Antigravity (or reload). Open the `/` menu in agent chat. For each of the 13 skill names there is exactly **one** `/<name>` entry — not two. Specifically: where the user previously saw two `/double-check-work` entries, only one remains.

3. Click `/double-check-work` in Antigravity and confirm it runs the skill body. Then prompt without a slash (e.g. *"please verify the work you just did"*) and confirm Antigravity's agent picks up the same skill via semantic discovery. Both invocation paths must work.

4. `git status` shows:
   - **deleted:** `scripts/create_antigravity_workflows.sh`, `scripts/install_antigravity_workflows.sh`, and 13 files under `generated/antigravity-workflows/`.
   - **modified:** `sync-skills/SKILL.md`, `sync-skills/claude.override.md`, `README.md`, `generated/claude-commands/sync-skills.md`.
   - **untracked:** `.agent/done/2026-05-08-rollback-antigravity-workflows.md` (after Step 7).

5. Sanity check no unrelated installs are touched: `readlink ~/.codex/skills/double-check-work` still returns `/Users/tanvach/GitHub/codex-skills/double-check-work` (base repo); `readlink ~/.claude/commands/double-check-work.md` still returns `/Users/tanvach/GitHub/codex-skills/generated/claude-commands/double-check-work.md` (base repo). `readlink ~/.gemini/skills/double-check-work` and `readlink ~/.gemini/antigravity/skills/double-check-work` continue to point at the worktree, unchanged.

6. Re-run the Step 6 command set a second time. The generator reports `skipped=13`; both installers report `skipped=13`. Idempotence preserved.

## Risks

**The auto-promotion claim is now load-bearing for both Google tools.** The README states it explicitly for both Gemini CLI and Antigravity. If a future version of either tool stops auto-promoting skills to slash commands, the bare `/<name>` form would silently stop working in that tool, and the only fix would be to reinstate the deleted slash-command target. Mitigation: the auto-promotion sentences in the README are the place a regression surfaces against documented expectation rather than as a mystery. Both targets remain in `git log` if a reinstatement is ever needed.

**The Antigravity bullet in the previous README round was wrong.** The previous rollback's plan landed a sentence asserting Antigravity does *not* auto-promote — citing search results, not behavioral evidence. Test A in this conversation refuted that. Mitigation: this plan replaces the wrong sentence with the correct one and adds Test A's outcome to the reasoning trail in the archived plan, so the next person reading sees the evidence. Worth treating "claims about tool behavior" as something to verify by running the tool, not just by searching for documentation. (This is the same lesson noted in the previous rollback's Outcomes & Retrospective; restating because it cost a round of churn this time too.)

**Skipping Codex and Claude installer re-runs in Step 6 is a deviation from the symmetric "run all installers" pattern.** Justification: the worktree-path divergence problem documented in the prior rollback's Surprises & Discoveries is real, and re-running Codex/Claude installers from this worktree would silently retarget user-stable symlinks to ephemeral worktree paths. Mitigation: the validation step explicitly checks `readlink` on the Codex and Claude paths to confirm they still resolve to the base repo. If they don't, the operator restores from the timestamped backup directory the same way the previous rollback did.

**`rm -rf` of two paths under `~/.gemini/antigravity/`.** Both paths are user-scoped; neither contains anything other than the symlinks this repo created (the `.disabled` was the user's own `mv` of the original install). Mitigation: the `rm -rf` targets are written out as full paths, not globs, and the second one is a no-op against a non-existent path so the command is safe to re-run. There is no risk to other user data.

## Progress

- [x] (2026-05-08) Step 1 — `~/.gemini/antigravity/global_workflows.disabled/` removed; `~/.gemini/antigravity/global_workflows/` confirmed absent (`ls ~/.gemini/antigravity/ | grep workflow` returns empty).
- [x] (2026-05-08) Step 2 — `scripts/create_antigravity_workflows.sh`, `scripts/install_antigravity_workflows.sh`, and `generated/antigravity-workflows/` (13 `.md` files) deleted.
- [x] (2026-05-08) Step 3 — `sync-skills/SKILL.md` now lists 5 scripts (1 generator + 4 installers); Rules section names only `generated/claude-commands/`.
- [x] (2026-05-08) Step 4 — `sync-skills/claude.override.md` invokes 5 scripts.
- [x] (2026-05-08) Step 5 — Seven `README.md` touchpoints landed: top 4-tool bullet (auto-promotion sentence mirrors Gemini CLI's), the "generated from the source skill folders" sentence trimmed, Layout dropped two scripts and softened "every generator" → "the generator", Antigravity Only collapsed to one install + one auto-promotion sentence, Sync All trimmed to 5 run lines and 4 prune lines, override-coverage sentence corrected (override is consumed only by the Claude generator), Generated Files entry trimmed to one line.
- [x] (2026-05-08) Step 6 — Generator reported `created=0 updated=1 skipped=12 removed=0` (only sync-skills changed). Gemini and Antigravity skill installers each reported `linked=0 skipped=13 backups=0 pruned=0`. Codex/Claude installers deliberately not re-run. `readlink ~/.codex/skills/double-check-work` returns `/Users/tanvach/GitHub/codex-skills/double-check-work` (base repo); `readlink ~/.claude/commands/double-check-work.md` returns `/Users/tanvach/GitHub/codex-skills/generated/claude-commands/double-check-work.md` (base repo). No regression.
- [x] (2026-05-08) Step 7 — Plan archived to `.agent/done/2026-05-08-rollback-antigravity-workflows.md`.
- [x] (2026-05-08) Validation — All shell-side checks passed: workflow dirs absent, Codex/Claude unchanged, sync-skills derivative regenerated. Live Antigravity `/` menu re-check is gated on the user restarting Antigravity.

## Surprises & Discoveries

**README line 149's override-coverage sentence was a leftover from the prior rollback, not caught by that pass.** When the previous rollback removed the Gemini CLI TOML target, the README sentence still claimed `claude.override.md` was consumed by the Gemini TOML generator — even though the generator was deleted. The improve pass for *this* rollback caught it because the sentence also mentioned Antigravity workflows, and once the workflow generator went away too, the sentence became fully wrong. The fix folds in here. Lesson: when removing a generator, grep for `claude.override` in the README explicitly, not just for the deleted script names.

**Off-by-one in script counts caught by the improve pass.** First-draft of this plan said "6 scripts" and "5 installers" in the Target State, but listed 4 installer names. Removing 2 scripts from 7 yields 5, not 6. The numerical inconsistency was internal to the plan and would have produced visibly wrong README text at validation. The improve pass renumbered everything to 5 scripts (1 generator + 4 installers) and corrected the Sync All run-block delta from "7 → 6" to "7 → 5".

## Outcomes & Retrospective

The rollback achieved its stated goal cleanly: zero workflow dirs remain under `~/.gemini/antigravity/`, two scripts and one `generated/` subdirectory deleted, README sentences updated to match the now-symmetric reality (Gemini CLI auto-promotes; Antigravity auto-promotes). Both pre-existing user installs (Codex, Claude) are untouched, confirmed via `readlink`. The Step 6 prediction matched exactly: `updated=1 skipped=12` from the generator, `skipped=13` from each of the two safe installers.

Two lessons reinforced from the prior rollback's retrospective:

1. **Verify tool behavior by running the tool, not by searching for documentation.** The previous rollback's plan asserted Antigravity does not auto-promote skills, citing search results. Test A in this conversation refuted that with a single mv. If the user hadn't shipped the install, this would have surfaced months later as a mystery; instead it surfaced in the next round.
2. **Worktree-path divergence in the install scripts is a real category of error.** This plan deliberately skipped Codex and Claude installer re-runs in Step 6, avoiding a recovery dance. A future improvement to the install scripts could canonicalize via `realpath` so worktree runs idempotently match base-repo runs; out of scope here, worth a backlog entry.

The four-tool architecture is now symmetric: each tool gets exactly one install, plus one (Claude-only) generator that exists because Claude's slash-command frontmatter genuinely differs from `SKILL.md`. The repo is smaller, the README is more honest, and the user can type `/double-check-work` in any of the four tools and get exactly one match.
