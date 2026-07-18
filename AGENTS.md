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

The first prototype row follows this exact specification hierarchy and display order:

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

This row contains eight separate `412px × 892px` web-component screens: Splash, Onboarding, Tájékoztatás, Kezdődátum, Felépülési cél, Szponzor hozzáadása, Értesítések, and Kezdőlap.
