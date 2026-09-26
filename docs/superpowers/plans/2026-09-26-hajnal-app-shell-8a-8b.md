# Hajnal app shell 8A–8B Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use inline execution with `executing-plans`; this is one coupled controller/renderer/test slice and is not suitable for parallel ownership.

**Goal:** Deliver a lightweight standalone Hajnal app shell whose 8A Home card can be dragged upward and settles into its 8B checklist state.

**Architecture:** `html-prototypes/app-shell/index.html` contains one semantic 412×892 app viewport, one centralized `HomeInteractionController`, and inline semantic CSS tokens. The controller owns in-memory sheet and task state; DOM/SVG only render that state. The focused Node test checks the static interaction and offline contracts before and after implementation.

**Tech Stack:** Standalone HTML, CSS custom properties, inline SVG, browser Pointer Events, Node `assert`.

## Global Constraints

- New prototype location is exclusively `html-prototypes/app-shell/`; catalog it in `html-prototypes/hajnal-prototypes-index.html`.
- Preserve `html-prototypes/offline-ui/index.html` and its existing tests.
- Fixed visual app viewport: 412 × 892.
- No external assets, font requests, fetches, or network APIs in the shell.
- One `HomeInteractionController` owns all gesture and task state. Do not add a second card/sheet interaction implementation.
- Bottom navigation text is exactly `Főmenü · Történetem · Ösvény · Gyűlések · Szponzor`.
- The result is a `variant` until user visual review promotes it.

---

### Task 1: Define the test-first shell contract

**Files:**

- Create: `html-prototypes/app-shell/tests/home_shell_test.js`
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`

**Interfaces:**

- Consumes: future `html-prototypes/app-shell/index.html`
- Produces: `node html-prototypes/app-shell/tests/home_shell_test.js`

- [ ] **Step 1: Write the failing test**

Create a Node `assert/strict` test which reads `../index.html`. Require a unique `hajnal/app-shell` variant metadata pair, a `412 × 892` viewport, `data-screen-state="8a-collapsed"`, `data-screen-state="8b-expanded"`, a semantic `button` daily-summary card, a semantic checklist with four native checkbox inputs, all five required nav labels, `HomeInteractionController`, `setProgress`, `settle`, Pointer Event hooks, Escape handling, `prefers-reduced-motion`, and forbid `fetch(`, `http://`, `https://`, CDN URLs, external stylesheet/script sources, and `img` sources.

- [ ] **Step 2: Run the focused test and verify RED**

Run: `node html-prototypes/app-shell/tests/home_shell_test.js`

Expected: a failure explaining that `html-prototypes/app-shell/index.html` does not exist yet.

- [ ] **Step 3: Record HJN-20260926-16 as in-progress acceptance**

Keep the single acceptance item in `docs/prototypes/ACCEPTANCE_CHECKLIST.md` with its explicit 8A→8B, controller, semantic-control, offline, and browser-validation contract.

### Task 2: Implement the single Home controller and renderer

**Files:**

- Create: `html-prototypes/app-shell/index.html`

**Interfaces:**

- Consumes: initial task objects and gestures defined by Task 1.
- Produces: one self-contained app shell with `HomeInteractionController` as its only state owner.

- [ ] **Step 1: Add metadata, semantic token CSS, and one 412×892 app viewport**

Use `prototype-id="hajnal/app-shell"`, `prototype-status="variant"`, CSS custom properties for all visual tokens, an inline dawn/panda/lama scene, a status/header layer, a bottom nav, a semantic daily-summary `<button>`, and a semantically labelled checklist sheet.

- [ ] **Step 2: Add the minimum controller implementation**

Implement:

```js
class HomeInteractionController {
  setProgress(value, { animate = false } = {}) { /* clamp 0..1 and render */ }
  settle(target) { /* set collapsed/expanded and animate once */ }
  bind() { /* pointer, click, checkbox, and Escape intents */ }
}
```

Store task objects in the controller, update its progress label after every native checkbox `change`, and use only `--sheet-progress` / data-state rendering during drag preview.

- [ ] **Step 3: Implement accessibility and motion fallbacks**

The summary card must respond to click and keyboard activation. Escape collapses. Apply `@media (prefers-reduced-motion: reduce)` so state remains functional while transitions are removed.

- [ ] **Step 4: Run the focused test and verify GREEN**

Run: `node html-prototypes/app-shell/tests/home_shell_test.js`

Expected: `PASS app-shell 8A → 8B contract`.

### Task 3: Catalog, verify, serve, and hand off

**Files:**

- Modify: `html-prototypes/hajnal-prototypes-index.html`
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`

**Interfaces:**

- Consumes: finished app shell and focused test.
- Produces: one named catalog link, a running shared server URL, and HJN-20260926-16 verification status.

- [ ] **Step 1: Add the app-shell catalog entry**

Add a direct `app-shell/index.html` link with its `hajnal/app-shell` ID and `variant` state. Do not alter the existing offline-ui entry.

- [ ] **Step 2: Run full verification**

Run:

```sh
node html-prototypes/app-shell/tests/home_shell_test.js
node docs/prototypes/hajnal_ui_static_test.js all
node html-prototypes/offline-ui/tests/offline_single_file_test.js
node --check html-prototypes/app-shell/tests/home_shell_test.js
node -e "const fs=require('node:fs'); const html=fs.readFileSync('html-prototypes/app-shell/index.html','utf8'); [...html.matchAll(/<script\\b[^>]*>([\\s\\S]*?)<\\/script>/gi)].forEach((m)=>new Function(m[1])); console.log('PASS app-shell embedded JavaScript syntax');"
git diff --check
```

Also scan `id=` values for duplicates and start a single static server rooted at `html-prototypes/` on a free port other than the previous port. Verify both the catalog and `app-shell/index.html` return HTTP 200.

- [ ] **Step 3: Render validation**

If browser tooling exists, capture 412×892 8A, drag preview, and 8B. If unavailable, run the browser-test syntax check and record visual evidence as partial.

- [ ] **Step 4: Update acceptance status and commit/push only owned files**

Set HJN-20260926-16 to `DONE` only with browser screenshot evidence; otherwise `PARTIAL`. Stage only the new app-shell, catalog, dedicated plan/spec, and acceptance update; do not stage pre-existing unrelated modifications. Commit with `feat: add interactive hajnal app shell`, then push `feat/first-prototype-page` to `origin`.
