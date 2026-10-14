# Ösvény / Történetem hero-alignment acceptance checklist

## Architecture card

- **State owner and only write path:** `state.path.overviewLayout` remains the
  sole owner of the Ösvény layout choice; `togglePathOverviewLayout()` is its
  only write path. `state.historyEventTypeFilter` and
  `toggleHistoryEventFilter()` remain the sole owner/write path for all History
  timeline icon filters.
- **Shared mechanisms reused:** the Ösvény alternative reads the existing
  `--path-overview-hero-height` and
  `--path-overview-current-card-height` tokens already used by the permanent
  History chapter hero. Calendar rail cards call the existing
  `filteredHistoryTimelineEvents()` and `renderHistoryTimelineEventMarkup()`;
  there is no second card renderer or filter implementation.
- **Rendering boundary:** controls collect intent through the delegated action
  handler; the existing app controller mutates state and re-renders. CSS owns
  layout only.
- **Focused evidence:** static DOM/CSS contracts in
  `tests/path_history_alignment_test.js`, existing History chapter and event
  filter contracts, syntax parsing, and a served HTTP response. Visual browser
  evidence is blocked until Chromium is available.

| ID | Source | Intended code area | Acceptance condition | Verification | Status |
| --- | --- | --- | --- | --- | --- |
| PHA-01 | User: Ösvény top hero action | `index.html` Path overview renderer/CSS | A non-overlapping hero action toggles the existing layout state with clear pressed semantics. | Static source test | DONE |
| PHA-02 | User: Ösvény alternative aligns to Történetem | shared CSS tokens / compact Path scope | In alternate state, hero bottom uses `--path-overview-hero-height`, fast card uses `--path-overview-current-card-height`, and list body starts at the History scroll-zone top. | Static source test; browser geometry when available | PARTIAL — token arithmetic and structural test pass; browser geometry remains blocked |
| PHA-03 | User: preserve fade-out | Path overview pseudo-element CSS | The alternate state does not remove/replace the existing vertically masked hero artwork. | Static source test | DONE |
| PHA-04 | User: `12 lépés` is not scroll content | Path overview CSS/markup | The list heading is a sibling above the `overflow-y:auto` step-list owner. | Static source test | DONE |
| PHA-05 | User: `Az utam pillanatai` is not scroll content | History pager slide renderer/CSS | The heading is a body-level sibling above the pager scroll owner in Timeline and calendar-rail timeline-card state. | Static source test | DONE |
| PHA-06 | User: calendar rail uses History timeline cards | History pager/calendar renderer | Rail renders the shared event timeline renderer; event icons retain tappable `toggle-history-event-filter` semantics. | Static source test + existing event-filter contract | DONE |
| PHA-07 | User: tapped calendar-day rail route matches too | History calendar workspace/template | The existing calendar rail also mounts the shared timeline renderer and filter icons rather than a parallel memory-card layout. | Static source test + existing event-filter contract | DONE |
| PHA-08 | Global visual-reference instruction | rendered app | Alternate hero geometry, non-overlap, fade, and both non-scrolling headings are checked in a browser screenshot. | Browser screenshot | BLOCKED — no Chromium runtime in this environment |
