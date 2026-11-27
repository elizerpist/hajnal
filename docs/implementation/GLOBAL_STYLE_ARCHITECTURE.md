# Globális stílus és onboarding – architektúrakártya

Forrás: a felhasználó globális stílusrendszerről szóló megbízása, a Flutter-specifikáció és a meglévő onboarding- és zárarchitektúra. Vizuális források: `docs/references/source-of-truth/pin.png`, `boarding1.png`, `boarding2.png`, `logo.png`, `onboarding.png`, `designnkovetelmenyek.png`, `checkin_visszaeses_panik.png`, `haladas_naptar_stat.png`, `eszkozok_12lepes_naplo.png`, `sponzor_profil_beallitasok.png`. A felhasználói szöveg a régi három szponzoropciót és vizuális méreteket felülírja.

## Tulajdonosok és írási út

Az aktív, verziózott stílust a meglévő Drift-adatbázis egyetlen rekordja tárolja; csak a stílusrepository írja, optimista revision-ellenőrzéssel. Az alkalmazás által publikált mentett értéknek egy app-élettartamú tulajdonosa van. A szerkesztő külön controllere birtokolja az ideiglenes piszkozatot; az egyetlen mentési use case előbb validál és ment, csak siker után publikál. A hibás adat gyári megjelenést eredményez, más adatot és az alkalmazászárat nem módosítja.

Az onboarding végleges és piszkozatadatait továbbra is az OnboardingController és a meglévő tranzakciós repository birtokolja; a szponzor adatát a SponsorRepository, az időszakot a RecoveryRepository írja. A naptár egyetlen állapottulajdonosa külön kezeli a kijelölt napot, a böngészett hónapot és a nyitott panelt. A mai nap és napszám a meglévő DayTracker és recovery-domain eredménye. A lifecycle és a lock tulajdonosa változatlan.

## Réteg és újrafelhasználás

UI → szerkesztőcontroller → mentési use case → stílusrepository → Drift. A tiszta, immutable stílusmodell nem tartalmaz Flutter-típusokat; a `core/theme` egyetlen adaptere és közös komponensei alakítják megjelenéssé. A meglévő theme/token, navigáció, naptári validáció, onboarding-tranzakció és logóasset bővül; párhuzamos életciklus-, navigációs, naptár- vagy stílusmotor nem készül. A témaváltás nem hozhat létre új lock-, onboarding- vagy daytrackert, navigátort vagy DB-kapcsolatot.

## Ellenőrzés és review

Szükséges a modell- és mentésvalidáció, stale és sérült adatok, megőrző migráció, draft/mentés viselkedése, több képernyőn tényleges stílusfogyasztás, naptár- és szponzorregresszió, teljes lock és dashboard suite, import- és írásitulajdonos-boundary teszt. A tényleges screenshotokat és a launcher maszkokat egyben kell felülvizsgálni. A tesztelt, aláírt bináris csak sikeres megőrző upgrade után publikálható; iOS és fizikai biometria csak tényleges eszközteszt esetén állítható ellenőrzöttnek.

A tényleges tulajdonosok: `StyleOwner` a mentett aktív állapoté, `StyleEditorController` a piszkozaté, `SaveStyle` a validált írásé, `StyleRepository` az egyetlen tartós írási úté. A `HajnalStyle` adapter és a közös komponensek oldják fel a Flutter-megjelenést; a domainmodell Flutter-függőség nélküli. A `StyleSettings` v4-es tábla bevezetése nem változtatja a többi táblát. A `style_boundary_test.dart` a szerepfeloldást és tulajdonost, a dependency suite az irányokat, a repository- és widgettesztek a verzióütközést, tartósságot és tényleges állapottartást ellenőrzik. A fennmaradó eszközös és vizuális kapuk állapota az elfogadási listában szerepel.
