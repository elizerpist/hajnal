# Hajnal • „Amit gyakorlok” • 90 perces implementáció

Implementáld az önálló gyakorlatkártyákat az `elizerpist/hajnal` Flutter-appban. A cél egy működő, telefonra telepíthető HUMAN APK és a hozzá tartozó kód. Az időkeret **90 perc a munka kezdetétől az átadásig**, a build és a várakozás is beleszámít. Az elfogadott termékterv a mellékelt négyoldalas PDF. Dolgozz végig ugyanebben az agent-munkamenetben.

## Munkamenet

| Eltelt idő | Feladat |
|---|---|
| 0–5 perc | Nyisd meg a HTML-t és a PDF-et. A repó utasításai mellett ellenőrizd az ágat, a sémát és az integrációs pontokat. Válaszd ki az egyetlen rendelkezésre álló átadási utat. |
| 5–40 perc | Helyben implementáld a teljes funkciót, készítsd elő a grafikákat és a célzott teszteket. A Drift-kódot és a sémakivonatot a végleges tábladefinícióból generáld. |
| 40–45 perc | Formázás, a módosítások átnézése, az átadandó commit véglegesítése. Ha hamarabb kész, azonnal indítsd a záró futást. |
| 45–90 perc | Egyetlen záró ellenőrzési és buildfolyamat, majd az eredmény átadása. |

- Minden fejlesztés inline, egy munkapéldányban történjen. Közben **0 CI-indítás**. Kerüld a köztes pushokat, próbából nyitott PR-t, workflow dispatch-et, ismételt teljes tesztcsomagokat és próba-APK-kat. A helyi formázás, kódgenerálás, szerkesztői diagnosztika és egy konkrét hiba helyi vizsgálata a fejlesztés része.
- **Pontosan egy buildút legyen.** A Hajnal szokásos felhős átadásánál a végén egyetlen push a `build/starter` ágra elindítja a meglévő workflow-t. Ebben futnak a tesztek és egyszer épül az átadandó, aláírt HUMAN profile APK. Ugyanerre a commitra ne nyiss még PR-t, ne indíts kézi workflow-t, helyi APK-buildet vagy külön teljes `ci_verify.sh` futást. Ugyanazt a run ID-t kövesd egyszer, a hátralévő időkeretben. Távoli naplót egy konkrét hibához olvass. Az eredmény lekérése és az APK letöltése nem igényel új indítást.
- A jelenlegi workflow a HUMAN APK mellett automatikusan fordít egy debug alkalmazást és Android-tesztcsomagot is. Ha **szó szerint egyetlen alkalmazásfordítás** szükséges, és az adott gépen eleve rendelkezésre áll a hivatalos aláírás, a megfelelő következő verziókód és az APK átadásának lehetősége, helyben végezd el az egyetlen záró futást. Ebben egyszer fusson a `flutter analyze` és a `flutter test`, majd egyszer a `flutter build apk --profile --target lib/main.dart --build-number <kiosztott_verziókód>`. A tényleges commit kerüljön a csomagba. Ellenőrizd az aláírót és a frissíthetőséget. Ehhez az átadáshoz 0 CI-t kiváltó push tartozik. A két út kölcsönösen kizárja egymást. Hagyd érvényben a meglévő kiadási ellenőrzéseket.
- Ha egy valódi akadály már a 45. perc előtt veszélyezteti az átadást, jelezd az okát, és folytasd az elvégezhető munkát. Az egyetlen végső futás hibájánál olvasd ki az első tényleges hibát és közöld a javítás állapotát. **Automatikus újraindítás vagy második build nincs.** A 90. percnél a tényleges állapotot, az elkészült APK-t vagy a folyamatban lévő futás linkjét add át. A még futó vagy sikertelen ellenőrzést jelöld nyitottként.

## A két referencia

- A `build/starter` ellenőrzött kiinduló commitja `f2bbe13f27ff6e2b0fac4a3b6cbb47f716b099d8`. A tényleges friss bázisról dolgozz. Nyisd meg a `html-prototypes/app-shell/index.html` fájlt, és nézd meg a felhúzott főmenüt és az „Amit gyakorlok” kezelőt. A geometria, rétegsorrend, koppintási célok, görgetés és eredeti akvarellek forrásai a `.home-practice-block`, `.practice-focus-dialog--manager`, `.practice-list-scroll`, `.practice-manager-footer` szabályok, továbbá a `renderHomePracticeBlock()`, `practicePickerArtwork()`, `practiceRow()` és `renderPracticeSheet()` függvények.
- Nyisd meg vizuálisan a `Hajnal_Amit_gyakorlok_terv.pdf` fájlt. Az 1. oldal a kezelő és a szerkesztés, a 2. az új kártya két állapota, a 3. a pontos magyar kérdések és feliratok, a 4. a műveletek. A kezelő HTML-geometriáját és a PDF új egymezős szerkesztőjét valósítsd meg. Az elfogadott listaműveleteket a repó `docs/prototypes/PRACTICE_ORNAMENTS_ACCEPTANCE_CHECKLIST.md` PM-11/12 sora is rögzíti.
- A feladathoz ez a terv és a PDF elegendő. A repó által kért elfogadási nyomot röviden rögzítsd egy helyen. A `docs/HAJNAL_FLUTTER_SPECIFIKACIO.md` 8.3. szakaszában vezesd át az új szövegmodellt és a Mentés szabályát. Ugyanebben a munkamenetben lépj tovább az implementációra.

## Önálló adatbázis-entitás

A `practice_cards` táblát a meglévő `HajnalDatabase` kezelje a közös `hajnal.sqlite` fájlban. Saját stabil elsődleges kulcs, kötelező saját kártyaszöveg, opcionális cím és gondolatindító, `active/paused/archived` státusz, létrehozási, módosítási és opcionális aktiválási UTC-időpont szükséges. Az opcionális Ösvény-eredet stabil hivatkozását, megnevezését és az átvett szöveget őrizd meg. Cím nélkül a saját mondat azonosítja a kártyát. Az üres adatbázis maradjon üres.

A bázis sémája v6, gyakorlatkártya-tábla még nincs. Készíts megőrző v6 → v7 migrációt, vagy újabb bázis esetén használd a következő sémaverziót. Regeneráld a Drift-kódot, add hozzá a sémakivonatot, és igazítsd a `scripts/ci_verify.sh` v6-os fájl-összehasonlítását az új verzióhoz. A korábbi exportokat őrizd meg. A régi HTML mintaadatait ne importáld.

A szöveges státuszú táblán például a `CREATE UNIQUE INDEX one_active_practice ON practice_cards(status) WHERE status = 'active'` biztosítja, hogy legfeljebb egy sor lehessen aktív. A korlát friss telepítésen és frissítéskor is jöjjön létre. Az egyetlen tartós író a Practice repository, a főmenü és a kezelő ugyanabból a figyelt DB-állapotból olvas. A bekötés az `app_services.dart`, `hajnal_app.dart` és `main.dart` meglévő útján történjen.

| Művelet | Eredmény |
|---|---|
| Új kártya · **Most ezt választom** | A létrehozás, az előző szüneteltetése és az új aktiválása egy tranzakció. |
| Új kártya · **Mentés későbbre** | Szünetelőként mentődik. Az aktív választás megmarad. |
| Listasor · **jobb nyíl** | A cél létezésének ellenőrzése és az aktív kártya váltása egy tranzakció. A főmenü és a kezelő azonnal frissül. |
| Kártyatest · **Mentés** | Megnyitás szerkesztésre, majd csak a tartalmi mezők módosítása. Egy korábban megnyitott szerkesztő sem írhatja vissza a régi státuszt vagy aktiválási időt. |
| **Kártya törlése** | Egyedi megerősítés után törlés. Az aktív kártya törlése üres aktív helyet hagy. A Mégse megtartja a szerkesztés szövegét. |

Kettős koppintás, már törölt célpont és írási hiba esetén maradjon konzisztens az állapot. A piszkozat maradjon meg javításra. A listában az aktív kártya egyszer szerepeljen, a többi módosítási idő szerint csökkenő, egyezéskor stabil ID-sorrendben.

## Felület és grafikák

A meglévő `dashboard.dart` felhúzott paneljére, a **Segítség kell** gomb fölé kerüljön az **Amit gyakorlok** sor. Üresen is megnyitja a kezelőt. Az aktív mondat itt balra igazított, legfeljebb kétsoros. Tartsd meg a panel gesztusát, a segélygombot és a visszanavigálást.

A kezelő a valódi főmenü felett középre igazított, törtfehér popup. Fent a cím, jobb felső X és fix levendulaszínű **MOST GYAKORLOM** kártya. A **Kártyáim** cím is fix. Csak a lista görgethető. A sor bal oldalán a témakép, mellette a név vagy mondat és az eredet, jobbra az önálló aktiváló nyíl. A kártyatest és a nyíl külön érintési és akadálymentesítési cél. A fix alsó **＋ Új kártya hozzáadása** gomb alatt marad a lótuszos lábléc. A törlés a meglévő kártya szerkesztőjében kap helyet. A hárompontos menü és a státuszszűrő a korábbi prototípushoz tartozott. A HTML 412 × 892-es nézetében a kezelő 368 × 784 logikai pixel. A Flutter-layout alkalmazkodjon a safe areához, a billentyűzethez és a szövegnagyításhoz.

**Új kártya.** Alapból egyetlen szövegmező látszik a „Mit írnál magadnak?” kérdéssel. A **Segíts elindulni** kezdetben csukott. Lenyitva a PDF szerinti 2 × 2 ikon és szöveg jelenik meg. A sorrend Felismerés, Iránytű, Kérdés, Apró lépés. A mondatkezdetek rendre „Észrevettem, hogy”, „Fontos nekem, hogy”, „Mi segítene” és „Legközelebb”. Az ikon a kérdést is cseréli. Üres mezőben a szerkeszthető kezdet végére kerül a kurzor. Érintetlen gépi kezdet cserélhető. Saját szöveget, kijelölést és kurzort őrizz meg. Puszta sablon vagy whitespace esetén mindkét mentés inaktív. A saját kérdés önmagában is teljes kártya. Címválasztás és típusadás opcionális. A **Cím hozzáadása** a lenyitott részben, saját szöveg után érhető el.

**Meglévő kártya.** A „Kártya szerkesztése” nézetben a kapcsolt Ösvény-forrás a fejléc alatt látható. A műveletek sorrendje **Mentés**, **Kártya törlése**, **Mégsem**. A törlési megerősítés nevezze meg a kártyát. Sikeres művelet után a kezelő frissüljön, a kezelő bezárása a felhúzott főmenühöz térjen vissza.

Használd az eredeti öt `html-prototypes/app-shell/assets/practice/practice_*.png` képet és a hozzájuk tartozó öt `decor/*_sheet_field_v4.png` mintát. A kis akvarell a kártyáé, a nagy halvány dísz a főmenü paneljéé. Egy közös determinisztikus feloldás párosítsa őket. Regisztráld az alkönyvtárakat is a `pubspec.yaml`-ban. A négy szerkesztőikon külön szerepű. A hajtás meglévő asset. Az arany iránytűt, lila kérdésbuborékot és barack lábnyomot a PDF 2. oldaláról vedd mintának és egyszer készítsd el offline assetként, ha nincs megfelelő eredeti. A feliratok és gombok Flutter-elemek. Használd a Hajnal meglévő stílusait.

A kártyák extrák nélkül is működnek és megmaradnak időszakváltás után. A kártyaműveletekből nem keletkezik idővonalesemény. A meglévő Ösvény-fogyasztó ugyanazt a szerkesztőt használhatja forrásszöveggel. A napi reflexió az első hozzárendeléskor egy önálló pillanatképet kap, amely a kártya későbbi módosításától vagy törlésétől független. A bázison még hiányzó fogyasztókhoz elegendő a Practice oldali forrásátvétel és pillanatkép-olvasás. Új Ösvény-, reflexió- vagy mentésmodul fejlesztése külön feladat.

## Egy végső ellenőrzés és átadás

- A funkció tesztjeit a meglévő Flutter-tesztcsomagba illeszd. Egy adatbázisos tesztcsoport fogja össze a megőrző migrációt, az egyetlen aktív rekord korlátját, az atomikus váltást, az inaktív mentést, a törlést és az adatbázis újranyitását. Egy widgetes felhasználói út fedje a főmenüből nyitást, a két mentési módot, az ikonváltáskor megőrzött szöveget, a sor és a nyíl eltérő hatását és a törlés megerősítését.
- A vizuális összevetés két döntő nézete a feltöltött kezelő és a lenyitott újkártya-szerkesztő. Ezeket hasonlítsd össze a HTML-lel, illetve a PDF-fel. A két képet ugyanabból a widgetes futásból mentsd ki. CI esetén tedd elérhetővé őket ugyanazon futás bizonyítékai között. A többi állapot működését a tesztek fedik. Külön screenshotmátrix, második emulátorkör vagy külön vizuális build ehhez a feladathoz nem szükséges.
- Egy végső összefoglalóban add meg a commitot, a tesztek tényleges eredményét, az eltelt időt és az APK elérhetőségét. Az ezen az útvonalon ténylegesen elkészült fájlt és annak SHA-256 értékét add át. Különböztesd meg az aláírt jelöltet az ellenőrzött, publikált kiadástól. Sikertelen ellenőrzésnél az első konkrét hibát, függő futásnál a meglévő futás linkjét közöld.
