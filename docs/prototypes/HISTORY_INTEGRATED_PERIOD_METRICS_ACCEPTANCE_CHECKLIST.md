# Történetem – integrált időszakstatisztika – elfogadási lista

Források: a 2026-10-15-i felhasználói implementációs specifikáció; a beszélgetésben hivatkozott utolsó integrált mockup; [`/storage/emulated/0/hajnal/source of truth/hajnal_tortenetem_redesign.png`](/storage/emulated/0/hajnal/source%20of%20truth/hajnal_tortenetem_redesign.png); a legfrissebb Android-kép: [`/storage/emulated/0/Pictures/Screenshots/Screenshot_20261015-015303.png`](/storage/emulated/0/Pictures/Screenshots/Screenshot_20261015-015303.png); `html-prototypes/app-shell/index.html`.

## Architecture card

- Meglévő állapotgazda: `historyPresentation.history.metricsExpanded`; kizárólag a meglévő `toggleHistoryMetrics('history')` írja ezt az állapotot.
- Új renderer nincs: a közös `renderHistoryMetricCards(period)` marad a metrics-csempék és a szűrőgombok egyetlen forrása.
- Új gesture motor nincs: a meglévő `historyMetricsRailPointer*`, `captureHistoryMetricsRailScrollPositions()`, `restoreHistoryMetricsRailScrollPositions()` és pager-rail kizárás működik tovább.
- Elrendezésgazda: a pager-slide közös CSS-változóban számítja a body kezdetét a card felső pozíciójából, aktuális magasságából és az eredeti résből; nincs overlay és nincs új scroll owner.
- Írási út: toggle → meglévő controller render → metrics/timeline scrollpozíció visszaállítás. A period, timeline események és statisztika adatait nem módosítja.

| ID | Követelmény | Kódterület | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| HIM-01 | Eredeti időszakkártya tartalma | History pager renderer + CSS | Cím, tiszta napok, dátum és levélikon collapsed/expanded állapotban is megmarad; collapsed magasság 102 px token | Integrált DOM/CSS kontraktteszt + Chromium runtime | DONE |
| HIM-02 | Levélikon mint akadálymentes toggle | Pager renderer + meglévő toggle action | Legalább 44 px-es gomb, dinamikus `aria-expanded`, `aria-controls`, címke és chevron; nincs nested button | Integrált DOM/CSS kontraktteszt + Chromium runtime | DONE |
| HIM-03 | Egyetlen integrált stats UI | `renderHistoryPagerSlide()` + shared metric renderer | A metrics panel a felső card belsejében van; az alsó `history-period-pager-summary` nem renderelődik | Integrált DOM kontraktteszt + Chromium calendar-runtime | DONE |
| HIM-04 | Valódi, kiszámított body-geometria | inline History pager CSS | Collapsed esetben az eredeti body-top; expanded esetben card-bottom + eredeti gap. Timeline/naptár nem kerül a card mögé | CSS-kontraktteszt + Chromium: 267→395 px body-top, card-bottom + 14 px | DONE |
| HIM-05 | Egyetlen vertikális scroll owner | pager body + timeline/calendar CSS | Header/card fix, csak a meglévő pager scroll-owner függőleges; nincs üres alsó stats grid-row | DOM/CSS kontraktteszt + Chromium calendar-scroll mérés | DONE |
| HIM-06 | Meglévő metrics carousel és filter | shared metrics renderer + existing gesture controllers | Metrikák horizontálisan scrollozhatók, tap szűr és old, scrollpozíció render után megmarad; rail swipe nem lapoz időszakot | Chromium touch runtime: rail drag, filter, visszaállított scroll és elkülönített outer-pager swipe | DONE |
| HIM-07 | Period- és naptárkompatibilitás | pager renderer + existing period/calendar state | Aktuális és korábbi period a saját adatait mutatja; korábbi hero grayscale; naptárban sincs alsó duplikátum | Statikus calendar-kontrakt + Chromium calendar runtime | DONE |
| HIM-08 | Változatlan környező UI | existing hero, switch, timeline, bottom nav | Hero artwork/fade, floating switch, event cardok és bottom nav nem változik | Teljes nem-runtime regressziós tesztcsomag + screenshot-inspekció | DONE |
| HIM-09 | 412×892, 360×800 és nagy Android viewport vizuális bizonyíték | browser/runtime | Nyitott/zárt card, timeline/naptár és rail nem overflowol, az utolsó tartalom elérhető | Chromium mobil-emuláció és screenshot: 412×892, 390×844, 360×800. Fizikai Android Chrome nem érhető el ebben a környezetben. | PARTIAL |
