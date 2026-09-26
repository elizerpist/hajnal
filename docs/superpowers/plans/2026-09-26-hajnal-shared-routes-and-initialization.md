# Hajnal Shared Routes and Initialization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend the lightweight app shell with the requested source-derived History, Panic, Meetings, and initialization flows without adding a second router or duplicate destination screens.

**Architecture:** `HomeInteractionController` remains the only interaction owner. It receives one route/state entry for the 8D/8F period-detail submenu, one reusable `meetings` route shared by Pánik and BottomNav, a data-driven five-step survival state, and an initialization view state. UI action buttons forward intents only; the controller selects the visible route and updates the one in-memory prototype state.

**Tech Stack:** standalone offline HTML, CSS, and embedded JavaScript; Node static contract tests.

## Global Constraints

- Canonical target: `html-prototypes/app-shell/index.html`; `offline-ui` is source/visual reference only.
- Preserve the existing one-controller architecture and all accepted routes.
- Keep the prototype offline: no CDN, `fetch`, external fonts, or remote image URLs.
- Use source semantics: 8D/8F are one route with two subviews; 31 is one route used by both entry points; 18A–E is one sequential state machine followed by 26.
- Use real buttons, inputs, textareas, labels, `aria-current`, and `aria-pressed` where applicable.
- Visual screenshot validation remains USER ONLY when Chromium/Playwright is unavailable.

---

### Task 1: Acceptance and red route contract

**Files:**
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`
- Modify: `html-prototypes/app-shell/tests/home_shell_test.js`

**Interfaces:**
- Consumes: the existing `HomeInteractionController` route/actions.
- Produces: `HJN-20260926-25` and a test contract for the requested new actions/routes.

- [ ] **Step 1: Add HJN-20260926-25 with every requested source-to-route mapping.**
- [ ] **Step 2: Add assertions for `history-detail`, `panic-why`, `panic-relapse`, `survival`, `panic-contacts`, `meetings`, and `initialization`; require one `meetings` screen and one controller.**
- [ ] **Step 3: Run the focused test.**

Run: `node html-prototypes/app-shell/tests/home_shell_test.js`

Expected: FAIL because these routes and actions do not exist yet.

### Task 2: Shared route state and entry actions

**Files:**
- Modify: `html-prototypes/app-shell/index.html`
- Test: `html-prototypes/app-shell/tests/home_shell_test.js`

**Interfaces:**
- Consumes: existing `HomeInteractionController`, `navigate(route)`, and shared BottomNav markup.
- Produces: controller state `{ historyDetailView, survivalStep, initializationView, motivation }` and actions `open-history-detail`, `open-meetings`, `open-initialization`, plus semantic Pánik options.

- [ ] **Step 1: Add minimal controller actions after the red test.**
- [ ] **Step 2: Wire the history current-period card, all shared Gyűlések items, Home hamburger, and the four relevant Pánik choices to those actions.**
- [ ] **Step 3: Run the focused test.**

Run: `node html-prototypes/app-shell/tests/home_shell_test.js`

Expected: PASS for shared entry-point routing while old routes remain present.

### Task 3: History detail and shared meetings page

**Files:**
- Modify: `html-prototypes/app-shell/index.html`
- Test: `html-prototypes/app-shell/tests/home_shell_test.js`

**Interfaces:**
- Consumes: `state.historyDetailView`, `openHistoryDetail(view)`, and `navigate('meetings')`.
- Produces: one 8D/8F source-derived period-detail screen with `overview`/`timeline` submenu controls, and one source-31 meeting-finder screen used by both destinations.

- [ ] **Step 1: Add the two shared route-screen DOM owners and source-derived visual tokens.**
- [ ] **Step 2: Add overview/timeline subview rendering and Back navigation.**
- [ ] **Step 3: Verify there is exactly one meeting route screen and no duplicate meeting renderer.**

Run: `node html-prototypes/app-shell/tests/home_shell_test.js`

Expected: PASS with a current-period card entry, both 8D/8F submenus, and shared meeting target.

### Task 4: Pánik child routes and the 18A–E state machine

**Files:**
- Modify: `html-prototypes/app-shell/index.html`
- Test: `html-prototypes/app-shell/tests/home_shell_test.js`

**Interfaces:**
- Consumes: `HomeInteractionController`, source 30/15/18A–E/26 semantics.
- Produces: reusable `panic-why`, `panic-relapse`, `survival`, and `panic-contacts` route views; `advanceSurvivalStep()` moves 0→4 then navigates to contacts.

- [ ] **Step 1: Add a failing assertion for the five named survival steps and contacts handoff.**
- [ ] **Step 2: Implement one `renderSurvival()` state-driven screen instead of five copied DOM screens.**
- [ ] **Step 3: Add source-30 motivation and source-15 relapse pages, each with a real Back/Home path.**
- [ ] **Step 4: Run focused and regression tests.**

Run: `node html-prototypes/app-shell/tests/home_shell_test.js && node html-prototypes/app-shell/tests/path_shell_test.js`

Expected: PASS.

### Task 5: Initialization state machine and validation

**Files:**
- Modify: `html-prototypes/app-shell/index.html`
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`
- Test: `html-prototypes/app-shell/tests/home_shell_test.js`

**Interfaces:**
- Consumes: Home hamburger action, source splash/onboarding sequence, shared motivation state.
- Produces: `initialization` route with `splash → onboarding → start-date → sponsor-setup → why-started → notifications → home` transitions and a single write path for the motivation text.

- [ ] **Step 1: Add the route screen plus state-driven initialization renderer.**
- [ ] **Step 2: Add semantic next/back/save controls and input handling.**
- [ ] **Step 3: Run all focused, static, offline, syntax, duplicate-ID, action, HTTP, and whitespace checks.**
- [ ] **Step 4: Update HJN-20260926-25 status honestly, then commit and push only task-owned files.**

Run:
`node html-prototypes/app-shell/tests/home_shell_test.js && node html-prototypes/app-shell/tests/path_shell_test.js && node docs/prototypes/hajnal_ui_static_test.js all && node html-prototypes/offline-ui/tests/offline_single_file_test.js && git diff --check`

Expected: PASS; visual screenshot evidence remains PARTIAL if browser tooling is absent.

## Plan Self-Review

- Coverage: every requested mapping has one task: 8D/8F (Task 3), 30/15/18A–E/26 (Task 4), shared 31 (Tasks 2–3), and hamburger initialization (Task 5).
- Centralization: all multiple-entry destinations have one route owner; survival has one state machine instead of five screen copies.
- Scope: Gyűlések receives only the supplied source-31 meeting finder; no unrelated meeting system is introduced.
- Verification: focused RED/GREEN test first, followed by regression, offline, syntax, action, and HTTP checks.
