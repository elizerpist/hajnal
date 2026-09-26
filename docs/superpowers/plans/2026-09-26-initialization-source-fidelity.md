# Initialization Source Fidelity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the existing Home hamburger render the exact lightweight equivalents of source Screens 1, 2, 4, 6, 6B, and 7, using their real local art assets.

**Architecture:** Retain `HomeInteractionController` as the sole route and initialization-state owner. Replace only its initialization renderer and matching screen CSS with source-component markup; place the two copied source SVGs under the single `app-shell` prototype's asset directory and refer to them locally.

**Tech Stack:** Standalone offline HTML, CSS, embedded JavaScript, Node static/runtime contract tests.

## Global Constraints

- Phone viewport remains `412px × 892px`.
- The primary source is `html-prototypes/offline-ui/index.html` plus the mandatory reference PNGs.
- Splash uses local `welcome_svg.svg` and `logo_svg.svg`; no network, CDN, or image flattening.
- One `HomeInteractionController` remains authoritative.
- Preserve unrelated Home, Történetem, Ösvény, Panic, meeting, daily-image, and reward behavior.

---

### Task 1: Establish a source-fidelity regression contract

**Files:**
- Create: `html-prototypes/app-shell/tests/initialization_source_test.js`
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`

- [x] **Step 1: Add HJN-20260926-26 covering the exact source sequence, two asset hashes, component hierarchy, single controller, offline rule, and visual evidence gate.**
- [x] **Step 2: Write an executable Node contract that requires the source view order, source component markers/text for each view, local copied asset hashes, and rendering from the existing controller.**
- [x] **Step 3: Run `node html-prototypes/app-shell/tests/initialization_source_test.js` and confirm it fails because the generic initialization renderer has no source asset/component contract.**

### Task 2: Replace generic initialization views with source components

**Files:**
- Modify: `html-prototypes/app-shell/index.html`
- Create: `html-prototypes/app-shell/assets/initialization/welcome_svg.svg`
- Create: `html-prototypes/app-shell/assets/initialization/logo_svg.svg`

- [x] **Step 1: Copy the exact two source SVG assets into the app-shell's canonical asset folder and prove matching SHA-256 values.**
- [x] **Step 2: Retain `HomeInteractionController` and render source-faithful Splash, Welcome, calendar, Sponsor, motivation, and notification views from its existing initialization state.**
- [x] **Step 3: Apply the source component geometry/CSS, preserving accessible real controls and the fixed shell bounds.**
- [x] **Step 4: Run the focused contract and confirm it passes.**

### Task 3: Verify and hand off

**Files:**
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`

- [x] **Step 1: Run the focused test, existing app-shell regressions, static/offline/syntax/duplicate-ID/no-network checks, HTTP asset checks, and `git diff --check`.**
- [x] **Step 2: Re-read HJN-20260926-26 and mark only evidence-backed requirements DONE; mark the screenshot gate PARTIAL when browser tooling is unavailable.**
- [ ] **Step 3: Commit only task-owned files and push `feat/first-prototype-page`.**
