---
name: find-refactor-candidates
description: >-
  Search a repo for the top 3-5 materially different refactor opportunities,
  record evidence for each, and create a work item for later selection and
  planning. Use when the user wants a shortlist before choosing a refactor,
  architectural simplification, boundary extraction, duplication removal, or
  high-leverage cleanup.
---

# Find Refactor Candidates

## Goal

Search the repo from first principles and produce a materially different
shortlist of refactor hypotheses before commitment hardens.

This is a search step, not a planning step and not a final-decision step. Do
not ask the user to choose among options. Do not create an ExecPlan. Leave
behind a work item that `$select-refactor` can pressure-test and decide.

## Work Item Model

Use one stable work-item directory per initiative:

`.agent/work/<YYYY-MM-DD-HHMM>-<slug>/`

Inside that directory, this skill owns:

- `meta.json`
- `candidates.md`

The work-item directory is the source of truth for the initiative. Do not
encode lifecycle state in filenames or by moving files between folders.

Create or update `.agent/active` as a convenience symlink pointing at the
current work item when practical, but treat `meta.json` as authoritative.

Use this compact metadata shape:

```json
{
  "id": "2026-04-28-1200-auth-boundary-owner",
  "slug": "auth-boundary-owner",
  "title": "Auth boundary owner refactor",
  "created_at": "2026-04-28T19:00:00Z",
  "updated_at": "2026-04-28T19:30:00Z",
  "stage": "candidates",
  "state": "completed",
  "artifacts": {
    "candidates": "candidates.md",
    "decision": null,
    "execplan": null,
    "review": null
  }
}
```

For this skill, the normal final metadata is `stage="candidates"` and
`state="completed"`.

## Design Lens

Use John Ousterhout's design philosophy as the primary lens:

- prefer simple mental models over elegant-looking structure
- prefer deep modules over shallow wrappers
- prefer interfaces that hide sequencing and policy details
- prefer fewer concepts and fewer special cases
- prefer moving complexity behind a stable boundary over redistributing it

Treat these as the main forms of complexity: change amplification, cognitive
load, and unknown unknowns.

Ask: "What are the strongest plausible refactor directions, before we decide
which one deserves commitment?"

## User Guidance

Treat user guidance as either:

- hard constraints: explicit scope, risk, or prohibitions
- soft guidance: hints, priors, or suspected messy areas

Honor hard constraints strictly. Treat soft guidance as weighting, not proof.
If the user says "planning only" or "do not implement," treat that as a hard
no-edit constraint on code. Creating or updating work-item artifacts under
`.agent/` is still allowed because this skill is a planning workflow.

## Workflow

1. Resolve scope and work item.
   - Determine the target repo or directory, hard constraints, soft guidance,
     and risk tolerance.
   - If the user references an existing work-item directory, reuse it.
   - Otherwise create `.agent/work/<timestamp>-<slug>/`, initialize
     `meta.json`, and update `.agent/active` when practical.
2. Build a first-principles repo model.
   - Read `README`, `ARCHITECTURE.md`, or similar docs.
   - Identify languages, frameworks, major entry points, and central modules.
   - Map 3-5 core flows.
   - Collect lightweight evidence: import or reference frequency, file size and
     directory spread, git churn when available, co-change evidence, nearby
     tests, and whether the area is core or niche.
3. Generate 3-5 materially different candidates.
   - Include one `do nothing` option.
   - Include one `minimal surgical change` option.
   - Do not produce variants of the same abstraction move.
   - Good candidate classes include deepening a shallow module, hiding
     sequencing or policy, consolidating duplicate concepts, eliminating
     special-case complexity, or removing a stale layer.
4. Write an assumption ledger for each candidate.
   - Capture the candidate name, refactor class, scope, problem statement,
     supporting evidence, contradictory evidence, falsifier, expected payoff,
     blast radius, reversibility, and cheapest useful probe.
5. Rank without locking the decision.
   - Score complexity removed from callers and readers, information-hiding
     gain, cognitive load reduction, change amplification reduction,
     special-case elimination, blast radius versus risk, and evidence
     confidence.
   - Name a provisional leader, not a final winner.
6. Write `candidates.md`.
   - Include repo scope and constraints, the repo model, ranked shortlist,
     assumption ledgers, provisional leader, why each runner-up is still alive,
     and the next step for `$select-refactor`.
7. Finalize metadata.
   - Set `stage="candidates"`, `state="completed"`,
     `artifacts.candidates="candidates.md"`, and `updated_at=<now>`.

## Anti-Patterns

- offering a single winner with no serious alternatives
- omitting the `do nothing` option
- omitting the `minimal surgical change` option
- creating candidates that are cosmetic variants of one idea
- creating `decision.md` or `execplan.md` in this skill
- asking the user to choose among the candidates
