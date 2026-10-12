# Path and History Hero Mask + Card Toggle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the abrupt History and Path overview hero fades with one semantic alpha-mask pattern, and add a controller-owned Path overview current-card visibility control.

**Architecture:** Keep `HomeInteractionController` as the single owner of view state. A single CSS custom-property mask describes vertical artwork fading; History hero-swipe and Path overview adapt their own existing artwork layers to it. The existing Path overview renderer conditionally lays out its current card based on a new boolean in `state.path`; it does not create a new route, carousel, or data model.

**Tech Stack:** Single-file HTML/CSS/JavaScript prototype, Node `assert` source contracts, existing Chromium mobile runtime harness.

## Global Constraints

- Modify only the canonical `html-prototypes/app-shell/index.html` and focused project-native tests/docs.
- Keep `historySelectedPeriodId`, the native History carousel, its Timeline scroll owner, Path topic state, and all routes unchanged.
- Use the existing local hero PNGs; no new visual asset, external dependency, or duplicated state machine.
- Verify at the fixed 412×892 viewport and retain the existing mobile History scroll regression.

---

### Task 1: Lock the presentation and state contracts

**Files:**
- Modify: `html-prototypes/app-shell/tests/history_hero_swipe_presentation_test.js`
- Create: `html-prototypes/app-shell/tests/path_overview_hero_card_toggle_test.js`

- [ ] **Step 1: Write failing tests**

Require a named, shared vertical alpha-mask CSS custom property used by both History hero-swipe art and Path overview artwork. Require that History’s hero-swipe `::after` no longer ends in opaque `#FFF9FC`. Require a Path overview-only control with a controller action, `aria-pressed`, and one `state.path` visibility value.

- [ ] **Step 2: Run focused tests to verify RED**

Run:
```sh
node html-prototypes/app-shell/tests/history_hero_swipe_presentation_test.js
node html-prototypes/app-shell/tests/path_overview_hero_card_toggle_test.js
```

Expected: the new assertions fail because neither the shared alpha mask nor the Path current-card visibility state/action exists.

- [ ] **Step 3: Implement the smallest scoped changes**

Add the semantic CSS mask token, apply it to the two existing art layers, retain only a subtle top-to-middle legibility overlay for hero text, and add `path.overviewHeroCardVisible` plus `togglePathOverviewHeroCard()`.

- [ ] **Step 4: Re-run focused tests to GREEN**

Run the two commands above; both must pass.

### Task 2: Visual and interaction regression

**Files:**
- Modify: `docs/prototypes/PATH_HISTORY_HERO_MASK_ACCEPTANCE_CHECKLIST.md`

- [ ] **Step 1: Render both changed states**

Use the local HTTP app shell at 412×892: inspect History hero-swipe, Path overview with card visible, and Path overview with card hidden.

- [ ] **Step 2: Run focused regressions**

Run the existing History mobile touch runtime test and relevant Path source test, then `git diff --check`.

- [ ] **Step 3: Record evidence**

Mark checklist entries only where direct source, runtime and screenshot evidence exists; leave any unavailable device-specific evidence explicitly open.

### Task 3: Repair the inline History layer chain without changing scroll ownership

**Files:**
- Modify: `html-prototypes/app-shell/index.html`
- Modify: `html-prototypes/app-shell/tests/history_hero_swipe_presentation_test.js`

- [ ] Lock the 238px hero and existing workspace overlap geometry in a failing source contract.
- [ ] Give the inline History body one semantic opaque surface token and make the workspace/detail layer transparent only through the overlap.
- [ ] Move the one decorative History artwork owner into a scoped layer that extends past the hero edge, uses the shared alpha mask, and sits below all History controls/content.
- [ ] Run the focused History contracts plus the full app-shell suite; record 412×892 before/after screenshot evidence before marking the task complete.
