---
description: "Score an ExecPlan's portability to a fresh implementer with no conversation history. Identify implicit references, judgment-requiring steps, missing evidence, and non-mechanical validation. Use after execplan-improve and before handing the plan off to a different model or session, or any time the user asks whether a plan is portable, self-contained, or safe to hand off."
---

<!-- Generated from execplan-portability-check. Do not edit directly. -->


# ExecPlan Portability Check

Read the plan in isolation. Test whether a fresh implementer — different model, different session, no conversation history — could execute every step unambiguously using only the plan text.

## Critical rule

Treat the plan file as your only source. Do not use prior conversation memory. Do not read other repo files. Do not assume the user described anything that is not literally in the plan. If a phrase in the plan would only make sense given prior context you happen to have, that is itself a finding — flag it.

If you find yourself wanting to read another file to "understand what the plan means," stop. That impulse confirms the plan is not portable. Record what context you wanted and where in the plan you wanted it.

## Resolve the plan

Same priority order as `execplan-improve`:

1. Explicit plan path supplied by the user.
2. Explicit work-item path supplied by the user.
3. `.agent/active` when it points to a work item with `stage="plan"` and `state="completed"`.
4. The most recently updated work item under `.agent/work/` with `stage="plan"` and `state="completed"`.
5. Legacy fallback: `.agent/execplan-pending.md`.
6. If running on a finished plan, the most recently dated file under `.agent/done/`.

If no plan exists in any supported location, tell the user and stop.

## Workflow

1. Read the plan file. That is the only file you read.
2. Walk the rubric below as a literal checklist. Record each finding with the line number or section heading where it appears.
3. Score portability 0-10 using the scoring section.
4. Produce a punch list. Each finding cites a specific location and offers a one-sentence prescription.
5. Issue a verdict: `ready`, `needs minor revision`, or `needs significant rewrite`.

## Rubric

### A. Implicit references to prior context

Flag any phrase that only resolves with conversation memory the plan does not itself contain. Common patterns:

- "the user said", "as we discussed", "as the user noted", "you mentioned"
- "above", "earlier", "the prior turn", "in this conversation"
- "Test A" or other named procedures not defined in the plan
- "the previous plan" without a path to that plan

Prescription: replace with a quoted excerpt of the actual content the phrase refers to, or define the named procedure inline.

### B. Vague file references

Flag any reference to a file or directory that is not a fully-qualified path or is described by position rather than name. Examples:

- "the script that handles X"
- "the relevant config file"
- "the one we just edited"

Prescription: name the absolute path or path relative to the repo root.

### C. Judgment verbs in implementation steps

Flag any step that requires the implementer to use reasoning beyond mechanical execution. Trigger words:

- "audit", "evaluate", "consider", "assess", "review"
- "decide whether", "choose the appropriate"
- "use your best judgment", "as needed", "if it makes sense"
- "reasonable", "appropriate", "sensible"

Prescription: either pre-make the decision in the plan and prescribe the mechanical edit, or mark the step `[REQUIRES_REASONING]` so a hybrid workflow routes that step to a stronger model.

A step in the Goal, Scope, Current State, or Risks sections may legitimately use judgment language to characterize the design. Only flag judgment verbs that appear in **Implementation Plan** or **Validation** steps where the implementer must act.

### D. Non-mechanical validation criteria

Flag any Validation step that cannot be reduced to one of:

- a shell command with expected output ("run `pytest`; expect 0 failures"),
- a file-state check ("file `foo.sh` exists and is executable", "symlink `~/.x` resolves to `<path>`"),
- a structural diff (`diff <(…) <(…)` returns empty or matches a stated pattern).

Failure mode: "verify the refactor is clean" — clean by what metric? "Confirm the agent picks up the skill" — confirm how, by what signal?

Prescription: rewrite as an exact predicate the implementer's tool can check without reasoning. If the only signal genuinely requires a human (e.g. "the dropdown menu shows X"), label that step `[REQUIRES_HUMAN]` and exclude it from automated portability claims.

### E. Unresolved external evidence

Flag references to external state — command output, banner text, error messages, test results, user observations — that are summarized but not quoted verbatim in the plan. The plan should contain the literal source, fenced, so the implementer can reason from it.

Failure mode: "the user confirmed the conflict banner appeared" — the implementer cannot tell which banner, what text, what conflict.

Prescription: copy the actual text into an `## Artifacts and Notes` section (or inline fenced block at the cite), verbatim.

### F. Missing required sections

Required by PLANS.md regardless of plan size:

- `Progress`

Required when the plan touches any of these triggers:

- Decisions taken between alternatives → `Decision Log`
- Discoveries made during execution → `Surprises & Discoveries`
- External evidence cited → `Artifacts and Notes`
- Completed plan archived to `.agent/done/` → `Outcomes & Retrospective`

If the trigger applies and the section is empty or missing, flag.

### G. Tool-surface assumptions

Flag any step that assumes a tool only one harness has. Common slips:

- "use the NotebookEdit tool" (Claude-specific)
- "click X in the IDE" (no headless harness can do this)
- "use the search tool" (vague — which tool?)
- "ask the user to confirm" (not portable across non-interactive runs)

Prescription: phrase steps in terms of the portable surface — `Read`, file edits described as `old_string` → `new_string`, `Write`, `Bash`, `Grep`, web fetch — that every reasonable agent harness supports.

## Scoring

Score is 10 minus a penalty count, capped at 0.

| Category | Penalty per finding |
|---|---|
| A — Implicit references | 1 |
| B — Vague file references | 1 |
| C — Judgment verbs in implementation steps | 2 |
| D — Non-mechanical validation | 2 |
| E — Unresolved external evidence | 2 |
| F — Missing required section | 1 per section |
| G — Tool-surface assumption | 1 |

Calibration:

- **9-10:** Ready for any handoff including weaker models or open-weight.
- **7-8:** Ready for same-family model handoff (Claude → Claude in new session, Claude → GPT-5).
- **5-6:** Same-model new-session is risky. Cross-model handoff likely to fail on at least one step.
- **3-4:** Only works in the original session. Significant context leakage.
- **0-2:** Plan is effectively a conversation summary. Rewrite required.

## Output

Report in this exact shape so the user can scan it quickly:

    Portability score: X/10

    Findings (N):
    1. [Category A] Line 42, "Goal" paragraph
       Issue: References "the previous discussion" without paraphrasing what was discussed.
       Fix: Quote the relevant decision or summarize it inline.
    2. [Category D] Validation step 3
       Issue: "Confirm the install works" is not a mechanical predicate.
       Fix: Replace with "run `./scripts/install_foo.sh --check`; expect 'Done. linked=N' line."
    …

    Verdict: ready | needs minor revision | needs significant rewrite
    Recommended next step: hand off to implementer | re-run execplan-improve with the punch list above | rewrite the plan from scratch using the findings as a checklist

If the plan scores 9-10 and has no findings, you may skip the empty findings block and end with the verdict.

## What this skill does NOT do

- Does not rewrite the plan. Use `execplan-improve` for that, feeding it the punch list as input.
- Does not run validation against actual repo state. Use `double-check-work` for post-implementation verification.
- Does not check code-grounding (whether prescribed edits match real files). That is `execplan-improve`'s job. This skill audits the *prose* of the plan, not the repo.

## Anti-patterns

- Reading other files to "fill in the gaps." If you do this, you have confirmed the plan is not portable — record the gap as a finding rather than closing it yourself.
- Using conversation memory to resolve ambiguous references. Same lesson.
- Scoring above 5 when categories C or E have any findings — those are the load-bearing categories for cross-model portability and a single finding in either is enough to make handoff unreliable.
- Flagging things as judgment-required when the plan already pre-decided them. "Choose between A and B" is a finding. "Use A because B is unsafe when Y" is the plan correctly making the decision.
