---
name: double-check-work
description: >-
  Run a short final self-check before responding after creating a plan,
  implementing code, editing files, or summarizing documentation. For code,
  scrutinize correctness, plausible edge cases, regressions, verification, and
  maintainability. Use when the user asks for code changes, a plan, a docs
  summary, or explicitly asks to double-check, verify, sanity-check, review
  your own work, or be especially careful.
---

# Double Check Work

Before you give your final answer, do one short skeptical pass over the work you just did.

## What to check

- Did I actually do what the user asked, not a nearby version?
- Did I miss an obvious bug, broken assumption, or important caveat?
- If I changed files, did I inspect the diff and run the most relevant verification I reasonably can?
- If I wrote a plan, is it concrete, ordered, and missing any important validation step?
- If I summarized docs or research, did I overclaim or leave out a key constraint?
- If I could not verify something, am I saying that plainly instead of implying it was checked?
- If code changed, did I scrutinize the actual output for maintainability, not
  just correctness?

## Code correctness and edge cases

When code changed, inspect the implementation in context for plausible bugs and
regressions, not only compilation or the happy path. Check the cases that apply:

- boundary inputs such as empty, missing, malformed, minimum, maximum, or
  unusually large values
- error, timeout, retry, cancellation, cleanup, rollback, and partial-failure
  paths
- state transitions, ordering, idempotency, and concurrency risks
- compatibility with nearby callers and behavior that should remain unchanged
- focused tests that would fail before a bug fix and pass afterward

Do not invent impossible edge cases merely to lengthen the review. Use the
code's actual contracts, types, callers, and failure modes to decide what is
plausible. Run the smallest relevant checks, fix clear in-scope bugs, and state
what could not be verified.

## Maintainability scrutiny

Treat generated or edited code as suspect until you have read the changed code
in its surrounding module and checked that a future engineer can understand,
test, and safely modify it. Look for cohesive responsibilities, clear names,
simple control flow, explicit error handling, appropriate tests, duplicated
logic, misleading comments, and abstractions that hide little. Remove or flag
incidental complexity rather than calling it "clean code." State any material
maintainability risk in the final answer.

## What to do

1. Spend a brief pass challenging the work you just completed.
2. Fix any clear problem you find before responding.
3. In the final answer, mention the verification you performed and any remaining risk or what you could not verify.

## Keep it lightweight

- Do not start a second large implementation unless the first pass missed something important.
- Do not invent issues just to appear thorough.
- Prefer one solid verification pass over a long meta-analysis.
