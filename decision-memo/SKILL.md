---
name: decision-memo
description: >-
  Write or restructure a document as an answer-first, evidence-gated,
  decision-oriented memo: recommendation in the first paragraph, every
  material claim sourced, alternatives rejected with reasons, staged plans
  with quantified go/kill gates, and actions with owners and deadlines. Use
  whenever the user asks for a strategy memo, decision doc, design doc, RFC,
  PRD, investment memo, business case, proposal, post-mortem, or board/exec
  update — or asks to make an existing draft more rigorous, decision-oriented,
  answer-first, exec-ready, or "Bain-style"/"consulting-style".
---

# Decision Memo

Write documents that exist to drive a decision, in the diligence idiom:
answer-first, evidence-gated, decision-oriented.

Documents like this fail in one predictable way: they become essays.
Background first, evidence as narrative color, the recommendation hedged into
the final paragraph, and a roadmap that is a wishlist. Two moves do most of
the work of preventing that:

- **Answer-first** kills the essay structure. The decider should be able to
  stop after the first paragraph knowing what you recommend and what you are
  asking of them.
- **Quantified go/kill gates** kill the wishlist roadmap. A phase that does
  not name the assumption it tests, and a threshold that would kill it, is a
  task list wearing a roadmap costume.

Everything else in this skill supports those two moves.

## Before Drafting

1. **Identify the decision and the decider.** If the request does not name a
   decision, find the implicit one and confirm it. A document with no
   decision behind it is a status report; imposing fake decisiveness on it
   makes it worse, so say so rather than forcing the format. The audience
   sets vocabulary and depth — a board reads differently than an engineering
   team.
2. **Inventory the evidence before writing.** Sort every fact you intend to
   use into three bins:
   - **Sourced fact** — attributable to a named source: a document, dataset,
     system, interview, or publication, dated where it matters.
   - **Directional estimate** — explicitly flagged as such, with its basis
     stated ("directional, based on three customer interviews", "~$4–6M,
     scaled from last year's run rate").
   - **Assumption** — untested. Every material assumption must either be
     tested by a roadmap gate or appear in the risk register.
   A number that fits none of these bins does not go in the memo.
3. **Decide honestly first.** Write the recommendation as one sentence, with
   the criterion that would prove it wrong, before drafting anything else.
   If you cannot, you are not ready to write — go back to the evidence, or
   surface the gap to the user.

## Core Structure

The default shape, adapted per document type below:

1. **Executive summary.** The recommendation in the first paragraph, plus
   the decision being asked for and the two to four strongest reasons, each
   traceable to a section of the memo.
2. **Situation – Complication – Resolution.** Situation: facts the audience
   already accepts, kept short. Complication: what changed, and why the
   decision cannot wait. Resolution: the recommendation restated, with what
   would have to be true for it to work.
3. **The choices.** The explicit choice being made — for strategy,
   where-to-play and how-to-win — plus alternatives considered and rejected,
   with reasons. At least one rejected alternative must be one a reasonable
   person actually advocates; rejecting only straw men signals a decision
   already made in private. Rejection reasons meet the same evidence
   standard as everything else.
4. **Staged roadmap.** Each phase names the assumption it tests and a
   quantified go/kill gate: "Phase 1 tests whether enterprise buyers convert
   without a pilot; go if ≥3 of 10 target accounts sign LOIs by March 31,
   otherwise kill and revert to pilot-led sales." Gates state metric,
   threshold, date, and what happens on failure.
5. **Risk register.** Risk, rough likelihood and impact, mitigation, the
   early-warning signal that says it is materializing, and who watches it.
6. **Actions.** Owner (a named person or role — never "the team"), output
   (a deliverable, not an activity), deadline.

## Evidence Rules

- Cite every material claim to a named source. Material means: if this were
  false, the decision could change.
- "It is widely known", "studies show", "experts agree" are not sources.
- Never invent precision. False precision from a directional basis
  ("$4.7M") is worse than an honest range ("$4–6M, directional").
- When sources conflict, say so, and state which you weighted and why —
  silently picking the convenient one is how memos lose trust on page two.
- Missing evidence is content, not an embarrassment to paper over: state
  the gap, convert it into an assumption tested by a gate, or narrow the
  recommendation to what the evidence supports.

## Adapting to Document Type

The invariants — answer-first, sourced claims, rejected alternatives, gated
stages, owned actions — hold for every type. What varies is what the
decision is and what the gates measure:

- **Strategy memo** — decision: commit resources to a direction. Choices:
  where-to-play / how-to-win. Gates: market and traction metrics.
- **Investment memo** — decision: invest or pass. State the thesis as what
  would have to be true; the alternatives include passing and the competing
  use of capital; gates are milestones to the next check-in, with explicit
  kill criteria.
- **Design doc / RFC** — decision: build this design. Alternatives
  considered is already the genre norm — enforce real rejection reasons.
  Gates: rollout stages with metric or SLO criteria and rollback conditions
  (rollback is the kill).
- **PRD** — decision: build this scope now. Non-goals are rejected
  alternatives and get reasons. Gates: launch criteria plus post-launch
  success metrics, with a sunset condition if they miss.
- **Post-mortem / incident review** — decision: which corrective actions to
  fund. The timeline is sourced to logs, alerts, and commits; root-cause
  claims cite artifacts. The action list is the resolution; gates verify
  each fix actually works (a test, a drill, a metric back in range).
- **Board / exec update** — decision: the asks. Asks in the first
  paragraph, evidence after. If there is genuinely no ask, say "no decision
  needed this cycle" explicitly rather than manufacturing one.
- **Business case / proposal** — decision: fund or not. Every cost and
  benefit figure sourced or flagged directional; stage the funding so each
  tranche has a gate.
- **Research report** — decision: what to do with the findings. Rank
  findings by decision impact, not by the order you found them; attach
  evidence strength to each; the recommendation section is still
  answer-first.

For a type not listed, derive the mapping: name the decision, name the
choice being made and its live alternatives, and decide what a gate
measures. If no decision can be found, this skill does not apply.

## Anti-Patterns to Kill

- **Essay structure** — background before the answer.
- **Hedged recommendation** — "consider exploring options around…".
  Recommend one thing; uncertainty lives in the gates and the risk
  register, not in the verb.
- **Wishlist roadmap** — phases as feature lists testing nothing.
- **Unfalsifiable success** — "improve alignment", "drive engagement".
  Every recommendation carries a criterion that could fail.
- **Unsourced numbers and false precision.**
- **Framework jargon as a substitute for analysis** — a 2×2 or a named
  framework is admissible only as compression of an argument the memo
  already makes in plain language. Naming the framework is not the
  analysis.
- **Unowned actions** — "the team should".
- **Filler** — throat-clearing openings, restated sections, "in today's
  rapidly evolving landscape". Length is not rigor.

## Restructuring an Existing Draft

When the user brings a draft: diagnose it against the anti-pattern list
first and report the two or three structural problems before rewriting.
Then restructure. Preserve the author's evidence and voice — this skill
governs structure and rigor, not tone. Where the draft asserts numbers
without sources, ask for the source or downgrade them to flagged
directional estimates; do not silently keep them, and do not silently
delete them.

## Final Check Before Delivering

- Can the decider read only the first paragraph and know the
  recommendation and the ask?
- Does every number have a named source or a directional flag with a
  stated basis?
- Does every phase name the assumption it tests and a gate with metric,
  threshold, date, and failure consequence?
- Is at least one rejected alternative genuinely live?
- Does every action have an owner, an output, and a date?
- Does every recommendation have a criterion that could prove it wrong?
- Anything that serves none of the above gets deleted.
