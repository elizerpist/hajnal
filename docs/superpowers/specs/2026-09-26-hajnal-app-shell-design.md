# Hajnal app shell – 8A → 8B design

## Goal

Create a lightweight, runnable Hajnal app shell that replaces the wide screen-inventory workflow for active interaction work. The first deliverable is the functional Home transition from 8A (collapsed daily card) to 8B (expanded daily checklist).

## Sources and scope

- Latest user instruction: create a separate HTML page that simulates the app; run it on a new port; first implement 8A as Home; its central card must be draggable upward and settle on 8B with the checklist expanded.
- Existing reference implementation: `html-prototypes/offline-ui/index.html`, current `#home-collapsed` (8A) and `#home` (8B) DOM/CSS.
- Specification: §§1–3, 6, 21–22, and 25 of `docs/HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md`.
- Visual references: all files in `docs/references/source-of-truth/`, especially `onboarding.png` (Home), `designnkovetelmenyek.png` (tokens and Home/check-in hierarchy), and `checkin_visszaeses_panik.png` (calm, non-shaming action language).

The work does not redesign the remaining destinations. It creates only one running Home shell with its two existing states.

## Prototype topology

The new canonical interactive artifact will be:

```text
html-prototypes/
  hajnal-prototypes-index.html
  app-shell/
    index.html
    tests/
      home_shell_test.js
```

`app-shell/index.html` has `prototype-id="hajnal/app-shell"` and `prototype-status="variant"`. It is a deliberate interactive successor under review; the existing `offline-ui` remains the accepted screen-inventory reference until the user promotes or retires it.

The app shell is a single self-contained HTML file with inline CSS, SVG, and JavaScript. It makes no network requests and does not pull external fonts or assets.

## Architecture card

### Single source and write path

| Concern | Owner | Write path |
| --- | --- | --- |
| Current Home presentation | `HomeInteractionController` in `app-shell/index.html` | Pointer/tap intent → `setProgress()` → DOM render |
| Pointer drag preview | `HomeInteractionController` | pointer down/move/up/cancel only; never persists |
| Daily-task checked state | `HomeInteractionController.tasks` | Native checkbox `change` event → task object update → progress copy render |
| Visual token values | `:root` semantic CSS custom properties | CSS reads semantic token names only |

There is no persistence, repository, network, or multi-screen router in this first slice. State exists for the lifetime of the loaded page only.

### State model

```js
const initialHomeState = {
  sheet: { progress: 0, settled: 'collapsed' },
  tasks: [
    { id: 'sponsor-call', label: 'Hívd fel a szponzorod', done: false },
    { id: 'write', label: 'Írj 10 percet', done: false },
    { id: 'meeting', label: 'Menj el egy meetingre', done: false },
    { id: 'gratitude', label: 'Írj 3 dolgot, amiért hálás vagy', done: true }
  ]
};
```

`progress` is clamped from `0` (8A) to `1` (8B). Release at or above the defined threshold expands; below it collapses. Tap offers an accessible equivalent to the gesture. Reduced-motion preference removes the settling animation without removing the state transition.

### Composition

- `HomeScene`: fixed 412×892 visual viewport; a light, semantic layered dawn scene with sky, hills, panda, and lama as inline SVG/DOM objects rather than a flattened screen image.
- `HomeHeader`: day, mantra, and non-functional menu/notification buttons.
- `DailySummaryCard`: the single gesture surface and direct click target.
- `ChecklistSheet`: one DOM sheet that translates and reveals from the card. Its task rows use native checkboxes and include the calm `Segítség kell` action.
- `BottomNavigation`: exactly `Főmenü · Történetem · Ösvény · Gyűlések · Szponzor`; only Főmenü is active in this slice.

## Interaction contract

1. Load begins in 8A: Home scene, compact daily summary card, and bottom navigation.
2. Pointer drag upward on the daily card drives `--sheet-progress` during the gesture. The card and sheet use transform/opacity custom properties only; no per-frame DOM re-creation or layout reads are needed.
3. Release at the expansion threshold, a fast upward fling, or an explicit tap settles with a short transform transition at 8B.
4. In 8B, the expanded sheet exposes real checklist controls and the `Segítség kell` button. A drag down or the visible collapse control returns to 8A.
5. Native keyboard activation on the summary card must expand; Escape returns to the collapsed state.

## Visual direction

The app preserves the existing Hajnal family: indigo/lavender/pink dawn gradient, softly rounded white sheet, low-contrast borders, warm sunrise, and quiet foreground characters. It keeps the Home content hierarchy from the accepted 8A/8B reference rather than importing dashboard density from other sections. Animation should make the sheet feel physically continuous with the card, not behave like a screen replacement.

## Acceptance and verification

- HJN-20260926-16 covers the initial app-shell slice.
- A focused Node test will inspect the standalone artifact for unique prototype metadata, the controller/state contract, semantic task controls, explicit 8A/8B state names, the five bottom-nav labels, pointer/tap/keyboard handlers, reduced-motion support, and the absence of external network dependencies.
- The test is written before the production page and must be observed failing before implementation.
- Validate the entire existing offline prototype suite remains green, then validate the new focused suite, inline JavaScript syntax, duplicate ID scan, `git diff --check`, and an HTTP response from the new single server.
- Render and inspect 8A, drag-preview, and 8B at exactly 412×892 if browser tooling is available. If it is unavailable, record the visual validation as partial rather than claiming it.

## Deliberate deferrals

- No persistent storage, data sync, or backend.
- No destination routing from bottom navigation or action buttons.
- No implementation of the daily-image, Timeline, recovery, meeting, sponsor, or evening-reflection flows.
- No migration or deletion of the existing `offline-ui` page in this slice.
