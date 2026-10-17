# Gyakorlatválasztó – `gyakorlat2.png` elfogadási lista

## Kötelező források és feloldott referenciaütközés

- Elsődleges, kötelező vizuális referencia: `/storage/emulated/0/hajnal/source of truth/gyakorlat2.png` (1024 × 1536) – közvetlenül megnyitva és elemezve 2026-10-16-án.
- Projekt-specifikáció: `docs/HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md` – teljes egészében újraolvasva.
- Designrendszer-referenciák: `docs/references/source-of-truth/{logo,onboarding,designnkovetelmenyek,checkin_visszaeses_panik,haladas_naptar_stat,eszkozok_12lepes_naplo,sponzor_profil_beallitasok}.png` – közvetlenül megnyitva.
- Érintett tényleges implementáció: `html-prototypes/app-shell/index.html`, ezen belül `HomeInteractionController.renderPracticeSheet()`, `practiceRow()`, `practicePopupHeader()` és `state.practice`.

Az írásos brief a listaelemekhez két információs szintet említ, a korábbi `gyakorlat2.png` értelmezése pedig három sort feltételezett. A felhasználó későbbi, kifejezett utasítása elsőbbséget élvez: a listakártyák pontosan két sort mutatnak (gyakorlatnév és forrás), a részletek kizárólag a szerkesztőben jelennek meg.

## Gyakorlatválasztó architektúra-kártya

### Hatókör és források

- A változás kizárólag a meglévő, középre igazított gyakorlatmanager `manager` nézetének szerkezete és vizuális renderelése.
- A `gyakorlat2.png` a layout, arányok, tipográfia, assetszerep és scroll-hierarchia kizárólagos vizuális forrása.

### Egyetlen forrás és írási út

- Gyakorlatok olvasási modellje: `this.state.practice.practices`.
- Aktív gyakorlat: `this.state.practice.activePracticeId` + `getActivePractice()`.
- Művelet- és perzisztenciaút: a meglévő `openPracticeEditor()`, `setPracticeStatus()` és `flushHomePracticeDraft()`.
- A manager nem vezet be új route-ot, tárolót vagy párhuzamos állapotot.

### Állapottulajdon

| Állapot | Tulajdonos | Élettartam | Publikáció |
| --- | --- | --- | --- |
| Popup-nézet | `state.practice.practicePopupView` | megnyitott overlay | a meglévő popup-host renderelése |
| Aktív gyakorlat | `state.practice.activePracticeId` | perzisztens | `renderHomePracticeBlock()` és manager |
| Gyakorlatlista | `state.practice.practices` | perzisztens | `renderPracticeSheet()` |
| Lista scrollpozíció | `.practice-list-scroll` DOM | popup-élettartam | nem perzisztálódik |

### Újrahasználat és centralizáció

| Jelölt | Meglévő tulajdonos | Döntés | Bizonyíték |
| --- | --- | --- | --- |
| Popup-lifecycle, fókusz, backdrop | `openAppOverlaySheet()` / `closeAppOverlaySheet()` | Változatlanul újrahasznált | nincs második overlay vagy route |
| Gyakorlatok státusza és mentése | `state.practice`, `setPracticeStatus()`, `flushHomePracticeDraft()` | Változatlanul újrahasznált | nincs új állapot-/tárolómodell |
| Gyakorlaticon-asset feloldása | egyetlen `practicePickerArtwork()` controller-metódus | Egyszeri, determinisztikus asset-resolver | az aktív és listakártyák ugyanabból olvasnak |
| Hajnal színek | meglévő `--hajnal-*` tokenek | Új nyers paletta nélkül | scope-olt CSS-inspekció |

### Rétegfolyam

`PracticePicker` HTML → `HomeInteractionController` intent → meglévő gyakorlatállapot → localStorage adapter.

## Elfogadási feltételek

| ID | Forrás | Kódterület | Elfogadási feltétel | Ellenőrzés | Státusz |
| --- | --- | --- | --- | --- | --- |
| GP2-01 | `gyakorlat2.png` §§0, 3 | popup host, `.practice-focus-dialog--manager` | A manager középre igazított, meleg törtfehér, nagy lekerekítésű focus popup; mögötte a jelenlegi főoldal csak blur-ös/sötétített. | 412×892 screenshot + runtime geometria. | DONE |
| GP2-02 | `gyakorlat2.png` §3.A–B + későbbi userutasítás | `practicePopupHeader()`, manager markup | Fix felső rész: `Ezt szeretném gyakorolni` cím, előírt alcím és jobb felső X; nincs vissza gomb és nincs szürke drag handle. | Statikus szerződés + screenshot. | DONE |
| GP2-03 | `gyakorlat2.png` §3.C + későbbi userutasítás | current-practice markup/CSS | Fix, külön levendula aktuális-kártya: helyi generált artwork, állapotcímke, tényleges név és forrás. A teljes kártya szerkesztőt nyit; nincs külön `Részletek` CTA. | Statikus szerződés + 412×892 Playwright screenshot. | DONE — `practice_manager_visual_reference_test.js`, `practice_manager_visual_runtime_test.js`, `practice-picker-gyakorlat2-412.png`. |
| GP2-04 | `gyakorlat2.png` §§3.D, 4 | `.practice-list-shell` | Egyetlen nagy listakonténer: a `Gyakorlataim` cím fixen a konténer tetején marad, és nem része a scrollnak. | Runtime scroll-geometria. | DONE |
| GP2-05 | `gyakorlat2.png` §§3.E–F, 4 | `.practice-list-scroll` | Kizárólag a lista görgethető; a lista végén benne van a `＋ Új gyakorlat hozzáadása` CTA és az alsó dekoráció. | Runtime overflow/scroll teszt. | DONE |
| GP2-06 | `gyakorlat2.png` §§5–6 + legutóbbi userutasítás | `practiceRow()`, `practicePickerArtwork()` | A listakártyák azonos, pasztell artworkos, chevronos, kerekített formák; az ikonok saját, helyi, generált PNG-assetek; a kártyán pontosan a cím és a forrás jelenik meg, harmadik előnézeti sor nélkül. | Asset-inspekció + screenshot. | DONE |
| GP2-07 | User §§2, 8 | manager renderer | Nincs `Szüneteltetett`, `Megőrzött`, állapotszűrő/pill/tab vagy külön csoportosítás; minden nem aktív gyakorlat egyetlen listában marad. | Negatív statikus szerződés + DOM runtime. | DONE |
| GP2-08 | User §§1, 9 + későbbi userutasítás | controller/markup | A gyakorlat-szerkesztő, bezárás és meglévő adat-/perzisztenciaút működik, új state/repository/route nélkül; az elavult Részletek nézet nem marad meg párhuzamosan. | Meglévő manager regresszió + ownership scan. | DONE — aktív/lista szerkesztés a meglévő `openPracticeEditor()` útvonalon, no-details ownership scan és Playwright regresszió. |
| GP2-09 | User §6, imagegen skill | `assets/practice/` | Az aktív és listakártyák pasztell, alacsony telítettségű, átlátszó hátterű generált artwork asseteket használnak; nincsenek generikus material ikonok. | Fájl- és alpha-inspekció + screenshot. | DONE |
| GP2-10 | Project `AGENTS.md` | tesztek + `docs/prototypes/verification/practice-manager-gyakorlat2/` | A forrásreferenciával összevetett 412×892 screenshot és releváns szerződés-/runtime-/regressziós tesztek zöldek. | Parancskimenetek + screenshot. | DONE |
| GP2-11 | Legutóbbi userutasítás | `practiceRow()`, szerkesztő-renderelő, action handler | A kártya fő, szöveges felületére koppintás a szerkesztőt nyitja; kizárólag a jobb oldali chevron aktiválja a gyakorlatot. Hárompontos gomb és context dropdown nincs. A már létező gyakorlat törlése a szerkesztőben elérhető, a meglévő megerősítéssel. | RED/GREEN statikus szerződés, Playwright-interakciós teszt és 412×892 screenshot. | DONE — `practice_manager_visual_reference_test.js`, Ubuntu/Chromium runtime és `practice-picker-gyakorlat2-412.png`. |
