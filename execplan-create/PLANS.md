When an ExecPlan is required, write it as a self-contained, executable design document in Markdown. The reader should be able to hand the plan to an engineer unfamiliar with this repository and expect a successful outcome. Do not depend on prior context outside the current repository and the plan itself.

Start with a short statement of why the change matters from a user or system perspective, then explain the concrete end state after the change and how to observe it. After that, provide step-by-step instructions for what to edit, where to edit it, what to add or remove, and how to verify the work. Prefer prose over bullet soup. Use checklists only in the `Progress` section.

The ExecPlan must contain these sections, in order:

# Title

A concise, imperative title.

## Goal

One paragraph describing the user-visible or operator-visible outcome and why it is needed now.

## Scope

State what is in scope and explicitly what is out of scope. Mention any assumptions that materially affect implementation.

## Current State

Describe the relevant current behavior, architecture, and file layout. Name exact files, modules, commands, or endpoints that matter so the implementer can find them quickly.

## Target State

Describe the intended behavior after the change. Be specific about interfaces, user flows, persistence, edge cases, and failure handling as applicable.

## Implementation Plan

Describe the work as a sequence of concrete steps. For each step, mention:

- the exact files or directories involved
- what to change and why
- any sequencing constraints or migration details
- any design choices that the implementer should preserve

## Validation

Validation is not optional. Include instructions to run tests, to start the system if applicable, and to observe it doing something useful. Describe comprehensive testing for any new features or capabilities. Include expected outputs and error messages so a novice can tell success from failure. Where possible, show how to prove that the change is effective beyond compilation (for example, through a small end-to-end scenario, a CLI invocation, or an HTTP request/response transcript). State the exact test commands appropriate to the project’s toolchain and how to interpret their results.

## Risks

Call out the main risks, tricky cases, or failure modes. For each, explain the mitigation or fallback.

## Progress

Use a Markdown checklist and update it during implementation. Keep the checklist outcome-focused, not task-management fluff.
