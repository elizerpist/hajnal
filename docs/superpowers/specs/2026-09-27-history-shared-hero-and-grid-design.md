# Shared History Hero and Calendar Grid Design

## Goal

Make the existing Rail Calendar image (`assets/hero/timelinehero.png`) the
single hero image for the Történetem main screen, Timeline detail, and Calendar
Grid detail in every existing hero variant. When a user opens the shared
Timeline/Calendar detail from a period card, show that card's title instead of
`Történetem`. Restore the Calendar Grid's visible order so its selected-day
card is beneath a larger monthly grid.

## Sources and scope

- User instructions on 2026-09-27, including the confirmation that compact
  variants change image too.
- Grid reference: `/storage/emulated/0/Pictures/Screenshots/Screenshot_20260927-182834.png`.
- Rail hero implementation: `html-prototypes/app-shell/index.html`.
- Existing shared route/controller tests in
  `html-prototypes/app-shell/tests/calendar_reference_test.js` and
  `html-prototypes/app-shell/tests/route_extensions_test.js`.

The scope is limited to the existing static app-shell prototype. It stays
offline, uses its one route controller, and introduces no route, network,
storage, or BottomNav owner.

## UX decisions

1. `timelinehero.png` is the common background image on all three requested
   surfaces, in large, compact, and Calendar integrated states. The existing
   hero geometry and controls remain; only the image selection changes.
2. The Rail's quote card and its quote text remain Rail-only. The request is
   for the Rail image on the other heroes, not three copies of the Rail quote
   component.
3. A tap on any `.history-period-card` selects that card's existing rendered
   title. Timeline and Calendar tabs share that selection and display it in
   their visible hero headings and the semantic hidden/header title. Changing
   tabs, opening Grid, or opening Rail preserves the selection.
4. The Calendar Grid's one monthly-card node is before the selected-day card
   in normal Grid and compact Grid. Its days flex vertically to occupy the
   available Grid panel; the selected-day card retains its compact fixed
   content height below. Integrated Calendar continues moving the one monthly
   node into its existing hero slot and does not create a second grid.

## Architecture card

### Single source and write path

| Concern | Source of truth | Only write path |
| --- | --- | --- |
| Shared History hero asset | a named constant in `HomeInteractionController` | `renderHistoryPresentation()` binds every presentation image from it |
| Selected history-period title | `state.historySelectedPeriodTitle` | `openHistoryDetail()` when invoked by a period card |
| Detail titles | `renderHistoryDetail()` | derives every hero/header title from selected state |
| Calendar month placement | one physical `.history-calendar-month-card` | `renderCalendarGridPlacement(integrated)` |

No persistence, error retry, repository, or adapter is involved: this is
local presentation state in the existing controller.

### Reuse and centralization

| Candidate | Existing owner | Decision |
| --- | --- | --- |
| History presentation state and hero variant cycle | `HomeInteractionController.renderHistoryPresentation()` | Extend it with one common asset source; do not add per-screen image branches. |
| Detail title renderer | `HomeInteractionController.renderHistoryDetail()` | Extend its existing title fan-out to include the two visible hero headings. |
| Calendar grid move | `renderCalendarGridPlacement()` | Correct the existing move operation so Grid restores the month before the selected-day card; do not clone markup. |
| Rail quote visual | `.history-day-quote-card.calendar-rail-hero` | Keep its existing single physical owner and Rails-only quote text. |

### State ownership

| State | Owner | Lifetime | Publication |
| --- | --- | --- | --- |
| Hero variant | existing `historyPresentation` state | per surface | existing `renderHistoryPresentation()` |
| Selected period title | `HomeInteractionController.state` | current detail navigation | `renderHistoryDetail()` |
| Grid/Rail mode and selected date | existing Calendar controller state | current detail navigation | existing Calendar renderer |

### Layer flow

Period-card tap → `HomeInteractionController` state → existing detail/hero
renderers → static DOM and CSS. There is no I/O boundary.

## Acceptance checklist

| ID | Requirement | Code area | Acceptance condition | Verification | Status |
| --- | --- | --- | --- | --- | --- |
| HJN-20260927-20 | All requested heroes use Rail image, including compact/integrated variants | `index.html`; `route_extensions_test.js` | History, Timeline, and Calendar images always resolve to `timelinehero.png`; Rail quote remains singular | TDD RED/GREEN state tests; static asset-owner scan; full suite; device screenshots | NOT DONE |
| HJN-20260927-21 | Detail title reflects the tapped period card | `index.html`; `route_extensions_test.js` | Timeline, Grid, Rail semantics, and visible Timeline/Grid headings retain the chosen card title across tabs | TDD RED/GREEN controller test; static title-owner scan; screenshots | NOT DONE |
| HJN-20260927-22 | Grid expands and selected-day card is below it | `index.html`; `calendar_reference_test.js`; `route_extensions_test.js` | Normal/compact Grid order is month then selected-day card; day rows fill the panel; integrated still moves its one node | TDD RED/GREEN placement/order test; CSS contract; screenshots | NOT DONE |

## Verification plan

1. Add a failing controller test that proves every requested surface and
   compact/integrated state uses `timelinehero.png`, and period selection is
   preserved from Timeline to Calendar and Rail.
2. Add a failing Calendar structural test for normal Grid DOM order and the
   no-duplicate one-month-card contract.
3. Implement the smallest controller/CSS/markup changes, run focused tests
   green, then the full `node --test tests/*.js` suite.
4. Parse embedded JavaScript, run `git diff --check`, and verify the local HTTP
   server serves the exact local source.
5. Capture or inspect current-device screenshots for History large/compact,
   Timeline, and Calendar Grid with its selected-day card below the expanded
   grid.

## Non-goals

- Changing the Rail quote wording or duplicating it into the other heroes.
- Creating individual routes or data stores for each history card.
- Altering BottomNav, calendar date selection, event details, or the current
  integrated Calendar interaction.
