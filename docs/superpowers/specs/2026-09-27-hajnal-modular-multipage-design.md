# Hajnal modular multi-page design

## Goal

Replace the monolithic interactive `app-shell/index.html` with route documents, shared assets, and focused controllers. A document must contain exactly one BottomNav mount point; no route document may include a second physical navigation copy.

## Evidence and problem statement

The 2026-09-27 device screenshot shows two BottomNav bars on the History route. The served HTTP response is byte-identical to the active worktree file, so this is not a stale server response. The existing document contains one home `bottom-nav` plus several route-local `route-bottom-nav` elements. Commit `394dbad` tried to hide inactive copies only after JavaScript starts; its test is static and does not exercise a rendered route transition.

The History and Timeline insight payloads remain in markup, but commit `20e401e` changed their visible arrow control into a transparent full-card surface. Their initial presentation deliberately uses `max-height: 0` and `opacity: 0`; in the failed layout the fixed summary strip is obscured by the duplicated navigation and gives no visible expansion affordance.

## Architecture card

| Concern | Owner | Contract |
| --- | --- | --- |
| Visual tokens and phone frame | `styles/tokens.css`, `styles/shell.css` | One source for dimensions, colors, typography, safe-area, and frame behavior. |
| Bottom navigation | `components/bottom-navigation.js` | `mountBottomNavigation(host, activeRoute)` clears and mounts one nav only; it uses normal document links. |
| Shared icon symbols | `components/icons.js` | `mountIconSprite(host)` mounts a single hidden symbol sprite before UI markup. |
| Screen styling | `styles/home.css`, `styles/history.css`, `styles/timeline.css`, `styles/routes.css` | A screen stylesheet owns only its screen plus its direct local states. |
| Screen behavior | `scripts/home-controller.js`, `scripts/history-insights.js`, `scripts/timeline-controller.js` | Each controller owns only page-local interaction and never controls another route's DOM. |
| Route documents | `index.html`, `pages/*.html` | One screen family per document, unique `prototype-id`, one app frame, and one nav mount point except intentional nav-free detail documents. |

## Navigation model

Top-level destinations are ordinary local links: Home, History, Path, Meetings, and Sponsor placeholder. History links to Timeline and Calendar pages; nested detail pages link back with normal anchors. The Panic and initialization flows remain page-local only where they do not expose a BottomNav. No fetch, remote dependency, second web server, or client-side global route switcher is introduced.

## Insight model

`history-insights.js` exposes `mountExpandableInsight(root)`. It owns `aria-expanded`, the payload visibility class, and a clearly visible affordance in the summary header. History and Timeline use the same neutral primitive and supply only their local title and metric content. The page document contains the summary once.

## Acceptance inventory

| ID | Requirement source | Intended code area | Acceptance condition | Verification | Status |
| --- | --- | --- | --- | --- | --- |
| HJN-20260927-14 | User: duplicated BottomNav; upper inert / lower swipe-only | route documents + `components/bottom-navigation.js` | Every nav-bearing document mounts exactly one BottomNav; its links target local existing documents and remain functional inside and outside fullscreen. | Node structural/component test; device screenshot/tap verification. | NOT DONE |
| HJN-20260927-15 | User: History and Timeline expandable insight cards disappeared | History/Timeline markup + `scripts/history-insights.js` | Both pages show a visible collapsed insight card and expand/collapse the existing five-metric payload by tapping its semantic trigger. | TDD interaction test and device screenshot. | NOT DONE |
| HJN-20260927-16 | User: split whole app to several HTML/component files | `app-shell/pages`, `styles`, `components`, `scripts` | Top-level routes are separate HTML documents; shared chrome/style/behavior lives in focused files; no page contains duplicate BottomNav markup. | File-ownership/static topology test and manual link sweep. | NOT DONE |
| HJN-20260927-17 | User: commit trace and preserve behavior | all migrated routes | Existing supplied assets, Hungarian copy, History cards, Timeline tabs, Calendar, Path, Meetings, and Panic flows are retained or explicitly linked from their route documents. | Existing focused contracts adapted to topology plus full test suite. | NOT DONE |

## Explicit non-goals

This is an HTML-prototype refactor, not a Flutter production change. It does not create an APK, add a backend, introduce external dependencies, or delete the historical source until all successor pages and tests are verified.
