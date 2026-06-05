---
description: "Make the current answer, current query response, previous assistant answer, or recent conversation easier to read by rewriting it in a direct, concise, conversational style. Use when the user asks for concise mode, less mental load, a shorter answer, a tighter rewrite, or invokes /concise."
---

<!-- Generated from concise. Do not edit directly. -->


# Concise

Make the answer easier to read with less mental load.

Use this skill in two modes:

- **Attached to a query:** answer the user's current request in concise style.
- **One-off cleanup:** rewrite the most recent assistant answer or recent
  conversation into a shorter, clearer version.

If the target is ambiguous, default to the most recent assistant answer. Ask one
short clarifying question only when choosing the wrong target would change the
work.

## Style Rules

- Be direct, concise, and conversational.
- Start with the answer, decision, or next action.
- Use active voice.
- Keep paragraphs under 4 sentences.
- Use bullets only when they reduce scan time.
- Prefer short common words over formal phrasing.
- Cut filler phrases such as "in order to", "delve", "basically", "it is
  important to note", "needless to say", and throat-clearing intros.
- Remove unnecessary recap, process narration, caveats, and closing summaries.
- End immediately after answering the prompt.

## Preserve

Do not remove information the user needs to act:

- commands, file paths, URLs, identifiers, and exact error messages
- important caveats, safety constraints, and failed checks
- decisions, blockers, and next steps
- user-specified tone or formatting requirements

## Workflow

1. Identify the target: current answer, current query, previous answer, or recent
   conversation.
2. Decide what the user needs from it: answer, status, decision, action list, or
   compressed context.
3. Remove repetition and low-value explanation.
4. Merge duplicate points.
5. Rewrite in natural language with short paragraphs.
6. Check that the result still contains the necessary details.
7. Stop. Do not add a meta-explanation of what you changed unless asked.

## Output Defaults

For a rewritten answer, output only the rewritten answer.

For recent conversation context, use this shape:

```markdown
**Current State**
[1-3 sentences]

**Decisions**
- [decision]
- [decision]

**Next**
- [next action]
```

Drop any section that has no useful content.

## Research Basis

This skill follows plain-language and UX writing guidance:

- Microsoft Style Guide: use simple words, concise sentences, and remove words
  that do not add substance.
- Digital.gov plain-language guidance: write for the audience, use active voice,
  and prefer shorter sections.
- National Archives plain-language principles: state the main point first, keep
  paragraphs short, use active voice, and omit unneeded words.
- Web usability research summarized in GOV.UK content principles: scannable,
  concise content helps users find and retain information.
