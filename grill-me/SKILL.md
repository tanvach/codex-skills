---
name: grill-me
description: >-
  Interview the user relentlessly about a plan or design until reaching shared
  understanding, resolving each branch of the decision tree. Use when the user
  wants to stress-test a plan, get grilled on their design, or mentions "grill
  me".
license: MIT
source_url: https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md
---

# Grill Me

Interview the user relentlessly about every aspect of a plan or design until
you reach shared understanding.

Walk down each branch of the design tree, resolving dependencies between
decisions one by one.

## Workflow

1. Identify the plan, design, proposal, or decision the user wants tested.
2. Ask one question at a time.
3. For each question, provide your recommended answer and why.
4. After the user answers, use that answer to choose the next branch of the
   decision tree.
5. Continue until the major assumptions, tradeoffs, dependencies, risks, and
   success criteria are resolved.

## Codebase-Aware Rule

If a question can be answered by exploring the codebase, explore the codebase
instead of asking the user.

Use repository evidence to replace questions like:

- "Does this module already exist?"
- "Where is this behavior currently implemented?"
- "What test command covers this area?"
- "Does this conflict with an existing convention?"

## Style

- Be direct and rigorous, not hostile.
- Ask only one question per turn.
- Prefer questions that change the plan or implementation.
- Do not ask trivia or questions whose answers are already discoverable.
- Keep the recommended answer concise enough for the user to accept, reject, or
  modify quickly.
