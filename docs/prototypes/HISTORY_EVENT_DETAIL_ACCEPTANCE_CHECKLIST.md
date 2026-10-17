# Történetem eseményrészletek – elfogadási lista

## Kompakt architektúra-kapu

- **Meglévő tulajdonos:** `HomeInteractionController.navigate()` / `syncMainNavigation()` és az egyetlen `.bottom-nav` az `html-prototypes/app-shell/index.html` fájlban.
- **Újrahasznált mechanizmus:** a már meglévő `NAVIGATION_ROUTES` határozza meg a közös BottomNav láthatóságát; az eseményrészletet ehhez bővítjük, nem kap saját navigációt.
- **Állapot-határ:** route és aktív BottomNav a controller tulajdona; az eseményrészlet markupja nem ír perzisztens vagy route-állapotot.
- **Ellenőrzés:** `route_extensions_test.js` controller-szerződés, Playwright 412×892 ellenőrzés, DOM/CSS-szerződés.

| ID | Forrás | Kódterület | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| HED-01 | 2026-10-17 user: „ha ez nyitva, akkor a bottom navot lehessen látni” | `NAVIGATION_ROUTES`, `syncMainNavigation()`, `.timeline-event-detail-content` | Az eseményrészlet route a meglévő közös BottomNavot használja; a Történetem marad aktív és a görgethető tartalom helyet tart fenn a navigációnak. | RED/GREEN route-szerződés + 412×892 Playwright screenshot. | DONE — `route_extensions_test.js`, `history_event_detail_runtime_test.js`, `history-event-detail-412.png`. |
| HED-02 | 2026-10-17 user: „szedd ki a címkéket belőle” | statikus `timeline-event-detail` markup/CSS | Az eseményrészlet Részletek szakaszából eltűnik a `Címkék` sor és minden címkepille; a többi részlet megmarad. | Negatív markup-szerződés + screenshot. | DONE — markup-szerződés és `history_event_detail_runtime_test.js`. |
| HED-03 | Projekt `AGENTS.md` centralizálási kapu | `HomeInteractionController`, meglévő route + BottomNav | Nincs új BottomNav, második route vagy új állapot-/adattároló; a közös controller dönt a láthatóságról. | Kódinspekció + route-szerződés. | DONE — az egyetlen `NAVIGATION_ROUTES` készlet és `syncMainNavigation()` változott. |
| HED-04 | 2026-10-17 user: „az alsó képek szekciót is” | statikus `timeline-event-detail` markup/CSS | Az eseményrészletből eltűnik a nem támogatott Képek blokk, a korábbi kép és a kép-hozzáadás vezérlője; nem marad inaktív feltöltési UI. | RED/GREEN markup- és Playwright-szerződés. | DONE — `route_extensions_test.js` és `history_event_detail_runtime_test.js`. |
| HED-05 | 2026-10-17 user: „a jobb felső sarokból a 3 pontos gombot is szedd ki, és a hero magasságát csökkentsd kicsit” | statikus `timeline-event-detail` fejléc és `.timeline-event-hero` | Nincs további-lehetőségek (hárompontos) gomb az eseményrészlet fejlécében; a hero 164 px helyett 148 px magas, miközben a vissza gomb, cím, tartalom és BottomNav megmarad. | RED/GREEN markup- és 412×892 Playwright geometriai szerződés. | DONE — `route_extensions_test.js` és `history_event_detail_runtime_test.js`. |
