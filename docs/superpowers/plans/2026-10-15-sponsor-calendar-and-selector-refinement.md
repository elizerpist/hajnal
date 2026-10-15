# Sponzor naptárnézetek és selector-finimítások Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A Gyűlések belépési és selector-geometriájának javítása mellett a Sponzor Legközelebb és Sponzorom mióta funkciói egységes, teljes képernyős naptárnézetekké válnak, app-lila Közös munkánk selectorral és FAB-okkal.

**Architecture:** A `HomeInteractionController` marad minden navigáció, kiválasztás és írás egyetlen tulajdonosa. A két Sponzor naptár route egy közös, paraméterezett naptár-renderelő és a meglévő `renderMonthCalendarCells()`, `halfHourTimeSlots()`, `isSponsorNextDateAvailable()` és `isSponsorNextTimeAvailable()` magra épül; nem marad párhuzamos bottom sheet vagy natív dátumpicker. A korábbi szponzori alkalmak kizárólag külön seed/mock megjelenítési rekordok, nem a Gyűlések vagy a profiladatok másolatai.

**Tech Stack:** Egyetlen HTML/CSS/vanilla JavaScript app shell; Node `assert` kontrakttesztek; meglévő Chromium/CDP runtime teszt és 412×892 screenshot-ellenőrzés.

## Global Constraints

- Kizárólag `html-prototypes/app-shell/index.html` változik a UI, állapot és navigáció számára; nem jön létre új alkalmazás, Flutter-implementáció vagy második controller.
- A Sponzor hero továbbra is `html-prototypes/app-shell/assets/hero/sponsor_hero_soft.png`; új artwork nem készül.
- A naptárbody felső koordinátája `var(--history-current-card-top)`; nem negatív margó vagy új statusbar-konstans igazítja.
- A `Legközelebb` nem nyithat slide-up sheetet; a `Sponzorom mióta` nem nyithat natív `input[type=date]` pickert.
- A Közös munkánk sínje és inaktív tabjai fehérek; mindkét aktív állapot és mindkét FAB `var(--hajnal-purple)`.
- A korábbi alkalmak csak olvasható mock/seed elemek. Nem kerülnek a Gyűlések state-be, nem módosítják a Sponzor-profilt és nem kapnak szerkesztő/törlő műveletet.
- A BottomNav az új `sponsor-next` és `sponsor-since-calendar` route-okon látható, a Sponzor marad aktív.
- A munka előtt és után az [elfogadási lista](../../prototypes/SPONSOR_WORKSPACE_ACCEPTANCE_CHECKLIST.md) SC-01–SC-09 sorai a tényleges evidence szerint frissülnek. Nem jelölhető `DONE` olyan vizuális/runtime feltétel, amelyhez nincs bizonyíték.

---

### Task 1: Kontraktusteszt és közös Sponzor-naptár állapotmodell

**Files:**
- Modify: `html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js`
- Modify: `html-prototypes/app-shell/tests/meetings_redesign_test.js`
- Modify: `html-prototypes/app-shell/tests/route_extensions_test.js`
- Modify: `html-prototypes/app-shell/index.html: NAVIGATION_ROUTES, HomeInteractionController constructor state, handleAction(), pathBack()/navigation helpers`

**Interfaces:**
- Consumes: `navigate(route)`, `syncMainNavigation()`, `renderMonthCalendarCells(options)`, `halfHourTimeSlots()`, `isSponsorNextDateAvailable(value)`, `isSponsorNextTimeAvailable(dateValue, time)`.
- Produces: `openSponsorNextCalendar()`, `openSponsorSinceCalendar()`, `closeSponsorCalendar()`, `selectSponsorCalendarDate(value)`, `selectSponsorCalendarTime(value)`, `moveSponsorCalendarMonth(direction)`, `saveSponsorNextCalendar()`, `saveSponsorSinceCalendar()` and state records `sponsorCalendar` / `sponsorConversationHistory`.

- [x] **Step 1: Add the failing source contracts.**

  In `sponsor_contact_workspace_test.js`, replace the old sheet/green assertions with these precise contracts:

  ```js
  assert.match(html, /data-route="sponsor-next"/, 'Legközelebb must be a full route');
  assert.match(html, /data-route="sponsor-since-calendar"/, 'Sponzorom mióta must be a full route');
  assert.match(html, /const NAVIGATION_ROUTES = new Set\([^\n]*'sponsor-next'[^\n]*'sponsor-since-calendar'/, 'both Sponsor calendars must retain the shared BottomNav');
  assert.match(html, /sponsorCalendar:\s*null/, 'one controller-owned calendar selection state is required');
  assert.match(html, /sponsorConversationHistory:\s*SPONSOR_CONVERSATION_SEED_ITEMS\.map/, 'past Sponsor occasions must come from a dedicated seed source');
  assert.match(html, /openSponsorNextCalendar\(\)/, 'Legközelebb must open the full calendar route');
  assert.match(html, /openSponsorSinceCalendar\(\)/, 'Sponzorom mióta must open the full calendar route');
  assert.doesNotMatch(html, /data-component="sponsor-next-sheet"/, 'the old next-conversation sheet must not remain mounted');
  assert.doesNotMatch(html, /data-sponsor-date-input/, 'the Sponsor detail must not contain a native date picker');
  assert.match(html, /\.sponsor-work-tab\[aria-selected="true"\][^{]*\{[^}]*background:\s*var\(--hajnal-purple\)/, 'both active work tabs must use app purple');
  assert.doesNotMatch(html, /sponsor-work-tab\[data-sponsor-work-tab="takeaways"\]\[aria-selected="true"\][^{]*\{[^}]*hajnal-mint/, 'Takeaways must not retain a mint active exception');
  assert.doesNotMatch(html, /sponsor-work-screen\[data-sponsor-work-tab="takeaways"\]\s+\.sponsor-work-fab[^{]*\{[^}]*hajnal-mint/, 'the takeaway FAB must not retain a mint exception');
  ```

  In `meetings_redesign_test.js`, append:

  ```js
  includes('.meetings-inline-view-switch { position: absolute; z-index: 8; top: 32px;', 'Meetings selector must align with History at 32px');
  assert.doesNotMatch(html, /\.meetings-main-content\s*\{[^}]*animation:\s*meetings-body-in/, 'Meetings body must not slide upward when entering the route');
  assert.doesNotMatch(html, /@keyframes meetings-body-in/, 'the obsolete route-entry keyframes must be removed');
  ```

  In `route_extensions_test.js`, add direct navigation assertions after existing main-route checks:

  ```js
  controller.navigate('sponsor-next');
  assert.equal(mainNavigation.hidden, false, 'Next conversation calendar must retain BottomNav');
  assert.equal(sponsorNav.getAttribute('aria-current'), 'page', 'Sponsor stays active on next conversation calendar');
  controller.navigate('sponsor-since-calendar');
  assert.equal(mainNavigation.hidden, false, 'Sponsor since calendar must retain BottomNav');
  assert.equal(sponsorNav.getAttribute('aria-current'), 'page', 'Sponsor stays active on since calendar');
  ```

- [x] **Step 2: Run the contracts in RED state.**

  Run:

  ```sh
  node html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js
  node html-prototypes/app-shell/tests/meetings_redesign_test.js
  ```

  Expected: `AssertionError` for the absent route/state/action contracts and obsolete sheet/green selector behavior.

- [x] **Step 3: Define the only new state shapes and seed records.**

  Place a frozen `SPONSOR_CONVERSATION_SEED_ITEMS` constant alongside the other Sponsor constants, using stable IDs and dates that precede the prototype’s current date context:

  ```js
  const SPONSOR_CONVERSATION_SEED_ITEMS = Object.freeze([
    Object.freeze({ id: 'sponsor-conversation-seed-2026-09-18', date: '2026-09-18', time: '18:30', note: 'Beszéltünk arról, mi segít a nehezebb napokon.' }),
    Object.freeze({ id: 'sponsor-conversation-seed-2026-09-30', date: '2026-09-30', time: '19:00', note: 'Átnéztük, mit szeretnék a következő héten gyakorolni.' }),
    Object.freeze({ id: 'sponsor-conversation-seed-2026-10-08', date: '2026-10-08', time: '17:30', note: 'Röviden visszanéztük az elmúlt napok tapasztalatait.' }),
  ]);
  ```

  Add exactly these state fields in the controller’s initial state:

  ```js
  sponsorCalendar: null,
  sponsorConversationHistory: SPONSOR_CONVERSATION_SEED_ITEMS.map((item) => ({ ...item })),
  ```

  `sponsorCalendar` must have these route-specific shapes only:

  ```js
  // Next conversation
  { kind: 'next', calendarMonth, selectedDate, selectedTime }
  // Sponsor since
  { kind: 'since', calendarMonth, selectedDate, initialDate }
  ```

- [x] **Step 4: Extend one existing navigation owner.**

  Add both strings to `NAVIGATION_ROUTES`, make `syncMainNavigation()` treat `sponsor-next` and `sponsor-since-calendar` as Sponzor-active routes, and add `handleAction()` cases for the controller methods produced above. `closeSponsorCalendar()` must navigate to `sponsor` for `kind: 'next'` and `sponsor-details` for `kind: 'since'`, then clear `state.sponsorCalendar` without writing profile or next-conversation data.

- [x] **Step 5: Run the focused contracts in GREEN state.**

  Run:

  ```sh
  node html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js
  node html-prototypes/app-shell/tests/meetings_redesign_test.js
  node html-prototypes/app-shell/tests/route_extensions_test.js
  ```

  Expected: all three print their existing `PASS ...` messages and have no assertion error.

- [ ] **Step 6: Commit the isolated contract/state slice.** — deliberately not committed: the shared worktree contains unrelated user changes.

  ```sh
  git add html-prototypes/app-shell/index.html html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js html-prototypes/app-shell/tests/meetings_redesign_test.js html-prototypes/app-shell/tests/route_extensions_test.js
  git commit -m "feat: add sponsor calendar route state"
  ```

### Task 2: Remove the Gyűlések entry animation and correct shared selector geometry

**Files:**
- Modify: `html-prototypes/app-shell/index.html: meetings CSS around .meetings-inline-view-switch and .meetings-main-content`
- Modify: `html-prototypes/app-shell/tests/meetings_redesign_test.js`

**Interfaces:**
- Consumes: the existing History selector landmark `top: 32px`.
- Produces: a static Meetings route body that retains the existing list/calendar renderers and scroll owner.

- [x] **Step 1: Keep the Task 1 failing regression assertions and run the focused test.**

  Run:

  ```sh
  node html-prototypes/app-shell/tests/meetings_redesign_test.js
  ```

  Expected: RED while `.meetings-inline-view-switch` remains at `top: 42px` and `.meetings-main-content` declares `meetings-body-in`.

- [x] **Step 2: Replace only the route-entry geometry and animation.**

  Change the selector declaration to the same top landmark as History and remove the body-entry animation/keyframes:

  ```css
  .meetings-inline-view-switch {
    position: absolute;
    z-index: 8;
    top: 32px;
    right: 20px;
    pointer-events: auto;
  }

  .meetings-main-content {
    z-index: 2;
    top: var(--meetings-body-top);
    padding: 0 18px 22px;
    overflow-y: auto;
    overscroll-behavior-y: contain;
  }
  ```

  Delete `@keyframes meetings-body-in` and remove only the corresponding animation clause from the reduced-motion declaration. Do not change the meeting-form-sheet animation, the list’s fixed/scroll split, or the calendar interaction.

- [x] **Step 3: Run the focused contract and CSS sanity check.**

  ```sh
  node html-prototypes/app-shell/tests/meetings_redesign_test.js
  git diff --check
  ```

  Expected: the test prints `PASS meetings redesign domain and UI boundary contract`; whitespace check is empty.

- [ ] **Step 4: Commit the isolated Gyűlések visual behavior change.** — deliberately not committed: the shared worktree contains unrelated user changes.

  ```sh
  git add html-prototypes/app-shell/index.html html-prototypes/app-shell/tests/meetings_redesign_test.js
  git commit -m "fix: align meetings selector and remove entry slide"
  ```

### Task 3: Normalize the Közös munkánk selector and action colors

**Files:**
- Modify: `html-prototypes/app-shell/index.html: sponsor-work CSS and renderSponsorWork()/setSponsorWorkTab()`
- Modify: `html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js`

**Interfaces:**
- Consumes: `--white`, `--hairline`, `--hajnal-purple`, `setSponsorWorkTab(tab)` and the current `sponsorWorkTab` state.
- Produces: one color system where active tabs and both creation FABs use the shared app-purple token.

- [x] **Step 1: Run the Task 1 sponsor contract to confirm the legacy mint rules fail.**

  ```sh
  node html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js
  ```

  Expected: RED until no Takeaways-only mint selector/FAB override remains.

- [x] **Step 2: Apply the shared lila selector/FAB rules.**

  Use the following CSS, preserving existing radius, size, focus and touch target behavior:

  ```css
  .sponsor-work-tabs {
    min-height: 46px;
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 4px;
    padding: 4px;
    border: 1px solid var(--hairline);
    border-radius: 17px;
    background: var(--white);
    box-shadow: 0 3px 9px rgba(44,46,119,.035);
  }
  .sponsor-work-tab {
    min-width: 0;
    min-height: 38px;
    padding: 0 8px;
    border: 1px solid rgba(106,86,180,.14);
    border-radius: 13px;
    background: var(--white);
    color: var(--hajnal-purple);
    font: inherit;
    font-size: 12px;
    line-height: 1.1;
    font-weight: 760;
    cursor: pointer;
  }
  .sponsor-work-tab[aria-selected="true"] {
    border-color: var(--hajnal-purple);
    background: var(--hajnal-purple);
    color: var(--white);
    box-shadow: 0 3px 9px rgba(44,46,119,.15);
  }
  .sponsor-work-fab {
    background: var(--hajnal-purple);
    color: var(--white);
    box-shadow: 0 10px 22px rgba(74,55,150,.24);
  }
  ```

  Remove the two `[data-sponsor-work-tab="takeaways"]` / `[data-sponsor-work-tab="takeaways"] .sponsor-work-fab` mint-specific rules. In `setSponsorWorkTab()`, remove only style assignments whose sole purpose is a green takeaway tab/FAB; do not alter the selected tab state, labels, aria state or add actions.

- [x] **Step 3: Verify the contract and source-color ownership.**

  ```sh
  node html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js
  rg -n "sponsor-work.*hajnal-mint|hajnal-mint.*sponsor-work" html-prototypes/app-shell/index.html
  ```

  Expected: contract PASS; the `rg` command has no output.

- [ ] **Step 4: Commit the selector/FAB palette slice.** — deliberately not committed: the shared worktree contains unrelated user changes.

  ```sh
  git add html-prototypes/app-shell/index.html html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js
  git commit -m "fix: unify sponsor work controls in app purple"
  ```

### Task 4: Render one reusable full-screen Sponzor-naptár surface

**Files:**
- Modify: `html-prototypes/app-shell/index.html: route markup, Sponsor calendar CSS, HomeInteractionController calendar rendering methods`
- Modify: `html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js`

**Interfaces:**
- Consumes: `renderMonthCalendarCells(options)`, `sponsorNextDateObject(value)`, `sponsorNextMonthKey(value)`, `formatSponsorNextDate(value, options)`, `isSponsorNextDateAvailable(value)`, `isSponsorNextTimeAvailable(date, time)`, `firstSponsorNextTimeForDate(date, preferred)`, `halfHourTimeSlots()`.
- Produces: `renderSponsorCalendarRoute()`, `renderSponsorCalendarMonth(calendar)`, `renderSponsorCalendarTimeSlots(calendar)`, `renderSponsorConversationHistory()`.

- [x] **Step 1: Add explicit RED contracts for shared route rendering.**

  Add the following to `sponsor_contact_workspace_test.js`:

  ```js
  assert.match(html, /renderSponsorCalendarRoute\(\)/, 'one renderer must choose the next/since full-screen content');
  assert.match(html, /renderMonthCalendarCells\(\{[\s\S]*?action: 'select-sponsor-calendar-date'/, 'both Sponsor calendars must use the existing calendar-cell builder');
  assert.match(html, /halfHourTimeSlots\(\)/, 'the next calendar must reuse the shared half-hour slots');
  assert.match(html, /data-component="sponsor-calendar-history"/, 'the next calendar must expose the read-only past-occurrence list');
  assert.match(html, /\.sponsor-calendar-content\s*\{[^}]*top:\s*var\(--history-current-card-top\)/, 'calendar content must share the Sponsor card landmark');
  assert.match(html, /assets\/hero\/sponsor_hero_soft\.png/, 'calendar routes must retain the Sponsor hero asset');
  ```

- [x] **Step 2: Add semantic route markup with no nested scroll owner.**

  Add two sibling route sections, both reusing the same hero asset and a `data-component="sponsor-calendar-content"` body. The full next route must use these semantic targets:

  ```html
  <section class="route-screen sponsor-calendar-screen" data-route="sponsor-next" aria-labelledby="sponsor-next-title">
    <section class="sponsor-hero" aria-hidden="true"><img src="assets/hero/sponsor_hero_soft.png" alt=""></section>
    <header class="sponsor-calendar-header"><button type="button" data-action="close-sponsor-calendar" aria-label="Vissza a Sponzorhoz">…</button><h1 id="sponsor-next-title">Legközelebb</h1></header>
    <main class="sponsor-calendar-content" data-component="sponsor-calendar-content" data-sponsor-calendar-kind="next"></main>
  </section>
  ```

  The since route has the same structure, `data-route="sponsor-since-calendar"`, `id="sponsor-since-calendar-title"`, and heading `Sponzorom mióta`. It must use the same `sponsor-calendar-content` class; only one route is visible at a time.

  Define the shared surface:

  ```css
  .sponsor-calendar-screen { --sponsor-calendar-body-top: var(--history-current-card-top); background: var(--screen-background); }
  .sponsor-calendar-content { position: absolute; z-index: 2; top: var(--sponsor-calendar-body-top); right: 0; bottom: var(--bottom-nav-h); left: 0; overflow-y: auto; overscroll-behavior-y: contain; padding: 0 18px calc(24px + env(safe-area-inset-bottom)); }
  ```

  Use one scroll owner: no inner `overflow-y:auto` on the calendar grid, time slots, or history list.

- [x] **Step 3: Implement one parameterized renderer.**

  `renderSponsorCalendarRoute()` must read `this.state.sponsorCalendar`, select the correct visible route host, and set one host’s content with three helpers:

  ```js
  renderSponsorCalendarRoute() {
    const calendar = this.state.sponsorCalendar;
    if (!calendar) return;
    const host = this.root.querySelector(`[data-route="${calendar.kind === 'next' ? 'sponsor-next' : 'sponsor-since-calendar'}"] [data-component="sponsor-calendar-content"]`);
    if (!host) return;
    host.innerHTML = `${this.renderSponsorCalendarMonth(calendar)}${calendar.kind === 'next' ? `${this.renderSponsorCalendarTimeSlots(calendar)}${this.renderSponsorConversationHistory()}` : this.renderSponsorSinceCalendarFooter(calendar)}`;
  }
  ```

  `renderSponsorCalendarMonth(calendar)` calls `renderMonthCalendarCells()` once with `action: 'select-sponsor-calendar-date'`, data attribute `data-sponsor-calendar-date`, and `selectable` equal to `isSponsorNextDateAvailable(value)` only for `kind === 'next'`; the `since` calendar accepts valid ISO days. Month arrows dispatch `move-sponsor-calendar-month` with `data-calendar-direction="-1"` or `"1"`.

  `renderSponsorCalendarTimeSlots(calendar)` only runs for `kind === 'next'`, maps `halfHourTimeSlots()`, disables every `!isSponsorNextTimeAvailable(calendar.selectedDate, time)`, and renders a `data-action="save-sponsor-next-calendar"` button disabled until both selected fields are valid.

  `renderSponsorConversationHistory()` sorts `state.sponsorConversationHistory` descending by `date` then `time`, escapes its note text, and returns only read-only `<article>` records under `data-component="sponsor-calendar-history"`.

- [x] **Step 4: Verify shared renderer contracts.**

  ```sh
  node html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js
  git diff --check
  ```

  Expected: contract PASS and no whitespace errors.

- [ ] **Step 5: Commit the full-screen visual route slice.** — deliberately not committed: the shared worktree contains unrelated user changes.

  ```sh
  git add html-prototypes/app-shell/index.html html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js
  git commit -m "feat: add shared sponsor calendar surfaces"
  ```

### Task 5: Replace old sheet/date-picker actions with safe full-screen selection

**Files:**
- Modify: `html-prototypes/app-shell/index.html: Sponsor main/details markup; handleAction(); input handling; next/since controller methods; old sheet markup/CSS/methods`
- Modify: `html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js`
- Modify: `html-prototypes/app-shell/tests/sponsor_contact_workspace_runtime_test.js`

**Interfaces:**
- Consumes: Task 1 state/method interfaces and Task 4 route renderer.
- Produces: safe `nextConversation` writes on explicit save and safe `sponsorDraft.since` writes on explicit confirmation.

- [x] **Step 1: Replace the entry actions and delete the old UI path.**

  Change the main quick action from:

  ```html
  data-action="open-sponsor-next-sheet"
  ```

  to:

  ```html
  data-action="open-sponsor-next-calendar"
  ```

  Change the Sponzorom mióta row from `data-action="open-sponsor-date-picker"` to `data-action="open-sponsor-since-calendar"`. Remove the hidden/native `data-sponsor-date-input` and its `handleInput()` branch. Remove the `data-component="sponsor-next-sheet"` markup, `.sponsor-next-sheet*` CSS, overlay wiring and methods `openSponsorNextSheet`, `closeSponsorNextSheet`, `renderSponsorNextSheet`, `renderSponsorNextDateStep`, `renderSponsorNextTimeStep`, `openSponsorNextTimeStep`, `openSponsorNextDateStep`, `selectSponsorNextTimePart`, and `openSponsorDatePicker`.

- [x] **Step 2: Implement the opening and selection transitions.**

  Use these semantics exactly:

  ```js
  openSponsorNextCalendar() {
    const current = this.state.nextConversation;
    const selectedDate = current?.date && this.isSponsorNextDateAvailable(current.date) ? current.date : null;
    this.state.sponsorCalendar = {
      kind: 'next',
      calendarMonth: this.sponsorNextMonthKey(selectedDate || localDateIso()),
      selectedDate,
      selectedTime: selectedDate ? this.firstSponsorNextTimeForDate(selectedDate, current?.time || '') : '',
    };
    this.navigate('sponsor-next');
    this.renderSponsorCalendarRoute();
  }

  openSponsorSinceCalendar() {
    const initialDate = this.getSponsorDraft().since || localDateIso();
    this.state.sponsorCalendar = { kind: 'since', initialDate, selectedDate: initialDate, calendarMonth: this.sponsorNextMonthKey(initialDate) };
    this.navigate('sponsor-since-calendar');
    this.renderSponsorCalendarRoute();
  }
  ```

  `selectSponsorCalendarDate(value)` validates ISO dates; it uses availability only for `kind === 'next'`, recalculates `selectedTime` through `firstSponsorNextTimeForDate()` for next, and rerenders. `selectSponsorCalendarTime(value)` accepts only a next calendar, only a selected date, and only an available half-hour time. `moveSponsorCalendarMonth(direction)` changes the month exactly one calendar month then rerenders.

- [x] **Step 3: Implement only explicit write points.**

  ```js
  saveSponsorNextCalendar() {
    const calendar = this.state.sponsorCalendar;
    if (!calendar || calendar.kind !== 'next' || !calendar.selectedDate || !this.isSponsorNextTimeAvailable(calendar.selectedDate, calendar.selectedTime)) return;
    this.state.nextConversation = { date: calendar.selectedDate, time: calendar.selectedTime, isInitial: false };
    this.state.sponsorCalendar = null;
    this.renderSponsorNextCard();
    this.navigate('sponsor');
  }

  saveSponsorSinceCalendar() {
    const calendar = this.state.sponsorCalendar;
    if (!calendar || calendar.kind !== 'since' || !this.sponsorNextDateObject(calendar.selectedDate)) return;
    this.getSponsorDraft().since = calendar.selectedDate;
    this.state.sponsorCalendar = null;
    this.renderSponsorDetails();
    this.navigate('sponsor-details');
  }
  ```

  `closeSponsorCalendar()` must never call either save method. It clears local calendar state then navigates to `sponsor` or `sponsor-details` according to `kind`. The existing `clearSponsorNextConversation()` remains a deliberate delete-like action from the Sponzor main/details workflow only if it has a visible, explicit future home; otherwise remove that unreachable sheet-only action rather than creating a new erase control in this scope.

- [x] **Step 4: Add runtime assertions that prove no accidental writes.**

  Extend `sponsor_contact_workspace_runtime_test.js` with this flow:

  ```js
  // Enter and abandon next route: existing nextConversation stays intact.
  await tap('[data-action="open-sponsor-next-calendar"]');
  await expectRoute('sponsor-next');
  await tap('[data-action="close-sponsor-calendar"]');
  await expectRoute('sponsor');
  assert.deepEqual(readControllerState('nextConversation'), initialNextConversation);

  // Enter since route, choose a date, leave with Back: sponsor draft is unchanged.
  await tap('[data-action="open-sponsor-details"]');
  await tap('[data-action="open-sponsor-since-calendar"]');
  await tap('[data-sponsor-calendar-date="2026-09-16"]');
  await tap('[data-action="close-sponsor-calendar"]');
  assert.equal(readSponsorDraftSince(), initialSponsorDraftSince);
  ```

  Then select an available date/time on `sponsor-next`, press `save-sponsor-next-calendar`, and assert `nextConversation` equals the selected pair; select a since date, press `save-sponsor-since-calendar`, and assert the draft display changed while the persisted `state.sponsor.since` remains unchanged before the details form itself is saved.

- [ ] **Step 5: Run focused static/runtime verification.** — static verification is green; Playwright/Chromium is unavailable on this Android host.

  ```sh
  node html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js
  node html-prototypes/app-shell/tests/route_extensions_test.js
  node html-prototypes/app-shell/tests/sponsor_contact_workspace_runtime_test.js
  ```

  Expected: all target tests PASS. If the runtime command is unavailable because its browser dependency is absent, record the exact missing executable/package and leave the related acceptance evidence `PARTIAL`; do not claim runtime completion.

- [ ] **Step 6: Commit the safe-action replacement.** — deliberately not committed: the shared worktree contains unrelated user changes.

  ```sh
  git add html-prototypes/app-shell/index.html html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js html-prototypes/app-shell/tests/sponsor_contact_workspace_runtime_test.js
  git commit -m "feat: move sponsor scheduling into full calendar routes"
  ```

### Task 6: Final verification, visual evidence, and honest checklist update

**Files:**
- Modify: `docs/prototypes/SPONSOR_WORKSPACE_ACCEPTANCE_CHECKLIST.md`
- Create: `docs/prototypes/verification/sponsor-calendar/01-next-calendar.png`
- Create: `docs/prototypes/verification/sponsor-calendar/02-next-calendar-time.png`
- Create: `docs/prototypes/verification/sponsor-calendar/03-since-calendar.png`
- Create: `docs/prototypes/verification/sponsor-calendar/04-meetings-list.png`
- Create: `docs/prototypes/verification/sponsor-calendar/05-sponsor-work-takeaways.png`

**Interfaces:**
- Consumes: completed Tasks 1–5.
- Produces: evidence for SC-01 through SC-09 and no unverified `DONE` claim.

- [x] **Step 1: Run every static app-shell contract.**

  ```sh
  git diff --check
  for test_file in html-prototypes/app-shell/tests/*_test.js; do
    case "$test_file" in
      *_runtime_test.js) continue ;;
    esac
    node "$test_file" || exit 1
  done
  ```

  Expected: no diff whitespace error and every static test emits its PASS line.

- [ ] **Step 2: Capture the required 412×892 visual states.** — BLOCKED: Playwright reports `Unsupported platform: android`; no local Chromium executable is available.

  With the existing runtime harness, capture:

  1. `sponsor-next`: selected date, visible time slots, and the mock `Korábbi alkalmaink` cards;
  2. `sponsor-next`: selected time and enabled Mentés;
  3. `sponsor-since-calendar`: selected date and visible Back action;
  4. Gyűlések list route, proving no initial body offset/slide and selector top alignment with History;
  5. Közös munkánk Útravalóim tab, proving a purple active tab and purple FAB.

  Use a 412×892 viewport and write files to the five exact `docs/prototypes/verification/sponsor-calendar/` paths above.

- [ ] **Step 3: Measure geometry rather than relying on appearance.** — BLOCKED with the same unavailable Chromium runtime; the shared 32px/top-token contracts are statically verified.

  In the browser context, compare:

  ```js
  const historyTop = document.querySelector('.history-inline-view-switch').getBoundingClientRect().top;
  const meetingsTop = document.querySelector('.meetings-inline-view-switch').getBoundingClientRect().top;
  if (Math.abs(historyTop - meetingsTop) > 2) throw new Error(`Selector top mismatch: ${historyTop}px vs ${meetingsTop}px`);
  ```

  Also assert that `.meetings-main-content` has computed `animationName === 'none'` or an empty computed animation name.

- [x] **Step 4: Update SC-01–SC-09 honestly.**

  Mark an item `DONE` only with its linked command/screenshot/measurement. If physical Android Chrome is still unavailable, preserve `PARTIAL` for the device-specific visual/gesture aspect while recording passing Chromium evidence. Update the evidence section with exact test command outputs and screenshot paths; remove obsolete claims that `05-sponsor-next-sheet.png` proves the current scheduling UX.

- [ ] **Step 5: Commit the verified evidence and checklist.** — deliberately not committed: the shared worktree contains unrelated user changes.

  ```sh
  git add docs/prototypes/SPONSOR_WORKSPACE_ACCEPTANCE_CHECKLIST.md docs/prototypes/verification/sponsor-calendar html-prototypes/app-shell/index.html html-prototypes/app-shell/tests
  git commit -m "test: verify sponsor calendar and selector refinements"
  ```
