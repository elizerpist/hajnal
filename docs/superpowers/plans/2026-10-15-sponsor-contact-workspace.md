# Sponzor kapcsolati központ és Közös munkánk Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A Sponzor főmenü legyen hero-alapú kapcsolati központ, míg a meglévő megbeszélendő és útravaló gyűjtemény egyetlen, kétállású Közös munkánk route-ra kerüljön.

**Architecture:** A `HomeInteractionController` marad minden state és navigáció tulajdonosa. A `sponsor-work` csak a meglévő `state.sponsor`, `state.sponsorBackups`, `getPendingTopicEntries()` és `takeawayItems()` adatainak más renderelése; az egyetlen új állapot a lokális megjelenítési `sponsorWorkTab`. A következő beszélgetéshez, a híváshoz, az SMS-hez, a backup szerkesztőhöz és a takeaway szerkesztőhöz a meglévő útvonalakat és handlereket használjuk.

**Tech Stack:** Egyetlen HTML/CSS/vanilla JavaScript app shell, Node `assert` alapú kontrakttesztek, Chromium CDP mobil-emuláció, built-in image generation.

## Global Constraints

- A produkciós felület kizárólag `html-prototypes/app-shell/index.html`-ben él; nem készül Flutter, második prototípus vagy párhuzamos controller.
- A hero valódi, szöveg nélküli, projektbe mentett PNG: `assets/hero/sponsor_hero_soft.png`.
- A Sponzor profilkártya és a Gyűlések lista `Gyűléseim` kártyája ugyanazt a `--history-current-card-top` geometriát használja.
- A Közös munkánk nem új adatmodell: a meglévő pending → takeaway folyamatot és a meglévő szerkesztőket használja.
- A BottomNav egyetlen közös példány marad, a `sponsor-work` route-on is a Sponzor aktív.
- A fizikai Android Chrome csak akkor jelölhető késznek, ha tényleges eszköz elérhető; emuláció nem helyettesíti azt a checklistben.

---

### Task 1: Elfogadási és regressziós szerződés

**Files:**
- Create: `docs/prototypes/SPONSOR_WORKSPACE_ACCEPTANCE_CHECKLIST.md`
- Create: `html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js`

**Interfaces:**
- Consumes: a jelenlegi `HomeInteractionController`, `NAVIGATION_ROUTES`, `renderPendingTopics()`, `takeawayItems()`.
- Produces: a fail-closed source contract a hero assetre, `sponsor-work` route-ra, új markupra, geometry tokenre, selectorra és egyetlen adathasználatra.

- [x] **Step 1: Írd meg a kezdetben hibázó kontrakttesztet.**

```js
assert.match(html, /assets\/hero\/sponsor_hero_soft\.png/);
assert.match(html, /data-route="sponsor-work"/);
assert.match(html, /--sponsor-body-top:\s*var\(--history-current-card-top\)/);
assert.match(html, /getPendingTopicEntries\(\)\.length/);
assert.match(html, /takeawayItems\(\)\.length/);
assert.doesNotMatch(html, /toggle-sponsor-layout/);
```

- [x] **Step 2: Futtasd RED állapotban.**

Run: `node html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js`

Expected: `AssertionError`, mert az asset/route és az új szerkezet még nem létezik.

- [x] **Step 3: Hozd létre és töltsd ki a követelménylistát.**

Rögzítsd a forrásokat, state-tulajdonosokat, reuse döntéseket, 14 acceptance itemet és a fizikai Android Chrome külön állapotát.

### Task 2: Sponzor hero és fő kapcsolati központ

**Files:**
- Create: `html-prototypes/app-shell/assets/hero/sponsor_hero_soft.png`
- Modify: `html-prototypes/app-shell/index.html:route visibility CSS, sponsor CSS, sponsor main HTML`

**Interfaces:**
- Consumes: `meetings_hero_soft.png` kompozíciós/fade mintája, `state.sponsor`, `[data-sponsor-call-link]`, `[data-sponsor-message-link]`, `openSponsorNextSheet()`.
- Produces: `sponsor-hero`, `sponsor-contact-card`, `sponsor-main-content`, `sponsor-work-summary` markup és a közös top-token.

- [x] **Step 1: Generáld a szöveg nélküli, minimalista hero PNG-t.**

Prompt invariánsok: világos levendula/púderrózsaszín/törtfehér, bal felső nyugodt negatív tér, jobb-közép rétegzett dombok és kanyargó ösvény, visszafogott növényzet és kapcsolódás-motívum; sem fotórealizmus, sem beégetett szöveg, sem sötét hátér.

- [x] **Step 2: A hero mögé tedd a főmenüt, a Gyűlések fade mintájával.**

```css
.sponsor-main-content { top: var(--history-current-card-top); }
.sponsor-hero::after {
  background: linear-gradient(180deg, rgba(255,251,253,0) 30%, rgba(255,251,253,.12) 52%, var(--screen-background) 96%);
}
```

- [x] **Step 3: Cseréld a régi profil + külön action-gridet egy szemantikusan helyes kapcsolati cardra.**

Használj külön profil-buttont és három sibling gyorsműveletet: Hívás, Üzenet, Legközelebb. A harmadik gomb `data-action="open-sponsor-next-sheet"`; nested button vagy anchor nem lehet.

- [x] **Step 4: A régi nagy Legközelebb card, layout-toggle state/action/CSS és főmenü-preview gyűjtemények eltávolítása.**

Ne töröld a sheetet, üzenetküldő rendszert, backup editor-t vagy takeaway editor-t.

### Task 3: Tartalék kapcsolatok és Közös munkánk route

**Files:**
- Modify: `html-prototypes/app-shell/index.html: sponsor main HTML/CSS; route screen list; HomeInteractionController state/actions/renderers`
- Modify: `html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js`

**Interfaces:**
- Consumes: `namedSponsorBackups()`, `sponsorDialValue()`, `getPendingTopicEntries()`, `takeawayItems()`, `renderPendingTopics()`, `renderTakeawayList()`.
- Produces: backup preview, `sponsor-work` route, `renderSponsorWork()`, `setSponsorWorkTab(tab)`, return-safe editor entry points.

- [x] **Step 1: Implementáld a backup previewt meglévő adatokból.**

Legfeljebb 2 contact, minden valós telefonszámmal hívás/SMS link, üres állapotban `open-sponsor-backups`; a kártya fejléce szintén a meglévő backup route-ra megy.

- [x] **Step 2: Hozd létre a `sponsor-work` route-ot a meglévő route rendszerben.**

`NAVIGATION_ROUTES` tartalmazza, `syncMainNavigation()` Sponzort jelöl aktívnak, Escape/Back vissza a Sponzor főmenübe visz.

- [x] **Step 3: Készíts egy valódi, billentyűzettel kezelhető selector-t.**

```js
setSponsorWorkTab(tab) {
  if (!['pending', 'takeaways'].includes(tab)) return;
  this.state.sponsorWorkTab = tab;
  this.renderSponsorWork();
}
```

`aria-selected`, `role="tablist"` és tartós state kell; nem születhet új pending/takeaway tömb.

- [x] **Step 4: Adapterezd a meglévő lista-renderelőket az új hostokra.**

`renderPendingTopics()` és `renderTakeawayList()` a route saját hostjára dolgozik; a plusz gomb a meglévő szerkesztőkbe visz. A pending editor és takeaway editor `returnRoute: 'sponsor-work'` értéket kap, a tab megmarad.

### Task 4: GREEN, regresszió és vizuális bizonyíték

**Files:**
- Modify: `docs/prototypes/SPONSOR_WORKSPACE_ACCEPTANCE_CHECKLIST.md`
- Modify: `html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js`

- [x] **Step 1: Futtasd a célzott tesztet GREEN állapotban.**

Run: `node html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js`

Expected: `PASS sponsor contact workspace contract`.

- [x] **Step 2: Futtasd a releváns és teljes statikus suite-ot.**

Run: `git diff --check && for f in html-prototypes/app-shell/tests/*_test.js; do case "$f" in *_runtime_test.js) continue;; esac; node "$f" || exit 1; done`

Expected: minden statikus teszt PASS.

- [x] **Step 3: Készíts 412×892 runtime screenshotokat és geometriamérést.**

Állapotok: főmenü adatokkal, üres backup, pending, takeaway, Legközelebb sheet. Mérd: `meetingsMyCard.getBoundingClientRect().top` és `sponsorProfileCard.getBoundingClientRect().top`; abs(delta) <= 2.

- [x] **Step 4: Frissítsd őszintén a checklistet.**

Csak a ténylegesen bizonyított itemek lehetnek `DONE`; a fizikai Android Chrome eszköz hiánya külön `PARTIAL`.

### Task 5: Alsó közös-munka rögzítés, közös hero és Gyűlések-lista szűrő

**Files:**
- Modify: `html-prototypes/app-shell/index.html`
- Modify: `html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js`
- Modify: `html-prototypes/app-shell/tests/meetings_redesign_test.js`
- Modify: `html-prototypes/app-shell/tests/sponsor_contact_workspace_runtime_test.js`
- Modify: `docs/prototypes/SPONSOR_WORKSPACE_ACCEPTANCE_CHECKLIST.md`

**Architecture card:** A `HomeInteractionController` marad az egyetlen owner: `sponsorWorkTab` és az új `meetingsListTab` kizárólag megjelenítési állapot. A Sponzor és Közös munkánk ugyanazt a hero assetet és `--history-current-card-top` geometriát használja. A Gyűlések új kétállású pillje a meglévő `meetingInstancesInRange()` eredményeit szűri, nem hoz létre második meeting-listát. A mentazöld a központi `--hajnal-mint-*` szemantikus tokenekből érkezik.

- [x] **Step 1: Írd meg a hibázó szerződés- és runtime teszteket.**

  Ellenőrizd a fixen alsó Közös munkánk kártyát, a belső kapcsolattartó scrollt, a közös Sponsor-hero/geometriát, a mentazöld tab/CTA felületet, a Gyűlések kétállású listapilljét és a lista-nézetből eltávolított add műveletet.

- [x] **Step 2: Futtasd RED állapotban.**

  Run: `node html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js && node html-prototypes/app-shell/tests/meetings_redesign_test.js`

  Expected: a mostani implementációból hiányzó új DOM/CSS/state szerződések miatt assertion failure.

- [x] **Step 3: Implementáld a minimális közös state-, render- és CSS-változtatást.**

  A fő Sponzor gridjében a kapcsolattartó-kártya az egyetlen rugalmas/scrollozó sáv, a Közös munkánk az alsó grid sorban marad. A Közös munkánk azonos hero markupot és body-top tokent használ. A Gyűlések lista egyetlen kiválasztott listatabot renderel és add gomb nélkül marad.

- [ ] **Step 4: GREEN és vizuális bizonyíték.**

  Célzott tesztek, teljes statikus suite, majd 412×892 Chromium screenshot a Sponzor főmenüről, Közös munkánk mindkét tabjáról és a Gyűlések lista mindkét tabjáról. A checklist státuszát csak a tényleges evidence után frissítsd.

  **Jelenlegi állapot:** a célzott tesztek, a JavaScript-szintaxisellenőrzés, `git diff --check` és a teljes statikus suite zöld. A frissített Playwright runtime teszt a hiányzó `playwright`/Chromium miatt blokkolt; a checklist érintett elemei ezért `PARTIAL` állapotúak maradnak.
