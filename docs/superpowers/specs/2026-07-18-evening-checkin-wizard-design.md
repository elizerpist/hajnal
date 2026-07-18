# Evening Check-in Wizard Design

## Goal

Replace the two writing-oriented home checklist items with a single `Esti check-in` entry and turn the evening path into a multi-screen wizard inserted directly after screen 11, before the remaining check-in/support/task screens.

## Sources

- User instruction: `most a főmenuvel foglalkozol...`
- User approval: `ok`
- Current prototype: `docs/prototypes/hajnal_ui.html`
- Current static tests: `docs/prototypes/hajnal_ui_static_test.js`
- Acceptance checklist: `docs/acceptance/first_page_acceptance.md`
- Latest screenshot inspected directly: `/storage/emulated/0/Pictures/Screenshots/Screenshot_20260718-182658.png`

## Current State

- Home checklist currently contains `Írj 10 percet` and `Írj 3 dolgot, amiért hálás vagy`.
- Detailed `Mai feladatok` currently repeats those two rows and also has `Töltsd ki az esti check-int`.
- Current screen 10 is `daily-checkin`.
- Current screen 11 is `checkin-clean`, used from the home `Ma tiszta maradtam` dashboard button, and now auto-returns to `home`.
- Current screen 12 is `checkin-mood`.
- Current screen 13 is `checkin-craving`.
- Current screen 14 is `checkin-note`.
- Current screen 17 is `support-note`.

## Required Flow

### Home Checklist

The compact home checklist must remove:

- `Írj 10 percet`
- `Írj 3 dolgot, amiért hálás vagy`

It must add one checklist item:

- `Esti check-in`

The `Esti check-in` row opens the evening wizard. It must carry semantic routing metadata for both states:

- If the user has already pressed `Ma tiszta maradtam` from the home dashboard, the wizard starts at `evening-reflection`.
- If the user has not yet completed the clean-day check-in, the wizard starts at `daily-checkin`, then proceeds through the alternate reward screen before entering `evening-reflection`.

The detailed `Mai feladatok` list must mirror the same cleaned-up task model: no separate 10-minute writing row and no separate gratitude-three-things row; the evening check-in row becomes the single writing/reflection entry.

### Screen 10 and Screen 11

Screen 10, `daily-checkin`, remains the optional first step for users who have not already confirmed the clean day.

Screen 11, `checkin-clean`, remains the direct home-dashboard confirmation screen:

- no `Tovább` button
- `data-auto-return-target="home"`

### Alternate Screen 11

Add a duplicate reward screen immediately after screen 11:

- ID: `evening-clean-reward`
- Visible index: `11B`
- Parent: `daily-checkin`
- Same core reward visual language as screen 11
- Bottom CTA: `Tovább az esti reflexióhoz`
- CTA target: `evening-reflection`

This is the reward step used by the evening wizard when the user did not already confirm the clean day from the home dashboard.

### Evening Reflection

Replace current screen 12 with the combined evening reflection screen:

- ID: `evening-reflection`
- Visible index: `12`
- Parent: `home`
- Uses the fullscreen check-in hero background asset.

The screen contains sections based on the latest screenshot:

- Top section: mood selector with 1-5 smileys.
- Middle selector: three reflection prompt cards:
  - `Mi volt ma a legjobb?`
  - `Mi volt ma a legnehezebb?`
  - `Van valami, amit nem szeretnél elfelejteni?`
- Active selector state: one card is visibly active and the note textarea below uses the active card's content/placeholder.
- Bottom memo actions:
  - `Hála hozzáadása`
  - `Fotó`
  - `Hangjegyzet`
- Save path returns to `home`.

### Removed Screens

Remove the old standalone screens:

- Current screen 13 / `checkin-craving`
- Current screen 14 / `checkin-note`
- Current screen 17 / `support-note`

The old note-writing behavior moves into the combined `evening-reflection` screen. The `support-next-step` screen remains, but its sponsor-message option must no longer target removed `support-note`.

### New Helper Screens

Add these helper screens after `evening-reflection` and before the remaining relapse/support screens:

- `gratitude-add`, visible index `12A`: the `+ Hála hozzáadása` popup/screen with 1-3 gratitude inputs and a `Kész` path back to `evening-reflection`.
- `photo-memo`, visible index `12B`: image memo screen with camera/upload affordance, caption textarea, and a `Kész` path back to `evening-reflection`.
- `voice-memo`, visible index `12C`: voice memo screen with record/pause visual controls, transcript/note textarea, and a `Kész` path back to `evening-reflection`.

These are separate semantic prototype screens, not generated PNGs.

## Target Home Row Order

The second row must become:

`home daily-image daily-checkin checkin-clean evening-clean-reward evening-reflection gratitude-add photo-memo voice-memo checkin-relapse support-next-step checkin-survival-pack checkin-breathing checkin-motivation daily-tasks panic-mode`

The removed IDs must not appear in `data-row-screens`, `screenOrder`, or as `data-target-screen` values:

- `checkin-mood`
- `checkin-craving`
- `checkin-note`
- `support-note`

## Visual Direction

Use the existing fullscreen check-in image treatment for the evening wizard and preserve the quiet Hajnal palette. The layout should follow the latest screenshot structurally:

- white or glassy panel on top of the fullscreen background
- compact section headings
- 1-5 smiley row with one active state
- three prompt cards in the middle
- one textarea below whose placeholder represents the active prompt
- memo actions aligned along the bottom of the panel

Do not create PNG evidence or flatten screens into PNG images. Use HTML/CSS/SVG/internal assets only.

## Verification

Update static tests before implementation and verify red/green:

- home checklist no longer contains `Írj 10 percet` or `Írj 3 dolgot, amiért hálás vagy`
- home checklist contains `Esti check-in`
- detailed `Mai feladatok` mirrors the cleaned task list
- screen order matches the target row order
- removed screen IDs and removed targets are absent
- `evening-clean-reward` exists with `Tovább az esti reflexióhoz`
- `evening-reflection` contains mood 1-5, three selectors, active selector, textarea, save path, and memo action targets
- helper screens `gratitude-add`, `photo-memo`, and `voice-memo` exist with semantic inputs/controls
- no PNG files are created or updated

Run:

- `node docs/prototypes/hajnal_ui_static_test.js homeBranch`
- `node docs/prototypes/hajnal_ui_static_test.js all`
- `git diff --check`
- `git status --short docs/prototypes/verification docs/prototypes docs/acceptance docs/superpowers`

Restart the static server after implementation and verify:

- `curl -I --max-time 5 http://127.0.0.1:8768/hajnal_ui.html`
