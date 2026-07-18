# Hajnal First Prototype Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first Hajnal prototype page as eight exact-size, semantic, visually source-faithful web-component screens in the approved entry-flow hierarchy.

**Architecture:** A single self-contained HTML file owns page markup, CSS tokens, inline vector scenes, and minimal native-control state. A dependency-free Node static test reads the HTML source and enforces screen order, content, semantics, geometry, palette, shape categories, and navigation contracts. Reference assets and analysis remain documentation inputs, never flattened screen implementations.

**Tech Stack:** HTML5, CSS custom properties, inline SVG, minimal vanilla JavaScript, Node.js built-in `fs`/`assert`, Android browser plus `screencap` for visual evidence.

## Global Constraints

- Re-read `docs/HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md`, `docs/acceptance/first_page_acceptance.md`, and every relevant PNG directly before each task.
- The specification controls information architecture, menu logic, screen hierarchy, content, states, and behavior.
- PNG references control colors, gradients, geometry, shape type, corner radii, borders, spacing, shadows, typography character, icon treatment, illustration style, and density.
- The eight screens are ordered Splash, Onboarding, Tájékoztatás, Kezdődátum, Felépülési cél, Szponzor hozzáadása, Értesítések, Kezdőlap.
- Every phone viewport is exactly `412px × 892px` with a `34px` outer radius.
- Mandatory colors are `#2C2E77`, `#6A56B4`, `#B89AD7`, `#F18EAF`, `#FEC884`, and `#FCF0F0`.
- Screens are semantic DOM components, never cropped, stretched, or flattened reference PNGs.
- Rounded cards, rows, fields, and full-width CTAs must not use pill geometry.
- The project remains documentation-only; do not create Flutter or platform code.

---

## File structure

- Create `docs/prototypes/hajnal_ui.html`: self-contained prototype, shared tokens/components, eight screen components, inline SVG, and minimal control-state script.
- Create `docs/prototypes/hajnal_ui_static_test.js`: dependency-free source-contract test with named groups.
- Create `docs/prototypes/verification/`: browser screenshot evidence generated after implementation.
- Modify `docs/acceptance/first_page_acceptance.md`: record evidence and honest final statuses.

### Task 1: Static prototype contract

**Files:**

- Create: `docs/prototypes/hajnal_ui_static_test.js`
- Test: `docs/prototypes/hajnal_ui_static_test.js`

**Interfaces:**

- Consumes: `docs/prototypes/hajnal_ui.html` as UTF-8 text.
- Produces: CLI `node docs/prototypes/hajnal_ui_static_test.js [shell|entry|setup|home|all]`; exit code 0 on contract success and nonzero on failure.

- [ ] **Step 1: Write the complete failing static test**

Use only Node built-ins. The test defines `expectContains`, `expectOrdered`, `expectCount`, and named groups:

```js
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');

const htmlPath = path.join(__dirname, 'hajnal_ui.html');
const html = fs.readFileSync(htmlPath, 'utf8');
const group = process.argv[2] || 'all';

function expectContains(value) {
  assert.ok(html.includes(value), `Missing ${value}`);
}

function expectCount(pattern, expected, message) {
  const actual = (html.match(pattern) || []).length;
  assert.equal(actual, expected, message || `${pattern} count`);
}

function expectOrdered(values) {
  let cursor = -1;
  for (const value of values) {
    const next = html.indexOf(value, cursor + 1);
    assert.ok(next > cursor, `${value} is missing or out of order`);
    cursor = next;
  }
}

const tests = {
  shell() {
    expectContains('--screen-w: 412px');
    expectContains('--screen-h: 892px');
    expectContains('--phone-radius: 34px');
    ['#2C2E77', '#6A56B4', '#B89AD7', '#F18EAF', '#FEC884', '#FCF0F0']
      .forEach(expectContains);
    expectCount(/class="phone-screen/g, 8);
    expectContains('docs/references/source-of-truth/logo.png');
    expectContains('class="prototype-brand"');
    assert.ok(!/\.(soft-card|choice-row|primary-button)[^}]*border-radius:\s*999px/s.test(html));
  },
  entry() {
    expectOrdered(['data-screen="splash"', 'data-screen="onboarding"',
      'data-screen="information"', 'data-screen="start-date"']);
    ['Hajnal', 'Csak a mai nap.', 'Nem kell 90 napot egyszerre végigcsinálnod.',
      'Kezdjük el', 'Már van fiókom', 'Elolvastam és elfogadom.',
      'Ma', 'Tegnap', 'Dátum kiválasztása'].forEach(expectContains);
    expectContains('type="checkbox"');
    expectCount(/name="start-date"/g, 3);
  },
  setup() {
    expectOrdered(['data-screen="recovery-goal"', 'data-screen="sponsor-setup"',
      'data-screen="notifications"']);
    expectCount(/name="recovery-goal"/g, 7);
    expectCount(/name="sponsor-choice"/g, 3);
    ['Alkohol', 'Kábítószer', 'Gyógyszer', 'Szerencsejáték',
      'Viselkedési függőség', 'Nem szeretném megadni', 'Egyéb',
      'Igen, hozzáadom', 'Később', 'Nincs még', 'Reggeli emlékeztető',
      'Esti check-in', '21:00', 'Szponzorhívás emlékeztetője',
      'Napi írás emlékeztetője', 'Meeting emlékeztetője',
      'Belépek a Hajnalba'].forEach(expectContains);
    expectCount(/data-component="toggle-row"/g, 5);
  },
  home() {
    expectContains('data-screen="home"');
    ['24. nap', 'Ma még nincs lezárva', 'Napi check-in', 'Segítség kell',
      'Kezdőlap', 'Haladás', 'Eszközök', 'Szponzor', 'Profil'].forEach(expectContains);
    expectCount(/data-component="daily-task"/g, 5);
    expectOrdered(['Kezdőlap', 'Haladás', 'Eszközök', 'Szponzor', 'Profil']);
    expectContains('<nav class="bottom-nav"');
  }
};

const selected = group === 'all' ? Object.keys(tests) : [group];
selected.forEach((name) => {
  assert.ok(tests[name], `Unknown test group: ${name}`);
  tests[name]();
  process.stdout.write(`PASS ${name}\n`);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `node docs/prototypes/hajnal_ui_static_test.js all`

Expected: FAIL with `ENOENT` for `hajnal_ui.html`.

- [ ] **Step 3: Commit the failing contract**

```bash
git add docs/prototypes/hajnal_ui_static_test.js
git commit -m "test: define Hajnal first-page prototype contract"
```

### Task 2: Prototype shell and shared visual system

**Files:**

- Create: `docs/prototypes/hajnal_ui.html`
- Test: `docs/prototypes/hajnal_ui_static_test.js`

**Interfaces:**

- Consumes: mandatory tokens and normalized geometry in `docs/references/REFERENCE_ANALYSIS.md`.
- Produces: CSS variables `--screen-w`, `--screen-h`, `--phone-radius`, six palette tokens; shared `.phone-screen`, `.soft-card`, `.choice-row`, `.primary-button`, `.toggle-row`, `.scene`, and `.bottom-nav` contracts.

- [ ] **Step 1: Add the document shell and mandatory tokens**

Create a Hungarian HTML5 document with a `.prototype-brand` header, hierarchy caption, and `.screen-row` containing eight labeled `.screen-column` elements. Use exact variables:

```css
:root {
  --screen-w: 412px;
  --screen-h: 892px;
  --phone-radius: 34px;
  --hajnal-navy: #2C2E77;
  --hajnal-purple: #6A56B4;
  --hajnal-lavender: #B89AD7;
  --hajnal-pink: #F18EAF;
  --hajnal-peach: #FEC884;
  --hajnal-cream: #FCF0F0;
  --page-blush: #FDF5F8;
  --card: #FEFBFA;
  --hairline: rgba(106, 86, 180, .13);
}
```

Set `.phone-screen` to exact width/height/radius, clipped overflow, warm surface, 1px hairline border, and restrained shadow. Set box component radii explicitly to 12–22px. Reserve `999px` for `.switch`, `.segmented-control`, and compact status rails only.

- [ ] **Step 2: Add shared status, icon, scene, character, and navigation markup**

Use inline SVG with `aria-hidden="true"` for decorative dawn/night layers and characters. Use real `button` elements for all actions and real form elements for selections. Add stable `data-component`, `data-action`, and `data-state` attributes.

- [ ] **Step 3: Run shell tests**

Run: `node docs/prototypes/hajnal_ui_static_test.js shell`

Expected: `PASS shell`.

- [ ] **Step 4: Commit the shared shell**

```bash
git add docs/prototypes/hajnal_ui.html
git commit -m "feat: add Hajnal prototype shell and design system"
```

### Task 3: Splash through start-date screens

**Files:**

- Modify: `docs/prototypes/hajnal_ui.html`
- Test: `docs/prototypes/hajnal_ui_static_test.js`

**Interfaces:**

- Consumes: shared visual components from Task 2.
- Produces: `splash`, `onboarding`, `information`, and `start-date` screen components with exact content and native control types.

- [ ] **Step 1: Confirm entry group fails before implementation**

Run: `node docs/prototypes/hajnal_ui_static_test.js entry`

Expected: FAIL on the first missing required content/control assertion.

- [ ] **Step 2: Implement Splash**

Use the in-project `logo.png`, application name, and motto. Do not add CTA controls. Add `data-transition-delay="2000-3000"`, `data-first-use-target="onboarding"`, and `data-returning-target="home"` as future behavior metadata.

- [ ] **Step 3: Implement Onboarding**

Use an arched inline-SVG scene, exact specification message, one violet rounded-box primary button and one quiet outlined/text secondary button. Set the primary action target to `information`.

- [ ] **Step 4: Implement Tájékoztatás**

Use three separate information cards that collectively contain all four safety/privacy points. Add an associated checkbox/label and semantic Tovább button with future gating metadata.

- [ ] **Step 5: Implement Kezdődátum**

Use three boxed radio choices named `start-date`, a compact calendar-style date panel, and the check-in confirmation note. Ma may be visually selected; no clean day is marked confirmed.

- [ ] **Step 6: Run entry tests**

Run: `node docs/prototypes/hajnal_ui_static_test.js entry`

Expected: `PASS entry`.

- [ ] **Step 7: Commit entry screens**

```bash
git add docs/prototypes/hajnal_ui.html
git commit -m "feat: add Hajnal splash and onboarding entry screens"
```

### Task 4: Goal, sponsor, and notification setup screens

**Files:**

- Modify: `docs/prototypes/hajnal_ui.html`
- Test: `docs/prototypes/hajnal_ui_static_test.js`

**Interfaces:**

- Consumes: `.choice-row`, `.soft-card`, `.toggle-row`, and shared CTA components.
- Produces: `recovery-goal`, `sponsor-setup`, and `notifications` components with complete specification content.

- [ ] **Step 1: Confirm setup group fails before implementation**

Run: `node docs/prototypes/hajnal_ui_static_test.js setup`

Expected: FAIL on missing goal, sponsor, or notification content.

- [ ] **Step 2: Implement Felépülési cél**

Add seven boxed radio rows named `recovery-goal`, each with an outlined circular state control and flat icon well. Provide Tovább and Kihagyom most. Preserve optionality.

- [ ] **Step 3: Implement Szponzor hozzáadása**

Add three large boxed radio choices named `sponsor-choice`. Represent name, phone, messaging method, preferred call time, and backup contact in a compact nested preview associated with the Yes choice, without creating an extra phone or top-level screen.

- [ ] **Step 4: Implement Értesítések**

Add five rectangular `data-component="toggle-row"` settings with native checkboxes styled as pill switches. Use exact label/time copy and 21:00 evening default. Add the full-width Belépek a Hajnalba CTA targeting Home.

- [ ] **Step 5: Run setup tests**

Run: `node docs/prototypes/hajnal_ui_static_test.js setup`

Expected: `PASS setup`.

- [ ] **Step 6: Commit setup screens**

```bash
git add docs/prototypes/hajnal_ui.html
git commit -m "feat: add Hajnal onboarding setup screens"
```

### Task 5: Home screen and first-row hierarchy

**Files:**

- Modify: `docs/prototypes/hajnal_ui.html`
- Test: `docs/prototypes/hajnal_ui_static_test.js`

**Interfaces:**

- Consumes: shared scene/card/action components and specification navigation order.
- Produces: `home` component, five-item `.bottom-nav`, complete eight-screen row order, and future action metadata.

- [ ] **Step 1: Confirm Home group fails before implementation**

Run: `node docs/prototypes/hajnal_ui_static_test.js home`

Expected: FAIL on missing Home content/navigation.

- [ ] **Step 2: Implement Home scenic header and state sheet**

Add 24. nap, motto, menu and notification buttons, tappable daily illustration, current streak, total clean days, and “Ma még nincs lezárva”.

- [ ] **Step 3: Implement tasks and support actions**

Add exactly five semantic task checkboxes, Napi check-in as the primary pink action, and Segítség kell as a secondary one-tap action that remains visible but not dominant.

- [ ] **Step 4: Implement exact bottom navigation**

Add a semantic `nav` with five real buttons in order: Kezdőlap, Haladás, Eszközök, Szponzor, Profil. Only Kezdőlap is active.

- [ ] **Step 5: Run all static groups**

Run: `node docs/prototypes/hajnal_ui_static_test.js all`

Expected:

```text
PASS shell
PASS entry
PASS setup
PASS home
```

- [ ] **Step 6: Commit Home**

```bash
git add docs/prototypes/hajnal_ui.html docs/prototypes/hajnal_ui_static_test.js
git commit -m "feat: complete Hajnal first prototype row"
```

### Task 6: Exact-size visual verification and acceptance closure

**Files:**

- Create: `docs/prototypes/verification/*.png`
- Modify: `docs/acceptance/first_page_acceptance.md`

**Interfaces:**

- Consumes: completed HTML, all relevant PNGs, static test output.
- Produces: browser screenshots plus final evidence-backed checklist statuses.

- [ ] **Step 1: Start a local HTTP server**

Run from the project root: `python -m http.server 4173`

Expected: server listens on `http://127.0.0.1:4173/`.

- [ ] **Step 2: Open the prototype in the Android browser**

Run: `termux-open-url 'http://127.0.0.1:4173/docs/prototypes/hajnal_ui.html#splash'`

Expected: browser opens the page at the first phone.

- [ ] **Step 3: Capture and inspect screenshots**

Create `docs/prototypes/verification/`, capture the current device screen with `/system/bin/screencap -p`, and inspect each relevant view. Repeat using anchors for all eight identifiers. Check exact geometry via static tests and visually check palette, box/pill distinction, radii, spacing, overflow, scene balance, and action hierarchy.

- [ ] **Step 4: Fix every visual discrepancy**

For each discrepancy, re-open the exact PNG and specification section, update HTML/CSS, rerun all tests, and recapture the affected screenshot. Do not change a shape category merely to make content fit; adjust spacing/type scale within the documented range.

- [ ] **Step 5: Update acceptance statuses**

Set an item to `DONE` only with matching static or screenshot evidence. Leave incomplete items `PARTIAL`, `BLOCKED`, or `NOT DONE` and report them explicitly.

- [ ] **Step 6: Run final verification**

Run:

```bash
node docs/prototypes/hajnal_ui_static_test.js all
git diff --check
git status --short
```

Expected: four PASS lines, no whitespace errors, and only intentional verification/checklist changes.

- [ ] **Step 7: Commit verification evidence**

```bash
git add docs/prototypes/verification docs/acceptance/first_page_acceptance.md docs/prototypes/hajnal_ui.html
git commit -m "test: verify Hajnal first prototype page"
```
