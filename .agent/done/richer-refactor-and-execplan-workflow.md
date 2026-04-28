# Add a richer refactor and ExecPlan workflow

## Goal

This change gives the skills repository a stronger planning workflow without throwing away the current simple one. After the change, a user can still ask for a normal ExecPlan and get `.agent/execplan-pending.md`, but they can also run a staged refactor workflow that creates candidates, pressure-tests a final decision, writes an ExecPlan from that decision, improves the plan against real code, and then implements it while tracking state. The result should be visible by inspecting the new source skill folders, regenerated Claude commands, and dry-run sync output.

## Scope

In scope: add source skills for `find-refactor-candidates`, `select-refactor`, and `execplan-improve`; bring the currently installed-only `refactor-something` idea into this repository as a tracked source skill or clearly fold it into the new refactor workflow; update `execplan-create` and `implement-execplan` so they understand both the new `.agent/work/<id>/` work-item model and the existing `.agent/execplan-pending.md` fallback; strengthen the ExecPlan guidance in `execplan-create/PLANS.md` and `.agent/PLANS.md`; update generated Claude commands and README documentation.

Out of scope: changing the shell installer architecture, publishing to any remote package registry, or implementing a real refactor in another project. The remote comparison source is the cloned repository at `/tmp/useful-codex-skills`, refreshed on April 28, 2026 with `git -C /tmp/useful-codex-skills pull --ff-only`, which reported `Already up to date`.

Assume the top-level skill folders in `/Users/tanvach/GitHub/codex-skills` are the canonical source of truth. Generated files under `generated/claude-commands/` are derived artifacts and should be regenerated from source rather than edited by hand.

## Current State

The repository at `/Users/tanvach/GitHub/codex-skills` tracks eight source skills: `architecture-docs-creator`, `create-todo`, `double-check-work`, `execplan-create`, `implement-execplan`, `sync-skills`, `update-architecture-docs`, and `update-todo`. The README explains that these top-level folders are the source of truth and that `scripts/create_claude_skills.sh` generates `generated/claude-commands/*.md`.

`execplan-create/SKILL.md` is intentionally small. It asks for a PRD, RFC, voice note, or detailed problem statement; reads `PLANS.md` if present; falls back to copying `execplan-create/PLANS.md` into `.agent/PLANS.md`; and writes `.agent/execplan-pending.md`. It does not understand `.agent/work/<id>/`, `decision.md`, `.agent/active`, or staged refactor work.

`implement-execplan/SKILL.md` only reads `.agent/execplan-pending.md`, implements it, and then renames and moves the completed plan into `.agent/done/`. That remains useful for legacy singleton plans, but it conflicts with the remote work-item model where lifecycle state lives in `meta.json` instead of in file moves.

`execplan-create/PLANS.md` and `.agent/PLANS.md` are concise and practical. They define the required ExecPlan sections and validation expectations, but they do not include the stronger design-quality language from the remote repo around deep modules, information hiding, change amplification, cognitive load, unknown unknowns, or complexity dividends.

The installed Codex skills directory `/Users/tanvach/.codex/skills` contains an installed-only `refactor-something/SKILL.md`. That skill already has a strong principal-architect stance: analyze the repo, generate candidate consolidation refactors, rank them, choose one, and produce an ExecPlan. However, because it is not a top-level folder in this source repository, it can drift from the managed source-of-truth workflow.

The remote repo `/tmp/useful-codex-skills` contains `find-refactor-candidates`, `select-refactor`, `execplan-improve`, and richer versions of `execplan-create` and `implement-execplan`. Its strongest ideas are the work-item directory `.agent/work/<YYYY-MM-DD-HHMM>-<slug>/`, small `meta.json` lifecycle state, separate `candidates.md`, `decision.md`, and `execplan.md` artifacts, a convenience `.agent/active` symlink, and a code-grounded `execplan-improve` pass that rewrites a plan only when it finds material evidence.

## Target State

The repository should expose two compatible paths.

The simple path remains: a user can ask for an ExecPlan from a PRD or problem statement, and `execplan-create` can still write `.agent/execplan-pending.md`; `implement-execplan` can still implement that singleton plan and move it to `.agent/done/` when complete.

The richer refactor path becomes available: `find-refactor-candidates` creates or updates `.agent/work/<id-slug>/meta.json` and `candidates.md`; `select-refactor` reads that candidate work item, runs an adversarial evidence pass, and writes `decision.md`; `execplan-create` can then write `.agent/work/<id-slug>/execplan.md`; `execplan-improve` can audit either that work-item plan or the legacy singleton plan; and `implement-execplan` can execute a work-item plan while updating `meta.json` instead of moving files around.

The design lens should be consistent across these skills. Use the best language from `refactor-something` and the remote repo: prefer deep modules over shallow wrappers, hide sequencing and policy behind stable boundaries, reduce concepts and special cases, and optimize for lower cognitive load and lower change amplification. Avoid making every skill a giant essay; keep each skill actionable and specific to its role.

The tracked source should include either a refreshed `refactor-something/SKILL.md` one-shot shortcut or a README note explaining that the staged workflow supersedes the installed-only version. Prefer adding `refactor-something/` as a source folder if the current installed skill should remain available, because this repository is meant to prevent copy drift.

## Implementation Plan

First, create the new source skill folders from the remote ideas, but adapt them to this repository instead of copying blindly.

Create `find-refactor-candidates/SKILL.md`. Base it on `/tmp/useful-codex-skills/find-refactor-candidates/SKILL.md`, preserving the search-only role, the `.agent/work/<id-slug>/` artifact model, the requirement to include `do nothing` and `minimal surgical change` candidates, and the assumption ledger. Tighten wording where useful so the skill remains concise. Also create `find-refactor-candidates/agents/openai.yaml` using the remote file as the starting point.

Create `select-refactor/SKILL.md`. Base it on `/tmp/useful-codex-skills/select-refactor/SKILL.md`, preserving the pressure-test step, cheap disconfirming evidence, `decision.md`, and `meta.json` transition to `stage="decision"` and `state="completed"`. Also create `select-refactor/agents/openai.yaml` from the remote file.

Create `execplan-improve/SKILL.md`. Base it on `/tmp/useful-codex-skills/execplan-improve/SKILL.md`, preserving the rule that every improvement must trace to actual code evidence, the work-item-first input resolution, the legacy `.agent/execplan-pending.md` fallback, and the final usefulness score. Keep the low-value repeat short-circuit if it still reads clearly. This skill should not change the plan's intent or turn into implementation.

Next, bring `refactor-something` under source control or explicitly retire it. Prefer creating `refactor-something/SKILL.md` from `/Users/tanvach/.codex/skills/refactor-something/SKILL.md`, but revise the final step so it does not pretend to be the only refactor path. It should read as the one-shot shortcut for small or urgent simplification requests, while `find-refactor-candidates` plus `select-refactor` is the deeper staged workflow. If the implementation chooses not to add this folder, update `README.md` to say the staged workflow replaces the installed-only shortcut and explain why it is not tracked here.

Update `execplan-create/SKILL.md`. Preserve its current ability to accept a PRD, RFC, voice note, brainstorming blurb, or detailed problem statement and write `.agent/execplan-pending.md`. Add the remote input-resolution order for decided work items: explicit work-item path, explicit `decision.md`, `.agent/active` pointing at a completed decision work item, most recently updated decision work item, then raw user brief. When using a decided work item, read `meta.json` and `decision.md`, write `execplan.md` inside the same work-item directory, and update metadata to `stage="plan"`, `state="completed"`, and `artifacts.execplan="execplan.md"`. Do not silently reopen candidate search unless `decision.md` is clearly incomplete. Fix the source-of-truth wording so `.agent/PLANS.md` is read when present, and `execplan-create/PLANS.md` is copied there only when needed.

Update `implement-execplan/SKILL.md`. Preserve the legacy singleton behavior for `.agent/execplan-pending.md`. Add work-item input resolution in this order: explicit work-item path, explicit `execplan.md`, `.agent/active` pointing at `stage="plan"` and `state="completed"` or `stage="implementation"` and `state="blocked"`, most recently updated matching work item, then legacy singleton. For work items, read `meta.json`, `decision.md` when present, and `execplan.md`; set metadata to `stage="implementation"` and `state="active"` before coding; set `state="completed"` when done; set `state="blocked"` with a recorded blocker if stopping partially complete. Keep the implementation-first rule: do not let this skill become a second plan-improvement pass.

Update `execplan-create/PLANS.md` and `.agent/PLANS.md` with the best remote guidance while keeping this repository's required section order. Add a short design-quality section that explains deep modules, information hiding, change amplification, cognitive load, unknown unknowns, and the complexity dividend. Make clear that every ExecPlan should explain what complexity exists today, who pays for it, what boundary becomes simpler, what knowledge moves out of callers, and how validation proves the result. Do not require nested fenced code blocks inside saved plan files.

Update `README.md`. Add the new skills to the included workflow list. Document the two supported workflows: the simple singleton ExecPlan flow and the richer staged refactor flow. Mention that source skill folders are canonical and generated Claude command files should be regenerated.

Regenerate derived Claude command files by running `./scripts/create_claude_skills.sh` from `/Users/tanvach/GitHub/codex-skills`. Do not hand-edit files under `generated/claude-commands/`. After generation, run `./scripts/create_claude_skills.sh --check` to confirm the generated files are current. Also run `./scripts/install_codex_skills.sh --check` and `./scripts/install_claude_skills.sh --check` to preview linking impact. If `refactor-something` is added as a source folder, expect the Codex install check to say it would back up the currently installed non-managed copy and link the source folder.

Review the resulting diff. Confirm that the new skill names in frontmatter exactly match folder names, descriptions are concise enough for discovery, and any references to sibling skills use the existing `$skill-name` convention so `scripts/create_claude_skills.sh` can convert them to Claude slash command references.

## Validation

Run these commands from `/Users/tanvach/GitHub/codex-skills`:

    ./scripts/create_claude_skills.sh
    ./scripts/create_claude_skills.sh --check
    ./scripts/install_codex_skills.sh --check
    ./scripts/install_claude_skills.sh --check
    git status --short
    git diff --check

Expected results: the first command creates or updates generated Claude command files for the new and changed skills; the second command reports all generated files unchanged; the install check commands preview links or backups without mutating installed skills; `git diff --check` reports no whitespace errors.

Inspect the generated files under `generated/claude-commands/` and confirm there are commands for `execplan-improve`, `find-refactor-candidates`, `select-refactor`, and, if added, `refactor-something`. Spot-check one generated file to ensure frontmatter was stripped and `$skill-name` references became `/skill-name` where applicable.

Read the final diff for `execplan-create/SKILL.md` and `implement-execplan/SKILL.md` and verify both mention work-item support and legacy singleton fallback. Read `README.md` and verify a new user can understand which workflow to use.

## Risks

The main risk is creating two competing refactor workflows that confuse discovery. Mitigate this by making `refactor-something` the explicit one-shot shortcut and making `find-refactor-candidates` plus `select-refactor` the staged workflow for larger refactors.

Another risk is over-importing the remote repo and bloating every skill. Mitigate this by preserving the remote concepts but trimming wording where the role is already clear. The skills should be opinionated, not ornamental.

A third risk is breaking the existing singleton ExecPlan flow. Mitigate this by keeping `.agent/execplan-pending.md` as an explicit fallback in `execplan-create`, `execplan-improve`, and `implement-execplan`, and by validating the generated Claude commands after edits.

If `refactor-something` is added as a source skill, `install_codex_skills.sh` may back up the currently installed copy on real install. That is expected, but the implementation should call it out in the final response before any non-check install is run.

## Progress

- [x] (2026-04-28 19:02Z) Refreshed `/tmp/useful-codex-skills` and confirmed it was already up to date.
- [x] (2026-04-28 19:02Z) Read the local ExecPlan rules, current `execplan-create`, current `implement-execplan`, sync workflow, remote refactor skills, remote plan-improvement skill, and installed-only `refactor-something`.
- [x] (2026-04-28 19:02Z) Created this pending ExecPlan for borrowing the strongest local and remote workflow ideas.
- [x] (2026-04-28 19:10Z) Added source folders for `find-refactor-candidates`, `select-refactor`, `execplan-improve`, and the one-shot `refactor-something` shortcut.
- [x] (2026-04-28 19:13Z) Updated `execplan-create`, `implement-execplan`, plan guidance, and README workflow docs for work-item and legacy flows.
- [x] (2026-04-28 19:16Z) Regenerated Claude commands and ran check-mode generation plus Codex and Claude install previews.
- [x] (2026-04-28 19:18Z) Reviewed final source and generated diffs, verified generated command conversion, and confirmed install preview impact.
