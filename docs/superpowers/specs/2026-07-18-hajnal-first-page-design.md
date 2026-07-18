# Hajnal first prototype page design

## Objective

Create the documentation-only foundation for Hajnal and one horizontally scrollable prototype row containing eight exact `412px × 892px` semantic phone screens:

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

The written application specification controls the flow, menu hierarchy, content, and future behavior. The seven in-project PNG files control visual appearance.

## Documentation architecture

- `AGENTS.md` enforces mandatory reference review and source precedence for future work.
- `docs/HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md` is the canonical product specification.
- `docs/references/source-of-truth/` holds byte-identical copies of all seven user-supplied PNGs.
- `docs/references/REFERENCE_ANALYSIS.md` records the full image inventory, sampled colors, normalized geometry, and per-screen relevance.
- `docs/acceptance/first_page_acceptance.md` maps each current requirement to implementation and verification evidence.
- `docs/prototypes/hajnal_ui.html` is the one-file HTML/CSS/JavaScript visual prototype.
- `docs/prototypes/hajnal_ui_static_test.js` verifies the prototype structure and mandatory tokens without requiring Flutter.

No Flutter scaffold or runtime application code is created during this phase.

## Prototype-page structure

The page begins with a brand header outside the phones: project icon, Hajnal name, motto, and a short explanation that the row represents the first entry flow. Beneath it, a hierarchy caption shows the root and child relationship. The phone components then appear in one horizontal row in approved navigation order.

Each phone has:

- a visible screen label above the frame;
- a stable `data-screen` identifier;
- a `data-parent-screen` relationship where applicable;
- a `412px × 892px` clipped viewport with `34px` outer radius;
- semantic HTML controls prepared for future interaction;
- an internal status bar consistent with the references.

The layout may scroll horizontally on narrow browser windows. Phone dimensions never shrink, because exact viewport geometry is an acceptance requirement.

## Component model

The prototype uses semantic DOM components rather than image slices:

- `.phone-screen` — exact-size screen viewport;
- `.status-bar` — shared time/system icon rail;
- `.screen-header` — setup-screen title/back affordance;
- `.soft-card` — standard rectangular card;
- `.choice-row` — boxed radio/checkbox option;
- `.primary-button` and `.secondary-button` — finite-radius CTA boxes;
- `.toggle-row` — rectangular setting row containing a pill switch;
- `.scene` — reusable inline-SVG dawn/night landscape;
- `.character-panda` and `.character-llama` — simplified flat-vector characters;
- `.bottom-nav` — five-item main navigation used only on Home/main-shell screens.

CSS classes and explicit `data-component`/`data-state` attributes form the stable interface for later JavaScript interaction. Actual buttons, radio inputs, checkboxes, and switches are used from the start.

## Visual system

Mandatory CSS tokens:

- navy `#2C2E77`;
- purple `#6A56B4`;
- lavender `#B89AD7`;
- pink `#F18EAF`;
- peach `#FEC884`;
- cream `#FCF0F0`.

Supporting surfaces use the measured blush/warm-white family. Text uses navy rather than black. Primary CTAs use violet; pink is compassionate emphasis; green is success without moral judgment.

Shape rules:

- phone: 34px;
- large sheets/cards: 20–22px;
- normal boxes: 16px;
- compact cards/inputs: 12–14px;
- CTAs: 16–18px;
- circle-only controls: 50%;
- pill-only controls: switches, compact filters, and explicitly pill-shaped status components.

No generic `border-radius: 999px` may be applied to cards, list rows, fields, or full-width CTAs.

## Screen designs

### Splash

Uses the master logo, Hajnal name, and motto only. It contains no CTA. A small non-interactive prototype annotation may state the 2–3 second transition outside the phone label, not inside the product UI. The visual field is calm and scenic.

### Onboarding

Uses the tall arched scene language from `onboarding.png`. It shows the exact specification message and two semantic actions: Kezdjük el and Már van fiókom. The primary action leads conceptually to Tájékoztatás.

### Tájékoztatás

Uses separate stacked information cards, not one undifferentiated text block. All four specification points fit across three visual cards without removing content. Acceptance is a real checkbox; Tovább is a real button.

### Kezdődátum

Uses separate rounded-box choices for Ma, Tegnap, and Dátum kiválasztása. The date-calendar visual remains a standard rectangular panel; selected dates remain circular. A quiet note explains that only evening check-in finally confirms a clean day.

### Felépülési cél

Uses seven separate rounded-box radio rows. The flow is optional and provides a clear skip action. Rows remain boxes, not pills.

### Szponzor hozzáadása

Uses three large boxed choices. Selecting Igen is represented by a compact preview of the fields/capabilities: name, phone, messaging method, preferred call time, and backup contact. The preview stays inside the same screen because the specification defines these as Screen 6 capabilities, not a new top-level screen.

### Értesítések

Uses five rectangular setting rows with left icons, two-line label/time text, and right pill toggles. Evening check-in is set to 21:00. The full-width CTA is Belépek a Hajnalba.

### Kezdőlap

Uses a scenic upper region, current day/motto, notification/menu actions, a daily-image affordance, a light streak/state sheet, at most five tasks, a visible daily check-in button, a visually secondary one-tap Segítség kell action, and the five-item bottom navigation in specification order.

## State and future interaction

The first delivery is primarily visual, but form controls retain native state. Future behavior can attach to stable action attributes without replacing markup:

- Splash routes by first-use/returning state after 2–3 seconds.
- Onboarding primary routes to Tájékoztatás.
- Acceptance gates the information-screen continuation.
- Date and goal screens are single-choice states.
- Sponsor Yes expands/contact data; Later/None bypasses it.
- Notification toggles retain boolean state and time labels.
- Enter Hajnal routes to Home.
- Home actions later route to daily image, check-in, tasks, and panic mode.

No external data, account operation, phone call, or message is triggered by this static documentation prototype.

## Error and safety behavior

- No screen silently assumes recovery success or relapse.
- Safety copy is clear and calm, not alarmist.
- Disabled/gated actions use accessible disabled state rather than hidden logic.
- Missing optional answers do not block core onboarding unless the specification explicitly requires consent.
- Sensitive content is not exposed through browser notifications in this phase.
- The visual prototype has no destructive behavior.

## Verification design

Static tests assert:

- eight screens in the exact order;
- exact viewport dimensions and phone radius;
- mandatory palette values;
- required screen text and control counts;
- semantic control element types and accessible labels;
- correct parent relationships and Home bottom-navigation order;
- no flattened full-screen PNG usage;
- no pill radius on forbidden component classes.

Browser verification captures the complete page and individual phone screens at exact size. Screens are inspected against the relevant PNGs for palette, component shape, radii, spacing hierarchy, text overflow, scene placement, and control density. Completion requires every checklist item to be `DONE` or an explicit user-approved deferral.
