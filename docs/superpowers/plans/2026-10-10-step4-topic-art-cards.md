# Step 4 illustrated topic cards — implementation plan

> Approved design source: `/storage/emulated/0/hajnal/source of truth/temak.png`.
> Runtime implementation target: `html-prototypes/app-shell/index.html` only.

## Architecture card

- **State owner:** existing `HomeInteractionController`, `PATH_STEPS`, answer state, and `lastWorked`. No state, router or progress algorithm will be added or changed.
- **Visual-data owner:** one immutable `PATH_STEP_FOUR_TOPIC_CARD_VISUALS` map. It joins each existing Step-4 topic id to an already tracked project PNG, crop position, existing icon-system name and navigation-only subtitle.
- **Rendering owner:** the existing `renderPathStepFourTopics()` branch consumes that map; it remains the sole markup owner for this one list.
- **Shared primitives reused:** existing project PNG paths, SVG icon sprite, topic-row control/action, current-topic data attribute, `openPathTopic()` and shared chapter identity renderer.
- **Scope boundary:** all selectors begin at `.path-screen[data-path-view="topics"][data-path-step="step-4"]`; no generic topic-row CSS or non-Step-4 renderer changes.

## Requirement inventory

| ID | Work | Acceptance evidence |
| --- | --- | --- |
| HJN-20261010-03A | Keep every non-list Step-4 surface byte-for-byte behaviorally stable. | Focused controller render comparison and scoped diff. |
| HJN-20261010-03B | Rebuild only the 11 cards with source geometry: icon medallion, 3 text lines, image band/fade, circular chevron and subtle active state. | DOM/CSS contract and 412×892 visual comparison. |
| HJN-20261010-03C | Map only existing inspected PNG paths; never consume `temak.png` at runtime. | Mapping/source scan. |
| HJN-20261010-03D | Preserve all live count, row action, back and answer-state behavior. | Controller navigation/data regression flow. |
| HJN-20261010-03E | Run RED/GREEN focused tests and proportional visual/static checks. | Commands plus screenshot evidence when renderer is available. |

## Execution sequence

1. Add failing assertions for the dedicated visual map, the 11 image bands, no `temak.png` runtime reference, the existing routing/progress, and Step-5 isolation.
2. Add the immutable visual mapping and consume it only from the existing Step-4 renderer.
3. Replace only the Step-4 scoped card CSS with the reference-derived geometry, crop, mask, active state and chevron surface.
4. Run the focused test, inspect the rendered DOM and source paths, then run static/syntax/HTTP verification. Capture a fixed 412×892 screenshot and iterate if a local browser becomes available.
5. Re-read this checklist/reference before a final review. No commit or push is included: the user did not request one for this change.
