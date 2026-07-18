# First-page visual verification

Verification date: 2026-07-18.

## Rendering method

The prototype was rendered with Chromium 140 through a temporary Playwright installation outside the project. The temporary browser dependency is not part of the Hajnal repository.

Android's system `screencap` command was unavailable to the Termux application UID (`SurfaceFlinger` permission denial), so the integer-clipped Chromium screenshots below are the canonical browser-render evidence.

The committed `../hajnal_ui_browser_test.mjs` script checks screen order and parentage, semantic calendar buttons, control names, visible focus indicators, computed geometry, overflow, and PNG dimensions before updating the evidence images.

Example isolated setup, without adding dependencies to the Hajnal project:

```sh
HAJNAL_VERIFY_DIR="$(mktemp -d)"
npm install --prefix "$HAJNAL_VERIFY_DIR/node" playwright@1.55.0
PLAYWRIGHT_BROWSERS_PATH="$HAJNAL_VERIFY_DIR/browsers" \
  "$HAJNAL_VERIFY_DIR/node/node_modules/.bin/playwright" install chromium
PLAYWRIGHT_BROWSERS_PATH="$HAJNAL_VERIFY_DIR/browsers" \
HAJNAL_PLAYWRIGHT_MODULE="file://$HAJNAL_VERIFY_DIR/node/node_modules/playwright/index.mjs" \
  node docs/prototypes/hajnal_ui_browser_test.mjs
```

The command above is read-only for committed evidence and renders into an automatically removed temporary directory. To intentionally refresh the nine committed images after an approved UI change, add `HAJNAL_UPDATE_EVIDENCE=1` to the final command.

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

For every screen, `scrollHeight === clientHeight` and `scrollWidth === clientWidth` after accounting for the 1 px phone border. Every committed individual PNG is independently asserted to be exactly `412 × 892px`.

## Visual comparison result

The eight component screenshots were compared directly with `onboarding.png`, `designnkovetelmenyek.png`, `logo.png`, and the secondary first-page references documented in `REFERENCE_ANALYSIS.md`.

- Mandatory palette values are exact CSS tokens.
- Cards, choices, fields, and CTAs retain finite box radii; full pills are limited to switches and circular state controls.
- Light surfaces use low-contrast 1 px lavender borders and restrained shadows.
- The three scenic screens use flat geometric layers and a recognizable panda/llama pair without texture.
- The Home screen keeps the scenic hero, two-part metrics card, five tasks, check-in/support actions, and the five-destination bottom navigation within the viewport.
- The full-page overview confirms the required root/child ordering and the icon-plus-description header above the row.
- The Splash transition annotation stays in the external prototype label rather than appearing inside product UI.

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
