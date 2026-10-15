# Survival visual reconstruction, Sponsor card and calendar implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the seven-step Survival pack against `15min.png`, refine the static Sponsor card with a generated decorative asset, and align the two Sponsor calendars with Meetings while replacing the time grid with a swipeable time card.

**Architecture:** Existing `HomeInteractionController` remains the sole state and action owner. The work is a renderer/CSS/asset refinement: generated PNGs are non-interactive background layers, while all controls keep their current semantic HTML and controller actions. Sponsor calendar date selection continues through `state.sponsorCalendar`; only its rendering and time affordance change.

**Tech Stack:** Single-file HTML/CSS/JavaScript prototype, Node `assert` contract tests, local PNG assets generated with the built-in image generator.

## Global Constraints

- Preserve the seven-state Survival workflow, its 900-second clock, free-note persistence, help sheet and existing Sponsor/backup sources.
- Do not create routes, stores, duplicate timer logic or a second calendar engine.
- Use `15min.png` as the Survival visual source of truth at 412×892.
- Keep generated art local, offline, text-free and non-interactive.
- Preserve all unrelated dirty-worktree edits.

---

### Task 1: Establish executable visual contracts

**Files:**
- Modify: `html-prototypes/app-shell/tests/survival_pack_test.js`
- Modify: `html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js`
- Modify: `docs/prototypes/SURVIVAL_VISUAL_SPONSOR_CARD_ACCEPTANCE_CHECKLIST.md`

**Interfaces:**
- Consumes: current `SURVIVAL_STEPS`, `renderSurvival()`, `renderSponsorCalendarRoute()` and Sponsor summary markup.
- Produces: failing assertions for title/time header, all seven artwork bindings, single Sponsor card copy, Meetings-style calendar and wheel time selector.

- [x] Add the focused static requirements as assertions before modifying production markup/CSS.
- [x] Run `node html-prototypes/app-shell/tests/survival_pack_test.js && node html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js` and confirm the new assertions fail solely because the requested rendering is absent.
- [x] Mark test intent and failure evidence in the acceptance checklist.

### Task 2: Generate and install the local decorative assets

**Files:**
- Create: `html-prototypes/app-shell/assets/hero/sponsor_shared_work_card.png`
- Create: `html-prototypes/app-shell/assets/survival/survival_stop_bg.png`
- Create: `html-prototypes/app-shell/assets/survival/survival_breathe_bg.png`
- Create: `html-prototypes/app-shell/assets/survival/survival_water_bg.png`
- Create: `html-prototypes/app-shell/assets/survival/survival_environment_bg.png`
- Create: `html-prototypes/app-shell/assets/survival/survival_contact_bg.png`
- Create: `html-prototypes/app-shell/assets/survival/survival_wait_bg.png`
- Create: `html-prototypes/app-shell/assets/survival/survival_reassess_bg.png`

**Interfaces:**
- Produces: one alpha-wide Sponsor asset and seven consistent portrait visual assets with no text/UI.

- [x] Generate the transparent wide seedling-and-hills card asset with the user-supplied production prompt.
- [x] Generate seven individual Survival background assets with the exact visual roles from `15min.png` and the supplied asset prompts.
- [x] Inspect all output assets; copy only the selected local PNG outputs into the project paths; verify dimensions, alpha where required and offline paths.

### Task 3: Sponsor card and calendar visual rendering

**Files:**
- Modify: `html-prototypes/app-shell/index.html`
- Modify: `html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js`

**Interfaces:**
- Consumes: `state.sponsorCalendar`, `renderMonthCalendarCells()`, `selectSponsorCalendarTime()`.
- Produces: `sponsor-work-summary` decorative layer and a scroll-snap `sponsor-calendar-time-wheel` with hour/minute controls.

- [x] Refactor the card markup to the four allowed visual items; retain its existing action and component marker.
- [x] Add an isolated, pointer-inert PNG background layer and token-based pastel card treatment.
- [x] Reuse the Meetings month-switch/grid/card class geometry or shared selectors so both Sponsor calendars match it without a second date calculation path.
- [x] Replace the timeslot grid with one card containing scroll-snap hour/minute rails; selected center value exposes `xx:yy`, uses the existing selection write path, and keeps unavailable times disabled.
- [x] Re-run the Sponsor focused test until green.

### Task 4: Survival layout and stage reconstruction

**Files:**
- Modify: `html-prototypes/app-shell/index.html`
- Modify: `html-prototypes/app-shell/tests/survival_pack_test.js`

**Interfaces:**
- Consumes: `SURVIVAL_STEPS`, `renderSurvivalHeader()`, `renderSurvival()`, `syncSurvivalElapsedLabel()`.
- Produces: fixed grid-zone visual shell with stage artwork `data-survival-artwork` and intact action markup.

- [x] Rebuild `renderSurvivalHeader()` into the specified three-column header and seven segment rail, without changing session computations.
- [x] Render a step-keyed artwork layer inside the main stage, always `aria-hidden` and pointer-inert.
- [x] Recompose each interactive visual using CSS/SVG over its matching asset: stop ring, breathe orb, glass, environment portal, contact card, wait progress and reassessment choices.
- [x] Convert Survival CSS to header/main/footer grid geometry that prevents the header from clipping and lets art occupy the usable middle stage; implement fade masks and reduced-motion fallbacks.
- [x] Ensure `syncSurvivalElapsedLabel()` updates the newly named elapsed/remaining nodes only.
- [x] Re-run the survival focused test until green.

### Task 5: Regression, visual evidence and checklist update

**Files:**
- Modify: `docs/prototypes/SURVIVAL_VISUAL_SPONSOR_CARD_ACCEPTANCE_CHECKLIST.md`
- Optional evidence: `docs/prototypes/verification/survival-visual/`

- [x] Run every static app-shell `*_test.js` test.
- [x] Run the existing browser runtime test at 412×892 if Chromium is available; otherwise record the exact environment blocker and do not represent it as passing.
- [x] Inspect generated assets and 412×892 screenshots for the seven states, Sponsor card and both Sponsor calendars when browser tooling exists.
- [x] Mark every requirement honestly `DONE`, `PARTIAL` or `BLOCKED`; report remaining visual-verification constraints.
