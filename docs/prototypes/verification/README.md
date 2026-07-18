# First-page visual verification

Verification date: 2026-07-18.

## Rendering method

The prototype was served over local HTTP and rendered with Chromium 140 through a temporary Playwright installation outside the project. The temporary browser dependency is not part of the Hajnal repository.

Android's system `screencap` command was unavailable to the Termux application UID (`SurfaceFlinger` permission denial), so the Chromium element screenshots below are the canonical browser-render evidence.

## Geometry result

Chromium measured every `.phone-screen` element directly:

| Screen | Width | Height | Outer radius | Content overflow |
|---|---:|---:|---:|---|
| Splash | 412 px | 892 px | 34 px | none |
| Onboarding | 412 px | 892 px | 34 px | none |
| Tájékoztatás | 412 px | 892 px | 34 px | none |
| Kezdődátum | 412 px | 892 px | 34 px | none |
| Felépülési cél | 412 px | 892 px | 34 px | none |
| Szponzor hozzáadása | 412 px | 892 px | 34 px | none |
| Értesítések | 412 px | 892 px | 34 px | none |
| Kezdőlap | 412 px | 892 px | 34 px | none |

For every screen, `scrollHeight === clientHeight` and `scrollWidth === clientWidth` after accounting for the 1 px phone border.

## Visual comparison result

The eight component screenshots were compared directly with `onboarding.png`, `designnkovetelmenyek.png`, `logo.png`, and the secondary first-page references documented in `REFERENCE_ANALYSIS.md`.

- Mandatory palette values are exact CSS tokens.
- Cards, choices, fields, and CTAs retain finite box radii; full pills are limited to switches and circular state controls.
- Light surfaces use low-contrast 1 px lavender borders and restrained shadows.
- The three scenic screens use flat geometric layers and a recognizable panda/llama pair without texture.
- The Home screen keeps the scenic hero, two-part metrics card, five tasks, check-in/support actions, and the five-destination bottom navigation within the viewport.
- The full-page overview confirms the required root/child ordering and the icon-plus-description header above the row.

## Evidence

- `first-page-overview.png`
- `splash.png`
- `onboarding.png`
- `information.png`
- `start-date.png`
- `recovery-goal.png`
- `sponsor-setup.png`
- `notifications.png`
- `home.png`
