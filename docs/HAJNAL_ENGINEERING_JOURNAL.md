# Hajnal engineering journal

## S0 előkészítés — 2026-11-26

A `feat/first-prototype-page` worktree biztonságos fast-forwarddal `c9c0afe` állapotra frissült. A meglévő HTML és dokumentációs módosítások nem részei az S0 munkának. A referencia `app-shell` aktív munkapéldánya helyi módosításokat tartalmaz; a home kártya és gesztus közvetlen vizsgálata megtörtént. A kötelező PNG-ket és az aktuális háttérképet megtekintettem. A repóban jelenleg nincs Flutter scaffold. A repo secret lista nem adott vissza secretet; a tartós CI aláírókulcs hozzáférhetősége nincs igazolva.

## S0 implementáció — folyamatban

A `build/starter` ágon az első köztes commit `f60b4dd`, a CI-t és további teszteket tartalmazó következő commit `47c44ce`. A naptári, adatbázis-, bootstrap-, dashboard- és artwork-részhez helyi célzott tesztek készültek; ez nem jelenti a teljes S0 elfogadását. A `47c44ce` GitHub-futás ellenőrzési lépései után az artifact-feltöltés a fiók Actions-tárhelykvótája miatt meghiúsult; az emulátoros és HUMAN kapu emiatt kimaradt. Az új futás a napló feltöltési problémáját a tesztkaputól elkülöníti, miközben a screenshot artifact és a HUMAN kiadás továbbra is kapuzott. iOS fizikai ellenőrzés nem történt.

A `f206da3` futásban a `verify` sikeres és a debug APK lefordult; a HTML screenshot az `ubuntu-latest` 26.04-es verziója és a Playwright 1.56.1 inkompatibilitása miatt nem készült el. A következő futás 24.04-re rögzül, és a HTML-referencia külön jobba kerül, hogy hibája ne akadályozza a natív vizsgálatot. A tényleges 23 és 25 órás budapesti DST napokra külön ellenőrzés készült.

A `192dbd7` futásban a `verify` és a HTML-referencia renderelése sikerült, de az utóbbi artifact-feltöltését a fiók tárhelykvótája megakadályozta. Az Android debug APK elkészült; az emulátor nem indult, mert a GitHub-runner lemezén nem maradt elég hely. A következő futás a csak azon a friss runneren lévő, nem használt SDK-k törlésével szabadít helyet. A natív és screenshot bizonyíték, az aláírt kiadás és a fizikai iOS-ellenőrzés továbbra sem igazolt.

A `f3eb5b2` futásban a runneren rendelkezésre álló lemezterület nem volt elég az emulátor adatpartíciójához. A `0a6e4f4` 3 GiB-os partícióbeállítása ellenére az emulátor 7372,80 MB-ot kért, miközben 6147,46 MB állt rendelkezésre; ezért a következő futás további, a teszthez nem használt eszközöket távolít el a rövid életű runneréről. Az artifactkvóta hibája ettől független. Az ellenőrzött helyi tesztkészlet 50 tesztből áll, és a statikus elemzés sikeres; az emulátoros és kiadási eredményt a pontos commit Actions-futása igazolja majd.

A `32f8202` futásban az emulátor elindult, az aláírt profile diagnosztikai build elkészült, és az apksigner érvényes v2 aláírást jelzett. A natív teszt előtt a futtató soronként külön shellt indított, így a `cd` elveszett; a következő commit egyetlen shellszkriptre vált. A HTML screenshotok a kvótahiba után a futási naplóból visszanyerhetők, de ez nem helyettesíti az artifact- és kiadási kaput.

A `6c7797e` futásban az emulátor és a shellszkript is elindult; a natív teszt fordítása a Flutter debugfüggősége által behozott AndroidX teszt-runner 1.2.0 és a natív teszt 1.6.2 verziója közötti Gradle-konzisztenciakorláton állt meg. A debug futásidejű függőség egységesítése és a natív teszt előzetes CI-fordítása ezt célozza; az új verzió eredménye még ellenőrzendő.

## Alkalmazászár — folyamatban

A felhasználó által megadott háromképernyős referenciát és az eredeti SVG-t a repó verziózott assetjei közé helyeztük. Az alkalmazászárhoz külön domain állapotgép, beállítási koordinátor, tárolási adapterek és teljes navigációs fát fedő zár készült. A Drift v1→v2 migráció az időszakot és az artwork-adatokat megőrzi. Az ellenőrzött PIN Argon2id-vel készül, a titkos tárolóban a mód is szerepel; egy tranzakciós mutatóváltás őrzi a korábbi beállítást sikertelen írásnál. A helyi tesztek nem bizonyítják a tényleges biometrikus hardvert, az iOS működést, a képernyők referenciaegyezését vagy a telepített APK frissíthetőségét: ezekhez külön CI- és eszközbizonyíték szükséges.

A `c587ed7` GitHub-futás második próbája lefordította az Android debug és aláírt HUMAN buildet, az aláíró tanúsítvány ellenőrzése sikerült. Az onboarding, újraindítás és nappali/éjszakai natív dátumválasztó tesztje emulátoron sikerült. A zárteszt első változata a `FLAG_ACTIVITY_CLEAR_TASK` használatával maga törölte az útvonalat, majd azt várta vissza; a tesztet a meglévő feladat előtérbe hozására javítottuk. Kiadás és vizuális elfogadás nem történt.

A `0ad1270` futásban a 106 Flutter-teszt, az Android lock és launcher teszt, valamint a korábbi aláírt APK-ról történő adatmegőrző frissítési teszt sikerült. A három vizuális tesztkép átvétele hibás volt: a `flutter test` a teszt végén eltávolítja az alkalmazást, így a privát fájlok nem olvashatók ki utólag. A képek immár a `flutter drive` hostoldali válaszkezelőjén keresztül, PNG-aláírás ellenőrzésével kerülnek át; a vizuális elfogadás továbbra is nyitott.
