# S0 célzott architektúra- és Ponytail-review

Forrás: `HAJNAL_S0_STARTER_PROMPT.md`, a 2026-11-26-i felhasználói kiegészítés és `S0_ARCHITECTURE.md`. A review a tényleges hívási útvonalakat és teszteket vizsgálja; az eredményeket az elfogadási lista követi.

| Állapot / útvonal | Tulajdonos és review |
|---|---|
| RecoveryPeriod | Drift az egyetlen tartós igazságforrás; onboarding → BootstrapController → InitializeRecovery → RecoveryStore → RecoveryRepository → Drift. Az egyetlen aktív időszakot adatbázis-korlát védi. |
| Dátum és lifecycle | DayTracker tulajdonolja az előtéri időzítőket, a naptári számítás tiszta domainfüggvény. A kezdőnap nem alakul át időzónaváltáskor. |
| Dashboard | Egyetlen interakciós tulajdonos és pozíció-progress maradt. A Back-jelzés csak nyitott/zárt váltásnál értesül; a statikus Scaffold/háttér nem épül újra animációs frame-enként. A DashboardLayout a közös, tisztán tesztelhető geometriai döntés. |
| Artwork | Az ArtworkService sorosítja a módosításokat, az ArtworkStore szerződést egyetlen DriftArtworkStore adapter valósítja meg. A renderer a ténylegesen használt fájlt tartja meg; nem végez descriptor- vagy fájlírást. |
| Kiadás | A megbízható ág kiadási jobja a tényleges tesztekre, screenshotokra és a pontos SHA-hoz kötött vizuális review-ra épít. A Release után a nyilvános byte-ok és hash ellenőrzése előzi meg a Pages módosítását. PR nem kap aláírókulcsot vagy írási jogot. |

Megtalált és javított kockázatok: a dashboard progress minden frame-ben újraépítette az egész oldalt; az artwork korábbi módosításai árva fájlt hagyhattak és nem voltak sorosítva; kétes DB-commit után egy hivatkozott fájl törlődhetett; a korábbi CI egy elfogyott artifactkvótától függött, és a Gradle instrumentation törölte az appot a restart teszt előtt. Az utóbbi javítások éles Android/Release bizonyítéka a CI-ben ellenőrzendő.

A `test/architecture` a Dart szintaxisfán vizsgálja a production importokat, feltételes importokat, exportokat és reexportokat; külön ellenőrzi a konkrét adatbázis-/fájlrendszer- és platformtulajdonosokat. Az adattartósság és a konkurencia helyességét nem a forrásszöveg-keresés, hanem DB- és viselkedési tesztek bizonyítják. iOS-eszközös build/teszt és valódi fizikai Android készülékes ellenőrzés külön nyitott.
