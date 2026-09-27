# Hajnal Modular Multi-page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver a modular, static multi-page Hajnal prototype with one reliable BottomNav per applicable document and restored expandable History/Timeline insights.

**Architecture:** Each navigable screen family becomes an HTML document under `html-prototypes/app-shell/`; styles, icon markup, BottomNav mounting, and page-local controllers are separated by responsibility. The navigation component mounts one physical nav in a host supplied by each route document, and History/Timeline reuse one insight behavior module.

**Tech Stack:** Static HTML, CSS custom properties, browser-native ES modules, Node built-in test runner, local Python HTTP server.

## Global Constraints

- Keep `html-prototypes/app-shell/` as the sole canonical folder for this prototype.
- Every HTML document declares unique `prototype-id` and a `prototype-status`.
- Remain fully local/offline: no fetch, remote scripts, packages, or additional HTTP server.
- Keep the existing locally supplied image assets byte-identical.
- The visible bottom navigation exists once per nav-bearing document, not as hidden route duplicates.
- Preserve Hungarian copy and functional History, Timeline, Calendar, Path, Meetings, Panic, and initialization flows.
- Add regression tests before each production behavior change and observe the expected RED result.

---

### Task 1: Establish modular shared chrome

**Files:**
- Create: `html-prototypes/app-shell/styles/tokens.css`
- Create: `html-prototypes/app-shell/styles/shell.css`
- Create: `html-prototypes/app-shell/components/icons.js`
- Create: `html-prototypes/app-shell/components/bottom-navigation.js`
- Create: `html-prototypes/app-shell/tests/bottom_navigation_component_test.js`

**Interfaces:**
- Produces `mountIconSprite(host)` and `mountBottomNavigation(host, activeRoute)`.
- `mountBottomNavigation` clears `host`, inserts one `<nav data-component="bottom-navigation">`, and maps routes to local document links.

- [ ] Write a Node test that imports the component source, verifies every top-level route target, and rejects two nav mount calls leaving more than one nav in a host.
- [ ] Run the test and observe RED because the component does not exist.
- [ ] Implement the two focused components and shared shell tokens/styles.
- [ ] Run the component test and observe GREEN.

### Task 2: Migrate Home, History, and Timeline

**Files:**
- Create: `html-prototypes/app-shell/pages/history.html`
- Create: `html-prototypes/app-shell/pages/timeline.html`
- Create: `html-prototypes/app-shell/styles/home.css`
- Create: `html-prototypes/app-shell/styles/history.css`
- Create: `html-prototypes/app-shell/styles/timeline.css`
- Create: `html-prototypes/app-shell/scripts/home-controller.js`
- Create: `html-prototypes/app-shell/scripts/history-insights.js`
- Create: `html-prototypes/app-shell/tests/history_insights_interaction_test.js`
- Modify: `html-prototypes/app-shell/index.html`

**Interfaces:**
- `mountExpandableInsight(root)` toggles only `data-expanded` and `aria-expanded` on one supplied summary.
- All three documents call the shared icon and BottomNav components once.

- [ ] Write an interaction test showing History and Timeline begin collapsed with a visible trigger, then expand/collapse their five-card payload.
- [ ] Run it and observe RED because the module/pages do not exist.
- [ ] Extract route-local markup and styles; replace the monolith's Home entry with a focused Home document and normal local links.
- [ ] Run the focused test and retain the existing source/reference contracts where applicable.

### Task 3: Migrate remaining destinations and nested documents

**Files:**
- Create: `html-prototypes/app-shell/pages/calendar.html`
- Create: `html-prototypes/app-shell/pages/timeline-event.html`
- Create: `html-prototypes/app-shell/pages/milestones.html`
- Create: `html-prototypes/app-shell/pages/meetings.html`
- Create: `html-prototypes/app-shell/pages/path.html`
- Create: `html-prototypes/app-shell/pages/panic.html`
- Create: `html-prototypes/app-shell/pages/initialization.html`
- Create: `html-prototypes/app-shell/styles/routes.css`
- Create: `html-prototypes/app-shell/tests/multipage_topology_test.js`

**Interfaces:**
- Nav-bearing documents provide exactly one `[data-component="bottom-navigation-host"]`.
- Detail documents that intentionally omit BottomNav declare `data-navigation="none"`.

- [ ] Write a topology test requiring a unique prototype ID, shared module imports, and the declared nav rule for each page.
- [ ] Run it and observe RED because pages are absent.
- [ ] Migrate remaining primary and nested flows without copying shared nav or shared styles.
- [ ] Run topology and existing route reference tests.

### Task 4: Remove obsolete route duplication and verify the handoff

**Files:**
- Modify: `html-prototypes/hajnal-prototypes-index.html`
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`
- Remove/replace: monolithic route-specific content in `html-prototypes/app-shell/index.html`
- Modify: all affected tests

- [ ] Write a test that fails if the entry document contains a legacy `route-bottom-nav`, multiple route-screen containers, or inline controller class.
- [ ] Run it and observe RED against the monolith.
- [ ] Remove obsolete duplicate-router implementation after its successor pages pass their contracts.
- [ ] Run full Node suite, `git diff --check`, static local-only/unique-ID scan, HTTP fetch sweep, and device visual verification of Home, History, Timeline, fullscreen/non-fullscreen navigation, and expanded insights.
- [ ] Update every acceptance row with evidence; commit and push the production prototype change.
