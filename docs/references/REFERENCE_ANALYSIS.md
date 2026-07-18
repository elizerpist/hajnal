# Hajnal PNG reference analysis

## Purpose and precedence

This document records the direct visual inspection of all seven project PNGs. It supplements but never replaces reopening the relevant images before work.

- The written specification controls information architecture, menu logic, screen relationships, content, and behavior.
- The PNGs control visual language: component shape, radii, color, gradient direction, border treatment, shadow softness, spacing rhythm, typography character, icon treatment, illustration style, and density.
- Raster collage dimensions are measurement inputs, not app viewport sizes. All implemented screens use the independently mandated `412px × 892px` viewport from `color_lab.html`.

## Analysis method

Each image was opened at original resolution. ImageMagick was used to verify dimensions, extract quantized color histograms, sample the six palette swatches at their center pixels, and compare source/project SHA-256 hashes. Visible geometry was measured against each collage's phone-panel width and normalized to the `412px` target width.

The collages compress screens into different thumbnail ratios. Therefore literal thumbnail coordinates must not be stretched into the app. Shape categories and relative hierarchy are retained, while target measurements are normalized through the shared token table below.

## File manifest

| File | Pixels | Contents | SHA-256 |
|---|---:|---|---|
| `logo.png` | 1254 × 1254 | Master Hajnal app icon | `c2b98473a980d83d999efa8f5cdbc38a843cec925db6c997b5d26b182279c358` |
| `onboarding.png` | 1536 × 1024 | Splash/welcome, onboarding setup, and Home references | `a72ac40a6f7ca052156e48ff349f40c35c3bb10ed9e107728227da569e48466c` |
| `designnkovetelmenyek.png` | 1536 × 1024 | Brand board, mandatory palette, semantic illustration meaning, global screen references | `8b28b20ecc9dd8a36bd9440e24f7e6861a42849bf5f6e1eefaf54cea1bad7064` |
| `checkin_visszaeses_panik.png` | 1536 × 1024 | Check-in, relapse, restart, support, panic, and survival flow | `5527ec5e16d912e078576d98c49f6dfc58f315e12dbcb191cf86610ce74c64c9` |
| `haladas_naptar_stat.png` | 1536 × 1024 | Progress overview, 90-day grid, calendar, statistics, milestones | `11bf474d69fb685a404a1840c26321c06ec27110ca977408fa28f8e7aab3dc5a` |
| `eszkozok_12lepes_naplo.png` | 1536 × 1024 | Tools, workbook, journal, craving log | `4a79b93977c44035dcce8b7c86f7c7d778836d4be0436dcbfe566955e2d2f767` |
| `sponzor_profil_beallitasok.png` | 1536 × 1024 | Sponsor, profile, notification, appearance, privacy | `04ff7aeafd1408b0cacbb7dcb08e50242516e73de86a24fdd911de12a85d3efc` |

## Mandatory palette

The six `designnkovetelmenyek.png` swatches were sampled at their center pixels:

| Token | Pixel | Required role |
|---|---|---|
| `--hajnal-navy` | `#2C2E77` | Primary text, deep landscape, dark emphasis |
| `--hajnal-purple` | `#6A56B4` | Primary controls, active states, mid-gradient |
| `--hajnal-lavender` | `#B89AD7` | Secondary surfaces, decorative gradients, soft states |
| `--hajnal-pink` | `#F18EAF` | Warm accent, compassionate high-emphasis action |
| `--hajnal-peach` | `#FEC884` | Dawn light, milestones, warm semantic accent |
| `--hajnal-cream` | `#FCF0F0` | Base warm surface and pale cards |

Supporting pixels observed in the references:

- page blush around `#FDF5F8`;
- onboarding neutral screen surface around `#F7F0F5`;
- elevated card interior around `#FEFBFA`;
- common violet CTA around `#5E56BB`;
- deep panic surface around `#434582`;
- panic action pink around `#F15990`;
- completed-day green around `#59986C`.

Supporting colors may be adjusted only within the reference family. The six mandatory swatches may not be substituted.

## Normalized geometry system

Measurements across the six collages show the same shape hierarchy despite different thumbnail scales. Target tokens for the `412 × 892` phones are:

| Element category | Target geometry | Reference evidence |
|---|---|---|
| Phone viewport | `412 × 892px`; `34px` radius | `color_lab.html` uses 412 × 892 and 34px; PNG phones show approximately 26–31px normalized rounding |
| Screen side inset | `20–24px` | Repeated content-to-phone proportions in all collages |
| Large sheet/card | `20–22px` radius | Home/check-in sheets and profile surfaces |
| Standard rounded box | `16px` radius | Onboarding choices, notification rows, settings rows, statistic cards |
| Compact card/input | `12–14px` radius | Calendar cells, compact fields, journal/search surfaces |
| Primary CTA | `16–18px` radius; never full pill | Onboarding, restart, save, continue buttons |
| Large choice button | `16px` radius | Check-in success/relapse and sponsor setup choices |
| Toggle/segmented filter | Full pill is permitted | Notification switches and compact filter rails only |
| Circular state/day/mood | `50%` radius | Radios, day nodes, emotion selectors, round emergency control |
| Hairline border | `1px` low-contrast lavender/blush | Cards and inputs across all light screens |
| Shadow | Low-opacity, broad blur, short vertical offset | Sheets float gently; no hard material shadow |
| Status bar | Approximately `28–32px` high | All phone references show 9:41 and compact system icons |
| Bottom navigation | Approximately `64–72px` high | Five equal destinations on main-shell screens |

Corner radii are attached to component categories. A rounded box must not be converted to a pill simply because its width changes.

## Shared visual grammar

- Typography is rounded-geometric, dark navy, and high-contrast without harsh black. Titles are centered on setup screens and left/centered according to the reference family on main screens.
- Primary buttons use violet or violet gradients with white text. Pink is reserved for compassionate emphasis, check-in, and emergency/support actions.
- Cards are warm white, not cold gray. Separators are thin and low contrast.
- Icons are simple outlined glyphs with occasional filled active states. Emoji may not replace the illustrated icon language.
- Landscapes use 3–5 large overlapping geometric layers, a soft sun/moon disk, sparse trees/stars, and no high-frequency texture.
- The panda and llama have minimal facial detail and smooth vector masses. The panda represents the user; the llama represents support/connection.
- Main-screen bottom navigation is five columns in this exact specification order: Kezdőlap, Haladás, Eszközök, Szponzor, Profil.
- Dark scenic headers transition into light card sheets; light form screens use a blush wash with quiet white cards.

## Image-by-image inspection

### `logo.png`

- A square icon with a large rounded-square artboard and generous surrounding white margin.
- Background gradient runs from violet at the top through pink/coral into warm dawn near the horizon.
- A pale yellow sun is centered behind the panda head.
- Two lavender mid-ground hills and two deep navy foreground hills create five calm horizontal depth bands.
- Panda geometry is symbolic: two round ears, one warm-white head oval, one dark torso oval, and two small dark arms. There is no face, fur texture, or outline-heavy cartoon treatment.
- The asset is the only raster allowed as an icon/brand asset in the first page. It must not be used as a flattened substitute for a whole screen.

### `onboarding.png`

Screen inventory, left-to-right and top-to-bottom:

1. Hajnal illustrated entry screen.
2. Welcome/onboarding message.
3. Important information and acceptance.
4. Start-date calendar.
5. Recovery goal.
6. Sponsor/support-person choice.
7. Notification setup.
8. Home.

Geometry and appearance:

- Four-column, two-row collage. The first-row phone thumbnails are approximately 341–351px wide and 493px high; second-row thumbnails are approximately 341–351px wide and 489px high.
- Entry screen is scenic edge-to-edge with the logo/name centered above a panda/llama dawn landscape. Its reference buttons are intentionally not copied to specification Splash.
- Welcome uses a tall arched illustration with a large continuous radius at the top, centered body copy, three compact pagination marks, and a rounded-box CTA.
- Information screen uses three separate stacked white rounded boxes, each with a lavender circular icon well. It does not use one giant text panel.
- Calendar is a large white rounded box; the selected day is circular. Quick-date selection is a separate rounded box below.
- Recovery goals are seven individual horizontal rounded boxes with circular radios; the box itself is not a pill.
- Sponsor choices are three large horizontal rounded boxes with a left icon and right circular state.
- Notification controls are five stacked rounded boxes with left icon, two-line label/time, and right pill toggle.
- Home combines a scenic header, a white streak card, a task sheet, two full-width rounded-box actions, and the five-item bottom navigation.

First-page use:

- Primary design reference for all eight first-row screens.
- Specification overrides its combined Splash/welcome behavior and missing Tegnap option.

### `designnkovetelmenyek.png`

Screen inventory:

1. Day-89 Home.
2. Daily check-in choice.
3. Journey/daily-image overview.
4. 90-day journey grid.
5. Panic entry.
6. Sponsor profile.
7. 12-step workbook question.
8. Profile.

Brand-board observations:

- App wordmark is dark navy; motto is pink.
- Mandatory palette is explicitly printed as six circular swatches.
- Logo reference isolates the dawn hills/sun/panda-ear motif.
- Motto presentation is a wide warm-white rounded box with decorative pink quotation marks, not a pill.
- Meaning section confirms panda=user and llama=program/support.
- Home and check-in use full scenic upper regions and light bottom sheets; utility screens use warm-white fields and consistent bottom navigation.

First-page use:

- Mandatory global palette and component-shape reference.
- Secondary Home reference, particularly the streak state, tasks, check-in action, and non-dominant panic action.

### `checkin_visszaeses_panik.png`

Screen inventory:

1. Evening check-in.
2. Successful-day confirmation plus mood reflection.
3. Relapse confirmation.
4. Restart date.
5. Support next steps.
6. Panic mode.
7. Fifteen-minute survival flow.

Geometry and appearance:

- Choice actions are large rounded boxes with left circular face/icon wells. Positive uses pale green; relapse uses pale blush; neither is presented as an error.
- White content sheets overlap the scenic illustration with large top radii.
- Relapse confirmation uses a white supportive sheet and pink primary CTA, never a red error surface.
- Restart options are full-width boxed rows with circular states and secondary descriptions.
- Panic mode is the single intentional dark full-screen utility surface. The central emergency control is circular with concentric soft rings; six alternatives are rounded-square grid tiles.
- The survival flow returns to a calm light surface, circular illustration, thin progress line, and standard rounded-box CTA.

Global use:

- Defines compassionate semantic colors, boxed choice geometry, emergency hierarchy, and non-punitive relapse language.

### `haladas_naptar_stat.png`

Screen inventory:

1. Progress overview.
2. 90-day grid.
3. Calendar/day summary.
4. Statistics overview.
5. Statistics detail.
6. Milestones.

Geometry and appearance:

- Overview begins with a split metric card and scenic landscape, followed by four boxed navigation rows.
- Day nodes are circular because they are discrete day states. Segmented filters are compact pills because they are filters.
- Calendar today is a filled circle; confirmed days use small green dots. Relapse is not visually shouted in red.
- Statistics use standard rounded rectangular cards, fine chart lines, small bars, and ample warm-white space.
- Milestones use a 3-column grid of rounded cards with separate illustration windows and small circular completion/lock states.

Global use:

- Confirms the strict distinction between circular state markers, pill filters, and rectangular data cards.

### `eszkozok_12lepes_naplo.png`

Screen inventory:

1. Tools home.
2. 12-step overview.
3. Workbook question.
4. Step summary.
5. Journal list.
6. New journal entry.
7. Craving log.
8. Journal detail.

Geometry and appearance:

- Tools home uses a scenic header and a 2-column grid of rectangular tool cards; Panic is a separate full-width row.
- Workbook steps are stacked rectangular cards. Step numbers are circles; lock/completion states are small circular/symbol controls.
- Question writing surface is a large rounded rectangle; microphone is circular; Previous/Next are rounded boxes.
- Summary answers are list rows inside one larger rounded rectangular group.
- Journal uses a rounded search field, pill tags, rectangular entries, and circular mood icons.
- New-entry metadata groups are rectangular surface sections. The craving slider thumb is circular because it is a range control.

Global use:

- Defines future form fields, large writing surfaces, list grouping, tags, and tool-grid geometry.

### `sponzor_profil_beallitasok.png`

Screen inventory:

1. Sponsor profile.
2. Contact log.
3. Quick messages.
4. Next meeting.
5. Profile.
6. Notifications.
7. Appearance.
8. Privacy and security.

Geometry and appearance:

- Sponsor profile overlaps a scenic header with a large white profile sheet. Call and Message are two equal rounded-box actions.
- Contact log and quick messages use stacked grouped rectangular rows; filter chips are compact pills.
- Meeting fields are one grouped rectangular form sheet with hairline separators and one standard CTA below.
- Profile repeats the scenic-header/light-sheet structure and five bottom destinations.
- Notification settings confirm row geometry: circular/outlined icon, two-line copy, and pill toggle inside a rectangular group.
- Appearance theme choices are rectangular preview cards; on/off settings remain rows with pill toggles.
- Privacy uses grouped rectangular rows and reserves pink/red only for the destructive account-data action.

First-page use:

- Secondary reference for Sponsor setup affordances and notification rows.
- Confirms that future settings remain accessible semantic controls inside rectangular groups.

## First-page mapping

| First-row component | Specification | Primary PNG | Secondary PNG |
|---|---|---|---|
| Splash | §5 Screen 1; §21 | `logo.png`, `onboarding.png` | `designnkovetelmenyek.png` |
| Onboarding | §5 Screen 2; §21 | `onboarding.png` | `logo.png` |
| Tájékoztatás | §5 Screen 3; §21 | `onboarding.png` | `designnkovetelmenyek.png` |
| Kezdődátum | §5 Screen 4; §21 | `onboarding.png` | `checkin_visszaeses_panik.png` |
| Felépülési cél | §5 Screen 5; §21 | `onboarding.png` | `eszkozok_12lepes_naplo.png` |
| Szponzor hozzáadása | §5 Screen 6; §21 | `onboarding.png` | `sponzor_profil_beallitasok.png` |
| Értesítések | §5 Screen 7; §21 | `onboarding.png` | `sponzor_profil_beallitasok.png` |
| Kezdőlap | §6 Screen 8; §21–22, §25 | `onboarding.png`, `designnkovetelmenyek.png` | all flow images for navigation consistency |

## Non-negotiable first-page conclusions

1. The row contains eight independently addressable web components in the approved hierarchy.
2. No phone screen may be implemented as a cropped or stretched PNG.
3. The six palette values are exact.
4. Rectangular cards, choice rows, inputs, and CTAs keep category-specific finite radii; they do not become pills.
5. Main navigation follows the specification even where a raster reference is incomplete.
6. Splash has no incorrect CTA; Onboarding owns the two welcome actions.
7. Home keeps Panic one tap away without allowing it to dominate the page.
