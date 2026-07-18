# Hajnal first page acceptance checklist

Status values: `DONE`, `PARTIAL`, `BLOCKED`, `NOT DONE`.

The checklist must be re-read and updated before every prototype edit, review, test, commit, or delivery.

| ID | Source instruction or approved reference | Intended code area | Acceptance condition | Verification method | Status |
|---|---|---|---|---|---|
| HJN-BASE-001 | User instruction: copy all seven Hajnal PNG files into the project | `docs/references/source-of-truth/*.png` | All seven files exist in-project and each SHA-256 hash matches `/storage/emulated/0/hajnal/` | `sha256sum` source/project comparison | DONE |
| HJN-BASE-002 | User instruction: local project Codex rules | `AGENTS.md` | Rules require full spec review, direct relevant-PNG inspection, reference precedence, semantic web components, and screenshot verification before every task | Direct file inspection | DONE |
| HJN-BASE-003 | User-provided 1–26 application specification | `docs/HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md` | The full specification, screens 1–38, navigation map, UX rules, and data model are stored in one canonical project file | Heading/screen count checks plus direct review | DONE |
| HJN-SCOPE-001 | User: project is in design phase and contains documentation only | Whole project | No Flutter scaffold, application implementation, APK, or platform folders exist | `find` tree inspection | DONE |
| HJN-REF-001 | `spendeetest-worktree/docs/prototypes/color_lab.html`, root tokens at lines 41–44 | `docs/prototypes/hajnal_ui.html` | Every phone viewport is exactly `412px × 892px` with a `34px` outer corner radius | Static CSS assertions and browser geometry check | DONE |
| HJN-REF-002 | All seven PNGs; mandatory source-of-truth inspection rule | `docs/references/REFERENCE_ANALYSIS.md` | Every PNG has a documented screen inventory, geometry/shape observations, color observations, and relevance map | Direct comparison against all seven open images | DONE |
| HJN-DS-001 | `designnkovetelmenyek.png` mandatory palette | Prototype design tokens | Exact palette includes `#2C2E77`, `#6A56B4`, `#B89AD7`, `#F18EAF`, `#FEC884`, and `#FCF0F0` | Pixel samples and static CSS assertions | DONE |
| HJN-DS-002 | All PNG references: cards, rows, inputs, CTA buttons | Shared web components | Rounded boxes remain boxes; no unintended pill styling. Pills occur only for reference-supported toggles, segmented controls, compact chips, and circular state controls | Selector/radius static tests plus screenshot review | DONE |
| HJN-DS-003 | All PNG references: quiet surfaces | Shared web components | 1 px low-contrast lavender/blush borders, restrained shadows, large calm surfaces, and consistent spacing hierarchy match the references | CSS token inspection and screenshot review | DONE |
| HJN-DS-004 | Specification §2 and all reference illustrations | Shared illustration components | Scenery uses flat geometric gradients; panda represents the user and llama represents supportive connection; no textured/cartoon-mimic style is introduced | SVG/component inspection and screenshot review | DONE |
| HJN-PAGE-001 | User: page top contains icon and short description | Prototype page header | The project logo appears at the top with the Hajnal name, motto, and short prototype description beneath it, all separate from the first phone row | DOM inspection and screenshot | DONE |
| HJN-NAV-001 | User-approved tree; specification §21 | First prototype row | Display order is exactly Splash → Onboarding → Tájékoztatás → Kezdődátum → Felépülési cél → Szponzor hozzáadása → Értesítések → Kezdőlap | DOM order assertion and screenshot | DONE |
| HJN-NAV-002 | User: structure by page and child screens | Prototype grouping markup | The row exposes its root/child hierarchy in headings, labels, and semantic data attributes rather than presenting an unrelated flat category | DOM inspection and static assertions | DONE |
| HJN-S01-001 | Specification §5, Screen 1; `logo.png`, `onboarding.png` | Splash component | Shows Hajnal logo, app name, and “Csak a mai nap.”; documents automatic transition after 2–3 seconds and first-use/returning branches without adding incorrect controls | Content assertion and screenshot comparison | DONE |
| HJN-S02-001 | Specification §5, Screen 2; `onboarding.png` | Onboarding component | Shows “Nem kell 90 napot egyszerre végigcsinálnod. Csak a mait.” plus semantic “Kezdjük el” and “Már van fiókom” controls | Content/element assertions and screenshot comparison | DONE |
| HJN-S03-001 | Specification §5, Screen 3; `onboarding.png` | Tájékoztatás component | Communicates all four safety/privacy points, provides an acceptance checkbox, and a semantic Tovább button | Content/control assertions and screenshot comparison | DONE |
| HJN-S04-001 | Specification §5, Screen 4; `onboarding.png` | Kezdődátum component | Presents Ma, Tegnap, and Dátum kiválasztása; calendar dates are semantic controls; explains check-in confirmation semantics without silently confirming the day | Content/control assertions and screenshot comparison | DONE |
| HJN-S05-001 | Specification §5, Screen 5; `onboarding.png` | Felépülési cél component | Contains all seven optional recovery-goal choices and preserves an explicit skip path | Content/control count assertions and screenshot comparison | DONE |
| HJN-S06-001 | Specification §5, Screen 6; `onboarding.png`, `sponzor_profil_beallitasok.png` | Szponzor hozzáadása component | Contains Igen, hozzáadom / Később / Nincs még and makes the five sponsor/contact detail capabilities discoverable without inventing a separate top-level screen | Content/control assertions and screenshot comparison | DONE |
| HJN-S07-001 | Specification §5, Screen 7; `onboarding.png`, `sponzor_profil_beallitasok.png` | Értesítések component | Contains all five reminder controls, shows 21:00 as default evening check-in, and provides “Belépek a Hajnalba” | Content/control assertions and screenshot comparison | DONE |
| HJN-S08-001 | Specification §6, Screen 8; `onboarding.png`, `designnkovetelmenyek.png` | Kezdőlap component | Shows day/motto/actions, daily illustration, streak/total/unclosed state, no more than five simultaneous tasks, visible check-in, and non-dominant one-tap panic entry | Content/control assertions and screenshot comparison | DONE |
| HJN-WEB-001 | User: screens are web components and buttons become interactive later | All eight screens | Screens use reusable component classes/data attributes and real `button`, `input`, `label`, and `nav` elements; calendar dates are buttons; no screen is a flattened PNG | Scoped DOM/static assertions and browser checks | DONE |
| HJN-WEB-002 | Specification §25: clear back navigation; later interactivity | Screens 3–7 and Home shell | Applicable child screens have explicit semantic back affordances and stable action/state attributes | DOM/static assertions | DONE |
| HJN-A11Y-001 | Semantic web-component requirement | All controls | Controls have accessible names, labels are associated with inputs, decorative SVG is hidden from assistive technology, and every keyboard-focusable control has a visible focus indicator | Static assertions and browser focus checks | DONE |
| HJN-VERIFY-001 | Global and project instructions: screenshots are UI evidence | Browser verification artifacts | Exact `412 × 892px` screenshots are captured and compared against the relevant PNGs for shape category, palette, spacing, radii, hierarchy, and overflow | Reproducible browser test, PNG dimension assertions, and visual inspection | DONE |

## Recorded reference conflict resolution

- `onboarding.png` visually combines welcome controls with its first illustrated screen, while specification Screen 1 is an automatic Splash. Resolution: follow the specification's separate Splash/Onboarding behavior and content, while retaining the PNG's visual language.
- `onboarding.png` omits the specification's explicit Tegnap start-date option. Resolution: include Ma, Tegnap, and Dátum kiválasztása using the reference's rounded-box selection language.
- The PNG navigation and some labels are illustrative and only partially correct. Resolution: the specification and the user-approved hierarchy control screen/menu relationships; PNGs control component appearance.

## Verification evidence

- Android system capture was unavailable to the Termux application UID, so a temporary out-of-project Playwright/Chromium installation was used for browser-render evidence.
- Chromium measured all eight phone components as exactly `412 × 892px` with `34px` outer radii and no internal content overflow.
- The reproducible browser test uses integer-aligned clips and independently asserts every committed screen PNG is exactly `412 × 892px`.
- The same browser run verifies screen parentage/order, semantic calendar controls, accessible names, visible keyboard focus, radii, and internal overflow before refreshing the overview.
