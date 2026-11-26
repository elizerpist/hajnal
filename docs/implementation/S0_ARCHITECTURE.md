# Hajnal S0 architektúrakártya

Forrás: `HAJNAL_S0_STARTER_PROMPT.md`, különösen §§3–8; `docs/HAJNAL_FLUTTER_SPECIFIKACIO.md` 0.3. Az állapot és ellenőrzések a `S0_ACCEPTANCE.md` fájlban vannak.

- Tartós igazságforrás: app-private Drift/SQLite. Egyetlen hivatalos időszakírás: onboarding controller → inicializáló use case → repository → tranzakció. Egy aktív rekordot adatbázis-korlát véd. A kezdőnap lokális naptári dátum, a létrehozás UTC pillanat.
- Kiolvasás: repository stream → view-model → megjelenítés. UI-állapot a menü, sheet progress és szerkesztési dátum; tartós időszakállapot a DB-é. Nincs mentett napszámláló vagy onboardingComplete.
- Tiszta naptári motor injektált órával; egy foreground-életciklus tulajdonos kezeli az éjféli és ritka kontextusellenőrző időzítőt. A platformadapter a kompozíciós gyökéren csatlakozik.
- A dátumválasztó közös szerződés mögött platformadapter; a widget nem hív MethodChannelt. A lifecycle és konkurens kérések az adapter felelőssége.
- Egy artwork resolver és renderer; a repository ellenőrzött, verziózott privát fájlt és tartós relatív leírót kezel. Hibánál előző kép vagy bundle fallback; nincs hálózat.
- A dashboard egy progressből számolja a kártya és üres panel helyét. Referencia: `html-prototypes/app-shell/index.html` `.home-metrics`, `.home-body`, `HomeInteractionController`; korábbi statikus állapot: `html-prototypes/offline-ui/index.html`. A helyi app-shell módosított, ezért a vizuális összehasonlításnál ezt az állapotot is külön dokumentálni kell.
- Ellenőrzés: boundary + domain + DB + widget, Android natív emulátor és restart, HTML/Flutter screenshotok, pontos SHA-s CI. iOS fizikai ellenőrzés külön nyitott.

Implementációs ág: `build/starter`; a `feat/first-prototype-page` a prototípus ága.

Fejlesztői alkalmazásazonosító: Android `hu.elizerpist.hajnal`; az iOS bundle-azonosító ugyanez. A rögzített CI eszközlánc Flutter 3.41.4 / Dart 3.11.1, Java 17 és Android API 35. A tartós fejlesztői kulcs a repón kívül van, a CI csak secretekből kapja. A közös Dart és az iOS-váz léte nem bizonyít iOS-en futtatást: iOS build és fizikai eszközvizsgálat még nem történt.

Az artwork felületi szerződése szerepazonosítót használ; az `ArtworkService` kizárólagos tulajdonosa a privát override-fájl és descriptor frissítésének. A repository és a platformadapter konkrét típusait csak a kompozíciós gyökér köti be, a képernyők a szerződéseket fogyasztják. Az adatbázis nyitását, az artwork inicializálását és lezárását a nem widget `AppServices` kezeli.

## Célzott refaktor és nyilvános átadás — architektúrakártya

Forrás: a felhasználó 2026-11-26-i S0 kiegészítése; vizuális referencia: `html-prototypes/app-shell/index.html`, `.home-metrics`, `.home-body`, `HomeInteractionController`. A már jóváhagyott S0 terjedelem és rétegek érvényesek.

| Állapot / mechanizmus | Egyetlen tulajdonos és élettartam | Írási vagy publikálási út |
|---|---|---|
| RecoveryPeriod, kezdőnap | Drift/SQLite; tartós | onboarding → BootstrapController → InitializeRecovery → RecoveryStore/repository → tranzakció; egy aktív sor |
| Napszám, helyi dátum | DayTracker; előtér | repository stream és injektált óra → naptári motor → csak megváltozott érték jelzése |
| Panelgesztus és progress | dashboard interakció tulajdonosa; képernyő | egy progress számolja a kártya és panel pozícióját; Back csak tényleges nyitott/zárt váltáskor értesül |
| Dashboard geometria | egyetlen tiszta layout-resolver | ablak, safe area és szövegméret → megjelenítési geometria; tesztelhető widgetfa nélkül |
| Aktív artwork descriptor | Drift/SQLite; tartós | ArtworkService rendezett módosítási sora → ArtworkStore szerződés → egyetlen DriftArtworkStore adapter és app-private verziózott fájl; renderelő csak szerepet olvas és képet jelenít meg |
| Artwork átmeneti és árva fájlok | artwork koordinátor és fájladapter | ellenőrzés → privát ideiglenes/végleges fájl → descriptor commit → biztonságos takarítás; aktív és még látható kép védett |
| Release és legfrissebb letöltés | GitHub Release és Pages publikáló ág | sikeres, ugyanazon SHA-t ellenőrző tesztek és képbizonyíték → változtathatatlan commitazonosítós release → nyilvános letöltés/checksum → monoton, versenyvédett Pages mutató |

A meglévő egyetlen sheet-interakciós tulajdonost, artwork-resolvert, vizuális tokeneket és DB-írási utat javítjuk; nem készül második párhuzamos implementáció. A renderer nem koordinál DB- vagy fájlműveletet. A release nem függ Actions artifactkvótától; PR nem kap aláírókulcsot vagy írási jogosultságot.

Ellenőrzés: Dart unit és determinisztikus konkurencia-/adatvesztés-tesztek, widget rebuild/layout/gesztus/Back tesztek, teljes boundary-contract suite, Android natív emulátorteszt és újraindítás, HTML–Flutter screenshotok szemrevételezése, ugyanazon SHA-ra épült aláírás- és nyilvános Release/Pages letöltésvizsgálat. Az iOS-váz fizikai ellenőrzése külön nyitott.
