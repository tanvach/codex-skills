---
description: "Add accurate, high-explanatory-power graphics to a document, walkthrough, or presentation after evaluating where visuals genuinely improve understanding. Use when the user asks to add graphics, diagrams, charts, images, visual aids, or a more visual walkthrough."
---

<!-- Generated from add-graphics. Do not edit directly. -->


# Add Graphics

Add only the visuals that make an explanation easier to understand. A graphic
must clarify a real question, not decorate empty space.

Use this skill for documents, walkthroughs, technical explanations,
presentations, and product material where a diagram, chart, screenshot, image,
or annotated visual may reduce reader effort.

## Core Standard

For every graphic, be able to answer:

- What question does this let the reader answer faster or more accurately?
- What source text, data, or verified asset supports every label, number, arrow,
  state, or visual claim?
- Why is a graphic better than a sentence, table, or heading here?

If those answers are weak, do not create the graphic. No graphic is better than
a decorative or misleading one.

## Re-entry, Idempotency, and Chaining

This skill is safe to run repeatedly on the same document. Start every run by
inventorying the scoped document's existing graphics, their source assets,
generation scripts or prompt manifests, and previous rendered-validation notes.
Treat them as owned artifacts, not disposable drafts.

Before creating anything, give every existing graphic one state:

- **Validated unchanged:** it still answers its reader question, its source
  material and placement have not changed, and its rendered check is still
  representative.
- **Repair:** the concept is still useful, but its source, labels, layout,
  rendering, or supporting text changed. Update the existing asset in place,
  then rerender and validate it.
- **Remove:** it no longer improves understanding, is inaccurate, or is
  redundant.
- **Create:** a newly identified reader question has enough explanatory value
  to justify a visual.

Do not create duplicate graphics or versioned copies merely because the skill
is rerun. Reuse stable graphic IDs, output paths, and scripts unless the new
asset represents a genuinely separate concept. Do not modify graphics outside
the document's agreed scope.

Use the repository's tracking convention when it has one. Otherwise, keep a
small manifest at `scripts/graphics/<document-slug>.manifest.json`, alongside
the generation scripts. For every graphic, record its stable ID, reader
question, source inputs, output path, generator script or prompt manifest,
target rendered surface, and latest validation result. Update the manifest on
every run, including no-op validation runs, so the next pass can distinguish a
current asset from a stale one.

This skill can follow writing, planning, or review skills. When an upstream
step changes the document's meaning, structure, data, or layout, revisit the
affected graphics from the fresh-read stage; do not assume previous validation
still applies. Finish with enough asset and validation state for a later
`add-graphics` run or collaborator to continue without reconstructing history.

## Stage 1: Fresh Read Without Graphics

Read the source linearly as a reader with no author context. Do not look for
places to decorate yet.

When a subagent is available, give it only the source text, target audience, and
desired outcome. Ask it to make brief reader notes:

- what it thinks the material is trying to explain
- where it slowed down or had to build a mental model
- where relationships, sequence, comparison, scale, state, or spatial layout
  are difficult to picture
- which one or two visuals would have the highest explanatory power, if any

Do not give this first reader a proposed graphic or ask it to validate the
author's plan. It needs to react independently.

When no subagent is available, make the same notes yourself before selecting a
graphic.

## Stage 2: Choose Visuals Deliberately

Turn the reader notes into a short candidate list. For each candidate, make a
visual brief with:

- the reader question it answers
- the exact source evidence it represents
- the most accurate visual form
- explanatory power: low, medium, or high
- implementation work: low, medium, or high
- hallucination risk: low, medium, or high
- decision: validated unchanged, repair, remove, create, defer, or reject

Choose the smallest set of high-value graphics. Prefer no more than the reader
needs to follow the logic.

Use these defaults:

- **Diagram:** explicit components, boundaries, flows, dependencies, or sequence.
- **Chart:** verified quantities, comparisons, distributions, or trends.
- **Screenshot or annotated existing asset:** real UI, product state, document, or
  physical object the reader must inspect.
- **Generated image:** atmosphere, concept, or non-evidentiary illustration only.
  Never present it as evidence or a faithful depiction of an unverified system,
  person, place, event, data point, or UI state.
- **No graphic:** the text or a compact table already explains it more clearly.

Favor diagrams and charts when correctness matters. Do not invent data, labels,
states, transitions, examples, or causal links to make a graphic feel complete.

## Stage 3: Build Reproducible Assets

Use the target repository's established asset and diagram conventions first. If
none exist, keep generation code under:

```text
scripts/graphics/<document-slug>-<graphic-slug>.<ext>
```

Use names that say what the script creates, such as
`scripts/graphics/checkout-flow-diagram.js` or
`scripts/graphics/api-latency-chart.py`. Do not put one-off generation scripts
in the repository root or hide them in temporary directories.

- Keep the script that generated each code-based graphic.
- Create or update `scripts/graphics/<document-slug>.manifest.json` with each
  graphic's stable ID, reader question, source inputs, output path, generator
  source, render target, and latest validation result.
- Record the source inputs and output path in a short comment at the top of the
  script.
- Store the output asset where the target project keeps document or UI assets.
- If a raster image tool cannot be reproduced with code, keep the exact prompt,
  source references, and output path in a nearby clearly named prompt manifest.
- Reuse existing graphics rather than recreating them when they are accurate and
  fit the material.

On a repair, update the established asset and its source in place. Do not leave
obsolete exports or use `-v2` filenames unless both versions are intentionally
needed by the document.

## Stage 4: Render and Inspect What the User Sees

A graphic is not validated until it has been rendered and inspected as an image
or in the final user surface. Source code, SVG markup, diagram syntax, chart
data, DOM structure, or a successful export command are not proof that the user
will see a correct graphic.

Render the graphic in the same medium the user will consume:

- **Web or app UI:** inspect a browser screenshot at the intended viewport and
  at least one constrained viewport when the graphic is responsive.
- **SVG, Mermaid, Canvas, or chart code:** inspect a rasterized render or
  screenshot, not only the source file.
- **Markdown or repository-rendered SVG:** inspect the graphic embedded in the
  target renderer when possible. At minimum, render it at the actual document
  content-column width and at the narrowest expected column width, rather than
  at its native export width.
- **Document, PDF, or slide:** render the actual page or slide at normal reading
  scale and inspect the placed result.
- **Standalone image:** inspect the image composited against the intended
  background and alongside the surrounding text.

Check the rendered result for:

- blank, missing, clipped, cropped, overlapped, or off-canvas elements
- readable labels, legends, arrows, annotations, and contrast at normal size
- correct line endpoints, grouping, order, scale, and visual hierarchy
- unintended implications caused by placement, proximity, color, or layout
- responsive breakage, font fallback, or export-specific rendering differences

### Occlusion and Placement Gate

Run a separate rendered-image pass for every graphic, especially SVG-derived
diagrams. Inspect at normal reading scale first, then zoom or crop only to
diagnose a defect. Do not accept a source-level bounding-box check, text
extraction result, or a vision summary that merely says a label is present.

### Consumption-Width Gate

Validate the graphic at the width the reader will actually encounter, not only
at the source canvas or native export width. For an embedded Markdown SVG, this
means the rendered repository or documentation column; GitHub-like renderers
often constrain it more than the original SVG. When the host renderer is not
available, emulate its content-column width and record the assumed width.

Use the narrowest normal presentation width as the acceptance gate. A graphic
that is clear at 840px but has overlapping labels, crowded arrows, or hidden
boundaries at a 680px documentation column fails validation. Check each target
width independently after any change to the SVG viewBox, responsive CSS, font,
or surrounding layout.

Do not ask only whether the labels are correct or whether the model can infer
their text. At each target width, ask whether an unfamiliar human can read each
important label immediately, without mentally separating it from an arrow,
border, dashed line, or nearby text. Treat a negative answer as an occlusion or
placement failure.

### Target-Surface Compatibility Gate

Inspect the graphic through the actual publishing path when possible. A valid
local SVG can fail when a documentation host, email client, PDF exporter, or
browser changes its dimensions, strips features, or blocks dependencies.

For SVG-derived graphics, confirm on the target surface that the viewBox and
intrinsic dimensions preserve the intended aspect ratio; fonts resolve or have
a readable fallback; and images, masks, clip paths, filters, markers, patterns,
and styles survive. Do not depend on scripts, external stylesheets, external
images, or `foreignObject` unless the target renderer demonstrably supports
them. Confirm relative asset paths work from the final document location.

If the target surface has a known limitation, use a compatible representation
or a verified raster fallback. Record the tested publishing surface and any
fallback in the manifest. A local preview is not a substitute for this check.

### Theme and Perception Gate

Inspect against every supported background or theme that can materially change
the result, especially transparent SVGs in light and dark interfaces. Check
contrast for text, lines, fills, and thin borders at normal reading scale.

Never make color the only way to distinguish an important state, series,
direction, or outcome. Add labels, patterns, line styles, shapes, or direct
annotations when needed. Verify that similar colors, low-saturation fills, and
gray-scale viewing do not collapse the argument or make adjacent components
indistinguishable.

List each label, legend entry, arrowhead, connector, value, node, boundary, and
other component needed to understand the graphic. For each one, confirm in the
rendered result that it is:

- fully visible: no glyph, word, endpoint, or meaningful area is covered,
  clipped, or hidden behind another element
- unobstructed: no line, arrow, node, fill, annotation, or neighboring label
  crosses it or makes it difficult to read
- clearly placed: it is visibly associated with the intended component and not
  closer to, inside, or visually competing with the wrong component
- comfortably spaced: it does not crowd a border, overlap a connector, or make
  the reader decode the layout to determine what belongs where

Treat "the text is technically present" as a failure when it is partially
obscured, visually merged with an arrow or shape, or inferable only from
context. Programmatic collision checks may find candidates, but the rendered
image is authoritative because SVG z-order, font metrics, transforms, and final
layout can create failures absent from source geometry.

For every failure, move, resize, reroute, relayer, or remove the conflicting
element and rerender. Important labels and components have a zero-tolerance
threshold for overlap or ambiguous placement. Record this pass in the manifest
with the inspected render, affected component IDs or label text, and the result
(`clear`, `repaired`, or `removed`).

Save or reference the render used for validation when the target project has a
place for visual test artifacts. Fix every material render defect before asking
the second reader to assess explanatory value.

## Stage 5: Accuracy Review

Before placement, verify every graphic against its sources.

- Trace every label, value, arrow, grouping, and ordering to the source.
- Check that a flow diagram does not imply an unsupported sequence or ownership.
- Check that scales, axes, legends, units, and comparisons are honest.
- For charts, verify the source's time range, population, missing-data policy,
  transformations, aggregation, ordering, and units. Do not hide uncertainty,
  turn a partial sample into a total, or compare incompatible denominators.
- Check chart encodings for misleading baselines, truncated or logarithmic axes,
  dual axes, unequal bin widths, area or perspective effects, and visual
  ordering that reverses the source's comparison.
- Check that screenshots show the intended state and do not expose sensitive or
  stale information.
- Check that accessibility text describes the informational purpose, not the
  visual decoration.

If a graphic cannot be made accurate from available evidence, replace it with
text, a question for the user, or nothing.

## Stage 6: Argument-Consistency Audit

For technical arguments, validate the graphic as a claim-making part of the
argument, not just an accurate picture of individual facts. Make a compact
claim map before final placement:

| Argument element | Text location | What the graphic shows | Verdict |
| --- | --- | --- | --- |
| premise, definition, constraint, or observation | section, heading, or paragraph | label, node, value, or grouping | supported / unclear / unsupported |
| inference, dependency, trade-off, or sequence | section, heading, or paragraph | arrow, ordering, boundary, or emphasis | supported / unclear / unsupported |
| conclusion or recommendation | section, heading, or paragraph | outcome, comparison, or callout | supported / unclear / unsupported |

Use the map to test the whole argument:

- **Bidirectional traceability:** every meaningful visual element must point to
  supporting text or evidence, and every argument step the graphic claims to
  explain must have a visible representation. Mark intentional omissions.
- **No invented inference:** arrows, proximity, color, containment, ordering,
  scale, and before/after placement can imply causation, ownership, priority,
  necessity, or certainty. Confirm the text makes the same claim. Downgrade the
  visual when the text establishes only correlation, possibility, or an example.
- **Logic preservation:** check that conditionals retain their conditions,
  alternatives remain alternatives, exceptions remain visible, and a
  multi-step argument does not collapse into an unjustified shortcut.
- **Reading-path test:** check that the intended starting point, direction, and
  grouping are unambiguous. Crossing connectors, bidirectional-looking arrows,
  symmetric layouts, or a detached legend must not permit a materially
  different reading from the text.
- **Scope and quantifiers:** do not turn "may," "some," "under these
  conditions," or a limited dataset into "will," "all," an unconditional flow,
  or a general rule.
- **Counterexample test:** ask what a skeptical reader could infer from the
  graphic that the text would reject. Repair the graphic, add a qualifying
  label, or remove it when that inference is plausible.
- **Conclusion test:** hide the surrounding prose and read the graphic alone.
  Its apparent conclusion must match, and not overstate, the document's actual
  conclusion.

Ask an independent subagent, when available, to perform this audit from the
text and rendered graphic without being told the intended answer. It should
state the argument it believes the graphic makes, cite its supporting text, and
list contradictions, missing conditions, or unsupported leaps. When no
subagent is available, perform the same adversarial read yourself.

Do not let a polished diagram settle a logical dispute. When the claim map has
an unsupported or unclear material element, fix the argument, the graphic, or
both before the reader-validation stage. Record the completed claim map or a
short equivalent in the document's graphics manifest, including any deliberate
abstractions and their rationale.

## Stage 7: Fresh Read With Graphics

Place the graphics where the reader needs them, then ask a second independent
subagent to read the material linearly with the graphics included. Give it no
explanation of why the graphics were added.

Give the reader the rendered page, screenshot, slide, PDF page, or composed
image that the user will actually see. Do not ask it to judge SVG markup,
diagram source, or a code preview.

Ask it to note for each graphic:

- whether it reduced confusion or added it
- whether it appeared at the right moment in the explanation
- what it seemed to claim
- any likely misreading, missing context, or factual concern
- whether the surrounding text now repeats what the visual already makes clear

Without a subagent, do the same cold reread yourself. Do not validate the work
by rereading only as its author.

## Stage 8: Iterate or Remove

Fix placement, labels, scale, surrounding text, or the graphic itself based on
the rendered inspection and second reader notes. Repeat the render inspection,
accuracy check, and fresh read until there is high confidence that each
remaining graphic improves understanding and is logically correct.

Remove a graphic when it is decorative, marginal, redundant, too expensive for
its explanatory value, or likely to cause a factual or conceptual misread.
Stopping with fewer graphics is a successful outcome.

For a graphic left unchanged, confirm that its existing rendered validation is
still representative of the current document, then record it as `validated
unchanged` in the manifest. For each repaired, created, or removed graphic,
update the manifest and remove stale outputs that no longer belong to the
document.

Invalidate a prior validation and rerun the affected gates when any of these
change: source evidence or data, generation script, asset dependency, font,
rendering library, host renderer, document wrapper, theme, responsive layout,
or target surface. Do not report `validated unchanged` merely because the
graphic file itself did not change.

## Output

Report the outcome clearly:

```markdown
**Graphics Added**
- `path/to/asset`: reader question answered; source basis; generation script or prompt manifest.

**Run State**
- `graphic-id`: created, repaired, validated unchanged, removed, deferred, or rejected; manifest and asset paths.

**Graphics Removed or Skipped**
- [candidate]: why it did not earn its place.

**Barely Made the Cut**
- [graphic]: why it remains, what to watch, and why text alone was not enough.

**Potential Issues**
- [accuracy, accessibility, maintenance, or rendering risk]

**Clarifications Needed**
- [only questions that block an accurate visual]

**Validation**
- [rendered surface, viewport or page scale, issues found, and fixes]
- [consumption-width gate: host or emulated surface, tested widths, and result]
- [occlusion and placement gate: inspected components, defects, and repairs]
- [target-surface and theme gate: compatibility, contrast, non-color cues, and fallbacks]
- [data provenance or chart-encoding check, when applicable]
- [claim-map result, counterexample test, and any corrected implication]
- [fresh-reader result and any iteration performed]

**Handoff**
- [the manifest, scripts, and rendered assets to reuse on the next run]
- [the document changes that would require revalidating a graphic]
```

Omit empty sections. When no graphic improves the material, say so plainly and
explain why.
