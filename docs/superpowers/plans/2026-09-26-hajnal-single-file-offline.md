# Hajnal Single-file Offline Prototype Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A címzett egyetlen letöltött HTML-fájlt nyithasson meg közvetlenül a böngészőben, helyi szerver és mellékelt assetmappa nélkül.

**Architecture:** A jelenlegi prototípus egyetlen kanonikus `html-prototypes/offline-ui/index.html` oldalra költözik. Az oldal minden SVG-je adat-URL vagy beágyazott template; a kezdő SVG-labor nem használ `fetch()`-et.

**Tech Stack:** HTML, inline CSS/JavaScript, beágyazott SVG, Node.js `assert` alapú statikus teszt.

## Global Constraints

- A prototípus az `hajnal/offline-ui` egyedi ID-t és `current` státuszt használja.
- A küldhető `index.html` nem hivatkozhat relatív assetre, HTTP(S)-re, CDN-re vagy `fetch()`-re.
- A 412 × 892 képernyőgeometria és a meglévő funkcionális HTML-vezérlők változatlanok maradnak.
- Flutter-, APK- vagy platformkód nem készül.

---

### Task 1: Canonical prototype home and failing offline contract

**Files:**
- Create: `html-prototypes/hajnal-prototypes-index.html`
- Create: `html-prototypes/offline-ui/tests/offline_single_file_test.js`
- Move: `docs/prototypes/hajnal_ui.html` → `html-prototypes/offline-ui/index.html`
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`

**Interfaces:**
- Consumes: the current HTML source and its eight `docs/prototypes/assets/*.svg` files.
- Produces: an `index.html` that is the single canonical prototype and a Node command that validates its offline contract.

- [x] **Step 1: Write the failing test**

```js
assert.match(html, /<meta name="prototype-id" content="hajnal\/offline-ui">/);
assert.match(html, /<meta name="prototype-status" content="current">/);
assert.doesNotMatch(html, /(?:src|href|url\()[^\n]*assets\//);
assert.doesNotMatch(html, /https?:\/\/|fetch\s*\(/);
assert.match(html, /data:image\/svg\+xml;base64,/);
assert.match(html, /id="welcome-svg-source"/);
```

- [x] **Step 2: Run the test and verify RED**

Run: `node html-prototypes/offline-ui/tests/offline_single_file_test.js`

Expected: failure because `index.html` does not exist yet or still contains external asset paths.

- [x] **Step 3: Move the sole canonical HTML and add its project index**

Move, do not copy, the existing prototype to `html-prototypes/offline-ui/index.html`; create the `hajnal-prototypes-index.html` catalog with a direct relative link and required meta tags. Add `prototype-id` and `prototype-status` to both HTML documents.

- [x] **Step 4: Re-run the test and confirm it still fails only for offline asset references**

Run: `node html-prototypes/offline-ui/tests/offline_single_file_test.js`

Expected: failure lists the remaining `assets/` references and `fetch()` call.

### Task 2: Embed assets and remove the runtime fetch

**Files:**
- Modify: `html-prototypes/offline-ui/index.html`
- Modify: `html-prototypes/offline-ui/tests/offline_single_file_test.js`
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`

**Interfaces:**
- Consumes: the eight source SVG bytes and the Task 1 offline contract.
- Produces: one portable `index.html`; its lighting lab reads `#welcome-svg-source` instead of a URL.

- [x] **Step 1: Keep the failing contract focused**

The test must count all eight distinct SVG source names before replacement and then assert that the resulting HTML has no `assets/`, no HTTP(S) URL, no `fetch(`, one `#welcome-svg-source` template, and at least one SVG data URI.

- [x] **Step 2: Embed each SVG**

Replace every CSS `url('assets/...')`, inline-style asset URL, and image `src="assets/..."` with the equivalent Base64 `data:image/svg+xml;base64,...` URL. Insert the raw `welcome_svg.svg` document in `<template id="welcome-svg-source">`.

- [x] **Step 3: Replace the lighting-lab reader**

```js
const svgTemplate = document.getElementById('welcome-svg-source');
const svgText = svgTemplate?.innerHTML.trim();
const ready = Promise.resolve(svgText)
  .then((source) => {
    if (!source) throw new Error('Missing embedded welcome SVG');
    return source;
  });
```

Keep the subsequent SVG normalization and lighting-profile logic unchanged.

- [x] **Step 4: Verify GREEN and direct-file behavior**

Run:

```sh
node html-prototypes/offline-ui/tests/offline_single_file_test.js
node --check html-prototypes/offline-ui/tests/offline_single_file_test.js
git diff --check
```

Expected: all return exit code 0. If an installed browser is available, open `file:///.../html-prototypes/offline-ui/index.html` and inspect Splash, Kezdőlap, and the lighting lab; no missing-image or network errors may appear.

- [x] **Step 5: Update acceptance status and hand off the direct file link**

Mark the offline acceptance item `DONE` only after the direct-file check succeeds. Give the user the absolute `index.html` link and state explicitly that only this file needs to be attached to an email.
