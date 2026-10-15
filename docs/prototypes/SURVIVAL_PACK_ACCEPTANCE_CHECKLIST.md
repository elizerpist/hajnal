# 15 perces túlélőcsomag – elfogadási checklist

## Referenciák és architektúra

- Elsődleges funkcionális forrás: a felhasználó 2026-10-15-i, hétállomásos túlélőcsomag-specifikációja.
- Írott termékspecifikáció: `docs/HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md`, különösen §§12, 17–18, 21, 25–26.
- Vizuális rendszer: `docs/references/source-of-truth/logo.png`, `onboarding.png`, `designnkovetelmenyek.png`, `checkin_visszaeses_panik.png`, `haladas_naptar_stat.png`, `eszkozok_12lepes_naplo.png`, `sponzor_profil_beallitasok.png`.
- Meglévő alkalmazás-owner: `HomeInteractionController` a `html-prototypes/app-shell/index.html` fájlban.
- Meglévő újrahasznosítandó rendszerek: `openPanicHelpSheet()`, `openPanicContactMessage()`, `openPanicMotivationSheet()`, `this.state.sponsor`, `this.state.sponsorBackups`, valamint a meglévő app-overlay sheet infrastruktúra.

### Architecture card

| Döntés | Egyetlen owner / write path | Újrahasznosítás | Verifikáció |
|---|---|---|---|
| Munkamenet | `HomeInteractionController.state.survivalSession`; `updateSurvivalSession()` és `persistSurvivalState()` | meglévő controller és `survival` route | futtatott controller-contract teszt |
| Teljes idő | `SURVIVAL_DURATION_SECONDS = 900`, `startedAt`-alapú származtatás | meglévő survival óra, de DOM-only frissítésre javítva | időzítő unit/contract teszt |
| Állomás és választások | `survivalSession.currentStep`, `selections`, `status`, `outcome` | meglévő `SURVIVAL_STEPS` adatmodell, hét elemre bővítve | 7 állomásos contract teszt |
| Kapcsolódás | meglévő sponzor/backup state és Pánik sheet | `tel:`, `openPanicContactMessage()`, `openPanicHelpSheet()` | markup + controller teszt |
| Motiváció | meglévő inicializációs motiváció és Pánik-motivációs sheet | `openPanicMotivationSheet()` | route/markup teszt |
| Szabad jegyzet | általános `freeNotes` store, `type: 'free'`, `source: 'survival-pack'` | controller-owned, localStorage adapter | persistencia és input contract |
| Időzítő renderelése | kizárólag `syncSurvivalElapsedLabel()` módosít timer node-okat | meglévő intervallum és route | static guard + controller teszt |

## Követelmények

| ID | Forrás | Kódterület | Elfogadási feltétel | Ellenőrzés | Állapot |
|---|---|---|---|---|---|
| SPK-01 | §4 | `SURVIVAL_STEPS`, `renderSurvival()` | Egyetlen `survival` route-on hét állomás van: megállás, légzés, víz, környezet, kapcsolódás, várakozás, újraértékelés. | `survival_pack_test.js` | DONE |
| SPK-02 | §§5,17,19 | survival CSS/render | Egységes fejléc–tartalom–footer, de állomásonként saját funkcionális vizuál; nincs böngésző-default CTA. | 412×892 screenshotok + CSS contract | DONE |
| SPK-03 | §§6–10,21 | controller + renderer | Az első öt állomás átugorható; légzés szüneteltethető; víz/környezet választások tárolódnak; kapcsolatok valódi meglévő state-ből jönnek. | `route_extensions_test.js` + browser smoke | DONE |
| SPK-04 | §§11,15 | timer + wait renderer | Egyetlen 900 mp-es `startedAt`-alapú óra, valós hátralévő idővel; nincs kényszerített váltás vagy hamis 15 perc. | `route_extensions_test.js` + browser smoke | DONE |
| SPK-05 | §§11–13 | asset, sheet, free notes | A várakozás hero saját pasztell asset + fade; a motiváció meglévő sheetet használ; a szabad írás szerkeszthető és `free` típusú jegyzetként menthető. | asset + persistence/browser smoke | DONE |
| SPK-06 | §14 | reassessment renderer/controller | Három azonos rangú válaszkártya; a „Még nehéz” nem indítja újra a lépéseket; „Erősebb lett” segítséghez vezet. | `route_extensions_test.js` + screenshot | DONE |
| SPK-07 | §§16,21 | persistence/lifecycle | Verziózott, validált localStorage session; háttérből visszatérve valós idő; kilépés után folytatható/újrakezdhető; intervallum nem szivárog. | `route_extensions_test.js` + browser smoke | DONE |
| SPK-08 | §§19–22 | responsive CSS, a11y | 412×892-en footer látszik, no bottom nav, nincs horizontális overflow; reduced-motion és semantika megvan. | 412×892 screenshotok + static test | PARTIAL — a headless Chromium nem tud Android szoftver-billentyűzetet megjeleníteni |
| SPK-09 | §23 | app-shell tests | A régi ötállomásos elvárásokat hétállomásos, időalapú szerződés váltja fel; regressziók futnak. | teljes Node-suite | DONE |
| SPK-10 | §24 | existing routes/state | Pánik, Sponzor, kapcsolattartók, Ösvény, Történetem és BottomNav változatlanul működnek. | teljes Node-suite + böngészős célzott ellenőrzés | PARTIAL — a három korábbi, Playwright/CDP-t igénylő regressziós teszt nem futtatható a jelenlegi tesztkörnyezetben |

## Referencia-konfliktus feloldása

Az írott specifikáció régi, öt/six-state offline referenciáit a felhasználó legfrissebb hétállomásos workflow-ja felülírja. A PNG-k továbbra is kötelezően a szín-, forma-, tipográfia- és nyugodt Pánik-vizuális nyelvet rögzítik; nem írják felül az új folyamat információs architektúráját.

## Verifikációs bizonyíték

- 412×892 screenshotok: `docs/prototypes/verification/survival-pack/` — a hét állomás, az írópanel és az összesített ellenőrző kép.
- Böngészős smoke: a jegyzet fókusza és tartalma megmaradt egy időzítőfrissítésen keresztül; a `free` jegyzet mentődött; a kilépett session ugyanazzal az `id`/`startedAt` értékkel folytatható volt.
- A jelenlegi Androidos/headless környezetben valódi szoftver-billentyűzet nem emulálható; ez az egyetlen SPK-08 nyitott verifikációs pont.
