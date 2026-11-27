# Globális stílus és onboarding – elfogadási lista

Forrás: a felhasználó 1–22. pontja; `docs/references/source-of-truth/pin.png`, `boarding1.png`, `boarding2.png` és az architektúrakártyában felsorolt hét arculati referencia. Az új szöveg felülírja a régi képek három szponzorválasztását és az eltérő tipográfiai méreteket. Státusz csak tényleges bizonyíték alapján módosítható.

| ID | Forrás | Terület | Elfogadási feltétel | Ellenőrzés | Állapot |
|---|---|---|---|---|---|
| GS-01 | 1–5 | theme, minden consumer | Egy globális típus és írási út; nincs feature-override | boundary, widget | PARTIAL |
| GS-02 | 6 | theme, font assets | Nyolc pontos szövegszerep és használt külön szerepek, két offline licencelt font, rendszeres nagyítás | unit, widget, asset/licenc | PARTIAL |
| GS-03 | 6 | editor | Szerkeszthető editor-alap, mentett tartalom változatlan | widget, persistence | PARTIAL |
| GS-04 | 7–8 | core/theme | Három kártya, választóállapotok, két gomb, kompakt Ma és validált térközök | widget, accessibility | PARTIAL |
| GS-05 | 9 | style editor | Név szerinti globális definíciók, minden előírt tulajdonság és közös komponens-előnézet | widget, képek | PARTIAL |
| GS-06 | 9 | style editor | Értékbevitel, palettakapcsolat, reset, kontrasztjelzés, draft, apply, cancel és Back | widget, unit | PARTIAL |
| GS-07 | 10 | model/repository/database | Validált verziózott JSON, tranzakció, revision, sérült és hiányzó adat, megőrző migráció | unit, DB, restart | PARTIAL |
| GS-08 | 10–11 | app és összes consumer | Téma érvényesül onboardingon és záron; route, draft, zár és állapottulajdonosok megmaradnak | widget, boundary | PARTIAL |
| GS-09 | 12 | welcome | Két felirat és helyük megszűnik, logó és CTA megmarad | widget, screenshot | PARTIAL |
| GS-10 | 13–15 | calendar | Felső év/hónap, közös panel, böngészés külön, Ma minden állapotban, jövő tiltva, helyes mai kör | widget, különböző DPI-s képek | PARTIAL |
| GS-11 | 16 | sponsor/onboarding | Két típusos választás; régi draft kompatibilis; kihagyás és tranzakció megőrző | unit, DB, widget | PARTIAL |
| GS-12 | 17 | brand generator/platform | Eredeti assetből reprodukálható crop, Android adaptive/round és iOS ikon; maszk kitöltve | képi maszk és launcher | PARTIAL |
| GS-13 | 18 | dashboard/drawer | Keret nélküli, 48 dp Menü és működő Stílus navigáció | widget, screenshot | PARTIAL |
| GS-14 | 19 | tests | Teljes style, calendar, sponsor, onboarding, lock, dashboard és boundary suite | analyze és tesztnapló | NOT DONE |
| GS-15 | 19 | visual | Alap és módosított téma, editor, naptárpanelek, sponsor, hamburger, launcher tényleges vizsgálata | screenshotok | NOT DONE |
| GS-16 | 20–21 | CI/release | Ugyanazon commit sikeres ellenőrzése és aláírt, növekvő verziójú, adatmegőrző upgrade, publikus Release és Pages | Actions, adb, aláírás, hash | NOT DONE |
| GS-17 | 21–22 | platform/docs | iOS és fizikai biometria tényleges határai; mérnöki napló és review | önellenőrzés | NOT DONE |
| GS-18 | Utólagos SVG-kiegészítés | assets/artwork/onboarding/welcome.svg, Welcome 1 | A négy megjelölt lila égbolt-path eltűnik, a pontos új gradient_0 a felső szélig tart; viewBox, háttér, hold, csillagok, jobb felhő és táj megmarad | SVG-szerkezeti teszt, tényleges render és kiadási Welcome 1 screenshot | PARTIAL |

A PARTIAL státusz azt jelenti, hogy a megvalósítás és a helyi célzott vizsgálat elkészült, de az adott commit emulátoros, illetve képi vagy kiadási bizonyítéka még hiányzik. A pontos lezárási eredményt az új forráscommit futásához kell kötni; a korábbi kiadás nem bizonyítja az új változatot.
