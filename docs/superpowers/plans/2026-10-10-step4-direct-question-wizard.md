# Step 4 direct question wizard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make only Step 4 topic rows enter a compact, journal-style question wizard directly, while retaining the existing Path data and answer state.

**Architecture:** The existing `HomeInteractionController` remains the single owner of navigation and `cycles[].steps[].topics[].answers`. A small resume-index resolver chooses the first unanswered question (or the final question when complete); `openPathTopic()` applies it only when the current step is `step-4`. `renderPathQuestion()` delegates only Step 4 to a dedicated renderer and scoped CSS, retaining the generic question screen for every other step.

**Tech Stack:** Semantic HTML, inline CSS, vanilla JavaScript controller, Node `assert`/`vm` static controller test.

## Global Constraints

- Modify only `html-prototypes/app-shell/index.html`, `html-prototypes/app-shell/tests/path_shell_test.js`, this plan, and the acceptance checklist.
- Scope the changed flow and visual selectors to Step 4; Steps 1–3 and 5–12 retain their topic starter and generic question UI.
- Use only existing local PNGs and the existing SVG sprite; no generated, copied, encoded, external, or screenshot-as-UI assets.
- Keep `PATH_STEPS`, every question, all answer objects/progress calculations, topic list, Step 4 hero/progress card, and step-level Answers/Sponsor review/Summary untouched.
- The direct Step 4 topic tap opens the first unanswered question, or the final question if all answers are complete; Back returns to Step-4 Témák.
- The formatting rail is visual placeholder UI only. It must not introduce a rich-text, voice-to-text, or audio engine.
- Fixed visual verification target is 412×892. Browser screenshots are required when a renderer is available; otherwise record the limitation honestly.

---

## Step 4 direct-question wizard architecture card

### Scope and sources

- **User requirement:** Latest explicit Step-4-only direct-wizard instruction, §§1–18.
- **Accepted reference paths:**
  - `docs/HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md` §§11, 21, 25–26.
  - `docs/references/source-of-truth/logo.png`
  - `docs/references/source-of-truth/onboarding.png`
  - `docs/references/source-of-truth/designnkovetelmenyek.png`
  - `docs/references/source-of-truth/checkin_visszaeses_panik.png`
  - `docs/references/source-of-truth/haladas_naptar_stat.png`
  - `docs/references/source-of-truth/eszkozok_12lepes_naplo.png`
  - `docs/references/source-of-truth/sponzor_profil_beallitasok.png`
- **Existing implementation paths:** `html-prototypes/app-shell/index.html`, `html-prototypes/app-shell/tests/path_shell_test.js`.

### Single source and write path

- **Source of truth:** existing `PATH_STEPS` plus current-cycle topic `answers` and navigation state.
- **Read model:** existing `getTopic()`, `getCurrentQuestion()`, `getCurrentPathAnswer()`, and derived `getAnsweredCount()`.
- **Only write path:** existing `openPathTopic()`, input binding, `togglePathVoiceMemo()`, `togglePathAnswerFlag()`, and question navigation methods on `HomeInteractionController`.
- **Error and retry owner:** no I/O exists in this prototype; controller input and action handlers remain the owner.

### State ownership

| State | Owner | Lifetime | Publication rule |
| --- | --- | --- | --- |
| Selected resume question | `HomeInteractionController` navigation | active Path flow | `openPathTopic()` derives and writes it before rendering |
| Answer draft / flags / memo state | existing topic answer object | current Path cycle | existing editor/action handlers write it and rerender |
| Step-4 visual composition | Step-4 renderer and scoped CSS | one render | reads state only; no feature-local store |

### Reuse and centralization decision

| Candidate | Existing owner | Shared invariant | Decision | Proof |
| --- | --- | --- | --- | --- |
| Resume selection | `HomeInteractionController` navigation | an entered topic must choose a meaningful question | Add one neutral `getTopicResumeQuestionIndex(topic, stepId)` helper, called from the existing topic opener | Step 4 empty/partial/complete tests; non-Step-4 control |
| Answer flag / voice state | `getCurrentPathAnswer()` and toggle actions | one answer object owns each flag | Reuse current state/actions; add no parallel booleans | direct object/ARIA assertions |
| Step hero asset | `pathChapterHeroAsset(step)` | each Step uses its own local artwork | Reuse existing resolver in compact Step-4 header | DOM asset path assertion |
| Decorative tiles | existing Step-4 PNG assets and icon sprite | local assets only | Compose two scoped semantic buttons from existing assets | runtime path scan |

### Layer flow

Semantic Step-4 question UI → `HomeInteractionController` → existing Path cycle/navigation and answer objects.

### Verification

- **Domain/unit:** controller resume-index, direct routing, back behavior, answer-state flag and memo regression.
- **Widget/integration:** Node DOM-string Path contract, Step 4 plus non-Step-4 control.
- **Screenshot/reference:** 412×892 compact wizard versus the inspected tool/workbook and sponsor visual language when browser tooling is available.
- **Performance/cancellation:** static local PNG paths, no base64 or added async work.

### Task 1: Lock the Step-4 navigation contract with failing tests

**Files:**

- Modify: `html-prototypes/app-shell/tests/path_shell_test.js`
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`

**Interfaces:**

- Consumes: `HomeInteractionController.openPathTopic(topicId)`, `pathBack()`, existing Path answer objects.
- Produces: failing assertions for `getTopicResumeQuestionIndex(topic, stepId)` and Step-4 direct-question destination.

- [x] **Step 1: Add the failing navigation assertions**

```js
controller.openPathStep('step-4');
controller.openPathTopics();
controller.openPathTopic('step-4-topic-2');
assert.equal(controller.getPathNavigation().view, 'question');
assert.equal(controller.getPathNavigation().questionIndex, 5);
controller.pathBack();
assert.equal(controller.getPathNavigation().view, 'topics');

controller.openPathStep('step-5');
controller.openPathTopics();
controller.openPathTopic('step-5-topic-1');
assert.equal(controller.getPathNavigation().view, 'topic');
```

- [x] **Step 2: Run the focused test to observe RED**

Run: `node html-prototypes/app-shell/tests/path_shell_test.js`

Expected: failure because Step 4 still routes to `topic` and resets `questionIndex` to zero.

- [x] **Step 3: Add complete-topic and state-preservation failures**

```js
const complete = controller.getTopic('step-4-topic-1');
complete.questions.forEach((question) => {
  controller.getTopicWork('step-4', complete.id).answers[question.id] = { text: 'kész', important: false, discussWithSponsor: false, discussedWithSponsor: false, voiceMemoState: 'none' };
});
controller.openPathTopic(complete.id);
assert.equal(controller.getPathNavigation().questionIndex, complete.questions.length - 1);
```

### Task 2: Implement the single Step-4 resume and direct-route path

**Files:**

- Modify: `html-prototypes/app-shell/index.html: HomeInteractionController Path navigation methods`
- Test: `html-prototypes/app-shell/tests/path_shell_test.js`

**Interfaces:**

- Consumes: `getTopicWork(stepId, topicId).answers`, existing `rememberLastPathWork()`.
- Produces: `getTopicResumeQuestionIndex(topic, stepId)` and Step-4-only direct navigation.

- [x] **Step 1: Add the neutral resume resolver near existing Path navigation helpers**

```js
getTopicResumeQuestionIndex(topic, stepId = this.getPathNavigation().stepId) {
  const answers = this.getTopicWork(stepId, topic.id).answers;
  const firstUnanswered = topic.questions.findIndex((question) => !answers[question.id]?.text.trim());
  return firstUnanswered === -1 ? Math.max(0, topic.questions.length - 1) : firstUnanswered;
}
```

- [x] **Step 2: Change only Step 4 inside the existing topic opener**

```js
navigation.topicId = topic.id;
navigation.questionIndex = this.getTopicResumeQuestionIndex(topic, step.id);
navigation.view = step.id === 'step-4' ? 'question' : 'topic';
// Retain the existing parent/topic start transitions.
if (step.id === 'step-4') this.rememberLastPathWork();
```

- [x] **Step 3: Make question back Step-4-aware while retaining generic behavior**

```js
if (view === 'question') {
  this.getPathNavigation().view = this.getStep().id === 'step-4' ? 'topics' : 'topic';
}
```

- [x] **Step 4: Run the focused test to observe GREEN**

Run: `node html-prototypes/app-shell/tests/path_shell_test.js`

Expected: the direct-route, resume-index, complete-topic, Step-4 back, and non-Step-4 control assertions pass.

### Task 3: Lock the Step-4 journal renderer and interactions with failing tests

**Files:**

- Modify: `html-prototypes/app-shell/tests/path_shell_test.js`

**Interfaces:**

- Consumes: the direct Step-4 question route from Task 2.
- Produces: markup/ARIA tests for the scoped journal surface and tests for existing answer-action writes.

- [x] **Step 1: Add the failing Step-4 renderer contract**

```js
assert.match(pathContent.innerHTML, /data-component="path-step-four-question-wizard"/);
assert.match(pathContent.innerHTML, /assets\/path-step-4\/hero-onleltar-mobile\.png/);
assert.match(pathContent.innerHTML, /data-component="path-step-four-formatting-rail"/);
assert.match(pathContent.innerHTML, /data-component="path-step-four-voice-memo"/);
assert.match(pathContent.innerHTML, /data-action="toggle-path-important"/);
assert.match(pathContent.innerHTML, /data-action="toggle-path-sponsor"/);
assert.doesNotMatch(pathContent.innerHTML, /Korábbi válaszaim|send-path-question-to-sponsor-pending/);
```

- [x] **Step 2: Add flag and memo state assertions**

```js
controller.togglePathVoiceMemo();
controller.togglePathAnswerFlag('important');
controller.togglePathAnswerFlag('discussWithSponsor');
assert.match(pathContent.innerHTML, /data-path-step-four-voice-state="recorded"/);
assert.match(pathContent.innerHTML, /data-path-step-four-important="true"/);
assert.match(pathContent.innerHTML, /data-path-step-four-sponsor="true"/);
```

- [x] **Step 3: Run the focused test to observe RED**

Run: `node html-prototypes/app-shell/tests/path_shell_test.js`

Expected: failure because the generic question renderer lacks the Step-4 journal component boundary, compact hero, rail, memo card, and decorative action tiles.

### Task 4: Render and style the Step-4-only journal editor

**Files:**

- Modify: `html-prototypes/app-shell/index.html: renderPathQuestion()` and a new `renderPathStepFourQuestionWizard(...)` method
- Modify: `html-prototypes/app-shell/index.html: Step-4 question-scoped CSS`
- Test: `html-prototypes/app-shell/tests/path_shell_test.js`

**Interfaces:**

- Consumes: `pathChapterHeroAsset(step)`, `question`, `answer`, `navigation`, `readOnly`, current SVG sprite and `assets/path-step-4/tile-answers.png` / `tile-sponsor-review.png`.
- Produces: semantic Step-4 journal markup nested under `data-component="path-step-four-question-wizard"`.

- [x] **Step 1: Branch only the existing question renderer**

```js
renderPathQuestion() {
  const step = this.getStep();
  const topic = this.getTopic();
  const question = this.getCurrentQuestion();
  const answer = this.getCurrentPathAnswer();
  const navigation = this.getPathNavigation();
  const readOnly = this.isPathReadOnly();
  if (step.id === 'step-4') {
    return this.renderPathStepFourQuestionWizard(step, topic, question, answer, navigation, readOnly);
  }
  // Keep the existing generic return unchanged.
}
```

- [x] **Step 2: Render semantic compact hero, question/editor/rail, memo card, tiles, and bottom navigation**

```html
<main class="path-step-four-question-shell" data-component="path-step-four-question-wizard">
  <header class="path-step-four-question-hero">…existing hero asset, back, context, x/y, progress ring…</header>
  <section class="path-step-four-question-body">
    <h1>…existing question…</h1>
    <p>Írj szabadon, nem kell tökéletes mondatokban.</p>
    <section class="path-step-four-editor-card">…textarea…<nav data-component="path-step-four-formatting-rail">…placeholder controls…</nav></section>
    <button data-component="path-step-four-voice-memo" data-action="toggle-path-voice-memo">…waveform and record/play affordance…</button>
    <section class="path-step-four-question-tiles">…important and sponsor flag buttons…</section>
    <nav class="path-question-navigation">…existing previous/next actions…</nav>
  </section>
</main>
```

- [x] **Step 3: Scope the visual implementation to Step-4 question view**

```css
.path-screen[data-path-view="question"][data-path-step="step-4"] .path-step-four-question-hero { /* compact local hero */ }
.path-screen[data-path-view="question"][data-path-step="step-4"] .path-step-four-editor-card { /* diary surface */ }
.path-screen[data-path-view="question"][data-path-step="step-4"] .path-step-four-question-tile[aria-pressed="true"] { /* lilac selected state */ }
```

- [x] **Step 4: Run the focused test to observe GREEN**

Run: `node html-prototypes/app-shell/tests/path_shell_test.js`

Expected: direct navigation, Step-4 markup/state, existing flags/memo, and non-Step-4 regression controls pass.

### Task 5: Verify scope, runtime locality, and visual evidence

**Files:**

- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`
- Modify: `docs/superpowers/plans/2026-10-10-step4-direct-question-wizard.md`

- [x] **Step 1: Run focused behavior and source-boundary checks**

Run:

```sh
node html-prototypes/app-shell/tests/path_shell_test.js
node -e '/* extract inline script and compile it with new Function */'
rg -n 'temak\.png|data:image|base64' html-prototypes/app-shell/index.html
git diff --check
```

Expected: Path test and syntax/checksum commands succeed; source scan finds no new runtime reference to prohibited image sources.

- [x] **Step 2: Serve and check the canonical prototype path**

Run:

```sh
python3 -m http.server 8765 --directory html-prototypes
curl -fsS http://127.0.0.1:8765/app-shell/index.html | sha256sum
```

Expected: one server serves the canonical `html-prototypes/app-shell/index.html` response.

- [ ] **Step 3: Capture the 412×892 Step-4 question state when browser tooling exists**

Compare the compact hero, readable editor, rail, voice card, two tiled actions, and bottom navigation against `eszkozok_12lepes_naplo.png` and `sponzor_profil_beallitasok.png`; compare a Step-5 question to prove isolation. If no browser renderer is installed, mark only screenshot-dependent acceptance items PARTIAL and state that limitation in the handoff.

- [x] **Step 4: Re-read the checklist and update every HJN-20261010-05 status truthfully**

No commit or push is included: the user did not request either in this change.

## Plan self-review

- Coverage: HJN-20261010-05A–05E each map to one or more explicit tasks.
- Scope: navigation deviation is guarded by `step.id === 'step-4'`; the generic topic and question routes remain retained for all other steps.
- State: all writes use existing controller-owned fields and actions; no new persistence, router, image, text-editor, or audio subsystem is introduced.
- Reference conflict resolution: specification Screen 24 retains a general step-introduction concept, but the later explicit user instruction supersedes it for Step 4 only; all other steps preserve that generic starter flow.
- Execution mode: inline. This is one tightly coupled controller-renderer-CSS-test change in the same HTML file; delegation would create shared-file conflicts.
