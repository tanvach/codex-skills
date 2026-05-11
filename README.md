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

Listed in roughly the order they appear in the staged workflow:

- `architecture-docs-creator` produces an opinionated `ARCHITECTURE.md` and stops for approval. Use at the start of a new repo or when none exists.
- `update-architecture-docs` refreshes `ARCHITECTURE.md` after implementation lands or when it has drifted. Reads completed plans from `.agent/done/` to find architectural shifts.
- `create-todo` creates a carefully ranked root `TODO.md` when a repo has no strong todo list yet.
- `update-todo` prunes, reranks, and integrates new requests into an existing root `TODO.md`. Reads completed plans from `.agent/done/` to integrate follow-ups.
- `execplan-create` creates an ExecPlan from a brief, PRD, RFC, or locked refactor decision.
- `execplan-improve` audits an existing ExecPlan against real code and rewrites only code-grounded improvements.
- `execplan-portability-check` scores an ExecPlan for portability to a fresh implementer with no conversation history. Use before handing a plan off to a different model or session.
- `implement-execplan` executes a work-item ExecPlan or legacy singleton plan, with per-step commits and mandatory living-section updates before archive.
- `verify-implementation` triangulates the plan against the actual `git diff` and validation runs. Use after `implement-execplan`, ideally in a fresh session or on a stronger model, to catch silent deviations and validation failures.
- `walk-through-changes` explains completed implementation work so a human can validate the structure.
- `find-refactor-candidates` creates a materially different refactor shortlist under `.agent/work/`.
- `select-refactor` challenges a shortlist and locks the final refactor decision before planning.
- `refactor-something` is the one-shot shortcut for a single consolidation refactor recommendation.
- `sync-skills` regenerates derived files and installs managed links for all four tools.

## Workflows

Three entry points. One shared per-task loop. Same-session work skips two rigor passes.

### Starting a new repo

Before any per-task work, lay down the shared artifacts:

```bash
$architecture-docs-creator   # produces ARCHITECTURE.md (stops for approval)
$create-todo                 # produces a prioritized TODO.md
```

Then pick the top item from TODO.md and enter the per-task loop with it as input.

### Continuing work on an existing repo

If ARCHITECTURE.md or TODO.md has drifted, refresh them first:

```bash
$update-architecture-docs    # refresh ARCHITECTURE.md if implementation has moved past it
$update-todo                 # rerank, prune, integrate any new requests
```

If the next piece of work isn't already named, pick it:

```bash
$find-refactor-candidates    # shortlist 3-5 refactor opportunities under .agent/work/
$select-refactor             # pressure-test the shortlist and lock the choice
# or use $refactor-something as a one-shot shortcut for small/urgent refactors
```

Otherwise, take the item directly from TODO.md or a PRD/RFC.

### Per-task loop (full rigor, cross-model handoff)

This is the loop with every rigor pass run. Use it when planning and implementing may happen in different sessions or on different models (e.g. plan on Claude/GPT-5, implement on Gemini Flash):

```bash
$execplan-create             # plan from a PRD, RFC, TODO item, or locked refactor decision
$execplan-improve            # rewrite the plan against real code, fix code-grounding gaps
$execplan-portability-check  # audit the plan in isolation; flag context that leaks from this session
$implement-execplan          # implement; per-step commits; fill living sections before archive
$walk-through-changes        # human-readable explanation for the reviewer
$verify-implementation       # triangulate plan vs git diff vs validation runs
$update-architecture-docs    # absorb any architectural shifts into ARCHITECTURE.md
$update-todo                 # mark done, integrate follow-ups from Outcomes & Retrospective
```

If `$verify-implementation`'s verdict is `silently deviates` or `fails validation`, loop back through `$execplan-improve` → `$implement-execplan` → `$verify-implementation` until the verdict is clean. **Do not run `$update-todo` until the verdict is good** — checking off TODO items for half-done work hides the gap.

### Per-task loop (same-session shortcut)

When planning and implementing happen in the same session and same model, two rigor passes are redundant because conversation context is already in the model:

```bash
$execplan-create             # plan
$execplan-improve            # still useful — catches code-grounding drift, not just context leakage
# skip $execplan-portability-check — its job is to detect handoff leakage
$implement-execplan          # the embedded $double-check-work pass covers same-session sanity
# skip $verify-implementation — same-session validation already happened via double-check-work
$walk-through-changes        # optional, mostly for the human reviewer
$update-architecture-docs    # still required — docs don't care about session boundaries
$update-todo                 # still required — backlog hygiene doesn't care about session boundaries
```

The two skips are `$execplan-portability-check` and `$verify-implementation`. Both exist specifically to catch what cross-session/cross-model handoff loses; in same-session use, conversation memory plus `$double-check-work` cover the same ground at lower cost. The rest of the loop still applies.

### ExecPlan artifact paths

**Singleton flow** (small/direct implementations):
- `.agent/execplan-pending.md` while planning and implementing.
- `.agent/done/<timestamp>-<slug>.md` after archive.

**Staged flow** (larger refactors, multi-step initiatives):
- `.agent/work/<id-slug>/`
  - `meta.json` — lifecycle state.
  - `candidates.md` — refactor shortlist.
  - `decision.md` — locked refactor choice.
  - `execplan.md` — executable plan.

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
