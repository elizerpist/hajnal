# Hajnal – coding principles and project instructions

## Scope and precedence

These are repository-local coding principles for Hajnal, imported at the user's request on 2026-11-26 from elizerpist/exptv2. They do not grant authority outside this repository.

Order within this repository:
1. The user's latest explicit instructions.
2. The accepted behavior in [the Flutter specification](docs/HAJNAL_FLUTTER_SPECIFIKACIO.md).
3. This integration section and the preserved Hajnal project-specific instructions below.
4. Imported coding principles and task-relevant skills.

The Flutter specification supersedes conflicting older product rules (including daily check-in based counting, cloud sync, and reset semantics). Read it along with relevant earlier references. Do not silently implement its open decisions.

## Active coding baseline

- Use [.agents/skills/ponytail/SKILL.md](.agents/skills/ponytail/SKILL.md) for coding: the smallest complete, robust solution, preserving all requested behavior.
- Use [.agents/skills/ponytail-review/SKILL.md](.agents/skills/ponytail-review/SKILL.md) for code reviews.
- Apply [.agents/skills/structuring-apps/SKILL.md](.agents/skills/structuring-apps/SKILL.md) before application-code changes, together with its [architecture checklist](.agents/skills/structuring-apps/references/architecture-checklist.md).
- Select other skills by actual task relevance; the presence of HTTP or multi-agent skills does not add network features or require delegation.
- Ponytail's brevity and shortcut language never permits a workaround, omitted requirement, weakened data integrity/security, duplicated mechanism, or speculative feature.
- Diagnose root causes. Monitor repeated ineffective fixes and regressions; identify a bugfix loop early and propose a rational refactor rather than another patch.
- For bug reports, inspect the implicated code, commits, tests and available evidence; state plausible hypotheses and a concrete diagnostic/fix plan. Report uncertainty honestly.
- Imported examples, historical absolute paths, external tool names and platform-specific commands are examples; resolve actual Hajnal paths and available tools before use. Android and iOS compatibility remains mandatory.
- The embedded architecture checklist link in the imported text resolves to `.agents/skills/structuring-apps/references/architecture-checklist.md`, not a root `references/` directory.
- The preserved 412 × 892 rule is for HTML prototype verification, not a fixed-size Flutter production viewport.
- Respond in the user's language; imported English report templates do not override Hungarian communication.
- This import does not authorize a Flutter scaffold or application implementation. The documentation/prototype phase remains until the user requests implementation.

Inventory and provenance: [.agents/SKILLS-INVENTORY.md](.agents/SKILLS-INVENTORY.md) and [.agents/HAJNAL-IMPORT.md](.agents/HAJNAL-IMPORT.md).

---

## Imported exptv2 agent instructions (verbatim)

# Global Codex Preferences

## Highest Priority Implementation Accuracy Rules

These are global user-level guardrails. Apply them before project-local workflow preferences unless the user explicitly gives a newer conflicting instruction in the current conversation.

When a task involves nontrivial implementation, UI design, feature work, bugfixes, or a previously approved visual reference, do not start coding until the concrete requirements are inventoried. Create or update an acceptance checklist that maps each user requirement to:

- a stable requirement ID,
- the source instruction or approved reference,
- the intended code area,
- the acceptance condition,
- the verification method,
- and a status of `DONE`, `PARTIAL`, `BLOCKED`, or `NOT DONE`.

Treat approved HTML prototypes, screenshots, and visual references as mandatory implementation inputs, not inspirational mockups. If the user says the app must match a reference `100%`, `1:1`, "pontosan ugyanaz", or similar, then before editing code you must:

- locate every referenced HTML file, screenshot, or design artifact;
- open/read/inspect those references directly;
- inspect the existing app code for the real component being changed;
- compare the implementation against the reference behavior, layout, colors, spacing, interaction model, and state transitions;
- and keep the reference path in the spec/checklist so it is re-read before future implementation.

Never claim a feature package is complete because the code compiles, tests pass, CI is green, or an APK was built. Completion requires every required checklist item to be `DONE` or an explicit user-approved deferral. If any requirement is `PARTIAL`, `BLOCKED`, or `NOT DONE`, say that clearly before giving build or APK status.

Do not silently implement a partial vertical slice when the user asked for the full behavior. If the requested scope is too large to complete in one pass, stop after the requirements inventory and state the proposed slice boundaries before coding, unless the user explicitly told you to proceed with partial work.

Before commit, push, PR, or build for a feature package:

- re-read the checklist and approved references;
- verify each acceptance condition with tests, screenshots, direct code inspection, or CI as appropriate;
- update all statuses honestly;
- and do not run a final build as a substitute for unfinished implementation work.

For UI work, screenshots are verification evidence. When the user references recent screenshots, inspect the actual screenshots from the Android screenshot directory below before diagnosing or changing UI.

## Android Screenshots

When the user asks to inspect a screenshot, assume Android screenshots are in `/storage/emulated/0/Pictures/Screenshots` unless they provide a different path.

To inspect the latest screenshot, list that directory by descending modification time and open the first image.

## Mandatory Architecture and Centralization Gate

For every request that changes application code, invoke $structuring-apps
before writing code. A small isolated edit may use its compact gate, but it may
not skip the ownership and reuse check.

Before a new feature-local implementation, search for an existing engine,
state machine, algorithm, cache policy, formatter, resolver, semantic token,
or UI primitive. When a second consumer shares the mechanism, extend or extract
the small neutral shared core before implementing its new renderer or feature
adapter. This includes repeated swipe, drag, gesture, scroll, inertia, snap,
animation, selection, debounce, retry, cache, pagination, validation, and
formatting behavior. Do not copy a working mechanism into a sibling feature
and defer centralization.

A deadline or an instruction not to change a working component never permits a
second copy. Preserve its public behavior while extracting the shared internals;
if that would require behavior change, stop and request direction instead of
shipping duplication as release debt.

Keep UI as rendering and intent collection. UI must not own a multi-step
storage, network, import, processing, or domain workflow; route it through a
controller/view-model and use case/coordinator to repositories and adapters.

Use one semantic theme/token source for each shared visual decision. Copied
color values or feature-local palettes are not centralization. Use one
theme-aware resolver for dynamic entity colors used in multiple places.


<!-- Embedded verbatim from .agents/skills/structuring-apps/SKILL.md. Relative reference links below are relative to that skill directory. -->

---
name: structuring-apps
description: Use when planning, modifying, or writing any application code, including small edits, feature work, UI, data/state changes, refactors, and bug fixes, especially when a new implementation could duplicate an existing engine, workflow, resolver, formatter, visual token, or UI component.
---

# Structuring Apps

## Core rule

Create one official implementation for each shared mechanism and one owner for
each kind of state. Before changing code, read applicable instructions,
references, and the real implementation; then use
[the architecture checklist](references/architecture-checklist.md).

Do not treat different feature names or different visual renderers as evidence
that their mechanism is different.

## Run the gate before code

Use the compact gate only when the change is isolated to one responsibility and
adds no state, data flow, reusable behavior, token, or component. Record:

1. the existing owner being changed;
2. whether a shared mechanism or token already exists;
3. the focused verification.

Otherwise create an architecture card and an acceptance checklist before code.
For a non-trivial feature, present the card and obtain approval before
implementation.

Always identify:

- the single source of truth and only write path;
- local UI, feature, derived, and persistent state owners;
- UI to controller/view-model to use case/coordinator to repository to adapter
  flow;
- the existing engine, resolver, formatter, token, or component to extend;
- the required unit, widget/integration, screenshot, and performance evidence.

## Centralize mechanisms, not just widgets

Compare state transitions, algorithms, gestures, cache behavior, formatting, and
semantic decisions. If a second known consumer shares one of these, extract the
neutral shared core before implementing the second consumer.

The ticker belt is only an example. Apply the same rule to every repeated
behavioral mechanism: swipe and drag handling, gesture arbitration, scrolling,
inertia, snap, selection/commit state, animation sequencing, debouncing,
retry, caching, pagination, validation, and formatting. Different screens,
item types, or visual renderers do not make the mechanism feature-local.

For example, avatar and box ticker belts must share a TickerBelt engine for
drag, inertia, snap, preview/settled/committed selection, and cancellation.
Feature wrappers may provide typed items, an item renderer, and a semantic
callback; they must not reimplement that state machine.

Do not postpone a proven second-consumer extraction to a hypothetical third
consumer. Do not create a configurable god-widget: expose only stable
variation points and keep feature semantics in adapters.

A release deadline, a request not to alter a working component, or a need to
preserve a public API never permits a second copy of the mechanism. Preserve
the public behavior while extracting its internals; if that cannot be done
without an approved behavior change, stop and obtain direction instead of
shipping a duplicate as debt.

## Keep data and UI boundaries honest

| Layer | Owns | Must not own |
| --- | --- | --- |
| UI | rendering, input, dialogs, focus, drag preview | persistence, multi-step workflows, domain aggregation |
| Controller/view-model | feature view state and intent mapping | storage implementation |
| Use case/coordinator | multi-domain workflow, cancellation, result mapping | widgets or BuildContext |
| Repository/adapter | one persistence or remote boundary | presentation state |
| Domain engine | typed rules, validation, calculations | Flutter, database, network, platform objects |

Pass immutable view models to UI. A screen may choose a file, but a use case
must coordinate copying, persistence, processing, retries, and refresh.

Do not satisfy this boundary by hiding an I/O coordinator in a screen file. A
unit that coordinates storage, network, import, processing, or multiple domain
operations must be a non-presentation unit in its own responsibility-focused
file and be testable without a widget tree.

## Mandatory boundary-contract test layer

For every non-trivial application feature, cross-file change, new UI component,
state change, shared mechanism, or refactor, add or extend a project-native
architecture/boundary test suite before implementation.

The boundary suite must fail when any of these contracts are violated:

1. **Dependency direction**
   - presentation does not depend on concrete repositories, databases, HTTP
     clients, platform adapters, or domain-engine implementation;
   - controllers/view-models do not depend on widgets, `BuildContext`, or
     persistence implementations;
   - use cases/coordinators do not depend on Flutter UI;
   - domain code does not depend on Flutter, database, network, or platform
     APIs.
2. **Forbidden dependencies**
   - no legacy package, deprecated module, forbidden import, or forbidden path
     enters the feature;
   - forbidden dependencies are checked in production source, not only in
     tests.
3. **State ownership**
   - each state kind has one declared owner and one write path;
   - leaf widgets do not create hidden feature state, persistence workflows, or
     duplicate controllers.
4. **UI boundary**
   - UI renders supplied immutable view data and forwards intents;
   - multi-step storage, network, import, processing, retry, or domain
     workflows do not live in widgets or screen files;
   - animation and gesture engines are not duplicated in sibling widgets.
5. **Centralization**
   - shared mechanisms, tokens, formatters, resolvers, and visual policies have
     one official implementation;
   - a second implementation requires an explicit architecture decision.

Boundary tests must fail closed. Do not silence a violation with a broad
allowlist, test skip, or renamed import. Every exception must identify the
owner, reason, scope, and removal condition.

Run the focused boundary suite during implementation and run the complete
boundary suite with the relevant full test suite and CI verification at task
milestones and before handoff.

For isolated edits that qualify for the compact gate, a full boundary suite is
not required; record the owner, reuse decision, and focused structural check.

## Centralize visual decisions

Use semantic theme tokens, not feature-local raw colors. A token is centralized
only after every current use of that semantic role reads the same theme/token
source; copying old values into a new palette is a second source, not a
migration.

Use one theme-aware resolver for dynamic entity colors such as category, tag,
avatar, or chart colors. It maps stable identity and semantic role to a color,
handles contrast and fallbacks, and is not recreated in widgets.

Promote a visual primitive after two real consumers share its behavior. Keep
feature-specific composition in the feature layer.

## Protect maintainability

Review files above 500 lines for mixed responsibilities. Above 800 lines,
write a responsibility justification or split plan. Size alone is not a
failure; a cohesive renderer can be large. A file mixing UI, lifecycle, cache,
domain calculation, and persistence is a boundary failure at any size.

Keep experiments in ui_lab, demo routes, or prototypes. Move only approved
behavior into a feature. For migration, classify behavior as keep, drop, or
later; rebuild the stable data core first and move one tested vertical slice at
a time.

## Verify the structure

Add focused tests to the shared core when extracting it. Verify dependency
direction, a single write path, central token/resolver use, and every acceptance
item. Boundary-contract tests must run independently of feature behavior tests
and must be included in the project's normal CI test command. For UI
references, inspect screenshots; for expensive flows, test real data volume and
cancellation. Follow the applicable TDD, debugging, plan, and completion
workflows rather than replacing them with this skill.


---

## Preserved Hajnal project-specific instructions (verbatim)

# Hajnal project instructions

These instructions apply to every file and task inside this project.

## Mandatory pre-work reference review

Before planning, editing, implementing, reviewing, testing, or answering a project-specific question:

1. Re-read `docs/HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md` in full.
2. Identify every PNG relevant to the requested screen, flow, component, or design-system decision.
3. Open and visually inspect those PNG files directly from `docs/references/source-of-truth/`; do not rely only on memory, summaries, extracted tokens, or earlier inspections.
4. Re-read the current acceptance checklist and record the exact specification sections and PNG paths used by the task.
5. Inspect the real HTML component being changed before making edits.

The mandatory PNG reference set is:

- `docs/references/source-of-truth/logo.png`
- `docs/references/source-of-truth/onboarding.png`
- `docs/references/source-of-truth/designnkovetelmenyek.png`
- `docs/references/source-of-truth/checkin_visszaeses_panik.png`
- `docs/references/source-of-truth/haladas_naptar_stat.png`
- `docs/references/source-of-truth/eszkozok_12lepes_naplo.png`
- `docs/references/source-of-truth/sponzor_profil_beallitasok.png`

If a task affects global tokens, shared components, navigation, or component geometry, inspect all seven PNG files again.

## Source-of-truth precedence

Apply references in this order:

1. The user's latest explicit instruction.
2. The written specification for correct information architecture, menu logic, screen hierarchy, content, states, and behavior.
3. The PNG references for the visual design system: colors, gradients, geometry, shape type, corner radii, borders, spacing, shadows, typography character, icon treatment, illustration style, and visual density.

The PNG screens are only partially correct for navigation and layout relationships. Never copy an incorrect menu structure from a PNG over the written specification. When the specification and a PNG conflict, keep the specification's logic and content structure while applying the PNG's visual language. Record the conflict and its resolution in the acceptance checklist.

## UI implementation rules

- Prototype screens are semantic web components, not screenshots, flattened images, or background-image replicas.
- Controls that will later be interactive must use appropriate HTML elements such as `button`, `input`, `textarea`, `label`, and `nav`.
- Preserve component shape categories exactly. Do not use a pill where the reference uses a rounded box. Pills are reserved for controls that are visibly pills in the references, such as toggles, segmented filters, and compact status controls.
- Use a fixed phone viewport of `412px × 892px`, derived from the mandatory `color_lab.html` reference.
- Treat screenshots as mandatory visual evidence. Verify UI changes with browser screenshots at the exact viewport size.
- Do not claim completion from syntax checks alone. Every acceptance item must be `DONE`, or the remaining status must be reported honestly.
- Keep the prototype prepared for later interaction: stable component names, explicit states, accessible labels, and no visual-only fake controls.

## Current documentation-only phase

Until the user explicitly authorizes Flutter implementation, the project contains documentation, reference assets, tests for the documentation prototype, and HTML/CSS/JavaScript prototypes only. Do not create a Flutter scaffold, `lib/` implementation, APK, or platform project.

## Current first-page structure

The first prototype page follows this exact specification hierarchy and display order:

```text
Splash
└── Onboarding
    ├── Tájékoztatás
    ├── Kezdődátum
    ├── Felépülési cél
    ├── Szponzor hozzáadása
    └── Értesítések
        └── Kezdőlap
```

The first screen row contains seven separate `412px × 892px` web-component screens: Splash, Onboarding, Tájékoztatás, Kezdődátum, Felépülési cél, Szponzor hozzáadása, and Értesítések.

The second screen row starts with Kezdőlap. It still declares `data-parent-screen="notifications"` because the specification's onboarding flow routes there after Értesítések, but it is no longer rendered in the same row as the onboarding children. The second row then renders the documented Kezdőlap branch in this order: Kezdőlap, Napi kép, Mai feladatok, Esti check-in, Tiszta maradtam, Esti reflexió, Visszaestem, Újrakezdés, Segítségkérés, and Pánik mód.

The third screen row expands Pánik mód into its complete documented action set: Pánik mód, Segítség kell panel, Szponzor hívása, Segítségkérő üzenet, Tartalék kapcsolat, 15 perces túlélőcsomag, Légzőgyakorlat, Miért kezdtem el, Meeting kereső, and Sürgősségi segítség.
