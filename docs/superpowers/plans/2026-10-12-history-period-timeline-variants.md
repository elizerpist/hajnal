# History Period Timeline Variants Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give every History period distinct Timeline data and full-hero-only indicator/workspace geometry while preserving the controller, native carousel and one vertical scroll owner.

**Architecture:** `HISTORY_PERIODS` continues to own period identity/currentness. A single immutable map keyed by those IDs will own prototype Timeline data. `renderHistoryWorkspace()` projects the currently selected map entry into the existing mounted workspace, while scoped CSS reads the existing selected-period data attribute for archival color and presentation-specific geometry.

**Tech Stack:** Existing single-file HTML/CSS/JavaScript prototype; Node source-contract tests.

## Global Constraints

- Reuse `HomeInteractionController.getSelectedHistoryPeriod()`; no second selection state or router.
- Keep `.history-detail-panel-slot` as the sole vertical scroll owner.
- Apply the dot/body geometry only under `data-history-period-presentation="hero-swipe"`.
- Do not change card presentation, Path, Sponsor, Meetings, History-detail route, BottomNav or native scroll-snap.
- Use no new raster assets.

---

### Task 1: Extend the Timeline source contract

**Files:**
- Modify: `html-prototypes/app-shell/tests/history_carousel_workspace_test.js`
- Modify: `docs/prototypes/PATH_HISTORY_HERO_MASK_ACCEPTANCE_CHECKLIST.md`

**Interfaces:**
- Consumes: `HISTORY_PERIODS`, `getSelectedHistoryPeriod()`, `renderHistoryWorkspace()`.
- Produces: Failing checks for keyed period event data, a single renderer, archival icon state and full-hero-only workspace geometry.

- [x] **Step 1: Write failing tests**

Add assertions that require:

```js
assert.match(html, /const HISTORY_PERIOD_TIMELINES = Object\.freeze\(/);
assert.match(html, /renderSelectedHistoryTimeline\(selected\)/);
assert.match(html, /historyWorkspace\.dataset\.historyPeriodCurrent = String\(Boolean\(selected\.current\)\);/);
assert.match(html, /data-history-period-current="false"\] \.history-event-node\s*\{[^}]*color:\s*var\(--history-past-timeline-node-icon\);/);
assert.match(html, /data-history-period-presentation="hero-swipe"\] \.history-workspace\s*\{[^}]*top:\s*var\(--history-hero-swipe-workspace-top\);/);
```

- [x] **Step 2: Verify RED**

Run:

```sh
node html-prototypes/app-shell/tests/history_carousel_workspace_test.js
```

Expected: an assertion error explaining that the keyed timeline source or full-hero geometry does not yet exist.

- [x] **Step 3: Record acceptance IDs**

Add checklist IDs for: archival icon color, full-hero dot/body layout and varied period event data. Set each to `NOT DONE` until runtime evidence exists.

### Task 2: Add the one keyed Timeline data source and renderer

**Files:**
- Modify: `html-prototypes/app-shell/index.html`
- Test: `html-prototypes/app-shell/tests/history_carousel_workspace_test.js`

**Interfaces:**
- Consumes: the selected `period.id`; existing `escapeHtml()` and event-card classes.
- Produces: `HISTORY_PERIOD_TIMELINES`, `renderSelectedHistoryTimeline(selected)`, one `[data-component="history-period-timeline-events"]` mount target.

- [x] **Step 1: Define immutable period timeline data**

Add one `Object.freeze` map after `HISTORY_PERIODS`:

```js
const HISTORY_PERIOD_TIMELINES = Object.freeze({
  '2024-05': Object.freeze([{ date: 'máj. 1.', day: 'Sze', kind: 'step', title: 'Első döntés', note: '...' }]),
  current: Object.freeze([{ date: 'febr. 3.', day: 'H', kind: 'step', title: 'Újrakezdtem', note: '...' }]),
});
```

Every `HISTORY_PERIODS` ID must occur exactly once and each list must contain at least three items. Use multiple existing kinds (`step`, `book`, `heart`, `meeting`, `milestone`) so layouts are visibly non-identical.

- [x] **Step 2: Render through one neutral method**

Replace only the template's static Timeline event-list children with a stable mount:

```html
<div class="history-detail-event-list" data-component="history-period-timeline-events"></div>
```

Implement:

```js
renderSelectedHistoryTimeline(selected) {
  const events = HISTORY_PERIOD_TIMELINES[selected.id] || [];
  const markup = events.map((event) => /* one existing event-card primitive */).join('');
  this.historyWorkspace?.querySelectorAll('[data-component="history-period-timeline-events"]')
    .forEach((target) => { target.innerHTML = markup; });
}
```

Call it once from `renderHistoryWorkspace()` after resolving `selected`. Do not rebuild the workspace or add a scroll owner.

- [x] **Step 3: Verify GREEN**

Run:

```sh
node html-prototypes/app-shell/tests/history_carousel_workspace_test.js
node html-prototypes/app-shell/tests/timeline_reference_test.js
```

Expected: both pass, while the original mounted workspace and direct scroll owner contracts remain intact.

### Task 3: Scope archival color and full-hero geometry

**Files:**
- Modify: `html-prototypes/app-shell/index.html`
- Test: `html-prototypes/app-shell/tests/history_hero_swipe_presentation_test.js`

**Interfaces:**
- Consumes: `data-history-period-current`, `data-history-period-presentation="hero-swipe"`, existing carousel-copy/dot/workspace elements.
- Produces: scoped neutral node colors and a hero-swipe-only workspace/dot position.

- [x] **Step 1: Add semantic History tokens**

On the scoped inline History screen add:

```css
--history-past-timeline-node-surface: #E6E6E6;
--history-past-timeline-node-icon: #5F5F5F;
--history-hero-swipe-workspace-top: /* exact top below dot row */;
```

- [x] **Step 2: Apply the archival icon surface and color**

Use one scoped rule:

```css
.history-screen[data-history-workspace="inline"] .history-workspace[data-history-period-current="false"] .history-event-node {
  background: var(--history-past-timeline-node-surface);
  color: var(--history-past-timeline-node-icon);
}
```

- [x] **Step 3: Apply full-hero-only layout**

Use `data-history-period-presentation="hero-swipe"` selectors to position dots below the full-hero `days` text and set the workspace top to `--history-hero-swipe-workspace-top`. Do not override the workspace top outside hero-swipe.

- [x] **Step 4: Verify GREEN**

Run:

```sh
node html-prototypes/app-shell/tests/history_hero_swipe_presentation_test.js
node html-prototypes/app-shell/tests/history_carousel_workspace_test.js
```

Expected: full-hero CSS is scoped and card presentation remains unchanged.

### Task 4: Verification and acceptance update

**Files:**
- Modify: `docs/prototypes/PATH_HISTORY_HERO_MASK_ACCEPTANCE_CHECKLIST.md`

- [x] **Step 1: Run static suite**

Run:

```sh
for test_file in $(find html-prototypes/app-shell/tests -maxdepth 1 -name '*_test.js' -print | sort | grep -v '/history_timeline_scroll_runtime_test.js$'); do node "$test_file" || exit 1; done
git diff --check
```

Expected: every static contract passes with no whitespace errors.

- [x] **Step 2: Verify the served source**

Run:

```sh
local_hash=$(sha256sum html-prototypes/app-shell/index.html | cut -d' ' -f1)
served_hash=$(curl -fsS http://127.0.0.1:8765/app-shell/index.html | sha256sum | cut -d' ' -f1)
test "$local_hash" = "$served_hash"
```

Expected: server and working tree hashes match.

- [ ] **Step 3: Visual confirmation**

At 412×892 Android fullscreen, select an older period and verify gray node surfaces/icons plus its distinct Timeline. Switch Cards → full hero and verify dots immediately under `X nap tiszta`, body lower, scroll/Calendar/footer/BottomNav intact. Capture a screenshot before marking the related criteria `DONE`.
