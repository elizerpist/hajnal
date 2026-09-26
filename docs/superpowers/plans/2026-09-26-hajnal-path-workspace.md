# Hajnal Ösvény Workspace Implementation Plan

> **For agentic workers:** Execute inline in the existing isolated `first-page` worktree. The user explicitly approved the data-driven Ösvény architecture in the task brief; do not create a second router or a second prototype.

**Goal:** Make Ösvény the fully navigable, stateful 12-step workspace behind the existing third bottom-navigation item.

**Architecture:** `HomeInteractionController` remains the only interaction owner. It receives one `path` route and one in-memory `pathState`; a single `PATH_STEPS` data definition and a generic renderer drive all overview, step, topic, question, answers, sponsor-review, summary, and cycle views. Existing application routes and the shared BottomNav remain intact.

**Tech Stack:** Single local HTML prototype with inline CSS and JavaScript; Node static-contract tests.

## Global Constraints

- Preserve the fixed 412 × 892 phone shell and the shared BottomNav/safe-area contract.
- Use only local assets and no external runtime dependency, network request, or `fetch()`.
- Keep all private step answers inside the Ösvény state; never auto-share, message, call, export, or add them to Timeline.
- Use original/paraphrased prompts; do not copy NA literature or alcohol-specific Step 1 wording.
- Do not create Gyűlések or Szponzor destination bodies.

---

### Task 1: Acceptance and focused path contract

**Files:**
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`
- Create: `html-prototypes/app-shell/tests/path_shell_test.js`

- [ ] Add `HJN-20260926-24` with all navigation, data, privacy, accessibility, geometry, offline, and regression conditions.
- [ ] Write a failing contract for `open-path`, the `path` route, each required path view, 12 structured steps, 121 topic definitions, unlocked stations, safe vocabulary, and the excluded root-menu concepts.
- [ ] Run `node html-prototypes/app-shell/tests/path_shell_test.js` and confirm it fails because the path workspace is absent.

### Task 2: Data-driven path core and main-navigation integration

**Files:**
- Modify: `html-prototypes/app-shell/index.html`
- Modify: `html-prototypes/app-shell/tests/home_shell_test.js`

- [ ] Add `data-action="open-path"` to every existing shared BottomNav Ösvény button.
- [ ] Extend `HomeInteractionController` with `route: 'path'`, a single `pathState`, and a main-nav synchronizer that marks Ösvény as `aria-current="page"` throughout its browsing hierarchy.
- [ ] Define `PATH_STEP_SEEDS` and `PATH_STEPS`: 12 neutral step definitions, 121 supplied Hajnal theme definitions, original sample questions, and no locked-step state.
- [ ] Add a focused test assertion for controller ownership and the structured model; run it green without regressing `home_shell_test.js`.

### Task 3: Generic Ösvény browsing renderer

**Files:**
- Modify: `html-prototypes/app-shell/index.html`
- Test: `html-prototypes/app-shell/tests/path_shell_test.js`

- [ ] Implement only one semantic `.path-screen` and its reusable content renderer for `overview`, `step`, `topic`, `answers`, `sponsor-review`, and `cycles`.
- [ ] Render Current Work, 12 tappable path stations, sponsor-review aggregate, and multiple cycles from state.
- [ ] Render generic step topics and genuine routes for each visible CTA; exclude journal/gratitude/panic/survival/daily-inventory content.
- [ ] Add readable historical-cycle state and a new-cycle action that appends, never overwrites.
- [ ] Run focused tests to green.

### Task 4: Focused writing and sensitive-work flows

**Files:**
- Modify: `html-prototypes/app-shell/index.html`
- Test: `html-prototypes/app-shell/tests/path_shell_test.js`

- [ ] Implement generic `question` and `step-summary` focus views with semantic textarea controls, non-blocking previous/next movement, draft retention, and writing tools.
- [ ] Implement independent important and sponsor-discussion flags, plus manual sponsor-review completion.
- [ ] Keep BottomNav visible on browsing views and intentionally hidden only on the two focus views with explicit back controls.
- [ ] Ensure Step 9 never pressures contact and Step 10 only explains that Daily Inventory lives elsewhere.
- [ ] Run focused tests to green.

### Task 5: Visual system, regression verification, and handoff

**Files:**
- Modify: `html-prototypes/app-shell/index.html`
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`

- [ ] Apply calm Hajnal cards, trail stations, restrained lavender/pink/cream surfaces, mobile scrolling, and focused-editor geometry.
- [ ] Run `path_shell_test.js`, `home_shell_test.js`, `docs/prototypes/hajnal_ui_static_test.js all`, `offline_single_file_test.js`, inline-JS syntax, duplicate-ID/action scans, offline scan, HTTP response, and `git diff --check`.
- [ ] If browser tooling exists, capture the nine required 412 × 892 states; otherwise mark the visual gate PARTIAL.
- [ ] Update the acceptance row with direct evidence, commit only task-owned files, and push `feat/first-prototype-page`.
