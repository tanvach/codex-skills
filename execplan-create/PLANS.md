When an ExecPlan is required, write it as a self-contained, executable design
document in Markdown. The reader should be able to hand the plan to an engineer
unfamiliar with this repository and expect a successful outcome. Do not depend
on prior context outside the current repository and the plan itself.

Start with why the change matters from a user or system perspective, then
explain the concrete end state and how to observe it. After that, provide
step-by-step instructions for what to edit, where to edit it, what to add or
remove, and how to verify the work. Prefer prose over bullet soup. Use
checklists only in the `Progress` section.

## Design Quality Lens

Use John Ousterhout's design philosophy as the default lens for shaping the
plan and resolving design ambiguity.

Prefer simple mental models over elegant-looking structure. Prefer deep modules
over shallow wrappers. Prefer interfaces that hide sequencing and policy
details. Prefer fewer concepts, fewer knobs, and fewer special cases. Prefer
moving complexity behind a stable boundary over redistributing it across more
files.

Treat these as the main forms of complexity:

- Change amplification: one logical change requires edits in many places.
- Cognitive load: a reader or caller must hold too many facts in mind.
- Unknown unknowns: important behavior is surprising, implicit, or scattered.

Every ExecPlan should explain the design quality of the proposed change, not
just the mechanics. Make clear what complexity exists today and who pays for
it, what boundary or interface becomes simpler, what knowledge or sequencing
moves out of callers and into the implementation, what concepts or special
cases disappear, and what future change becomes easier.

Do not mistake motion for simplification. A plan is weaker if it mainly adds
wrappers, adapters, flags, layers, or configuration without hiding more detail
from the rest of the system. If a new abstraction is required, state exactly
what it hides and why the system is simpler with it than without it.

The ExecPlan must contain these sections, in order:

# Title

A concise, imperative title.

## Goal

One paragraph describing the user-visible or operator-visible outcome, why it
is needed now, and the complexity or interface burden this change removes.

## Scope

State what is in scope and explicitly what is out of scope. Mention any
assumptions that materially affect implementation.

## Current State

Describe the relevant current behavior, architecture, and file layout. Name
exact files, modules, commands, or endpoints that matter so the implementer can
find them quickly. Define any non-obvious terms in plain language. Identify
what callers or maintainers currently need to know that they should not need to
know after the change.

## Target State

Describe the intended behavior after the change. Be specific about interfaces,
user flows, persistence, edge cases, and failure handling as applicable. State
what boundary becomes deeper or simpler and what knowledge moves behind it.

## Implementation Plan

Describe the work as a sequence of concrete steps. For each step, mention:

- the exact files or directories involved
- what to change and why
- any sequencing constraints or migration details
- any design choices that the implementer should preserve
- how the step reduces complexity, hides policy, or removes a special case

Prefer additive, testable changes followed by cleanup that keeps validation
passing. Do not leave key decisions to the implementer when repository evidence
is already strong enough to decide.

## Validation

Validation is not optional. Include instructions to run tests, to start the
system if applicable, and to observe it doing something useful. Describe
comprehensive testing for any new features or capabilities. Include expected
outputs and error messages so a novice can tell success from failure. Where
possible, show how to prove that the change is effective beyond compilation,
for example through a small end-to-end scenario, a CLI invocation, or an HTTP
request and response transcript. State the exact test commands appropriate to
the project's toolchain and how to interpret their results.

## Risks

Call out the main risks, tricky cases, or failure modes. For each, explain the
mitigation or fallback. Include risks to the intended simplicity boundary: for
example, cases where callers might still need to know sequencing details or
where a new layer might hide too little.

## Progress

Use a Markdown checklist and update it during implementation. Keep the
checklist outcome-focused, not task-management fluff. Every stopping point must
be documented here, even if it requires splitting a partially completed task
into done and remaining work.

Saved ExecPlan files should contain only the Markdown plan itself. Do not wrap
the entire saved file in outer triple backticks. If commands, transcripts,
diffs, or code snippets are useful, include concise indented examples rather
than nested fences.
