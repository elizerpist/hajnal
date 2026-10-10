# Step 4 Topics Chapter Header Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make only Step 4’s Témák screen retain the existing Őszinte önleltár hero and step-level progress card while replacing the main-menu body with its 11 compact topic rows.

**Architecture:** `HomeInteractionController` remains the sole owner of PATH navigation and the answer-backed Path state. A single controller renderer will own the Step 4 chapter identity fragment (hero plus step-progress card); the existing chapter menu and Step 4 topics body consume that fragment, while all other topic views retain their current renderer. The topic list reads existing `PATH_STEPS` and `getAnsweredCount()` values only; it introduces no write path or router.

**Tech Stack:** One local, interactive HTML/CSS/JavaScript prototype; Node static contract tests; local static HTTP server.

## Global Constraints

- Change only `html-prototypes/app-shell/index.html` and its focused Path test/checklist documentation for the Step 4 Témák presentation.
- Preserve `PATH_STEPS`, question text/counts, current answer state, `openPathTopic(topicId)`, and `pathBack()`.
- Reuse `assets/path-step-4/hero-onleltar-mobile.png`, current hero geometry/crop, and `getStepProgress()`; do not create an asset or a second progress source.
- The main-menu hero/progress card and Témák hero/progress card must come from one renderer, not copied markup.
- Use only lilac/lavender state treatment; do not add a green completion visual.
- The Step 4 list is independently scrollable below a stable header when the existing viewport structure safely supports it.
- No Flutter scaffold/build/APK work; this is the documentation/HTML prototype phase.

## Architecture Card

### Scope and sources

- User requirement: 4. lépés → Őszinte önleltár → Témák only; constant hero/progress chapter header, compact 11-row body, existing navigation/state unchanged.
- Accepted references: `/storage/emulated/0/hajnal/source of truth/onleltar.png`, `/storage/emulated/0/hajnal/source of truth/osveny.png`, `docs/references/source-of-truth/eszkozok_12lepes_naplo.png`, and the project’s mandatory PNG set.
- Existing implementation: `html-prototypes/app-shell/index.html`, `HomeInteractionController.renderPathChapterMenu()`, `.renderPathTopics()`, `.getStepProgress()`, `.openPathTopic()`, `.pathBack()`.

### Single source and write path

- Source of truth: `PATH_STEPS` plus `state.path.cycles[currentCycleId].steps`.
- Read model: `getStepProgress(stepId)` for the chapter and `getAnsweredCount(topic, stepId)` for rows.
- Only write path: existing `openPathTopic()` is allowed to mark a not-started step in progress; this feature does not write answers or navigation state differently.
- Error/retry owner: not applicable to this in-memory prototype rendering.

### State ownership

| State | Owner | Lifetime | Publication rule |
| --- | --- | --- | --- |
| Selected Path view/topic | `state.path.navigation` in `HomeInteractionController` | Current prototype session | Controller calls existing `renderPath()` |
| Step-wide progress | `getStepProgress()` derived from existing answers | Render only | Never written as separate state |
| Topic-row progress | `getAnsweredCount()` derived from existing answers | Render only | Never written as separate state |
| Step-start status | Existing `currentCycle.steps[stepId].status` | Current cycle | Existing `openPathTopic()` transition only |

### Reuse and centralization decision

| Candidate | Existing owner | Shared invariant | Decision | Proof |
| --- | --- | --- | --- |
| Step 4 chapter identity | `renderPathChapterMenu()` | Same hero, motto, step-wide progress card | Extract one `renderPathChapterIdentity(step, progress)` fragment | Main menu and Step 4 Témák output contain the same marked fragment |
| Progress calculation | `getStepProgress()` / `getAnsweredCount()` | Same answer-backed totals | Reuse directly | Contract test checks header and rows against source data |
| Topic navigation | `openPathTopic()` / `pathBack()` | Same topic state transition and back stack | Reuse directly | Controller flow regression test |

### Layer flow

Semantic button → `HomeInteractionController` intent method → current in-memory Path state → derived renderer → DOM. No repository, network, persistence, or cross-route workflow is added.

### Verification

- Domain/unit: `node html-prototypes/app-shell/tests/path_shell_test.js`.
- Integration: controller-driven root → Step 4 → topics → topic → topics → Step 4 path in the same contract.
- Screenshot/reference: inspect the two supplied Path references and capture a 412×892 device/browser screenshot if a renderer is available.
- Performance/cancellation: no asynchronous or expensive process is added.

---

### Task 1: Lock the Step 4 Topics contract before production code

**Files:**

- Modify: `html-prototypes/app-shell/tests/path_shell_test.js`
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`

**Interfaces:**

- Consumes: existing `HomeInteractionController`, `PATH_STEPS`, `getStepProgress()`, `openPathTopics()`, `openPathTopic()`, and `pathBack()`.
- Produces: a failing regression contract for the shared chapter header, Step 4-only topics body, retained data, and back path.

- [ ] **Step 1: Write the failing test**

```js
controller.openPathStep('step-4');
const chapterMenu = pathContent.innerHTML;
controller.openPathTopics();

assert.match(pathContent.innerHTML, /data-component="path-step-four-chapter-header"/);
assert.equal(pathContent.innerHTML.match(/data-topic-id="step-4-topic-/g).length, 11);
assert.doesNotMatch(pathContent.innerHTML, /path-step-four-menu-card/);
assert.doesNotMatch(pathContent.innerHTML, /path-step-four-quote/);
assert.match(pathContent.innerHTML, /Témák/);
assert.match(chapterMenu, /data-component="path-step-four-chapter-header"/);
```

- [ ] **Step 2: Run the focused test to verify it fails**

Run: `node html-prototypes/app-shell/tests/path_shell_test.js`

Expected: FAIL because the current Step 4 Témák renderer uses its own `Témák` header and has no shared chapter-header component.

### Task 2: Render one identity fragment and a Step 4-only compact topics body

**Files:**

- Modify: `html-prototypes/app-shell/index.html` around `renderPathChapterMenu()` and `renderPathTopics()`
- Modify: `html-prototypes/app-shell/index.html` scoped Step 4 topics CSS

**Interfaces:**

- Consumes: `renderPathChapterIdentity(step, progress)`, `getStepProgress(step.id)`, `getAnsweredCount(topic, step.id)`, `openPathTopic(topic.id)` action, and current navigation state.
- Produces: marked shared header markup and 11 Step 4 compact rows; leaves every non-Step-4 topics renderer byte-for-byte behaviorally equivalent.

- [ ] **Step 1: Implement the shared header renderer**

```js
renderPathChapterIdentity(step, progress) {
  const heroAsset = this.pathChapterHeroAsset(step);
  const heroQuote = this.pathChapterHeroQuote(step);
  return `<section data-component="path-step-four-chapter-header">…existing hero and progress card…</section>`;
}
```

Use the existing current menu markup inside this method without changing its asset, copy, dimensions, calculated values, shadow, radius, or spacing.

- [ ] **Step 2: Make only Step 4 topics use the common identity plus body**

```js
if (step.number === 4) {
  return `${this.renderPathStepFourTopicsHeader()}${this.renderPathChapterIdentity(step, progress)}
    <section class="path-step-four-topics-body">…11 existing topics…</section>`;
}
```

The body contains a simple `Témák` / `11 témakör` heading and no reflection quote or function tiles. Each full-width semantic button retains `data-action="open-path-topic"` and its exact existing topic ID.

- [ ] **Step 3: Add only scoped visual rules**

```css
.path-screen[data-path-view="topics"][data-path-step="step-4"] { overflow: hidden; }
.path-step-four-topics-body { overflow-y: auto; }
.path-step-four-topic-row { min-height: 70px; }
```

Use existing path surface/typography/colour roles, add a small single status indicator per row, and keep hero/progress dimensions inherited from the menu. Do not change generic topics, topic detail, question editor, other Step 4 subviews, or root Path rows.

- [ ] **Step 4: Run the focused test to verify it passes**

Run: `node html-prototypes/app-shell/tests/path_shell_test.js`

Expected: `PASS Ösvény data-driven workspace contract`.

### Task 3: Verify scope and update the acceptance evidence

**Files:**

- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`

**Interfaces:**

- Consumes: final controller output and test results.
- Produces: truthful `DONE`/`PARTIAL` statuses, including visual-proof limitations.

- [ ] **Step 1: Run Path and suite checks**

```sh
node html-prototypes/app-shell/tests/path_shell_test.js
for test in html-prototypes/app-shell/tests/*_test.js; do node "$test"; done
node --check /tmp/hajnal-app-shell.js
git diff --check
curl --fail http://127.0.0.1:8765/app-shell/
```

Expected: focused path contract passes; report any unrelated baseline failures separately rather than hiding them.

- [ ] **Step 2: Inspect scope preservation**

```sh
git diff -- html-prototypes/app-shell/index.html html-prototypes/app-shell/tests/path_shell_test.js
```

Confirm the only product branch is `step.number === 4` in `renderPathTopics()` and that `PATH_STEP_SEEDS`, the question overrides, `openPathTopic()`, and `pathBack()` have no functional change.

- [ ] **Step 3: Record evidence truthfully**

Set completed structural/navigation entries to `DONE` only when verified. Keep screenshot-dependent visual entries `PARTIAL` if the environment still lacks a 412×892 browser renderer, and state the remaining device check in handoff.
