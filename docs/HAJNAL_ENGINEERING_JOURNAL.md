# Hajnal engineering journal

## S0 előkészítés — 2026-11-26

A `feat/first-prototype-page` worktree biztonságos fast-forwarddal `c9c0afe` állapotra frissült. A meglévő HTML és dokumentációs módosítások nem részei az S0 munkának. A referencia `app-shell` aktív munkapéldánya helyi módosításokat tartalmaz; a home kártya és gesztus közvetlen vizsgálata megtörtént. A kötelező PNG-ket és az aktuális háttérképet megtekintettem. A repóban jelenleg nincs Flutter scaffold. A repo secret lista nem adott vissza secretet; a tartós CI aláírókulcs hozzáférhetősége nincs igazolva.

## S0 implementáció — folyamatban

A `build/starter` ágon az első köztes commit `f60b4dd`, a CI-t és további teszteket tartalmazó következő commit `47c44ce`. A naptári, adatbázis-, bootstrap-, dashboard- és artwork-részhez helyi célzott tesztek készültek; ez nem jelenti a teljes S0 elfogadását. A `47c44ce` GitHub-futás ellenőrzési lépései után az artifact-feltöltés a fiók Actions-tárhelykvótája miatt meghiúsult; az emulátoros és HUMAN kapu emiatt kimaradt. Az új futás a napló feltöltési problémáját a tesztkaputól elkülöníti, miközben a screenshot artifact és a HUMAN kiadás továbbra is kapuzott. iOS fizikai ellenőrzés nem történt.

A `f206da3` futásban a `verify` sikeres és a debug APK lefordult; a HTML screenshot az `ubuntu-latest` 26.04-es verziója és a Playwright 1.56.1 inkompatibilitása miatt nem készült el. A következő futás 24.04-re rögzül, és a HTML-referencia külön jobba kerül, hogy hibája ne akadályozza a natív vizsgálatot. A tényleges 23 és 25 órás budapesti DST napokra külön ellenőrzés készült.
