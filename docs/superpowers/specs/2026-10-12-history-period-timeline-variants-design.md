# History period Timeline variants – Design

## Goal

Give every History period its own prototype Timeline while retaining the one existing History controller, route, workspace host and vertical scroll owner. In full-hero presentation, align the carousel indicator row directly below the selected period's `X nap tiszta` copy, then begin the Timeline workspace below it. Earlier periods must read as archival through neutral-gray Timeline node surfaces and darker-gray node icons.

## Scope

- `html-prototypes/app-shell/index.html` only for rendering, state projection and scoped CSS.
- Existing static source-contract tests plus one focused test extension.
- Existing `PATH_HISTORY_HERO_MASK_ACCEPTANCE_CHECKLIST.md` for acceptance tracking.

## Ownership and data flow

`HISTORY_PERIODS` remains the immutable owner of period identity and the current-period flag. A new immutable `HISTORY_PERIOD_TIMELINES` map, keyed by the same period IDs, owns prototype event collections. `HomeInteractionController.getSelectedHistoryPeriod()` remains the sole selected-period resolver. One new neutral renderer reads the selected period and projects its events into the already-mounted inline History workspace; no route, persistence, gesture engine, or scroll container is created.

The renderer may select from a finite set of existing event-card presentation variants (`standard`, `illustrated`, `milestone`, `meeting`) and uses the existing Timeline CSS/card primitives. It does not create a second Timeline layout implementation.

## Visual behavior

### Earlier periods

The existing `data-history-period-current` projection determines archival styling. When `false`, each Timeline round node receives the scoped neutral gray background and its icon uses a darker neutral gray. The currently active recovery period keeps all existing semantic colours.

### Full-hero presentation only

The hero-swipe variant gets a dedicated vertical geometry token for the Timeline workspace start. The selected slide's `X nap tiszta` copy stays in the fixed hero copy layer; carousel indicator dots render immediately below it. The workspace begins lower than in cards presentation, below the dot row. The cards presentation, its body start, and native scroll-snap are unchanged.

### Timeline data variants

Each period receives an independently authored event list with at least three events and a non-identical combination/order of variants. The current period preserves the currently visible event content and breadth. Other period data may use prototype copy but must be materially different in titles, dates, event kinds and card composition.

## Constraints

- Keep `.history-detail-panel-slot` as the only vertical scroll owner.
- Keep native carousel `scroll-snap`; do not add a gesture/controller duplicate.
- Keep Timeline/Calendar tabs, rail, expandable summary and BottomNav intact.
- Do not modify Path, Sponsor, Meetings or the History-detail route.
- No new image generation or assets are necessary; existing Timeline assets and icon symbols are reused.

## Acceptance evidence

1. Focused source contracts prove a single keyed period-timeline data owner and one rendering path.
2. Current/previous period data-state styling is proven by CSS/data attributes.
3. Full-hero-only geometry is proven scoped; cards presentation has no overriding workspace offset.
4. Targeted static tests and the full static app-shell suite pass.
5. A post-change Android screenshot remains required to validate the hero-dot/body vertical relationship and archival node appearance.
