# Sponzor – kapcsolati központ és Közös munkánk – elfogadási lista

Források: a 2026-10-15-i felhasználói implementációs specifikáció; [`docs/HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md`](../HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md) 3.4., 19., 21. és 25. fejezetei; `docs/references/source-of-truth/logo.png`, `onboarding.png`, `designnkovetelmenyek.png`, `checkin_visszaeses_panik.png`, `haladas_naptar_stat.png`, `eszkozok_12lepes_naplo.png`, `sponzor_profil_beallitasok.png`; a kért Gyűlések-referencia (`html-prototypes/app-shell/assets/hero/meetings_hero_soft.png`) és az aktuális `html-prototypes/app-shell/index.html`.

## Architektúra-kártya

- **Egyetlen állapot- és írási út:** `HomeInteractionController.state`. A profil a `state.sponsor`, a tartalék kapcsolatok a `state.sponsorBackups`, a megbeszélendők a `getPendingTopicEntries()`, az útravalók a `takeawayItems()` forrásából jönnek.
- **Új, lokális megjelenítési állapot:** `state.sponsorWorkTab` (`pending` vagy `takeaways`). Ez csak a Közös munkánk lista megjelenítését választja, nem hoz létre új gyűjteményt.
- **Navigáció:** a meglévő `navigate()` és `syncMainNavigation()` kap egy `sponsor-work` route-ot. A szerkesztők meglévő `returnRoute` paramétere ezt a route-ot őrzi meg.
- **Újrafelhasznált mechanizmus:** a meglévő hívás/SMS linkfrissítés, következő beszélgetés sheet, backup-kezelő, pending-topic → takeaway folyamat, takeaway editor és BottomNav. Nem készül új sheet, adatmodell vagy gesture-motor.
- **Vizuális döntés:** a Gyűlések `--meetings-body-top: var(--history-current-card-top)` geometriája a Sponzor profilkártya egyetlen referenciaforrása; a hero a közös `--screen-background` fade-be olvad.
- **Bizonyíték:** célzott DOM/navigációs kontraktteszt, teljes statikus tesztcsomag, 412×892 Chromium screenshotok és `getBoundingClientRect().top` koordináta-összehasonlítás.

| ID | Követelmény | Kódterület | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| SW-01 | Saját, generált Sponzor hero | `assets/hero/sponsor_hero_soft.png`, sponsor CSS/HTML | Új PNG, világos minimalista támogatás-metafora, szöveg nélküli; a Gyűlésekhez igazodó hero/fade | Asset-inspekció + 412px screenshot | DONE |
| SW-02 | Hero szöveg és háttérviselkedés | sponsor hero markup/CSS | `Sponzor` és `Együtt könnyebb.`, teljes szélesség, nem interaktív, egységes fade | DOM/CSS test + screenshot | DONE |
| SW-03 | Pontos közös geometria | sponsor/meetings CSS | Profilkártya és Lista mód Gyűléseim card top eltérése legfeljebb 2px | Chromium DOM mérés | DONE — 150px vs. 150px, delta 0px |
| SW-04 | Egyetlen kapcsolati profil-blokk | sponsor main markup/render | Valódi `state.sponsor` adatok, nem nested button, három gyorsművelet | DOM/navigációs test | DONE |
| SW-05 | Hívás, Üzenet, Legközelebb | existing link/calendar integrations | `tel:`/`sms:` marad; Legközelebb teljes képernyős naptárban választ dátumot és időt; nincs next sheet | route/state teszt + 412px screenshot | PARTIAL — a route- és mentési szerződés zöld; Chromium screenshot nem futtatható ebben a környezetben |
| SW-06 | Tartalék kapcsolattartók | existing backup state/render | Valós kapcsolatok, működő hívás/SMS, üres állapot a meglévő kezelőbe visz | DOM/runtime teszt | DONE |
| SW-07 | Közös munkánk összesítő | main sponsor render | Valós pending/takeaway számláló, külön route-ra navigál | DOM/navigációs test | DONE |
| SW-08 | Közös munkánk route és selector | new view + controller state | Vissza a Sponzorba, két billentyűzetes tab, `sponsorWorkTab` megmarad | route/state test | DONE |
| SW-09 | Megbeszélendő nézet | reused pending renderer | Teljes meglévő manuális+Ösvény lista, meglévő add/edit folyamat, FAB nem fed ki tartalmat | DOM/runtime teszt | DONE |
| SW-10 | Útravalóim nézet | reused takeaway renderer | Teljes lista, meglévő create/edit/delete/reorder funkció, nem csak 3-as preview | DOM/runtime teszt | DONE |
| SW-11 | Visszatérés és adatok védelme | editor return route/renderers | Pending → editor → Közös munkánk/pending, takeaway → editor → Közös munkánk/takeaways; nincs adatduplikáció | navigációs teszt | DONE |
| SW-12 | Régi layoutváltó eltávolítása | old sponsor layout CSS/state/actions | Nincs `toggle-sponsor-layout`, `sponsorLayout` vagy rejtett alternatív elrendezés | statikus kontraktteszt | DONE |
| SW-13 | Egy scroll owner és BottomNav | sponsor/work CSS | Nincs egymásba ágyazott versengő vertikális scroll; utolsó tartalom elérhető, Sponzor aktív | DOM/CSS + mobile screenshot | DONE |
| SW-14 | Vizuális és regressziós ellenőrzés | tests + screenshots | 412×892 fő/üres/work/pending/takeaway/next-sheet képek; releváns és teljes statikus suite zöld | test logs + screenshots | PARTIAL — 412×892 Chromium mobile evidence complete; physical Android Chrome was not connected |
| SW-15 | Fixen alsó Közös munkánk kártya | sponsor main CSS/layout | A kártya a BottomNav fölött marad, míg a többi főmenü-tartalom nem kap második függőleges scroll ownert | DOM geometry + runtime screenshot | PARTIAL — CSS-grid és source szerződés zöld; Chromium/Android runtime nem futtatható ebben a környezetben |
| SW-16 | Fix méretű, belül görgethető kapcsolattartó-konténer | sponsor backup CSS/renderer | A Tartalék kapcsolattartók kártya kitölti a profil és az alsó kártya közötti teret; a fejléce fix, a valós kapcsolatok belül scrolloznak | DOM/CSS + runtime scroll test | PARTIAL — a lista `overflow-y:auto` és a külső owner `hidden` source-szerződéssel ellenőrzött; élő scrollteszt blokkolt |
| SW-17 | Közös munkánk közös hero- és geometriai rendszere | sponsor-work markup/CSS | Ugyanaz a `sponsor_hero_soft.png`, hero-copy koordináta és 32px címméret; a kompakt profil felülről ugyanott kezdődik, mint a Sponzor profilkártyája | DOM geometry + 412×892 screenshot | PARTIAL — közös asset/class és közös top-token statikusan igazolt; 412×892 vizuális/DOM méréshez nincs Chromium |
| SW-18 | Közös munkánk app-lila vizuális nyelve | semantic CSS token + sponsor-work CSS | A sín és inaktív fülek fehérek; mindkét aktív pill és FAB az alkalmazás lila színét használja; a számláló-pillek színes hátterűek | CSS contract + screenshot | PARTIAL — a lila pill/FAB szerződés zöld; screenshot-ellenőrzés blokkolt |
| MW-01 | Gyűlések lista-szűrő | meetings controller/render/CSS | A lista hero-kártyája alatt Közelgő/Múltbeli gyűléseim kétállású pill váltja a listát; mindkét lista a meglévő meeting resolverből épül | DOM/runtime test | PARTIAL — `meetingsListTab`, action és egyetlen lista-renderer szerződése zöld; élő tap teszt blokkolt |
| MW-02 | Gyűlések hozzáadásának elhelyezése | meetings list/calendar render | Lista módban nincs plusz gomb vagy add action; új gyűlés csak a naptárnap fejlécéből indítható | source contract + runtime test | PARTIAL — lista rendererben nincs add action, naptár napfejléce megtartja; élő route-ellenőrzés blokkolt |
| SW-19 | Közös munkánk selector-színek | sponsor-work CSS + semantic tokens | Fehér sín és inaktív fülek; a Megbeszélendő aktív állapota `--hajnal-purple`; az aktív Útravalóim pontosan a FAB `--hajnal-mint-accent` felületét használja | CSS contract + 412×892 Chromium screenshot | DONE |
| MW-03 | Gyűlések selector-színek | meetings list CSS + semantic tokens | Fehér sín és inaktív fülek; a Közelgő/Múltbeli aktív állapot `--hajnal-purple` | CSS contract + 412×892 Chromium screenshot | DONE |
| SC-01 | Gyűlések belépési slide-up eltávolítása | meetings CSS | A route belépésekor nincs body `translateY` vagy külön body entry animation | CSS contract + 412×892 screenshot | PARTIAL — a CSS-kontraktus zöld; Chromium screenshot nem futtatható ebben a környezetben |
| SC-02 | Gyűlések/History floating selector igazítás | meetings/history CSS | Mindkét selector számított felső koordinátája 32px | DOM/CSS contract + screenshot | PARTIAL — a megosztott 32px CSS-landmark szerződés zöld; élő DOM-mérés blokkolt |
| SC-03 | Közös munkánk lila selector és FAB rendszer | sponsor-work CSS + tokens | A sín fehér; mindkét tab lila rendszerű; aktív tab és mindkét FAB `--hajnal-purple`; nincs zöld kivétel | CSS contract + screenshot | PARTIAL — CSS-kontraktus zöld; screenshot-ellenőrzés blokkolt |
| SC-04 | Legközelebb teljes képernyős naptár | sponsor routes/controller/render | A gyorsművelet nem sheetet nyit; a hero marad, van naptárrács, időpontválasztó és Vissza | route/runtime test + screenshot | PARTIAL — route- és render-kontraktus zöld; a frissített Playwright-teszt nem indítható helyi Chromium nélkül |
| SC-05 | Szponzori időpont elérhetőségi és mentési logika | existing calendar/time core adapter | Érvényes dátum/idő menthető; tiltott időpont nem; mentésen kívül nincs írás | unit/runtime test | DONE — `route_extensions_test.js` közvetlenül ellenőrzi a dátum/idő kiválasztását és mentését |
| SC-06 | Elkülönített korábbi-alkalmak mock-lista | sponsor seed data + schedule renderer | Nem Gyűlések rekordok és nem szerkeszthetők; a teljes naptár route-on olvashatók | source/runtime test + screenshot | PARTIAL — elkülönített, csak olvasható seed/render út zöld; screenshot-ellenőrzés blokkolt |
| SC-07 | Sponzorom mióta teljes naptár route | sponsor details/controller/render | Nincs natív date picker; Vissza nem ír draftot, megerősítés csak az adatlap draftját írja | unit/runtime test | DONE — route- és draft-védelmi teszt zöld |
| SC-08 | Naptár navigáció, scroll és BottomNav | route CSS/navigation | Egy scroll owner, Sponsor aktív, Back útvonalak helyesek, az overlay/sheet nem marad párhuzamosan aktív | runtime test + screenshot | PARTIAL — BottomNav/route szerződés zöld; élő scroll- és Back-teszt blokkolt |
| SC-09 | Célzott regresszió és vizuális evidence | tests + screenshots | A célzott és teljes statikus suite zöld; 412×892 képek a két naptár route-ról | logs + screenshot | PARTIAL — minden statikus `*_test.js` zöld; a frissített Chromium screenshot-test környezeti függősége hiányzik |

## Referenciakonfliktus feloldása

`sponzor_profil_beallitasok.png` a régi, egyszerűbb Sponzor menü információarchitektúráját mutatja. A felhasználó legutóbbi specifikációja elsőbbséget élvez: a főmenü kapcsolati központ, a két gyűjtemény kizárólag a külön `Közös munkánk` képernyőn jelenik meg. A PNG pasztelles, világos kártyanyelvét, hero-fade karakterét, tipográfiáját és ikonkezelését megtartjuk.

## Ellenőrzési bizonyíték — 2026-10-15

- `node html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js` — zöld.
- Teljes statikus app-shell suite — zöld (`*_runtime_test.js` nélkül); beleértve Pánik, Ösvény, Gyűlések, route- és BottomNav-regressziókat.
- `sponsor_contact_workspace_runtime_test.js` — Chromium mobil-emulációban zöld: 150px / 150px felső koordináta, tartalék kapcsolat létrehozása, Közös munkánk route és aktív BottomNav, profilból való visszatérés, pending létrehozása, takeaway létrehozása/szerkesztése/törlése/átrendezése, Legközelebb sheet.
- Vizuális evidence: `docs/prototypes/verification/sponsor-contact/01-sponsor-empty.png`, `02-sponsor-backup.png`, `03-sponsor-work-pending.png`, `04-sponsor-work-takeaways.png`, `05-sponsor-next-sheet.png`.
- Selector-finomítás evidence: `docs/prototypes/verification/selector-pills/01-sponsor-work-pending.png`, `02-sponsor-work-takeaways.png`, `03-meetings-list-upcoming.png` — fehér sín/inaktív fülek, app-lila aktív állapot és a FAB-éval egyező menta Útravalóim állapot.
- `node html-prototypes/app-shell/tests/sponsor_contact_workspace_test.js`, `node html-prototypes/app-shell/tests/meetings_redesign_test.js`, valamint a teljes statikus app-shell Node-csomag — zöld (38 teszt).
- Fizikai Android Chrome kapcsolat nem állt rendelkezésre; ezt a hiányt az SW-14 szándékosan nem rejti el.
- A 2026-10-15-i rögzített-kártya, közös-hero és Gyűlések-listapill finomítások teljes statikus suite-ja zöld. A frissített Playwright runtime tesztet a környezetben hiányzó `playwright`/Chromium miatt nem lehetett elindítani; ezért SW-15–18 és MW-01–02 szándékosan `PARTIAL`.
