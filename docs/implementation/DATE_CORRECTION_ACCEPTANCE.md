# Kezdődátum-korrekció: architektúra és elfogadás

Forrás: a felhasználó 2026-11-26-i feladata; régi vizuális referencia: `docs/references/source-of-truth/onboarding.png` (a naptárra a natív Android dialogra vonatkozó új utasítás irányadó); `html-prototypes/app-shell/index.html`. A felhasználó a tervet és implementációt jóváhagyta.

Tulajdonosok: a RecoveryPeriod tartós igazságforrása változatlanul a Drift/SQLite. Az aktív ID és dátum a repository streamen, szerkesztési pillanatkép az onboardingnál, mentési állapot a BootstrapControllerben, származtatott napszám a DayTrackerben van. Írás: onboarding → controller → külön korrekciós use case → RecoveryStore → Drift repository → ID-ra és aktív állapotra feltételes update. Az initialize idempotens marad. A meglévő platformadapter és natív DatePickerDialog marad; Android activity theme adja a rendszeres kinézetet. A korábbi DB-fájl, artwork és applicationId változatlan. Boundary suite az importokat és a kijelölt írási tulajdonost ellenőrzi.

| ID | Forrás | Terület | Elfogadás | Ellenőrzés | Állapot |
|---|---|---|---|---|---|
| D01 | felhasználó §1 | onboarding/controller | Mentett dátum kijelölve; választás tervezet, Back/Cancel nem ment | widget | PARTIAL — helyi widgettesztek sikeresek; CI hátravan. |
| D02 | §1 | use case/repository | Korábbi/későbbi/mai; jövő elutasítva, ID/createdAt változatlan, elavult ID és zárt rekord nem írható | DB/use case | PARTIAL — helyi adatbázistesztek sikeresek; CI hátravan. |
| D03 | §1 | controller | Dupla mentés és DB-hiba, siker nélkül nincs navigálás; reaktív nap és restart | widget/DB | PARTIAL — helyi widget/DB-tesztek sikeresek; CI és natív restart hátravan. |
| D04 | §2 | Android theme/picker | Merged manifest, nappali/éjszakai rendszeres framework dialog, natív választás/cancel és screenshot | natív emulátor/manifest | NOT DONE |
| D05 | §3 | CI és APK | Előző tényleges HUMAN APK → új APK install -r, adat/ID/createdAt/artwork megőrzés és korrekció restarttal | aláírt emulátoros upgrade | NOT DONE |
| D06 | §3–4 | CI release | Stabil app ID, korábbi tanúsítvány, nagyobb versionCode, ugyanazon SHA-hoz kötött Release/Pages | apksigner/aapt/HTTP/hash | NOT DONE |
| D07 | §4 | docs/boundary | Ütköző spec és teszt frissítve, egy írási tulajdonos és teljes releváns teszt | architecture, CI, review | NOT DONE |
