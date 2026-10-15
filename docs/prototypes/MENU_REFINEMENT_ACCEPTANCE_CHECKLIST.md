# Menu refinement acceptance checklist

## Menu refinement architecture card

### Scope and sources

- User requirements: current Hungarian instruction sequence, 2026-10-15.
- Visual references: `docs/references/source-of-truth/{logo,onboarding,designnkovetelmenyek,checkin_visszaeses_panik,haladas_naptar_stat,eszkozok_12lepes_naplo,sponzor_profil_beallitasok}.png`.
- Existing implementation: `html-prototypes/app-shell/index.html`.

### Single source and write path

- Shared selector vertical geometry remains CSS-token owned.
- Sponsor profile edits remain owned by `HomeInteractionController.state.sponsor`; automatic field intents use the existing controller write path.
- The fixed Home surface is `--screen-background-original`; no selectable surface state remains.
- Path overview layout is a single fixed compact/lower presentation; per-step work-history remains owned by the existing per-step menu workflow.

### Reuse and centralization decision

| Candidate | Existing owner | Decision |
| --- | --- | --- |
| Main-menu selector geometry | shared CSS root tokens | Extend one `--main-menu-hero-view-switch-top` token for Meetings and History. |
| Sponsor field persistence | `HomeInteractionController` sponsor state | Reuse and invoke its existing write path on input; no second draft store. |
| Decorative card treatment | sponsor shared-work card asset pattern | Add a local History-only decorative asset and retain real HTML text/controls above it. |

### Focused verification

- Static contract: `tests/menu_refinement_contract_test.js`.
- Updated existing contracts: Path, global surface tone, Meetings, and BottomNav tests.
- Playwright geometry check at 412 × 892 for History/Meetings selector alignment and Sponsor-details BottomNav visibility.
- Screenshot inspection at 412 × 892 for History card expanded/collapsed, Sponsor work, Sponsor details, Meetings, Path, and Home.

## Acceptance checklist

| ID | Source | Code area | Acceptance condition | Verification | Status |
| --- | --- | --- | --- | --- | --- |
| MRF-01 | User | Sponsor work profile CSS | Avatar, call/message and chevron icons scale with the 102px card without clipping. | Contract + `03-sponsor-work-pending.png` at 412 px | DONE |
| MRF-02 | User | Meetings renderer | The hero subtitle is exactly `Közösség. Támogatás.` | Contract + `meetings-412x892.png` | DONE |
| MRF-03 | User | Path renderer/controller | The overview is permanently in its lower/compact layout; its height-toggle is removed. | Contract + Path test suite + `path-412x892.png` | DONE |
| MRF-04 | User | Path overview renderer | The top-right alternative `Korábbi lépésmunkáim` action is removed while step-level history remains intact. | Contract + Path test suite + `path-412x892.png` | DONE |
| MRF-05 | User | History card CSS/assets | One local, expandable decorative card asset is visible; expansion reveals additional image detail without covering controls. | PNG contract + collapsed/expanded 412 px screenshots | DONE |
| MRF-06 | User | Home theme CSS/controller | The global swatch palette is absent and the background is fixed to the default light pink. | Contract + Home rendering checks | DONE |
| MRF-07 | User | Meetings/History CSS | Floating dual selectors have identical measured top coordinates through one shared token. | Playwright rect comparison (41 px / 41 px rendered) | DONE |
| MRF-08 | User | Sponsor details CSS/controller | Details preserve BottomNav visibility and auto-save edits; no save CTA remains. | Sponsor Playwright runtime + `03a-sponsor-details-autosave.png` | DONE |
