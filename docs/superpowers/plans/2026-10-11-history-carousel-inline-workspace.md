# Történetem carouseles inline workspace Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Történetem vertical period-list presentation with a hero carousel and the existing shared Idővonal/Naptár workspace directly below it, without changing the Ösvény list view.

**Architecture:** `HomeInteractionController` remains the only owner of the selected History period and the existing timeline/calendar state. Add a small, neutral History-period selection and carousel gesture core; render the carousel and the body from `HISTORY_PERIODS` plus the existing History workspace view state. Move the existing timeline/calendar body into the Történetem route as one shared markup source and make the old detail route an alias into that same state, rather than duplicating event or calendar renderers.

**Tech Stack:** Single-file HTML/CSS/vanilla JavaScript prototype; Node `assert` source/runtime tests.

## Global Constraints

- Modify only `html-prototypes/app-shell/index.html` for production UI/controller behavior; do not change the Ösvény view, PATH_STEPS, questions, or Path routing.
- Keep the Történetem hero at `238px`, retaining its current artwork asset, fade-out treatment, and body/hero visual proportion.
- Do not create a second timeline, calendar, footer, period data source, or carousel selection state.
- Use `HISTORY_PERIODS[].id` as the selected-period identity and `period.current` as the default/fallback.
- The selected carousel period is always reachable by tap as well as horizontal swipe; `aria-current` must reflect selection.
- Keep the existing Idővonal/Naptár, calendar rail, event-detail, and Utam számokban behavior available from the merged Történetem route.
- Keep all tests dependency-free (`node test-file.js`); use `apply_patch` for edits; commit only verified changes.

---

## File Structure

- Modify: `html-prototypes/app-shell/index.html`
  - Owns History markup, scoped CSS, `HomeInteractionController`, `HISTORY_PERIODS` rendering, selection, swipe, and navigation adapters.
- Create: `html-prototypes/app-shell/tests/history_carousel_workspace_test.js`
  - Static/boundary contract for the merged History workspace, single state owner, carousel accessibility, and no Path regression.
- Modify: `html-prototypes/app-shell/tests/alternative_runtime_test.js`
  - Runtime contract for default selection, tap selection, swipe selection, tab switching, period copy updates, and route alias behavior.
- Modify: `docs/superpowers/specs/2026-10-10-panic-alternative-history-path-inspired-design.md`
  - Record and complete HCW-01 through HCW-08 with real verification evidence.

### Task 1: Establish the History carousel boundary contract

**Files:**

- Create: `html-prototypes/app-shell/tests/history_carousel_workspace_test.js`
- Modify: `html-prototypes/app-shell/tests/alternative_runtime_test.js`

**Interfaces:**

- Consumes: `HISTORY_PERIODS`, `HomeInteractionController`, `historySelectedPeriodId`, `selectHistoryPeriod(periodId)`, `moveHistoryCarousel(direction)`, `renderHistoryWorkspace()`.
- Produces: executable source and runtime contracts that fail until the single selected-period state and merged workspace exist.

- [ ] **Step 1: Write the failing static boundary test**

```js
'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /historySelectedPeriodId:\s*['"]current['"]/, 'History needs one controller-owned selected period ID');
assert.match(html, /getSelectedHistoryPeriod\(\)/, 'the selected period must resolve through one helper');
assert.match(html, /selectHistoryPeriod\(periodId\)/, 'tap and gesture selection must use one write path');
assert.match(html, /moveHistoryCarousel\(direction\)/, 'swipe selection must reuse the same selection state');
assert.match(html, /data-component="history-period-carousel"/, 'History must contain one carousel boundary');
assert.match(html, /data-action="select-history-period"/, 'carousel cards must be tappable buttons');
assert.match(html, /aria-current="\$\{period\.id === selected\.id\}/, 'the active carousel card must expose its selected state');
assert.match(html, /history-workspace/, 'the Történetem body must contain the inline shared workspace');
assert.doesNotMatch(html, /data-component="history-overview-layout-toggle"/, 'the obsolete History comparison control must be removed');
assert.doesNotMatch(html, /data-component="history-overview-density-toggle"/, 'the obsolete History density control must be removed');
assert.match(html, /data-component="path-workspace"/, 'the unrelated Ösvény workspace must remain present');
console.log('PASS History carousel workspace source contract');
```

- [ ] **Step 2: Run the new static test and confirm RED**

Run: `node html-prototypes/app-shell/tests/history_carousel_workspace_test.js`

Expected: fail on missing `historySelectedPeriodId` or carousel component.

- [ ] **Step 3: Extend the existing runtime fixture with carousel elements**

Add `historyCarousel` and `historyWorkspace` stub elements in `alternative_runtime_test.js`; map:

```js
if (selector === '[data-component="history-period-carousel"]') return historyCarousel;
if (selector === '[data-component="history-workspace"]') return historyWorkspace;
```

Then append a failing test after the existing History setup:

```js
assert.equal(controller.state.historySelectedPeriodId, 'current', 'the current period must seed the carousel selection');
controller.selectHistoryPeriod('period-1');
assert.equal(controller.state.historySelectedPeriodId, 'period-1', 'a carousel tap must update the sole selected period ID');
assert.match(historyWorkspace.innerHTML, /Kezdetek/, 'the inline workspace must reflect the selected period');
controller.moveHistoryCarousel(1);
assert.equal(controller.state.historySelectedPeriodId, 'period-2', 'a horizontal carousel move must reuse selection state');
```

- [ ] **Step 4: Run the runtime test and confirm RED**

Run: `node html-prototypes/app-shell/tests/alternative_runtime_test.js`

Expected: fail because `historySelectedPeriodId` and `selectHistoryPeriod` do not exist.

- [ ] **Step 5: Commit the failing contracts only**

```bash
git add html-prototypes/app-shell/tests/history_carousel_workspace_test.js html-prototypes/app-shell/tests/alternative_runtime_test.js
git commit -m "test: define history carousel workspace contracts"
```

### Task 2: Introduce one selected-period and carousel gesture core

**Files:**

- Modify: `html-prototypes/app-shell/index.html:2145-2250, 2285-2405, 3140-3305`
- Test: `html-prototypes/app-shell/tests/history_carousel_workspace_test.js`
- Test: `html-prototypes/app-shell/tests/alternative_runtime_test.js`

**Interfaces:**

- Consumes: `HISTORY_PERIODS`, existing `historyDetailView`, `historyCalendarView`, `historyCalendarDate`.
- Produces: `getSelectedHistoryPeriod()`, `selectHistoryPeriod(periodId)`, `moveHistoryCarousel(direction)`, `beginHistoryCarousel(event)`, `updateHistoryCarousel(event)`, `finishHistoryCarousel(event)`, and `renderHistoryWorkspace()`.

- [ ] **Step 1: Add the selected-period field and DOM references**

Replace `historyOverviewElements`/legacy list element ownership with the direct carousel and workspace references:

```js
this.historyWorkspaceElements = {
  screen: root.querySelector('[data-component="sobriety-batch-history"]'),
  carousel: root.querySelector('[data-component="history-period-carousel"]'),
  workspace: root.querySelector('[data-component="history-workspace"]')
};
```

Add the state next to the existing History state:

```js
historySelectedPeriodId: 'current',
historyDetailView: 'timeline',
historyCalendarView: 'grid',
historyCalendarDate: HISTORY_CALENDAR_GRID_REFERENCE_DATE,
```

- [ ] **Step 2: Implement safe period resolution and the only write path**

```js
getSelectedHistoryPeriod() {
  return HISTORY_PERIODS.find((period) => period.id === this.state.historySelectedPeriodId)
    || HISTORY_PERIODS.find((period) => period.current)
    || HISTORY_PERIODS[0];
}
selectHistoryPeriod(periodId) {
  const next = HISTORY_PERIODS.find((period) => period.id === periodId);
  if (!next || next.id === this.state.historySelectedPeriodId) return;
  this.state.historySelectedPeriodId = next.id;
  this.state.historySelectedPeriodTitle = next.title;
  this.renderHistoryWorkspace();
}
moveHistoryCarousel(direction) {
  const currentIndex = HISTORY_PERIODS.findIndex((period) => period.id === this.getSelectedHistoryPeriod().id);
  const nextIndex = Math.min(HISTORY_PERIODS.length - 1, Math.max(0, currentIndex + Math.sign(direction)));
  this.selectHistoryPeriod(HISTORY_PERIODS[nextIndex].id);
}
```

The selection method must also focus/scroll the resulting active carousel card into view with `scrollIntoView({ block: 'nearest', inline: 'center', behavior: this.motionReduced ? 'auto' : 'smooth' })` only after render.

- [ ] **Step 3: Bind a narrow horizontal gesture with no duplicated state**

Bind the pointer listeners to `this.historyWorkspaceElements.carousel`, not to the whole History screen. Store one transient controller field:

```js
this.historyCarouselDrag = { pointerId: event.pointerId, startX: event.clientX, startY: event.clientY };
```

In `finishHistoryCarousel`, ignore movement under 32px and any movement whose `Math.abs(deltaY) >= Math.abs(deltaX)`; otherwise call `moveHistoryCarousel(deltaX < 0 ? 1 : -1)`. Release pointer capture and clear `historyCarouselDrag` in both finish and cancel paths.

- [ ] **Step 4: Route all period-selection actions through the core**

Add the action case:

```js
case 'select-history-period':
  this.selectHistoryPeriod(event.target.closest('[data-history-period-id]')?.dataset.historyPeriodId);
  break;
```

Change `openHistoryDetail(view, periodTitle)` to resolve an ID when opened from an old compatibility action, set the shared selected period if valid, set `historyDetailView`, then navigate to `history`; do not leave it as a second visual route.

- [ ] **Step 5: Run contracts and confirm GREEN**

Run:

```bash
node html-prototypes/app-shell/tests/history_carousel_workspace_test.js
node html-prototypes/app-shell/tests/alternative_runtime_test.js
```

Expected: both pass, including tap and carousel movement assertions.

- [ ] **Step 6: Commit the controller core**

```bash
git add html-prototypes/app-shell/index.html html-prototypes/app-shell/tests/alternative_runtime_test.js
git commit -m "feat: add shared history period carousel state"
```

### Task 3: Replace History list presentations with the hero carousel and inline workspace

**Files:**

- Modify: `html-prototypes/app-shell/index.html:470-610, 1685-1765, 3170-3305`
- Test: `html-prototypes/app-shell/tests/history_carousel_workspace_test.js`

**Interfaces:**

- Consumes: `getSelectedHistoryPeriod()`, `selectHistoryPeriod(periodId)`, `historyDetailView`, `historyCalendarView`, existing timeline event/calendar render helpers.
- Produces: `renderHistoryCarousel()`, `renderHistoryWorkspace()`, one History inline workspace DOM boundary.

- [ ] **Step 1: Replace only the History overview markup**

In the `data-component="sobriety-batch-history"` section:

1. Retain `history-hero`, `history-hero-image` (`assets/hero/timelinehero.png`), `history-hero-copy`, status bar, and the shared History metrics/footer markup.
2. Remove the History layout and density toggle buttons, `history-current-layout`, `history-period-list`, and `history-path-overview`.
3. Add one hero-contained carousel host and one body workspace host:

```html
<div class="history-period-carousel" data-component="history-period-carousel" role="region" aria-label="Időszakok közti választás"></div>
<main class="history-content" data-component="history-workspace" aria-label="Kiválasztott időszak részletei"></main>
```

Keep the existing `history-number-summary` as a child/footer rendered by the workspace; do not create a second summary section.

- [ ] **Step 2: Move, do not copy, the existing Timeline/Calendar body source**

Move the `period-detail-tabs`, `history-detail-panel-slot`, timeline event markup, calendar markup, calendar rail markup, and existing `history-number-summary` from the `history-detail-screen` into the History workspace source. Update selectors and component references so `renderHistoryDetail` becomes `renderHistoryWorkspace` and queries the one workspace host.

The minimum render flow is:

```js
renderHistoryWorkspace() {
  const period = this.getSelectedHistoryPeriod();
  const view = this.state.historyDetailView;
  const calendarView = this.state.historyCalendarView;
  this.renderHistoryCarousel();
  this.historyWorkspaceElements.screen.dataset.historyDetailView = view;
  this.historyWorkspaceElements.screen.dataset.historyCalendarView = calendarView;
  this.historyWorkspaceElements.workspace.querySelectorAll('[data-history-workspace-title]')
    .forEach((title) => { title.textContent = period.title; });
  this.historyWorkspaceElements.workspace.querySelectorAll('[data-history-detail-tab]')
    .forEach((tab) => tab.setAttribute('aria-pressed', String(tab.dataset.historyDetailTab === view)));
  if (calendarView === 'rail') this.renderHistoryCalendarRail();
  if (view === 'timeline') this.renderHistoryPresentation('timeline');
  if (view === 'calendar' && calendarView === 'grid') this.renderHistoryPresentation('calendar');
}
```

Do not duplicate timeline events, month controls, calendar days, or footer markup into another renderer.

- [ ] **Step 3: Add scoped carousel CSS without changing Ösvény styles**

Keep the hero at the existing `--path-overview-hero-height` (`238px`). Add History-only rules equivalent to:

```css
.history-screen[data-history-workspace="inline"] .history-hero { height: var(--path-overview-hero-height); }
.history-period-carousel { position: absolute; z-index: 3; right: 0; bottom: 14px; left: 0; display: flex; gap: 10px; overflow-x: auto; padding: 0 calc(50% - 114px); scroll-snap-type: x mandatory; scrollbar-width: none; touch-action: pan-y; }
.history-period-carousel-card { flex: 0 0 228px; min-height: 78px; scroll-snap-align: center; }
.history-period-carousel-card[aria-current="true"] { transform: scale(1); opacity: 1; }
.history-period-carousel-card:not([aria-current="true"]) { transform: scale(.91); opacity: .62; }
.history-workspace { position: absolute; z-index: 2; top: var(--path-overview-header-stack); right: 0; bottom: var(--bottom-nav-h); left: 0; overflow: hidden; }
```

Reuse the History pink/lilac colors, existing `history-period-badge`, status colors, and artwork assets. Do not import Path CSS or alter a `.path-*` selector.

- [ ] **Step 4: Update workspace navigation actions**

Ensure the current tab actions no longer route into `history-detail`:

```js
case 'open-history-detail': this.setHistoryWorkspaceView('timeline'); break;
case 'open-history-detail-calendar': this.setHistoryWorkspaceView('calendar'); break;
case 'return-to-history-detail': this.navigate('history'); break;
```

`setHistoryWorkspaceView(view)` must update only `historyDetailView`, reset a calendar rail to its grid when switching to `calendar`, and call `renderHistoryWorkspace()`; it must not change `historySelectedPeriodId`.

- [ ] **Step 5: Expand the static contract for no vertical list/no duplicate workspace**

Append assertions:

```js
assert.doesNotMatch(html, /data-component="history-period-list"/, 'the vertical History list must be removed');
assert.equal((html.match(/data-component="history-workspace"/g) || []).length, 1, 'History must have one inline workspace host');
assert.match(html, /\.history-period-carousel \{[^}]*scroll-snap-type: x mandatory;/, 'carousel must use native horizontal snap');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-hero \{ height: var\(--path-overview-hero-height\);/, 'the original 238px hero geometry must remain explicit');
```

- [ ] **Step 6: Run tests and inspect the changed state**

Run:

```bash
node html-prototypes/app-shell/tests/history_carousel_workspace_test.js
node html-prototypes/app-shell/tests/alternative_runtime_test.js
node html-prototypes/app-shell/tests/history_reference_test.js
git diff --check
```

Expected: all commands exit 0. Inspect a 412×892 local browser rendering of the History route with current, first-prior, timeline, calendar grid, and calendar rail states; record screenshot availability honestly.

- [ ] **Step 7: Commit the visual/layout merge**

```bash
git add html-prototypes/app-shell/index.html html-prototypes/app-shell/tests/history_carousel_workspace_test.js html-prototypes/app-shell/tests/alternative_runtime_test.js
git commit -m "feat: merge history carousel and workspace"
```

### Task 4: Reconcile History route aliases, back behavior, and acceptance evidence

**Files:**

- Modify: `html-prototypes/app-shell/index.html:2278, 3245-3305, 3752-3765`
- Modify: `docs/superpowers/specs/2026-10-10-panic-alternative-history-path-inspired-design.md`
- Test: `html-prototypes/app-shell/tests/alternative_runtime_test.js`
- Test: `html-prototypes/app-shell/tests/history_carousel_workspace_test.js`

**Interfaces:**

- Consumes: `renderHistoryWorkspace()`, `setHistoryWorkspaceView(view)`, `openHistoryCalendarRail(date)`, `openHistoryCalendarGrid()`.
- Produces: no History back-navigation path that restores a removed vertical list, and a fully updated acceptance list.

- [ ] **Step 1: Write failing runtime navigation assertions**

```js
controller.selectHistoryPeriod('period-3');
controller.setHistoryWorkspaceView('calendar');
assert.equal(controller.state.route, 'history', 'calendar selection must stay on the merged History route');
assert.equal(controller.state.historyDetailView, 'calendar', 'the inline calendar tab must be active');
controller.openHistoryCalendarRail('2025-02-14');
assert.equal(controller.state.historyCalendarView, 'rail', 'calendar rail remains available from the merged workspace');
controller.openHistoryCalendarGrid();
assert.equal(controller.state.route, 'history', 'returning from calendar rail must stay in History');
assert.equal(controller.state.historySelectedPeriodId, 'period-3', 'calendar navigation must preserve carousel selection');
```

- [ ] **Step 2: Run the runtime test and confirm RED**

Run: `node html-prototypes/app-shell/tests/alternative_runtime_test.js`

Expected: fail because legacy calendar methods still navigate to `history-detail`.

- [ ] **Step 3: Adapt alias and back paths to the merged route**

Update `openHistoryCalendarRail`, `openHistoryCalendarGrid`, Escape/back logic, and `navigate(route)` so History workspace actions render the inline workspace and preserve selection. For an incoming legacy `history-detail` route, normalize to `history` before screen visibility is synchronized:

```js
if (route === 'history-detail') route = 'history';
```

Do not apply this rule to `timeline-event-detail`; its existing back target becomes the active History workspace.

- [ ] **Step 4: Verify GREEN and run all relevant regression tests**

Run:

```bash
node html-prototypes/app-shell/tests/history_carousel_workspace_test.js
node html-prototypes/app-shell/tests/alternative_runtime_test.js
node html-prototypes/app-shell/tests/history_path_inspired_test.js
node html-prototypes/app-shell/tests/history_reference_test.js
node html-prototypes/app-shell/tests/path_shell_test.js
git diff --check
node -e "const fs=require('node:fs'); const html=fs.readFileSync('html-prototypes/app-shell/index.html','utf8'); new Function(html.match(/<script>([\\s\\S]*?)<\\/script>\\s*<\\/body>/)[1]); console.log('PASS inline JavaScript syntax')"
```

Expected: every command exits 0. If a historical source-contract test is intentionally superseded by the approved merged layout, replace only its stale History assertion with the new carousel contract; do not weaken any Path assertion.

- [ ] **Step 5: Update the acceptance list honestly**

In `docs/superpowers/specs/2026-10-10-panic-alternative-history-path-inspired-design.md`, add HCW-01 through HCW-08 or link the design-spec IDs, update each verified result to `DONE`, and leave screenshot-dependent items `PARTIAL` if Android screenshot capture remains unavailable. Add the exact commands and output status to the validation log.

- [ ] **Step 6: Commit and push the completed package**

```bash
git add html-prototypes/app-shell/index.html html-prototypes/app-shell/tests/history_carousel_workspace_test.js html-prototypes/app-shell/tests/alternative_runtime_test.js docs/superpowers/specs/2026-10-10-panic-alternative-history-path-inspired-design.md
git commit -m "refine: finalize merged history workspace"
git push origin feat/first-prototype-page
```

## Plan self-review

- Spec coverage: HCW-01 is enforced by the no-Path-change source assertion; HCW-02 and HCW-08 receive CSS/screenshot review; HCW-03/04 cover carousel layout and one selection state; HCW-05 covers a single moved workspace source; HCW-06 covers rail/back aliases; HCW-07 preserves the shared footer.
- Placeholder scan: no unassigned or deferred implementation steps remain; every implementation task names concrete files, controller interfaces, assertions, and commands.
- Interface consistency: Tasks 2–4 use the same `historySelectedPeriodId`, `getSelectedHistoryPeriod`, `selectHistoryPeriod`, `moveHistoryCarousel`, `renderHistoryWorkspace`, and `setHistoryWorkspaceView` names.
