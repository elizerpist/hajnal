# Gyakorlatmanager vizuális reprodukció – elfogadási lista

## Kötelező források

- Felhasználói implementációs prompt: „HAJNAL / GYAKORLATMANAGER DESIGN REPRODUKCIÓ”.
- Elsődleges, kizárólagos vizuális referencia: `/storage/emulated/0/hajnal/source of truth/gyakorlat.png` – közvetlenül megnyitva és elemezve 2026-10-15-én.
- Projekt-specifikáció: `docs/HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md`.
- Designrendszer-referenciák: `docs/references/source-of-truth/{logo,onboarding,designnkovetelmenyek,checkin_visszaeses_panik,haladas_naptar_stat,eszkozok_12lepes_naplo,sponzor_profil_beallitasok}.png` – közvetlenül megnyitva.

## Kompakt architektúra-kapu

| Téma | Döntés |
| --- | --- |
| Meglévő tulajdonos | `HomeInteractionController.renderPracticeSheet()` és `practiceRow()` a `html-prototypes/app-shell/index.html` fájlban. |
| Közös mechanizmus | A meglévő `practicePopupView`, `state.practice`, `openAppOverlaySheet()` és `persistPracticeEveningState()` marad az egyetlen popup-/állapot-/írási út. |
| Állapothatár | Kizárólag jelenítési markup és a hozzá tartozó, scope-olt CSS változik; nincs új perzisztens vagy workflow-állapot. |
| Fókuszált ellenőrzés | Előbb RED/GREEN statikus vizuális szerződés, majd 412×892, 390×844 és 360×800 Chromium screenshot és funkcionális interakciós regresszió. |

## Elfogadási feltételek

| ID | Forrás | Kódterület | Elfogadási feltétel | Ellenőrzés | Státusz |
| --- | --- | --- | --- | --- | --- |
| PMV-01 | `gyakorlat.png` §3 | `.practice-popup-host`, `.practice-focus-dialog--manager` | A manager középre igazított, 85% széles, nem fullscreen, erősen lekerekített, enyhén blur-ölt háttér előtti focus popup. | Chromium bounding box + `practice-manager-reference-412.png`. | DONE — a 412×892 futás középre igazított, 348 px széles, a rendszerterület fölött maradó popupot mért. |
| PMV-02 | `gyakorlat.png` §§4–5 | manager header, `.practice-active-card` | A fejléc/X és a kompakt aktív kártya aránya, balra igazított információja és jobb oldali Részletek gombja a referenciát követi. | Statikus szerződés + screenshot. | DONE — közvetlen referenciakép-összevetés és `practice-manager-reference-412.png`; a cím/alcím egy soros, az aktív kártya kompakt, háromoszlopos. |
| PMV-03 | `gyakorlat.png` §§6–8 | `.practice-manager-list-heading`, `.practice-list-filter`, `practiceRow()` | A cím és háromszegmenses filter egy sorban van; a listaelemek négyoszloposak, balra igazítottak, kompaktak, ellipszissel rövidítenek, külön aktiváló és context akcióval. | RED/GREEN szerződés + runtime interakció. | DONE — a forrás-szerződés RED → GREEN volt; a Chromium futás balra igazított copy-t, háromállású szűrőt és külön aktiváló/context gombokat ellenőrzött. |
| PMV-04 | `gyakorlat.png` §§9–10 | `.practice-manager-scroll`, `.practice-manager-create` | Csak a lista görgethető; fejléc, aktív kártya, filter és szaggatott új-gyakorlat gomb látható marad. | 412×892, 390×844, 360×800 runtime ellenőrzés. | DONE — mindhárom viewport screenshotja elkészült; a listának kizárólagos `overflow-y: auto` tulajdonosa van, a fix alsó gomb minden méreten látszik. |
| PMV-05 | User §§2, 13, 15 | meglévő manager/controller | A működő szűrő, aktiválás, Részletek, context menu, szerkesztőnyitás, bezárás és meglévő adatok érintetlenek. | `practice_manager_runtime_test.js`, `home_practice_evening_wizard_test.js`. | DONE — mindkét célzott regresszió zöld; a manager műveletei továbbra is a meglévő controller- és tárolási úton futnak. |
| PMV-06 | Projekt `AGENTS.md` | minden érintett terület | Egyetlen manager, `state.practice`, popup host és tárolási út marad; nincs új manager/state/route. | Statikus ownership-scan, célzott teszt. | DONE — a renderer továbbra is egy `practicePopupView` és a meglévő `state.practice`/`persistPracticeEveningState()` tulajdonosait használja. |
