# Onboarding Motivation and Statistics Heading Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move personal-motivation authoring into the penultimate onboarding slot, retain screen 30 as Pánik's read-only reminder, and visibly separate the post-Pánik statistics menu row.

**Architecture:** `onboarding-why-started` owns the initialization authoring state through a single `data-motivation-record` value. `panic-why-started` retains its Pánik parent and reads that record through `data-motivation-source`; it has no editable control. The existing `.flow-heading` primitive marks the Statistics bottom-navigation branch without duplicating a row or screen.

**Tech Stack:** Standalone semantic HTML, CSS, vanilla JavaScript metadata, Node.js static/browser prototype tests.

## Global Constraints

- Modify only the canonical `html-prototypes/offline-ui/index.html` prototype and its documentation/tests.
- Retain the fixed `412px × 892px` phone viewport and existing semantic control conventions.
- Do not duplicate the Pánik flow or introduce a second personal-motivation record.
- Follow the latest user instruction over older navigation references; use the written spec for IA and the source PNGs for visual language.
- Keep the task checklist HJN-20260926-10 current; browser screenshots remain required visual evidence when Playwright/Chromium is available.

---

### Task 1: Specify the entry and reminder contracts before markup changes

**Files:**
- Modify: `docs/prototypes/hajnal_ui_static_test.js`
- Modify: `docs/prototypes/hajnal_ui_browser_test.mjs`

**Interfaces:**
- Consumes: existing `screenOrder`, `screenRows`, `screenSlice`, and `screenRowSlice` test helpers.
- Produces: regression coverage for the new onboarding authoring screen, read-only screen 30, and ordered Statistics heading.

- [x] **Step 1: Write the failing static assertions**

```js
assert.ok(entryRow.includes('data-row-screens="splash onboarding start-date sponsor-setup onboarding-why-started notifications"'));
assert.ok(screenSlice('onboarding-why-started').includes('data-parent-screen="sponsor-setup"'));
assert.ok(screenSlice('onboarding-why-started').includes('data-motivation-record="initial-personal-motivation"'));
assert.ok(screenSlice('panic-why-started').includes('data-motivation-source="initial-personal-motivation"'));
assert.ok(!screenSlice('panic-why-started').includes('aria-label="Szerkesztés"'));
assert.ok(statisticsHeading.index < statisticsRow.index);
```

- [x] **Step 2: Run the focused static group to verify RED**

Run: `node docs/prototypes/hajnal_ui_static_test.js homeBranch panicBranch hierarchy`

Expected: failure because the entry row has no `onboarding-why-started` screen and screen 30 still has an edit button.

- [x] **Step 3: Add corresponding browser DOM/position expectations**

```js
["onboarding-why-started", "sponsor-setup"],
assert.equal(await page.locator('#panic-why-started textarea').count(), 0);
assert.equal(await page.locator('[data-statistics-menu-heading]').textContent(), 'Statisztikák');
```

- [x] **Step 4: Check browser-test syntax**

Run: `node --check docs/prototypes/hajnal_ui_browser_test.mjs`

Expected: exit code 0.

### Task 2: Build the shared-source onboarding authoring and Pánik reminder views

**Files:**
- Modify: `html-prototypes/offline-ui/index.html`

**Interfaces:**
- Consumes: `data-motivation-record="initial-personal-motivation"` and existing `why-card`, `soft-card`, `light-screen`, and Pánik flow styles.
- Produces: `onboarding-why-started` as an entry-row child and screen 30 as a read-only Pánik reminder.

- [x] **Step 1: Extend the entry row in its penultimate slot**

```html
<section class="screen-column" id="column-onboarding-why-started">
  <article id="onboarding-why-started" data-screen="onboarding-why-started"
    data-parent-screen="sponsor-setup" data-motivation-record="initial-personal-motivation">
```

- [x] **Step 2: Make the new screen the single authoring surface**

```html
<textarea data-component="onboarding-motivation-input" aria-label="Miért kezdtem el?">Szeretnék jelen lenni, tisztábban gondolkodni, és újra bízni magamban.</textarea>
<button data-action="save-initial-motivation" data-target-screen="notifications">Tovább</button>
```

- [x] **Step 3: Retarget the sponsor continuation and make screen 30 read-only**

```html
<button data-action="save-sponsor" data-target-screen="onboarding-why-started">Tovább</button>
<article id="panic-why-started" data-motivation-source="initial-personal-motivation">
```

Remove screen 30's edit button and leave its Pánik back target and reminder action intact.

- [x] **Step 4: Run focused tests to verify GREEN**

Run: `node docs/prototypes/hajnal_ui_static_test.js setup homeBranch panicBranch hierarchy`

Expected: every named group prints `PASS`.

### Task 3: Label the Statistics bottom-navigation branch after Pánik

**Files:**
- Modify: `html-prototypes/offline-ui/index.html`
- Modify: `docs/prototypes/hajnal_ui_static_test.js`
- Modify: `docs/prototypes/hajnal_ui_browser_test.mjs`

**Interfaces:**
- Consumes: `.prototype-page` flex ordering and the existing `.flow-heading` visual primitive.
- Produces: `data-statistics-menu-heading` immediately before `home-statistics-views`, after the Pánik section.

- [x] **Step 1: Insert the titled heading before 8C/8D**

```html
<div class="flow-heading statistics-menu-heading" data-statistics-menu-heading>
  <div>
    <h2>Statisztikák</h2>
    <p>Saját alsó navigáció · időszakok és részletes áttekintés</p>
  </div>
</div>
```

- [x] **Step 2: Adjust the shared flex-order declarations**

```css
.home-screen-section > .statistics-menu-heading { order: 7; }
.home-screen-section > .screen-row[data-page="home-statistics-views"] { order: 8; }
.screen-section[aria-labelledby="progress-row-title"] { order: 9; }
.screen-section[aria-labelledby="recovery-row-title"] { order: 10; }
.screen-section[aria-labelledby="alt-progress-row-title"] { order: 11; }
```

The explicit later orders keep the existing progress, recovery, and alternative-progress sequence unchanged.

- [x] **Step 3: Run focused visual-structure tests**

Run: `node docs/prototypes/hajnal_ui_static_test.js homeBranch hierarchy && node --check docs/prototypes/hajnal_ui_browser_test.mjs`

Expected: exit code 0.

### Task 4: Complete verification and acceptance evidence

**Files:**
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`

**Interfaces:**
- Consumes: HJN-20260926-10 acceptance condition and all prior tasks.
- Produces: an honest completion status with the browser-evidence limitation noted if it persists.

- [x] **Step 1: Run the complete static and offline checks**

Run:

```sh
node docs/prototypes/hajnal_ui_static_test.js all
node html-prototypes/offline-ui/tests/offline_single_file_test.js
git diff --check
curl -fsS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:55305/offline-ui/index.html
```

Expected: every command exits 0 and curl prints `200`.

- [x] **Step 2: Attempt browser evidence**

Run: `node docs/prototypes/hajnal_ui_browser_test.mjs`

Expected: browser assertions and a 412×892 screenshot pass when Playwright/Chromium is installed; otherwise record the exact unavailable dependency as `PARTIAL`.

- [x] **Step 3: Update HJN-20260926-10 status**

Mark `DONE` only with all requested visual evidence. Otherwise mark `PARTIAL` and name the missing evidence.
