# Sponsor, Pánik és találkozók – elfogadási lista

## Kötelező források

- Felhasználói specifikáció: 2026-10-15, `prompt1`–`prompt4`.
- Képernyőreferencia: `/storage/emulated/0/hajnal/source of truth/sponzoradatok.png`.
- Designrendszer: `docs/references/source-of-truth/{logo,onboarding,designnkovetelmenyek,checkin_visszaeses_panik,haladas_naptar_stat,eszkozok_12lepes_naplo,sponzor_profil_beallitasok}.png`.
- Implementáció: `html-prototypes/app-shell/index.html`.

## Architektúra-kártya

| Téma | Tulajdonos és újrahasználat | Egyetlen írási út |
| --- | --- | --- |
| Szponzor elérhetőség | `HomeInteractionController.state.sponsor`; a meglévő auto-save út bővül `availability` adatokkal | `autoSaveSponsorDetails()` |
| Natív dátum/idő | Láthatatlan, valódi `input[type=date]` és `input[type=time]`, a meglévő detail renderer vizuális proxyi mögött | input `change` → controller intent → sponsor auto-save |
| Következő meeting | Meglévő `meetingInstancesInRange()`, `meetingOccurrenceKey()`, `meetingAttendance()` | közös, rendezett meeting-előfordulás feloldó |
| Pánik meeting-kártya | `panicNextMeetingOpen` és kijelölt találat indexe csak a controller lokális UI-állapota | pánik intentek; nincs route-váltás |
| Szponzor Legközelebb | Meglévő `sponsor-next` route és meeting-kártya komponens | `nextConversation` meglevő mentési útja |

## Elfogadási feltételek

| ID | Követelmény | Kódterület | Ellenőrzés | Státusz |
| --- | --- | --- | --- | --- |
| SPM-01 | A Sponsor adatai fehér fő kártyájában jelenik meg a hét napos rail, a Bármikor pill és az inline napeditor. | Sponsor-details renderer/CSS | `sponsor_panic_meetings_refinement_test.js` zöld; 412 px screenshot böngésző hiányában függőben | PARTIAL |
| SPM-02 | A kijelölt nap lila, a többi kompakt; naponként külön enabled/start/end állapot marad meg. | Sponsor availability state/controller | állapot és renderer szerződéses teszt zöld; interaktív böngészőteszt függőben | PARTIAL |
| SPM-03 | A Bármikor mód nem törli a korábbi heti beosztást, csak letiltja a szerkesztést. | Sponsor availability state/controller | controller közös `availability.mode`/`days` állapottal kész; böngészős állapotváltás függőben | PARTIAL |
| SPM-04 | Tól/Ig és Sponzorom mióta valódi natív time/date inputot nyit, külön sheet vagy route nélkül. | Sponsor details event bridge | valódi `input[type=time/date]` és `showPicker()` bridge szerződése zöld; Android Chrome picker függőben | PARTIAL |
| SPM-05 | Minden sponsor adat automatikusan mentődik; nincs Mentés CTA. | Sponsor auto-save | controller `autoSaveSponsorDetails()` és CTA-hiány szerződése zöld; újratöltéses böngészőteszt függőben | PARTIAL |
| SPM-06 | A Pánik mód kizárólag a pulzáló gombos, három gyorscsempés elrendezést mutatja; nincs layoutválasztó. | Panic renderer/CSS | `panic_alternative_test.js` és forrás-szerződés zöld; screenshot függőben | PARTIAL |
| SPM-07 | Pánikból a Következő gyűlés helyben, route-váltás nélkül nyílik ki, és a valóban soron következő alkalmat mutatja. | shared meeting resolver + panic renderer | közös előfordulás-feloldó és inline panel szerződése zöld; runtime-interakció függőben | PARTIAL |
| SPM-08 | Online/személyes meeting elsődleges akciója és alkalomspecifikus Ott leszek állapota a meglévő meeting adatokkal szinkronban működik. | meeting action/controller | occurrence-kulcsos attendance és elsődleges action forrásellenőrzése zöld; böngészős végpontteszt függőben | PARTIAL |
| SPM-09 | Sponsor Legközelebb képernyőn BottomNav, Meetings-szerű lista/naptár selector, jelölt napok és időmentő kártya van. | sponsor-next renderer/CSS | szerződéses teszt zöld; screenshot függőben | PARTIAL |
| SPM-10 | Lista módban a következő találkozó hero-kártya alatt a korábbi alkalmak Meetings-kártya formában és scrollozható bodyban jelennek meg. | sponsor-next renderer | szerződéses teszt zöld; scroll runtime ellenőrzés függőben | PARTIAL |
| SPM-11 | 360 / 390 / 412 px szélességen nincs vízszintes overflow és a BottomNav nem takar ki akciót. | CSS/layout | Playwright/Chromium nincs telepítve ebben a környezetben | BLOCKED |
| SPM-12 | A régi availability sheet, sponsor-since calendar és második panic layout útvonala nem marad aktív navigációs célként. | actions/routes/CSS | `sponsor_panic_meetings_refinement_test.js` zöld | DONE |
| SPM-13 | 2026-10-17 user: „az event cardok közt nincs padding, annyi padding legyen, mint a gyűlések lista modeban” | `renderSponsorNextListView()`, `renderSponsorConversationCardsForDate()` | A Szponzor / Legközelebb korábbi és kijelölt napi beszélgetéskártyái a meglévő `meetings-day-list` távolságot használják, nem külön lokális spacinget. | RED/GREEN source-szerződés és 412 px Playwright mért gap-összehasonlítás. | DONE — `sponsor_panic_meetings_refinement_test.js` és `sponsor_contact_workspace_runtime_test.js`. |
