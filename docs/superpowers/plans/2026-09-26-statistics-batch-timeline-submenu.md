# Statistics Batch Timeline Submenu Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep 8E as the direct, tab-free current-period timeline while adding the selected batch's Timeline submenu beside 8D in the Statistics row.

**Architecture:** The standalone prototype has no persistent runtime model. 8C remains the one batch-selector owner; its existing native horizontal scroll and `data-batch-id` cards lead to the selected period menu 8D. 8D and new 8F share the existing detail header, `.period-detail-tabs`, timeline CSS, semantic tokens, and event contracts, but 8F is a distinct screen because it owns the Statistics-context navigation (`8D → 8F`) while 8E remains the direct Home route.

**Tech Stack:** Standalone semantic HTML/CSS, native buttons, static Node.js contracts, optional Playwright DOM/screenshot test.

## Global Constraints

- Modify the one canonical prototype: `html-prototypes/offline-ui/index.html`.
- Keep the `412px × 892px` phone viewport, semantic controls, existing warm Statistics palette, and the current 8E direct-home contract.
- Reuse `.period-detail-tabs`, `.timeline-*`, and existing semantic CSS variables; add no copied interaction engine, new raw palette, runtime storage, or new batch-selection state.
- The new 8F has the single parent `home-statistics-detail`; only 8D opens it.
- Update HJN-20260926-11 truthfully. Browser screenshot evidence remains `PARTIAL` while Playwright/Chromium is unavailable.

## Statistics Batch Timeline architecture card

### Scope and sources

- User requirement: the latest Hungarian instruction in this conversation; it overrides the former 8C/8D-only row condition.
- Accepted references: `docs/references/source-of-truth/haladas_naptar_stat.png`, `docs/references/source-of-truth/designnkovetelmenyek.png`, and `/storage/emulated/0/hajnal/timeline.png`.
- Existing implementation: `html-prototypes/offline-ui/index.html` 8C batch carousel, 8D detail view, and 8E direct-home timeline.

### Single source and state ownership

| State | Owner | Lifetime | Publication rule |
| --- | --- | --- | --- |
| Batch identity | 8C `data-batch-id` card metadata | Static prototype document | A selected card navigates to 8D through its existing native button target. |
| Direct current-period route | Kezdőlap `Tiszta napok` button | Static prototype document | It stays targeted at tab-free 8E. |
| Statistics Timeline route | 8D Timeline native button | Static prototype document | It alone targets 8F, whose sole parent is 8D. |

There is no persistent write path, controller, repository, retry, or asynchronous workflow in this static HTML prototype.

### Reuse and centralization decision

| Candidate | Existing owner | Shared invariant | Decision | Proof |
| --- | --- | --- | --- | --- |
| Detail submenu | `.period-detail-tabs` | two semantic menu choices, native button styling and active state | Reuse in 8D and 8F | Both screens have exactly the same two DOM contracts. |
| Timeline renderer | `.timeline-*` classes and `data-component="timeline-event"` | interactive event rows, date/node/content/badge structure | Reuse classes and event contract in the distinct 8F navigation context | Both paths render 12 native event buttons with the established semantic structure. |
| Statistics visual surface | `.home-statistics-detail-screen` and existing CSS variables | warm detail palette and fixed mobile layout | Extend with a sibling state class only | 8F consumes the same palette and viewport tokens. |

### Verification

- Static/domain: targeted RED then GREEN, followed by `node docs/prototypes/hajnal_ui_static_test.js all`.
- Offline/integration: `node html-prototypes/offline-ui/tests/offline_single_file_test.js` and HTTP 200 check.
- Visual: browser DOM/412×892 screenshot contract attempted; blocked only by absent local Playwright/Chromium.
- Boundary: direct inspection confirms no new runtime workflow, duplicate selector engine, raw visual palette, or data owner.

---

### Task 1: Write the failing batch-menu contracts

**Files:**
- Modify: `docs/prototypes/hajnal_ui_static_test.js`
- Modify: `docs/prototypes/hajnal_ui_browser_test.mjs`

**Interfaces:**
- Consumes: `screenOrder`, `screenRows`, `screenSlice`, `screenRowSlice`, and existing 8E batch-timeline event assertions.
- Produces: contracts for `home-statistics-detail-timeline`, two-tab 8D/8F menus, and the Statistics explanation.

- [x] **Step 1: Add a static 8F expectation before its markup exists.**

```js
assert.ok(statisticsViewsRow.includes('home-statistics home-statistics-detail home-statistics-detail-timeline'));
assert.ok(screenSlice('home-statistics-detail-timeline').includes('data-parent-screen="home-statistics-detail"'));
assert.equal((screenSlice('home-statistics-detail').match(/data-period-detail-tab=/g) || []).length, 2);
assert.ok(!screenSlice('home-statistics-detail').includes('>Időszakok<'));
assert.ok(!screenSlice('home-statistics-detail').includes('>Trendek<'));
```

- [x] **Step 2: Run the focused group and observe RED.**

Run: `node docs/prototypes/hajnal_ui_static_test.js homeBranch hierarchy`

Expected: FAIL because 8F and its parent/tab contracts do not yet exist.

- [x] **Step 3: Add browser DOM contracts for the copied timeline.**

```js
["home-statistics-detail-timeline", "home-statistics-detail"],
assert.deepEqual(detailTimeline.tabs, [
  { tab: "overview", pressed: "false", text: "Áttekintés" },
  { tab: "timeline", pressed: "true", text: "Timeline" },
]);
assert.equal(detailTimeline.eventCount, 12);
```

- [x] **Step 4: Check browser-test syntax.**

Run: `node --check docs/prototypes/hajnal_ui_browser_test.mjs`

Expected: exit code 0.

### Task 2: Add the selected-batch Timeline screen and simplify the menu

**Files:**
- Modify: `html-prototypes/offline-ui/index.html`

**Interfaces:**
- Consumes: 8C `sobriety-batch-carousel`, 8D `period-detail-tabs`, `.statistics-detail-content`, and 8E `.timeline-*` body/event markup.
- Produces: 8F `home-statistics-detail-timeline` with parent `home-statistics-detail`, active Timeline tab, and 12 interactive timeline events.

- [x] **Step 1: Reduce 8D to the two implemented submenu buttons.**

```html
<nav class="period-detail-tabs" data-component="period-detail-tabs" aria-label="Az időszak menüje">
  <button type="button" data-period-detail-tab="overview" aria-pressed="true">Áttekintés</button>
  <button type="button" data-period-detail-tab="timeline" data-action="open-period-timeline" data-target-screen="home-statistics-detail-timeline" aria-pressed="false">Timeline</button>
</nav>
```

- [x] **Step 2: Add 8F immediately after 8D in the Statistics row.**

```html
<article id="home-statistics-detail-timeline" data-screen="home-statistics-detail-timeline"
  data-parent-screen="home-statistics-detail" data-reference-image="/storage/emulated/0/hajnal/timeline.png">
```

Copy the existing 8D status/header/period heading and the existing 8E `.timeline-content` body. In 8F, the same tab pair has Timeline active and Overview targets `home-statistics-detail`.

- [x] **Step 3: Make the shared selector responsive to two tabs.**

```css
.period-detail-tabs { grid-template-columns: repeat(2, minmax(0, 1fr)); }
.home-statistics-detail-timeline-screen { background: linear-gradient(180deg, #FFF8FC 0%, #F8EEF7 100%); }
```

- [x] **Step 4: Keep the 8E direct route unchanged.**

The Home `Tiszta napok` action remains `home-statistics-timeline`; 8E retains no detail tabs or Statistics title.

### Task 3: Correct the two explanatory texts and hierarchy metadata

**Files:**
- Modify: `html-prototypes/offline-ui/index.html`
- Modify: `docs/prototypes/hajnal_ui_static_test.js`
- Modify: `docs/prototypes/hajnal_ui_browser_test.mjs`

**Interfaces:**
- Consumes: `.home-row-explanation`, current 8E/M period-history row, and the Statistics row.
- Produces: accurate direct-timeline copy plus implemented-scope copy beside 8C/8D/8F.

- [x] **Step 1: Keep the 8E/M aside focused on the current clean period.**

```html
<h3>Egy tiszta időszak története</h3>
```

It explains the direct Home route, the relapse-bounded period, event types, and background-tap reward gallery; it does not carry the Statistics implementation-status copy.

- [x] **Step 2: Replace the Statistics-row aside.**

```html
<h3>Józan időszakok, egy helyen</h3>
<p>A Statisztikák a tiszta időszakok vízszintesen görgethető gyűjteménye. Egy batchre koppintva nyílik meg az adott időszak 8D menüje: Áttekintés vagy Timeline.</p>
<p>Jelenleg a Statisztikákból ez a három nézet készült el: a batch-választó 8C, az Áttekintés 8D és a Timeline 8F. A többi statisztikai funkció tervezés alatt van.</p>
```

- [x] **Step 3: Update screen order, row arrays, parent maps, and direct DOM expectations.**

Run: `node docs/prototypes/hajnal_ui_static_test.js homeBranch hierarchy && node --check docs/prototypes/hajnal_ui_browser_test.mjs`

Expected: both commands exit 0.

### Task 4: Verify and record evidence

**Files:**
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`
- Modify: `docs/superpowers/plans/2026-09-26-statistics-batch-timeline-submenu.md`

- [x] **Step 1: Run complete static/offline/syntax checks.**

```sh
node docs/prototypes/hajnal_ui_static_test.js all
node html-prototypes/offline-ui/tests/offline_single_file_test.js
node --check docs/prototypes/hajnal_ui_browser_test.mjs
git diff --check
curl -fsS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:55305/offline-ui/index.html
```

Expected: each exits 0; curl prints `200`.

- [x] **Step 2: Attempt the browser DOM/screenshot evidence.**

Run: `node docs/prototypes/hajnal_ui_browser_test.mjs`

Expected: pass with a local Playwright/Chromium installation; otherwise retain an explicit `PARTIAL` limitation naming the unavailable dependency.

- [x] **Step 3: Mark the plan and HJN-20260926-11 honestly.**

Mark `DONE` only if direct static/browser visual evidence exists. With an unavailable browser runtime, record `PARTIAL` and the verified non-browser evidence.
