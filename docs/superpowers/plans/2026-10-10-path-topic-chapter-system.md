# Path topic chapter system — implementation plan

> User-approved visual baseline: the existing Step 4 topics screen and
> `/storage/emulated/0/hajnal/source of truth/temak.png`.
> Implementation target: `html-prototypes/app-shell/index.html`.

## Architecture card

- **State owner:** the current `HomeInteractionController` Path cycle and its
  per-topic `answers` object gain one compatible `status` field. It is the
  sole owner for initial/started topic state; progress remains derived from
  the existing answer data.
- **Shared renderer:** one neutral chapter-topics renderer replaces the
  Step-4-only renderer. It calls the existing `pathChapterHeroAsset(step)`
  and chapter-progress renderer, so each step uses its own existing hero.
- **Visual resolver:** a single resolver uses the approved Step 4 art mapping
  for Step 4 and maps all other topics to already-present step assets, crop
  positions, existing sprite icons and their current navigation summaries.
- **Highlight rule:** the renderer alone sets the highlighted-card marker,
  and only for `step-4-topic-2`. Started state is not a highlight state.
- **Scope:** topic-list markup/CSS only. Topic detail, editor, answers,
  sponsor review, summary, root overview, PATH_STEPS content and routing stay
  owned by their existing components.

## Requirement inventory

| ID | Work | Acceptance evidence |
| --- | --- | --- |
| HJN-20261010-04A | Generalize the card/list chapter surface to every step without duplicating renderer, router or hero logic. | Every `PATH_STEPS` list’s rendered asset/count/body contract. |
| HJN-20261010-04B | Seed first-half `in-progress` status and one-way open transition; render not-started visual state as grayscale. | State, answer-snapshot and CSS contracts. |
| HJN-20261010-04C | Pin the sole lavender/border highlight to Neheztelések. | Exact single-marker contract across all topic lists. |
| HJN-20261010-04D | Preserve full-card actions, source topic data and per-step back paths. | Controller action/back loop and asset scan. |
| HJN-20261010-04E | Validate with RED/GREEN tests and static/live checks; record screenshot limitation honestly if no renderer exists. | Command evidence and 412×892 result/limitation. |

## Execution sequence

1. Add failing assertions for all-step chapter/state/highlight contracts before implementation edits.
2. Centralize status in the existing cycle state and expose a derived visual-state resolver; opening a topic changes its status only among sibling topics while retaining the pre-existing one-way parent-step start transition.
3. Replace the Step-4 branch with the shared renderer and an asset resolver; retain the special Step-4 art choices.
4. Generalize only topic-list card CSS; add not-started grayscale and retain the targeted Neheztelések highlight.
5. Run focused and broader verification, serve/check the shell, then review this plan and the source reference.

## Execution mode

This is one tightly coupled state-renderer-CSS-test change in the same HTML shell. Inline implementation avoids conflicting edits and duplicated logic.

## Preserved parent transition

Opening a topic in a not-started step continues to start that parent step. This
preserves the earlier root-card rule that an opened Step 6–12 becomes coloured.
The topic action must not alter answers or any sibling topic status; the focused
controller contract covers all three boundaries.
