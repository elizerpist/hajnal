# Pánik mód – focus popupok elfogadási lista

## Compact architecture gate

- **Tulajdonos:** a meglévő `HomeInteractionController`; a három meglévő
  nyitási állapot (`panicHelpSheet`, `panicMotivationSheet`,
  `panicNextMeetingOpen`) és a meglévő
  `openAppOverlaySheet()` / `closeAppOverlaySheet()` életciklus marad az
  egyetlen state- és fókuszkezelő útvonal.
- **Újrahasznosítás:** a közös app-overlay host, inert háttérkezelés,
  fókusz-visszaállítás, Escape/backdrop/X bezárás és a már meglévő
  kapcsolatfelvételi/motivációs renderelők változatlanok maradnak. A Következő
  gyűlés a harmadik fogyasztója ugyanennek a `panic-focus-popup-*` vizuális
  primitívnek; a meglévő, controller-tulajdonú időalapú alkalomfeloldót és
  részvételi write pathot használja, nem hoz létre második meeting-adatforrást.
- **Nem keletkezik:** új route, második popup-state, második kapcsolattartó
  adatforrás vagy új perzisztencia.

## Követelmények

| ID | Forrás | Kódrész | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| PFP-01 | Legutóbbi felhasználói utasítás; specifikáció §18 | `index.html` pánik segítség host | A `Hívj fel valakit` felület középre igazított, fókuszált popup; nem alsó slide-up sheet. A szponzor, tartalék kapcsolatok, üzenet és `tel:112` változatlanul működnek. | TDD forráskontraktus zöld; 412×892 screenshot nem készült, mert nincs telepített Chromium/Playwright. | PARTIAL |
| PFP-02 | Legutóbbi felhasználói utasítás; specifikáció §§17–18 | `index.html` motiváció host | A `Miért kezdtem el?` felület ugyanilyen focus popup; a saját motivációs szöveg és a Pánik módban maradás változatlan. | TDD forráskontraktus zöld; 412×892 screenshot nem készült, mert nincs telepített Chromium/Playwright. | PARTIAL |
| PFP-03 | Legutóbbi felhasználói utasítás; `checkin_visszaeses_panik.png` sötét pánik-vizuális nyelve | megosztott CSS | Mindhárom popup egy közös, középre igazított sötétlila/üveg vizuális primitívet használ: backdrop, rövid opacity/scale átmenet, lekerekített dialogus, belső scroll csak szükség esetén. | A célzott CSS-kontraktus zöld; a renderelt screenshot külső böngésző hiányában függőben. | PARTIAL |
| PFP-04 | Legutóbbi felhasználói utasítás; projekt overlay viselkedés | `HomeInteractionController` | Backdrop, X, Escape/Android Back bezárja a popupot és a korábbi Pánik/survival felületre tér vissza; nincs route-váltás és a trigger fókuszt kap vissza. | Meglévő `openAppOverlaySheet()` / `closeAppOverlaySheet()` és Escape/Android Back útvonal közvetlen kódellenőrzése; célzott teszt zöld. | DONE |
| PFP-05 | `AGENTS.md` | tesztek, vizuális ellenőrzés | A reduced-motion beállítás nem animál; 412×892-en a dialogus teljesen hozzáférhető, nem lóg a safe-area alá. | Reduced-motion CSS közvetlen ellenőrzése zöld; a 412×892 screenshot telepített böngésző hiányában függőben. | PARTIAL |
| PFP-06 | Legutóbbi felhasználói utasítás; specifikáció §18; `checkin_visszaeses_panik.png` | `index.html` pánik-gyűlés renderelő, közös popup host és meglévő meeting resolver | A `Következő gyűlés` gyorsművelet középre igazított focus popupot nyit, nem inline kártyát és nem új route-ot. A popup a meglévő, ismétlődést feloldó következőalkalom-keresést, `Útvonal`/`Csatlakozás`, `Ott leszek`, `Másik gyűlés`, üres állapot és percenkénti frissítés működését változatlanul használja. Backdrop, X, Escape és Android Back csak a popupot zárja. | A célzott TDD forráskontraktus RED → GREEN; teljes nem-böngészős app-shell regresszió zöld; controller- és overlay-életciklus közvetlen kódellenőrzése zöld. A kötelező 412×892 screenshot nem készült, mert nincs telepített Chromium/Playwright. | PARTIAL |

## Referenciák és precedencia

- Vizsgált projekt-referenciák: `docs/references/source-of-truth/logo.png`,
  `onboarding.png`, `designnkovetelmenyek.png`,
  `checkin_visszaeses_panik.png`, `haladas_naptar_stat.png`,
  `eszkozok_12lepes_naplo.png`, `sponzor_profil_beallitasok.png`.
- A specifikáció §18 még alsó panelt említ. A későbbi, kifejezett felhasználói
  utasítás ezt felülírja: azonos biztonsági tartalommal, de focus popup
  prezentációval valósul meg.
