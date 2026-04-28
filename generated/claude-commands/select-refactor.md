---
description: "Read a refactor candidate shortlist, pressure-test the leading options with cheap repo evidence, and lock the final refactor choice in a work item before planning. Use when the user wants the best refactor chosen from a shortlist, wants the current favorite challenged, or wants a final decision before an ExecPlan."
---

<!-- Generated from select-refactor. Do not edit directly. -->


# Select Refactor

## Goal

Turn a refactor shortlist into a locked decision.

This is the commitment step between search and planning. Pressure-test the
current leader, gather cheap disconfirming evidence, compare runner-ups
honestly, and freeze one decision so `/execplan-create` does not silently
re-open the search space.

Do not create an ExecPlan here.

## Work Item Resolution

Preferred target resolution order:

1. Explicit work-item path supplied by the user.
2. Explicit `candidates.md` or `decision.md` path supplied by the user.
3. `.agent/active` when it points to a work item with `stage="candidates"` and
   `state="completed"`.
4. The most recently updated work item under `.agent/work/` with
   `stage="candidates"` and `state="completed"`.

If no candidate work item exists, stop and tell the user to run
`/find-refactor-candidates` first.

This skill owns:

- `decision.md`
- updates to `meta.json`

## Design Lens

Use John Ousterhout's design philosophy as the design lens:

- prefer deep modules over shallow wrappers
- prefer interfaces that hide sequencing and policy details
- prefer fewer concepts and fewer special cases
- prefer simpler mental models over structurally tidy but leaky decompositions

Treat these as the main forms of complexity: change amplification, cognitive
load, and unknown unknowns.

## Selection Rule

The job is not to polish the current favorite. The job is to decide which
candidate survives criticism best.

Every pre-planning cycle inside this skill must end by doing at least one of
these:

- introducing one materially new candidate
- deleting a candidate from serious consideration
- changing confidence based on new repo evidence

If a cycle does none of those things, it is probably only producing nicer
prose.

## Workflow

1. Read the candidate brief and metadata.
   - Read `meta.json` and `candidates.md`.
   - Extract the candidate set, provisional leader, assumptions, falsifiers,
     cheapest probes, and repo constraints.
2. Run an adversarial challenge pass.
   - Assume the provisional leader may be wrong.
   - Ask what hidden coupling makes it costlier than it looks, what evidence
     contradicts it, what simpler alternative gets most of the benefit, what
     runner-up strengthens if the leader's main assumption fails, and whether
     the minimal surgical change or do-nothing option dominates under the
     stated risk tolerance.
3. Gather cheap evidence.
   - Favor disconfirming evidence over elaboration.
   - Useful probes include call-site and import fan-out, dependency graphs,
     churn or co-change history, nearby tests, ownership boundaries, API
     surface spread, and tiny non-editing repros.
   - Do not drift into planning or implementation.
4. Lock the decision.
   - Choose the winning refactor and write `decision.md` with the chosen
     refactor, why it beats the alternatives now, evidence that changed
     confidence, why runner-ups lost, success criteria, first safe slice,
     abandonment conditions, and hard constraints for `/execplan-create`.
5. Finalize metadata.
   - Set `stage="decision"`, `state="completed"`,
     `artifacts.decision="decision.md"`, and `updated_at=<now>`.

## Anti-Patterns

- merely rephrasing the provisional leader
- treating critique as decorative instead of decision-changing
- reopening the entire search space without new evidence
- creating `execplan.md` here
- leaving the decision implicit
