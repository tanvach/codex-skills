---
name: refactor-something
description: >-
  Suggest one consolidation refactor that reduces surface area after repo
  analysis. Use as the one-shot shortcut for small or urgent simplification
  requests; use find-refactor-candidates and select-refactor for deeper staged
  refactor selection.
---

# Consolidation Refactor Shortcut

## Mindset

Approach this task as a principal software architect would. The job is not to
find every possible refactor. It is to identify the one refactor that delivers
the highest value relative to cost and risk.

Be decisive. Do not ask clarifying questions when the codebase can answer
them. Make reasonable assumptions based on evidence, state those assumptions,
and move forward with the best recommendation.

For larger, riskier, or more ambiguous refactor searches, prefer the staged
workflow:

1. `$find-refactor-candidates`
2. `$select-refactor`
3. `$execplan-create`
4. `$execplan-improve`
5. `$implement-execplan`

Use this skill when the user wants the shortcut: one recommendation and,
optionally, an ExecPlan.

## Prioritization Criteria

Rank candidates by:

1. Blast radius versus payoff. A refactor touching 3 files that eliminates an
   entire abstraction layer beats a cleaner refactor touching 30 files.
2. Cognitive load reduction. Fewer concepts for a new engineer to learn matters
   more than fewer lines of code.
3. Bug surface area. Consolidating code paths that diverge for no good reason
   removes classes of bugs.
4. Velocity unlock. Refactors that unblock future work get priority.
5. Risk tolerance. Favor refactors with clear validation and rollback paths.

Do not propose cosmetic cleanup, speculative abstraction, or broad rewrites of
stable working code without a clear win.

## Workflow

1. Establish scope and constraints.
   - Default to the current workspace root unless the user specifies a
     directory.
   - Assume production-level caution unless the repo is clearly experimental.
   - Treat user-mentioned pain points as weighting, not proof.
2. Analyze the repo with evidence.
   - Start with `README`, `ARCHITECTURE.md`, or similar docs.
   - Identify the top 5-10 most imported or referenced modules.
   - Trace 2-3 core user flows.
   - Look for duplicate abstractions, thin wrappers, shotgun surgery, dead
     code, and leaky abstractions.
3. Rank 2-4 candidate consolidation refactors.
   - Score payoff, blast radius, cognitive load reduction, velocity unlock,
     and ease of validation or rollback.
4. Propose the single best refactor.
   - Include current state, proposed change, impacted files, expected outcome,
     acceptance criteria, and risks with mitigations.
5. Make the call.
   - If candidates score similarly, pick the smallest blast radius.
   - Tie-break by easiest validation.
6. Produce an ExecPlan when requested or clearly useful.
   - Use `$execplan-create`.
   - The problem statement is the consolidation summary plus acceptance
     criteria.
   - Preserve affected paths, test steps, and validation criteria.

## Anti-Patterns

- asking clarifying questions when repo evidence is enough
- presenting multiple options without a recommendation
- boiling the ocean
- proposing cosmetic cleanup
- inventing speculative abstractions
- ignoring stable working code
- making claims without file evidence
