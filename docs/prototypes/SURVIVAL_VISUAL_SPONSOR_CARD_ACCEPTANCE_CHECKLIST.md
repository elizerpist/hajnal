# Survival visual reconstruction, Sponsor card and calendar refinement – acceptance checklist

## References read before implementation

- Latest user instructions from 2026-10-15: shared-work card, Sponsor calendar/time selection, and `15min.png` visual reconstruction.
- Functional source: `docs/HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md` §§16–19, 21 and 25–26.
- Mandatory visual system: `docs/references/source-of-truth/logo.png`, `onboarding.png`, `designnkovetelmenyek.png`, `checkin_visszaeses_panik.png`, `haladas_naptar_stat.png`, `eszkozok_12lepes_naplo.png`, `sponzor_profil_beallitasok.png`.
- Primary Survival visual source of truth: `/storage/emulated/0/hajnal/source of truth/15min.png`.
- Relevant real components: `html-prototypes/app-shell/index.html`, especially `HomeInteractionController`, `renderSurvival()`, `renderSponsorCalendarRoute()`, `renderMeetingsCalendarView()` and `.sponsor-work-summary`.

## Architecture card

| Concern | Sole owner / write path | Reused core | Verification |
| --- | --- | --- | --- |
| Survival workflow and timer | `HomeInteractionController.state.survivalSession`; existing `updateSurvivalSession()` | Existing seven-step state machine and DOM-only `syncSurvivalElapsedLabel()` | Controller and markup contract tests |
| Survival visual stage | `renderSurvival()` supplies an explicit visual key; CSS only renders it | Existing `SURVIVAL_STEPS`, footer, help, note and contact renderers | Static route/render tests + screenshots |
| Sponsor calendar date | `state.sponsorCalendar` via existing Sponsor calendar methods | `renderMonthCalendarCells()` and Meetings calendar geometry | Focused calendar contract tests |
| Sponsor time selection | `state.sponsorCalendar.selectedTime` through `selectSponsorCalendarTime()` | One wheel-card renderer; no second schedule store | Focused controller/render test |
| Shared-work navigation card | Existing `open-sponsor-work` action and route | Existing `sponsor-work-summary` node | DOM/CSS contract + screenshot |
| Semantic colours | Existing `--hajnal-*` and `--screen-background` tokens | Existing global design token source | CSS contract + screenshot |

## Requirement inventory

| ID | Source | Code area | Acceptance condition | Verification | Status |
| --- | --- | --- | --- | --- | --- |
| CWC-01 | Prompt 1 §§1–3,6–8 | sponsor summary markup/CSS | The main Sponsor card stays a single navigation control in the same slot, with only icon, `Közös munkánk`, `Beszélgetésekből felismerések.` and chevron. No counters/pills/CTA. | Focused DOM/CSS contract passes; 412×892 capture blocked | PARTIAL |
| CWC-02 | Prompt 1 §§4–5 | `assets/hero/sponsor_shared_work_card.png` and card layer | New local transparent PNG shows quiet lower landscape, stones and a seedling at lower right; card has pastel lavender–ivory–mint surface, border/shadow; art cannot receive pointer events. | 2048×768 RGBA file inspection and focused contract pass; screenshot blocked | PARTIAL |
| CAL-01 | Prompt 2 | Sponsor calendar CSS/renderer | Both Sponsor calendar routes adopt the Meetings monthly-card geometry, weekdays, cells, controls and pastel language while retaining one controller-owned draft. | Focused source contract passes; visual capture blocked | PARTIAL |
| CAL-02 | Prompt 2 | Sponsor time renderer/controller/CSS | Next-conversation uses one visible `xx:yy` scroll-snap swipe wheel card, rather than a multi-button time grid; time remains selectable and save validation is unchanged. | Focused source contract passes; physical swipe check blocked | PARTIAL |
| SVR-01 | Prompt 3 §§1–5,23 | survival markup/CSS | All seven steps show the reference header: Back, `15 perces túlélőcsomag`, dynamic `N / 7`, clock + remaining time and seven visible segments; it is never clipped. | CSS/markup contract passes; screenshot blocked | PARTIAL |
| SVR-02 | Prompt 3 §§6–15 | `assets/survival/*.png`, survival renderer/CSS | Seven individual local decorative assets, no embedded text or UI, use the reference pastel vector language and fade into the screen; every step maps to its own asset. | Seven 1024×1536 RGBA asset files and binding contract pass; screenshot blocked | PARTIAL |
| SVR-03 | Prompt 3 §§7–13,17–20 | existing survival renderer/controller | SVG/CSS ring, breathing orb, glass, contact card, wait timer/progress and reassessment cards remain actual interactive HTML/CSS/SVG, with existing help, notes, timer and workflow preserved. | Focused and regression source tests pass; interactive browser run blocked | PARTIAL |
| SVR-04 | Prompt 3 §§5,16–18 | survival layout CSS | Grid header/main/footer eliminates large disconnected empty areas; assets fill the main stage without blocking buttons; common CTA positions/style and reduced-motion support remain. | CSS contract passes; 412×892/360px capture blocked | PARTIAL |
| SVR-05 | Prompt 3 §§19–21 | controller/timer | No new route, state owner, store, timer or contact source; timer updates nodes only and never destroys note input. | Existing seven-step controller contract and complete static suite pass | DONE |
| SVR-06 | Prompt 3 §§22–25 | tests and evidence | Targeted tests plus full static suite pass; browser screenshots attempted for all seven at 412×892. Environment blocker, if any, is reported rather than hidden. | All non-runtime `*_test.js` tests pass; Playwright/Chromium absent and `/system/bin/screencap` returns status -1 | PARTIAL |

## Source conflict resolution

`15min.png` is newer and therefore overrides the older generic Pánik/túlélő visual layouts, but not the already implemented seven-state workflow, safety actions, timer semantics or persistence. The card and calendar prompts explicitly prohibit changing their information architecture; only their visual rendering and the Sponsor time-control affordance change.

## Implementation evidence

- The two focused tests were deliberately observed red before production changes: Survival lacked the seven asset bindings and Sponsor lacked the quiet card subtitle.
- `node html-prototypes/app-shell/tests/survival_pack_test.js` → pass.
- `node html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js` → pass.
- All non-runtime files under `html-prototypes/app-shell/tests/*.js` → pass.
- The one existing browser runtime test is environment-blocked because `playwright`/Chromium are unavailable. A local HTTP preview on port 8000 serves the updated file, but Android screen capture is unavailable to this shell (`/system/bin/screencap`: status -1), so the requested viewport screenshots cannot be honestly attached from this environment.
