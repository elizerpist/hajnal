# Hajnal S0 – Flutter shell, helyi adatbázis és naptári napszámláló

Dátum: 2026-11-26
Megbízás: implementáció a helyi Termux → Ubuntu → flutteruser környezetben, majd commit, push, GitHub Actions ellenőrzés és letölthető Android teszt-APK.
Ez a felhasználó által kért nulladik starter build. Nem a teljes alkalmazás implementációja.

## 1. Munkakörnyezet, felhatalmazás

A meglévő ~/flutterapps/hajnal repóban dolgozz; előbb ellenőrizd a tényleges útvonalat, remote-ot, ágat és munkakönyvtárat. GitHub: elizerpist/hajnal. Kiinduló prototípuság: feat/first-prototype-page. Az S0 implementáció külön ága: build/starter; az implementációt erre az ágra commitold és pushold. Más feladat munkáját ne keverd bele. Tilos reset --hard, git clean és force push.

Olvasd el az AGENTS.md-t, a releváns skilleket, a docs/HAJNAL_FLUTTER_SPECIFIKACIO.md-t és az előírt referenciaanyagokat. A felhasználó MOST engedélyezte az itt körülhatárolt Flutter-implementációt, tehát a korábbi dokumentáció-only tiltás erre a feladatra nem vonatkozik.

A terv és az alábbi felelősségi határok az implementáció alapjai. Készíts architecture cardot és követelményenkénti acceptance checklistet a kódolás előtt, majd haladj a megrendelt feladattal; ne kérj ismét általános engedélyt a scaffoldra, tesztekre, commitra vagy pushra. Valódi ütközést vagy lényeges megoldatlan termékdöntést jelezz.

## 2. S0 pontos terjedelme

Készüljön natív Flutter app, elsőként Androidon építve és futtatva. Az adatmodell és a Dart üzleti logika legyen iOS-kompatibilis. Generálj Android és iOS projektvázat, de most nem feltétel egy aláírt iOS build. Az iOS ellenőrizetlenségét külön jelezd.

Ebben a buildben:
- Egy dashboard, egyetlen csomagolt háttérkép-placeholderrel.
- A HTML napszámláló téglalapjának formáját és felhúzható viselkedését követő komponens.
- A kinyitott panel belseje teljesen üres.
- Bal felső hamburgergomb; balról becsúszó menü.
- Egyetlen menüpont: Onboarding.
- Fullscreen onboarding, kezdődátum-választással és mentéssel.
- Androidon valódi rendszer DatePickerDialog.
- SQLite + Drift adatbázisalap, működő tartós kezdődátummal.
- Automatikus naptári napszámláló, indulás/resume/éjfél frissítéssel.
- Központi artwork-katalógus és tesztelt helyi artwork-csere alap.
- GitHub Actions tesztek, emulátoros smoke teszt és külön emberi teszt-APK.

Későbbi szakasz: modulcheckboxok, pánikmód, idővonal, gyakorlatkártyák, reflexiók, szponzor, gyűlések, lépésmunka, rich-text editor, hang, diktálás, ajándékképek, teljes reset/visszaesés/törlés, zár és export/import. Ezeket most ne implementáld, ne gyárts hozzájuk üres táblákat, menüpontokat vagy demo-adatokat. A teljes termékspecifikációban maradnak követelmények.

## 3. Valódi HTML-referencia, nem új design

Vizsgáld meg közvetlenül:
- html-prototypes/offline-ui/index.html
- html-prototypes/app-shell/index.html
- a kapcsolódó dashboard referenciákat és az AGENTS.md szerinti PNG-ket
- docs/prototypes/ACCEPTANCE_CHECKLIST.md releváns home/sheet bejegyzéseit.

A jelenleg megvizsgált offline-ui a régebbi csukott/nyitott képernyőket tartalmazza; az interaktív app-shell hordozza a húzás tényleges működését. Azonosítsd a lokális legfrissebb megfelelő komponenst; a két fájlból ne keverj véletlenszerűen két eltérő változatot.

Konkrét app-shell horgonyok:
- .home-illustration / .home-hero-image
- .home-metrics, data-component="daily-summary-card"
- .home-body, data-component="checklist-sheet"
- HomeInteractionController: setProgress, settle, startDrag, updateDrag, endDrag, cancelDrag.

Megfigyelt 412×892 referencia:
- Téglalap bal/jobb margó: 58 px, szélesség: 296 px.
- Minimum magasság: 118 px, saroksugár: 24 px.
- Alapszín: #FFFCFB; finom lila keret és visszafogott árnyék.
- Két belső rész, közöttük 1 px széles, 74 px magas elválasztó.
- Téglalap felső éle: csukva y=614, nyitva y=518; mozgás 96 px.
- Mögöttes panel felső éle: y=682 → 586; nagy, ívelt felső sziluett.
- Mozgás: 300 ms cubic-bezier(.2,.85,.25,1); panel opacity: 180 ms.
- A panel és a téglalap ugyanabból az egyetlen progress értékből kapja a helyzetét.

Ezek referenciaértékek, nem minden telefonra ráégetett koordináták. Flutterben SafeArea/ablakméret alapján egyetlen layout-resolver számoljon. A 412×892 nézetben a komponens mérete, formája és mozgása legyen összevethető a HTML-lel; keskenyebb és alacsonyabb készüléken se lógjon ki.

Kifejezett eltérések a felhasználó legújabb kéréséből:
- NINCS bottom nav és nincs számára fenntartott 70 px üres sáv.
- A háttér a teljes dashboardot tölti ki, a rendszer biztonságos területeit a vezérlők tiszteletben tartják.
- Nincs HTML-es hamis státuszsor, „9:41”, telefonkeret.
- Nincs felső dekoratív 24. nap/90 nap felirat, értesítés-, Aa- vagy fullscreen gomb.
- A napszám a központi téglalapban valódi adatból jelenik meg.
- A kártya külső és kétosztatú geometriája marad; bal oldalon „Tiszta napok”, szám és „nap”.
- A jobb oldali tartalomhely ebben az üres starterben üres, nem hamis funkciógomb.
- Nem másolható át a régi „Ma tiszta maradtam” művelet, Reflexió-link, 90 napos cél vagy kitalált mérföldkő-progress.
- A kinyitott panelben nincs cím, lista, gyakorlat, pánikgomb vagy helykitöltő szöveg.

A téglalap fel/le húzható, elengedéskor a HTML alapján snap-el; megszakított gesztus sem hagyhat hibás állapotot. A drag és tap legyen megkülönböztetve. Legyen hozzá akadálymentes nyitás/csukás művelet, és érintéssel is nyitható/csukható. Back először a megnyitott menüt/panelt zárja. Reduced motion mellett is működjön. A háttérképet ne dekódold újra minden animációs frame-ben.

## 4. Navigáció és onboarding

A hamburger a meglévő vizuális nyelvű bal felső körgomb legyen. A menü balról slide-in, háttérscrimmel; azon kívüli tap és Back bezárja. Egyetlen eleme az Onboarding, amely fullscreen route-ra visz, nem bottom sheetre.

Első indításkor, ha nincs aktív időszak, az onboarding nyíljon meg. A dátum szerkesztési alapértéke ma, de semmi ne mentődjön automatikusan. Mentés előtt elhagyható: ilyenkor a dashboard „—” jelzést mutat, nem hamis 0 napot, és a hamburgerből újra megnyitható az onboarding.

Dátumválasztás:
- Androidon tényleges android.app.DatePickerDialog, nem Flutter showDatePicker vagy Material utánzat.
- Egy kis platformadapteren keresztül nyíljon; a UI ne használjon közvetlen MethodChannelt.
- Siker, cancel és platformhiba külön eredmény. Egyetlen pending kérés; dupla tap nem nyit két dialogot.
- Év/hónap/nap értékeket adj át, ne időzónán elcsúszó epoch timestampet. Figyelj az Android hónapindexére.
- Előre dátumozás tiltott, mentéskor is újra validálva. Korábbi valódi naptári dátum választható; ne találj ki termékszintű 90 napos vagy néhány éves korlátot.
- Android konfigurációváltás, Activity-életciklus és megszakítás után ne maradjon lógó Future vagy duplikált mentés.
- Az iOS adapter ugyanazon szerződésen keresztül platformhoz illeszkedő dátumválasztót adjon; Android-hívás nem szivároghat közös kódba. Most ennek eszközös ellenőrzése külön, nem teljesített tétel.

Mentéskor egy tranzakcióban jöjjön létre az első aktív időszak, majd csak sikeres commit után lépj a dashboardra. Dupla mentés, újranyitás és restart nem hozhat létre újabb időszakot.

Az aktuális időszak mentett kezdőnapja az onboardingban korrigálható: a mentett nap kijelölve indul, a választás mentésig tervezet, Back/Cancel nem ír. Csak mai vagy korábbi dátum menthető, külön ID-ra és aktív állapotra feltételes korrekcióval; a period ID és createdAtUtc megmarad. Reset/visszaesés most nincs. A későbbi modulválasztást külön szekcióként lehessen majd hozzáadni, de most ne legyenek nem működő checkboxok.

## 5. Adatbázis és felelősségi határok

Használj Flutter/Dart + SQLite/Drift + Riverpod alapot. A csomagok és a Flutter SDK verzióit kompatibilitási ellenőrzés után rögzítsd; commitold az alkalmazás lockfile-ját. Ne emelj át Fluvi Room/Kotlin domain-adatbázist: Hajnal közös Dart adatlogikát használ Androidon és iOS-en.

Első séma:
- RecoveryPeriod: stabil id, startLocalDate (naptári dátum), createdAtUtc; a későbbi lezáráshoz szükséges minimális closedAtUtc/állapot következetes modellel.
- Legfeljebb egy aktív időszak: adatbázis-korlát és tranzakció, nem csak UI-feltétel.
- Csak a most valóban szükséges kis metaadat/konfiguráció rekordok, ha a választott megoldás indokolja.
- Nincs napi sor csak azért, mert elindult az app.
- Nincs külön tárolt, kézzel növelt cleanDays számláló vagy onboardingComplete boolean az aktív időszak mellett.

A startLocalDate ne UTC timestamp legyen. A létrehozási idő UTC pillanat, a naptári nap külön adattípus. Az adatbázis app-private, tartós könyvtárban legyen; ne cache-ben vagy külső publikus tárhelyen.

Adatfolyam:
UI → controller/view-model → inicializáló use case → repository → Drift.
Olvasás: repository stream → view-model → UI.
A clock/calendar engine tiszta Dart, injektált időforrással. A production clock és platforméletciklus adapter a kompozíciós gyökérben kerül bekötésre.

Egy írási út legyen. Hibás DB-megnyitás/migráció nem eredményezhet csendes üres DB-t, törlést vagy új onboardingot. Legyen olvasható hiba és biztonságos újrapróbálás.

Schema version 1 és verziózott sémaexport készüljön. Az első verzió nyitását, bezárás utáni visszaolvasását és integritását teszteld; ne találj ki mesterséges v0 adatokat csak migrációs teszt kedvéért. Dokumentáld: minden jövőbeli entitás/mező megőrző migrációval, korábbi sémafixture-ön tesztelve kerül be; delete-and-recreate tilos.

A jövőbeli Content, Reflection, Practice és TimelineEntry most még nem létezik a sémában. Az architektúrát nem általános EAV/JSON „mindent egy táblába” tárolóval tesszük bővíthetővé, hanem normális külön táblákkal és migrációkkal.

## 6. Dátumkövető motor

A kezdőnap 0. nap. Ma és a kezdőnap naptári sorszámának különbsége adja a tiszta napokat. Nem local DateTime.difference(...).inDays és nem 24 órás blokkok számlálása, mert a DST napjai eltérő hosszúságúak.

Injektálható Clock/CalendarContext, tesztelhető tiszta számítás. UTC dátumkonstrukció használható a lokális év/hónap/nap sorszámmá alakítására, de a mai napot a készülék aktuális helyi dátumából kell venni.

S0 időkezelési szabály:
- A kezdőnap fix naptári dátum; időzónaváltáskor nem konvertáljuk másik napra.
- A mai nap a készülék aktuális helyi dátuma.
- Napszám = max(0, mai nap - kezdőnap).
- Kézi óra/időzónaváltás visszafelé is módosíthatja a kijelzett napszámot; nem írjuk át a kezdőnapot, nem gyártunk visszaesést.
- Ez eszközórán alapuló offline számítás, nem manipulációbiztos időhitelesítés.

Appindításkor a DB és dátumállapot betöltése ELŐTT ne villanjon fel demo 24 nap vagy hamis 0. Rövid bootstrap/loading állapot használható. Resume után azonnal újraszámítás.

Előtérben egyszeri timer a következő helyi éjfélig, utána újraszámítás és újraütemezés. Ne 24 órát adj az előző triggerhez. A kézi óra- és időzónaváltás előtérben is kezelendő: egy központi, csak foregroundban működő ritka ellenőrzés (például 30 másodperc) ellenőrizze a calendar contextet, változáskor számoljon és ütemezzen újra. Egyetlen tulajdonos, nincs egymásra halmozott timer. Háttérbe kerüléskor minden ilyen timer leáll; resume után újraindul.

Nincs háttérszolgáltatás, WorkManager, alarm, értesítés vagy napi DB-növelés. Timer tick nem rebuildeli a teljes appot, ha az eredmény nem változott. Lezárt időszakok kezelése később jön.

## 7. Artwork-kezelés

A HTML képei PLACEHOLDEREK, nem a végleges készlet. Egyetlen dashboard háttérképet válassz a meglévő app-shell assets/backgrounds/index1.png vagy a tényleges aktuális referenciában szereplő megfelelő fájlból, ellenőrzés után. Ne másold be az összes HTML assetet.

Szervezés:
- assets/artwork/dashboard/...
- assets/artwork/catalog.json vagy ennek kicsi típusos megfelelője
- docs/ARTWORK_GUIDE.md

A widget szerepet/stabil artwork-azonosítót kérjen, például dashboard.default; ne ismerjen fájlnevet vagy relatív útvonalat.
A katalógus tartalmazza a stabil ID-t, szerepet, forrást, revíziót, képméretet/aspect információt, crop/fókuszpontot és placeholder/provenance jelzést. A pontos kicsi sémát dokumentáld. A resolver egy helyen választ, a renderer egy helyen tölt és jelenít meg.

Különítsd el:
1. Bundle-kép: repo/katalógus módosításával cserélhető; telepített alkalmazásban a bundle nem írható át.
2. Helyi runtime override: app-private képfájl; ugyanahhoz a szerephez új descriptor/revízió rendelhető, képernyőkód-módosítás nélkül.

Az S0-ban legyen működő, tesztelhető helyi override install/clear út az artwork service/repository határán, fejlesztői/integrációs használatra. Nem kell új menüpont, fájlválasztó vagy mood UI. Az integrációs teszt hozhat létre kis ideiglenes képfájlt, így az APK-ban továbbra is csak egy dashboard háttérasset kell.

Override telepítése: fájltípus/dekódolhatóság és méretkorlát ellenőrzése → app-private ideiglenes fájl → verziózott végleges fájl → tartós aktív descriptorváltás. Hibánál a korábbi jó kép marad. A DB és fájlrendszer közti megszakítást kezeld: induláskor érvényes hivatkozás/fallback, a hátramaradt ideiglenes fájl biztonságos takarítása. Ne ugyanazt a fájlnevet írd felül úgy, hogy a Flutter ImageCache régi pixeleket mutasson.

A runtime választás restart után is maradjon meg; ehhez kis artwork override tábla indokolt. Relatív app-private fájlazonosítókat tárolj, ne készülékspecifikus abszolút útvonalakat.
Hiányzó/sérült override esetén visszaállás a bundle-placeholderre; a fallback sem okozhat végtelen újratöltést.

A váltás előtt az új képet töltsd/dekódold; a korábbi maradjon látható, amíg az új készen nincs. Korlátozott image cache, kijelzőmérethez igazított decode, nem az összes jövőbeli kép előtöltése. Régebbi async betöltés nem írhatja felül az újabb választást.

A későbbi mood engine ugyanehhez az artwork-kiválasztási szerződéshez kapcsolódik majd; most nincs mood-adatmodell vagy döntési algoritmus. Sem hálózati URL, sem letöltés nem kell.

## 8. Projektstruktúra és ellenőrzés

A Flutter projekt a meglévő repó gyökerében készüljön, ha nincs ott más Flutter alkalmazás. A scaffold ne írja felül az AGENTS.md-t, dokumentációt, HTML-t vagy referenciákat. Szükség esetén ideiglenes könyvtárban generálj és ellenőrzötten emelj át.

Kicsi, felelősség szerinti szerkezet:
- app: bootstrap, kompozíciós gyökér, route-ok
- core: adatbázis, idő/platform adapterek, artwork, vizuális tokenek
- features/recovery: domain és repository/use case
- features/dashboard: view-model, renderer, sheet interaction
- features/onboarding: dátumválasztás és mentési flow
- test, integration_test, docs, scripts

Ne legyen egyetlen hatalmas controller, de ne készíts üres rétegeket minden egyes függvényhez. A közös mechanizmus és token egy helyen legyen.

Kód előtt készüljön:
- docs/implementation/S0_ARCHITECTURE.md
- docs/implementation/S0_ACCEPTANCE.md
- docs/HAJNAL_ENGINEERING_JOURNAL.md, ha még nincs, különben a meglévőt folytasd.

Követelményenként forrás, kódterület, ellenőrzés és valós státusz: DONE/PARTIAL/BLOCKED/NOT DONE.
A fő termékspecifikációt egészítsd ki az S0 terjedelmével és a most választott dátumkezelési szabállyal, de ne jelöld késznek a teljes appot.

## 9. Kötelező tesztek

Domain:
- mai kezdés 0, tegnap 1, több hónap/év és szökőnap;
- DST tavaszi/őszi váltás, nem 24 órás napszám;
- kezdeti jövőbeli dátum tiltása;
- későbbi visszaállított rendszeróra: nem negatív szám, kezdődátum változatlan;
- időzónaváltás, resume, előtérben éjfél;
- időforrás/timer fake, ne valós várakozásos tesztek.

Adatbázis:
- új DB, időszak létrehozás, bezárás/újranyitás;
- dupla/konkurens inicializálás: legfeljebb egy aktív időszak;
- hibás mentés nem navigál sikerre és nem hagy részleges adatot;
- dátumkorrekció az egyetlen hivatalos írási úton, aktív ID feltétellel és változatlan létrehozási idővel;
- schema v1 export és idegenkulcs/integritás ellenőrzés;
- artwork override tartósság és hibás/hiányzó fájl fallback.

Widget és boundary:
- onboarding, üres/mentett dashboard, menü és Back;
- csukott/nyitott/drag-cancel sheet, nincs véletlen tap drag után;
- nincs bottom nav, demo napszám, jövőbeli funkciógomb;
- egyetlen progress mozgatja a kártyát és panelt;
- 412×892, 390×844, 360×800, nagyobb betűméret: nincs overflow;
- architektúra-határok, egyetlen DB write path, UI nem hív platformot/adatbázist;
- artwork csere cache-frissítése és async race.

Natív/emulátor:
- Android valódi DatePickerDialog megnyílik, dátum visszaadása és Cancel.
- A natív dialogot tényleges UI Automator/Espresso vagy megfelelő natív teszt ellenőrizze; a MethodChannel mock nem bizonyítja ezt.
- onboarding mentés → valódi SQLite → dashboard.
- folyamat force-stop/relaunch után ugyanaz az időszak és napszám.
- felhúzás/csukás, hamburger/onboarding visszalépés.
- screenshot a csukott/nyitott dashboardról és onboardingról.

A generált Flutter golden önmagában nem bizonyítja a HTML-egyezést. Készíts friss HTML screenshotot és Flutter screenshotot, szemmel is hasonlítsd össze a kártya geometriáját, színeit, belső tagolását és nyitott állapotát. A tartalmi/navigációs eltéréseket a fenti explicit S0 szabályok szerint értékeld.
Ha a Termux környezet nem tud böngészőt/emulátort futtatni, ezt a CI végezze. Hiányzó vizuális vagy natív bizonyítékot ne jelölj DONE-nak.

## 10. GitHub Actions – exptv2 mintájára, Hajnalhoz szabva

Megvizsgált referenciák:
elizerpist/exptv2 main, fe10593ec833e41080186404c053e81e5889d623:
- .github/workflows/fluvi-core.yml
- .github/actions/setup-fluvi-flutter/action.yml
- scripts/build-human-diagnostic-apk.sh

Ott külön native/Flutter tesztkapu van, majd profile human APK és külön automated harness. A setup Flutter 3.41.4-et, Java 17-et használ; az emulátoros lane API 35-öt. Ezek megfigyelt repoértékek, nem automatikusan a Hajnal végleges verziói. Ellenőrizd az aktuális kompatibilitást és rögzíts egy egységes Hajnal toolchaint.

Hajnal workflow: .github/workflows/hajnal-ci.yml
Trigger: push az implementációs ágra, pull_request, workflow_dispatch.
A futás a commit tényleges SHA-ját ellenőrizze; ne egy régi, zöld runra hivatkozz.

Kapuk:
A. verify: dependency install a lockfile alapján, format check, flutter analyze, teljes S0 unit/widget/boundary suite, Drift generált kód/séma konzisztencia, artwork katalógus ellenőrzés.
B. Android: A után, emulátorral valódi natív date-picker, DB persist/relaunch, aláírt frissítés és alap navigáció/sheet tesztek; screenshotok és tesztlogok a közös kiadási munkaterületen.
C. HUMAN: A és B, a képek és a szemrevételezett összehasonlítás sikere után külön normál lib/main.dart entrypointból aláírt profile APK. Ez nem az integration_test APK.

A HUMAN Release asset neve `hajnal_S0_HUMAN_<12-karakteres-SHA>.apk`; a teljes SHA kerüljön a build metaadatába és a kiadás leírásába. Legyen SHA-256, verzió/buildszám, futáslink és aláírás-ellenőrzés. Már kiadott commit binárisa nem cserélhető le eltérő tartalomra.

Az Actions artifact-tárhely használata nem feltétele a kiadásnak: a tesztek, nem üres képek és logok a munkaterületről Release assetként kerülnek fel. Funkcionális tesztet nem lehet continue-on-error-ral gyengíteni; emberi APK publikálás nem lehet always() vagy sikertelen kapu után.
A kis S0-nál ne másolj át curated listát, amely kihagyja a hibás teszteket. Nincs szükség nightly/baseline/dashboard performance infrastruktúrára vagy Fluvi demo seedre.

A felhasználónak közvetlenül letölthető GitHub prerelease APK készüljön a sikeres push-futásból, az exptv2 mintájára. A publikálás csak a saját megbízható ág push/dispatch futásában történjen, ne PR-on. Read-only alap jogosultság, contents:write csak a publikáló jobban; untrusted PR ne férjen signing secrethez.

A nyilvános, commitonként változatlan Release-URL mellett a ténylegesen konfigurált GitHub Pages `/download/` oldala mindig a legfrissebb sikeres, nyilvánosan letöltött és checksum alapján ellenőrzött APK-ra mutasson. Az oldal a commitot, buildidőt és checksumot is mutassa; régebbi párhuzamos futás ne állíthassa vissza. A Pages ág frissítése csak az ellenőrzött Release után történhet.

Android appazonosító egyedi Hajnal azonosító legyen, ne Fluvi és ne com.example. Válassz és dokumentálj stabil fejlesztői azonosítót.
Az APK aláírását ellenőrizd. Ismételt CI build telepítése ne kényszerítsen adatvesztő uninstallra: tartós Hajnal fejlesztői aláírókulcs szükséges. Már meglévőt használj, ha van. Kulcs/jelszó ne kerüljön gitbe, logba, artifactba vagy chatbe. Ha nincs hozzáférhető tartós CI aláírás, ezt tényleges konfigurációs blokkolóként jelentsd; a teszteket és build-ellenőrzést ettől még végezd el. Ne ígérj frissíthetőséget futásonként új debug kulccsal.

Rögzített toolchain, ésszerű timeout és ágankénti concurrency/cancel-in-progress legyen. Ne másolj Room modulokat, Fluvi oracle teszteket, widget/ORB kódot vagy más projektre szabott jogosultságot.

Ha workflow_dispatch új workflow miatt még nem használható a nem-default ágon, a push triggerrel indítsd. A run státuszát kövesd, olvasd a hibás job logját, gyökérok alapján javíts. Ne állj meg annál, hogy „push kész, majd lefut”.

## 11. Átadás

Készíts célzott review-t, ellenőrizd a checklistet, commitold csak a feladathoz tartozó munkát, majd pushold. Ne bontsd meg a működő HTML prototípust.

Végső jelentés magyarul:
- branch és ellenőrzött commit SHA;
- megvalósult S0 funkciók;
- GitHub run link és minden kapu eredménye;
- állandó Pages letöltési URL és commitazonosítós közvetlen HUMAN APK-link, checksum, aláírás/frissíthetőség állapota;
- screenshot/evidence linkek;
- a felhasználó fizikai telefonján ellenőrzendő rövid lista;
- ténylegesen hiányzó vagy blokkolt tételek, iOS külön.

Nem elég „lefordul”. Nem állítható fizikai eszközön teszteltnek az emulátoros eredmény, és nem állítható iOS-en ellenőrzöttnek a közös Dart kód. Ismétlődő hatástalan javításoknál jelezd a hibajavítási kör kockázatát, diagnosztizálj és tervezett refaktorral oldd meg.
