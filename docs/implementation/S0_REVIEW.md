# S0 célzott architektúra- és Ponytail-review

Forrás: `HAJNAL_S0_STARTER_PROMPT.md`, a 2026-11-26-i felhasználói kiegészítés és `S0_ARCHITECTURE.md`. A review a tényleges hívási útvonalakat és teszteket vizsgálja; az eredményeket az elfogadási lista követi.

| Állapot / útvonal | Tulajdonos és review |
|---|---|
| RecoveryPeriod | Drift az egyetlen tartós igazságforrás; onboarding → BootstrapController → InitializeRecovery → RecoveryStore → RecoveryRepository → Drift. Az egyetlen aktív időszakot adatbázis-korlát védi. |
| Dátum és lifecycle | DayTracker tulajdonolja az előtéri időzítőket, a naptári számítás tiszta domainfüggvény. A kezdőnap nem alakul át időzónaváltáskor. |
| Dashboard | Egyetlen interakciós tulajdonos és pozíció-progress maradt. A Back-jelzés csak nyitott/zárt váltásnál értesül; a statikus Scaffold/háttér nem épül újra animációs frame-enként. A DashboardLayout a közös, tisztán tesztelhető geometriai döntés. |
| Artwork | Az ArtworkService sorosítja a módosításokat, az ArtworkStore szerződést egyetlen DriftArtworkStore adapter valósítja meg. A renderer a ténylegesen használt fájlt tartja meg; nem végez descriptor- vagy fájlírást. |
| Kiadás | A megbízható ág kiadási jobja a tényleges tesztekre, screenshotokra és a pontos SHA-hoz kötött vizuális review-ra épít. A Release után a nyilvános byte-ok és hash ellenőrzése előzi meg a Pages módosítását. PR nem kap aláírókulcsot vagy írási jogot. |

Megtalált és javított kockázatok: a dashboard progress minden frame-ben újraépítette az egész oldalt; az artwork korábbi módosításai árva fájlt hagyhattak és nem voltak sorosítva; kétes DB-commit után egy hivatkozott fájl törlődhetett; a korábbi CI egy elfogyott artifactkvótától függött, és a Gradle instrumentation törölte az appot a restart teszt előtt. Az utóbbi javításokat a lent hivatkozott Android- és Release-futás igazolta.

A `test/architecture` a Dart szintaxisfán vizsgálja a production importokat, feltételes importokat, exportokat és reexportokat; külön ellenőrzi a konkrét adatbázis-/fájlrendszer- és platformtulajdonosokat. Az adattartósság és a konkurencia helyességét nem a forrásszöveg-keresés, hanem DB- és viselkedési tesztek bizonyítják. iOS-eszközös build/teszt és valódi fizikai Android készülékes ellenőrzés külön nyitott.

## Szemrevételezett összevetés és futás

A `8e43cf78cbc91346313a6bf0c1d8f3fee773337a` commit [Actions-futásában](https://github.com/elizerpist/hajnal/actions/runs/45863321576) a 68 Flutter teszt, az Android DatePicker/relaunch, az artwork-integráció és az aláírt újratelepítési próba sikeres volt. Az öt 412×892 képet és az azokra számított hash-eket a commit release-piszkozatában vizsgáltuk. A háttér, a 296×118-as, középen elválasztott kártya és a 96 pixeles együttmozgás összevethető; az Android rendszer-navigációs területe mellett a kártya 48 pixellel feljebb látszik. Az alsó navigáció, a jobb oldali tartalom és a panel funkciói az S0 kifejezett előírása szerint hiányoznak. A helyi app-shell más munkából származó módosításait megőriztük; a vizsgált home/sheet horgonyok a diffben nem változtak, a CI a commitált referenciáról készített képet.

A futás második próbája minden kapun átment, és a [nyilvános Release](https://github.com/elizerpist/hajnal/releases/tag/hajnal-s0-8e43cf78cbc9) mellett a [Pages letöltőoldal](https://elizerpist.github.io/hajnal/download/) is elkészült. A helyileg hitelesítés nélkül letöltött APK SHA-256 értéke `51117ce8f163f5fcbfd109e9001bf4e4a4a57f951c40f14679d16c862ea81f31`; az 1.0.0 (13) bináris APK-v2 aláírása igazolt. Ez az első nyilvános kiadás, ezért az emulátoron ugyanazon tartós kulccsal aláírt csomag újratelepítése és adatmegőrzése igazolt; egy későbbi, eltérő verzióról történő frissítést a következő kiadás fog ténylegesen tesztelni. iOS build és fizikai készülékes teszt továbbra sem történt.
