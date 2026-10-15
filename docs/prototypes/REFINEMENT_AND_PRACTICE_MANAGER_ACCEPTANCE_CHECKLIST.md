# Fókuszált finomítások és gyakorlatmanager – elfogadási lista

## Kötelező források

- Felhasználói utasítás: 2026-10-15, Sponzor / Legközelebb / Pánik / Történetem / Gyűlések / Főmenü és Gyakorlatmanager prompt.
- Ellenőrzött vizuális referencia: `/storage/emulated/0/hajnal/source of truth/sponzoradatok.png`.
- Gyakorlatmanager vizuális referencia: `/storage/emulated/0/Pictures/Screenshots/Screenshot_20261015-192913.png`.
- Gyakorlatszerkesztő vizuális referencia: `/storage/emulated/0/Pictures/Screenshots/Screenshot_20261015-194007.png`.

Az utóbbi két screenshot az Android képszerkesztő felületén látszik; kizárólag a középre igazított világos popup belső geometriája, tipográfiája, felületkezelése és a sötétített háttér az irányadó. A megjelenített demonstrációs légzőgyakorlat-tartalom nem kerül a Hajnal gyakorlat-adatmodelljébe.

## Architektúra-kártya

| Téma | Egyetlen tulajdonos | Újrahasználat / írási út |
| --- | --- | --- |
| Gyakorlatok | `state.practice` | `persistPracticeEveningState()`; nincs második tároló |
| Popup-életciklus | meglévő `data-app-overlay-sheet` host | egy `practicePopupView` belső nézet, `openAppOverlaySheet()` / `closeAppOverlaySheet()` |
| Napi reflexió | `state.evening.sessions` | az indítás új munkamenetet választ, a meglévő napi rekordot tölti |
| Sponsor elérhetőség | `state.sponsor.availability` | `autoSaveSponsorDetails()` |
| Gyűlések és naptárak | meglévő meeting-/History renderer | csak közös kártya- és dátumfeloldó használható |

## Elfogadási feltételek

| ID | Követelmény | Kódterület | Ellenőrzés | Státusz |
| --- | --- | --- | --- | --- |
| RPM-01 | Sponsor adatai egy 412×892 képernyőn indokolatlan oldal-scroll nélkül, kompaktabb időmezőkkel jelenik meg. | Sponsor CSS | `sponsor_contact_workspace_runtime_test.js`, `06-sponsor-details-availability.png` | DONE |
| RPM-02 | Legközelebb naptárban nincs timebox: a kiválasztott napra az Android time pickerből hozható létre új találkozó. | Sponsor-next controller | `sponsor_contact_workspace_runtime_test.js`, `05-sponsor-next-calendar.png` | DONE |
| RPM-03 | Pánik inline meeting-kártyája nem vágódik le, a fő elemek feljebb rendeződnek. | Panic CSS | `panic_alternative_test.js`, `09-panic-next-meeting.png` | DONE |
| RPM-04 | History expanded metrics kompaktabb, artwork balra kifakul; a grid nem zsugorodik és napi eseménykártyákat mutat. | History renderer/CSS | `history_full_page_pager_{test,runtime_test}.js`, `history-metrics-expanded.png` | DONE |
| RPM-05 | Gyűlésrészlet a Sponsor adatai geometriáját és a közös BottomNavot használja. | Meeting-detail CSS/navigation | `sponsor_contact_workspace_runtime_test.js`, `12-meeting-detail.png` | DONE |
| RPM-06 | Napi reflexió új megnyitáskor első állomásról indul és bezárás után a Főmenü swipe/gombjai működnek. | Daily reflection lifecycle | `practice_manager_runtime_test.js` | DONE |
| RPM-07 | Az Amit gyakorlok manager és editor középre igazított focus popup, közös state/overlay tulajdonossal. | Practice renderer/CSS | `refinement_practice_manager_test.js`, `practice_manager_runtime_test.js`, `13–15-practice-*.png` | DONE |
| RPM-08 | Egy aktív gyakorlat van; szerkesztés, szüneteltetés, archiválás, aktiválás és törlés nem veszít történeti reflexiót. | Practice controller | `home_practice_evening_wizard_test.js` | DONE |
| RPM-09 | Ösvény forrásból és saját gyakorlatból is ugyanaz az editor nyílik; napi reflexió a snapshotot és opcionális jegyzetet használja. | Practice/reflection integration | `home_practice_evening_wizard_test.js`, `practice_manager_runtime_test.js`, `16-daily-reflection-practice-note.png` | DONE |
