# Napi reflexió és Közös munkánk finomítás Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A Napi reflexió legyen bármikor elérhető, ugyanakkor semmilyen reflexiós művelet ne rögzíthessen tiszta napot; a Sponsor Közös munkánk felülete igazodjon a History geometriájához.

**Architecture:** The existing `HomeInteractionController` remains the sole owner of Home, reward, daily-session and persistence transitions. A normalized existing evening session becomes the single daily reflection record, with independent `cleanDayRecorded` and reflection state. The existing Survival Pack full-screen visual shell is reused for the reflection renderer, while the existing Home sheet and Sponsor route primitives are extended.

**Tech Stack:** One HTML/CSS/JavaScript prototype in `html-prototypes/app-shell/index.html`; project-local PNG assets; Node contract tests.

## Global Constraints

- Keep all existing user work in the dirty working tree.
- Do not add another daily-session store, reflection route family, BottomNav item, or gesture controller.
- Only the clean-day controller action may mark a day clean.
- Use generated local PNGs for requested reflection decorations; all controls remain semantic HTML/CSS/SVG.
- Validate the changed UI at 412×892 when a renderer is available; otherwise record the blocker honestly.

### Task 1: Guardrails and Sponsor work geometry

**Files:**
- Modify: `html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js`
- Modify: `html-prototypes/app-shell/index.html`

- [ ] Write a contract asserting that the Sponsor Work profile uses the History current-card top and collapsed height, and inactive selector tabs have no border.
- [ ] Run the contract and observe RED.
- [ ] Change only the existing Sponsor Work profile/tab styles to satisfy the geometry and semantic colors.
- [ ] Run the contract and observe GREEN.

### Task 2: Daily record separation

**Files:**
- Create: `html-prototypes/app-shell/tests/daily_reflection_test.js`
- Modify: `html-prototypes/app-shell/index.html`

- [ ] Write failing contracts for session creation without clean-day confirmation, idempotent clean confirmation, one record per cycle/date, and existing-data normalization.
- [ ] Run the test and observe RED.
- [ ] Add normalized reflection session accessors and restrict clean-day writes to `markCleanToday()`.
- [ ] Run the test and observe GREEN.

### Task 3: Two entry paths and Home integration

**Files:**
- Modify: `html-prototypes/app-shell/tests/daily_reflection_test.js`
- Modify: `html-prototypes/app-shell/index.html`

- [ ] Add failing contracts for Home expanded Napi reflexió card, direct daily-reflection navigation without reward, and reward-to-choice navigation.
- [ ] Run the test and observe RED.
- [ ] Render the Home card, common route and reward choice screen using existing navigation ownership.
- [ ] Run the test and observe GREEN.

### Task 4: Reflection full-screen stages and persistence

**Files:**
- Create: `html-prototypes/app-shell/assets/reflection/daily_reflection_mood.png`
- Create: `html-prototypes/app-shell/assets/reflection/daily_reflection_writing.png`
- Create: `html-prototypes/app-shell/assets/reflection/daily_reflection_practice.png`
- Modify: `html-prototypes/app-shell/tests/daily_reflection_test.js`
- Modify: `html-prototypes/app-shell/index.html`

- [ ] Add failing render/data contracts for mood, writing and conditional practice stages, draft preservation, no panda artwork, and no duplicate practice reflection.
- [ ] Run the test and observe RED.
- [ ] Generate local artwork, implement the Survival Pack-based full-screen renderer and controller-owned draft persistence.
- [ ] Run the test and observe GREEN.

### Task 5: Regressions and visual evidence

**Files:**
- Modify: `docs/prototypes/DAILY_REFLECTION_ACCEPTANCE_CHECKLIST.md`

- [ ] Run focused daily-reflection and Sponsor tests, existing Home/reflection tests, syntax parser, whitespace and full static suite.
- [ ] Capture/inspect the requested 412×892 changed states if the local renderer is available; otherwise add the concrete unavailable-tool evidence to the checklist.
- [ ] Update every checklist status honestly.
