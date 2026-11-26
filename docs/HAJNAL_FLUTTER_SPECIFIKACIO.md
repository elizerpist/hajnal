# Hajnal – Flutter működési és adatkezelési specifikáció

Verzió: 0.3  
Dátum: 2026-11-26  
Állapot: elfogadott működési alapok; a jelölt technikai és termékdöntések további egyeztetésre várnak.

## 1. Hatókör és elsőbbség

Ez a dokumentum a Flutter-változat előkészítése során elfogadott felhasználói döntéseket rögzíti. Nem implementációs megbízás, nem kész adatbázisséma, és nem állítja, hogy a követelmények már megvalósultak vagy eszközön ellenőrzöttek.

A benne szabályozott témákban ez a dokumentum felülírja a korábbi, `HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md` fájl eltérő működési előírásait. Különösen: nincs kötelező napi megerősítés a számlálóhoz, nincs felhőbackend vagy fiók, az extra modulok választhatók, a reset és a visszaesés külön művelet. A korábbi specifikáció mérföldkő-napértékei nem tekinthetők véglegesnek.

A már kialakított vizuális nyelv és a prototípus megmarad referenciának. Ez a dokumentum nem tervez új képernyődesignt és nem módosít HTML-komponenst.

## 2. Platformok és offline működés

- Flutter alkalmazás Androidra és iOS-re.
- Teljesen offline működés; a „backend” az eszközön működő alkalmazáslogikát jelenti.
- Nincs szükség saját szerverre, online fiókra vagy felhőszinkronra.
- A szövegek, hangmemók, kapcsolatok, beállítások és folyamatállapotok helyben tárolódnak.
- A magyar beszédfelismerés már az első használatkor internet és külön modellletöltés nélkül működjön. A modell az alkalmazással együtt érkezik.
- A tárcsázó/SMS és a felhasználó által indított fájlmegosztás külső rendszerfunkciók. Nem jelentenek alkalmazáson belüli hálózati backend-függőséget.
- A konkrét minimum Android/iOS-verzió és eszközteljesítmény-követelmény még nincs véglegesítve.

## 3. Modulválasztás

Az onboarding során, később a beállításokban választható, mire használja a felhasználó az appot.

| Modul | Tartalom |
| --- | --- |
| Alap, mindig elérhető | Tiszta napok, időszakok, pánikmód, idővonal, elnyert képek, gyakorlatkártyák |
| Extra 1: napi reflexió | Napi szöveges és hangos bejegyzések |
| Extra 2: szponzor | Elérhetőség, átbeszélendő témák, átbeszélt tartalmak |
| Extra 3: gyűlések | Gyűlések, részvétel és megjegyzések |
| Extra 4: lépésmunka | Párhuzamos lépésmunkák, lépések és válaszok |

Az extrák egymástól függetlenül bekapcsolhatók. A lépésmunka nem követelhet aktív szponzor- vagy gyűlésmodult.

Kikapcsolás nem adattörlés. A korábbi adatok és a mentési csomagban való szereplésük megmaradnak. A modulhoz kötődő belépési pontok és emlékeztetők az aktiváláshoz igazodnak. A kikapcsolt modul korábbi tartalmának szerkeszthetőségét még pontosítani kell; megőrzése kötelező.

## 4. Tiszta napok és időszakok

### 4.1. Számítás

- A kiválasztott kezdőnap a 0. nap.
- Minden naptári napváltás egy nappal növeli a számlálót.
- Korábbi kezdőnap kiválasztásakor az azóta eltelt éjfelek számát mutatjuk.
- A számítás naptári napkülönbség, nem eltelt órák osztva 24-gyel.
- A kezdőnap létrehozás után rögzített, nem szerkeszthető. Adatbázisban tárolt érték, nem kódba égetett konstans.
- Nincs napi megerősítési kötelezettség.
- A számláláshoz nem fut folyamatos háttérszolgáltatás.

### 4.2. Frissítés

Appindításkor a dashboard előtt frissül a napszám és a mérföldkövek állapota. Háttérből visszatéréskor szintén ellenőrzünk. Nyitott alkalmazásban éjfélkor a szám frissül akkor is, ha a felhasználó más képernyőn dolgozik.

Az S0-ban az időzónaváltás és a kézi óraváltoztatás a készülék aktuális helyi dátumát módosíthatja; a rögzített kezdőnap nem változik. A pontos offline szabályt a 19. szakasz tartalmazza.

### 4.3. Lezárás, reset, visszaesés

- Visszaesés: a korábbi időszak lezárul és megmarad saját idővonalával; új időszak nyílik.
- Reset: az aktuális időszak törlési folyamat után nem kerül a lezárt időszakok közé; új kezdőnap választható.
- Időszak törlése: a 7. fejezet szabályai szerint történik.
- Visszaesés önmagában nem reseteli a szponzori témákat vagy a lépésmunkákat.
- A lezárt időszakok eseményei időrendben elérhetők.

## 5. Mérföldkövek és ajándékképek

A konkrét mérföldkő-napértékek később dőlnek el.

Az elnyerés és az ajándék megjelenítése két külön tartós állapot:
1. A mérföldkő elérésekor elnyerési rekord keletkezik.
2. A bemutatás a dashboard megfelelő állapotában történik.

Szabályok:
- Egy időszakon belül egy mérföldkövet egyszer regisztrálunk.
- Az elnyert kép az idővonalon is megjelenik.
- Más képernyőn végzett szerkesztést vagy folyamatot nem szakítunk meg.
- Dashboardra lépéskor megjelenhetnek a még át nem adott ajándékok.
- Ha éjfélkor a dashboardon van a felhasználó, és nincs megszakítandó folyamat, az ajándék ott megjelenhet.
- Hosszabb kihagyás vagy korábbi kezdőnap miatt több elért mérföldkő mindegyikét rögzítjük; egy lapozható átadásban mutatjuk meg.
- A már bemutatott ajándékot nem adjuk át minden indításkor újra.
- Időszak törlésekor az elnyerési rekord törlődik; az alkalmazás közös képassetje nem felhasználói adat.

## 6. Tulajdonosi modell és idővonal

**Az idővonal minden esetben csak hivatkozik. Nem birtokol tartalmat, és nem készít önálló tartalommásolatot.**

A tulajdonos modul, az időszakhoz való kapcsolat és az idővonali megjelenítés külön fogalom.

| Adat | Tulajdonos |
| --- | --- |
| Napi reflexió | Reflexiók |
| Pánikmódban írt bejegyzés | Reflexiók, pánik flaggel |
| Gyűlésrészvétel és gyűlésmegjegyzés | Gyűlések |
| Lépésmunka, lépések és válaszok | Lépésmunkák |
| Átbeszélendő és átbeszélt szponzori téma | Szponzor |
| Ajándék elnyerése | Elismerések |
| Gyakorlatkártya | Gyakorlatok; az alapapp önálló, időszaktól és idővonaltól független része |

A közös Content kezeli a formázott dokumentumot és a hangmemók kapcsolatait. A tulajdonos modul adja a tartalom üzleti jelentését és életciklusát.

Minden önálló entitás stabil azonosítót kap. Egy lépésválasz Content-azonosítója mellett külön hivatkozik a lépésmunkára; az idővonali kapcsolat ettől független.

### 6.1. Tervezett entitások

Az elnevezések tervezési munkanevek, nem végleges SQL-séma.

| Entitás | Szerep |
| --- | --- |
| RecoveryPeriod | Kezdőnap, lezárás, időszakállapot |
| Content | Strukturált dokumentum és tartalomazonosító |
| AudioAttachment | Hangfájl metaadata és Content-kapcsolata |
| Reflection | Reflexió tulajdonosi rekordja, pánik flag és időszak-kapcsolat |
| PanicSession | A 15 perces eljárás konkrét alkalma és állapota |
| StepWorkbook / StepRun / StepAnswer | Lépésmunka, adott lépés kidolgozása és válasz |
| SponsorTopic | Átbeszélendő/átbeszélt téma, saját és hivatkozott tartalom |
| Meeting / MeetingOccurrence / Attendance | Gyűlés, konkrét alkalom, saját részvétel |
| AwardGrant | Elnyerés és bemutatási állapot |
| TimelineEntry | Eredeti forrásra mutató, időszakhoz kapcsolt hivatkozás |
| Practice | Önálló gyakorlatkártya, saját azonosítóval és életciklussal; nincs időszak- vagy idővonalkapcsolata |
| AppSettings | Modulválasztás és alkalmazásbeállítások |

### 6.2. Megjelenítési szabályok

- Az idővonalból megnyitott szerkesztés az eredeti tartalmat módosítja.
- Automatikus mentés nem hoz létre mentésenként új idővonalkártyát.
- A függő szponzori checklist nem kerül az idővonalra.
- A gyakorlatkártya nem idővonali forrás. Létrehozása, szerkesztése, aktiválása, szüneteltetése, archiválása és törlése sem hoz létre idővonaleseményt.
- Átbeszélés után az adott időszak idővonala az átbeszélt témára/tartalomra hivatkozik.
- A tárcsázó vagy SMS-alkalmazás megnyitása nem bizonyít megtörtént hívást vagy elküldött üzenetet.
- A gyűlésrészvétel konkrét alkalomhoz kötődik. Egy megjegyzés önmagában nem bizonyít részvételt.
- A létrehozás, a módosítás és a megjelenített esemény időpontja nem keverhető össze.
- Az összetett események csoportosításának és a pánikeljárás idővonali lezárásának részletes szabályai még pontosítandók.

## 7. Törlési szabályok – véglegesített működési alap

Ez a fejezet felváltja a beszélgetés korábbi, eltérő törlési javaslatait.

### 7.1. Egyedi tartalom

A tartalom a saját moduljából és az időszak/idővonal felől is kezelhető. Ugyanazt az eredeti rekordot módosítjuk vagy töröljük.

Törléskor:
- törlődik a saját tartalom és a hozzá tartozó hangmemó;
- minden rá mutató idővonali bejegyzés eltűnik;
- pusztán hivatkozott, más tulajdonoshoz tartozó önálló tartalom nem törlődik automatikusan.

Például szponzori listaelem törlése nem törli a csak hivatkozott eredeti lépésválaszt.

### 7.2. Teljes időszak/idővonal törlése

A művelet a tulajdonos modulokból is törli az időszakhoz tartozó:
- napi reflexiókat;
- pánik flaggel ellátott reflexiókat;
- gyűlésrészvételeket és megjegyzéseket;
- szponzorral átbeszélt tartalmakat;
- elnyerési rekordokat;
- saját hangmemókat és az idővonal hivatkozásait.

**A lépésmunka külön választható kivétel.** A törlés rákérdez, hogy a felhasználó a kapcsolódó lépésmunkát is törölni akarja-e.

- Megtartás: lépésmunka, válaszok és hangmemók megmaradnak a lépésmenüben; a törölt idővonal hivatkozásai megszűnnek.
- Törlés: a megerősítésben felsorolt érintett lépésmunka-tartalmak is törlődnek.
- Ha más időszakban megjelenő tartalom is érintett, ezt a megerősítés jelzi.

A közös szponzori elérhetőség, a gyűlések alapadatai, a még átbeszélendő témák, a gyakorlatkártyák és az appbeállítások megmaradnak. A gyakorlatkártyákra sem az időszak resetje, sem a visszaesés, sem az időszak/idővonal törlése nem hat.

A több időszakban szerkesztett lépésválasz, illetve a teljes munkafüzet és az egyes lépéskidolgozások pontos törlési határát még a részletes adatmodellben kell lezárni. A program nem dönthet erről rejtett, túl széles kaszkáddal.

### 7.3. Konzisztencia

Az adatbázis-változások összehangolt tranzakcióban történjenek. A fájltörlés külön, megszakítás után folytatható feladat, mivel fájlrendszer és adatbázis nem alkot közös tranzakciót. Nem maradhat megnyitható, érvénytelen hivatkozás.

## 8. Lépésmunkák és szponzor

### 8.1. Lépésmunka

- Független a tiszta időszakok életciklusától.
- Több lépésmunka párhuzamosan létezhet.
- Visszaesés után ugyanaz a munka folytatható.
- Az adott időszakban végzett munka megjelenik annak idővonalán.
- A lépésmenüben külön kezelhető reset, törlés és új munka indítása.
- Új munka indítása nem írja felül a korábbi munkát.
- Az időszaktörlés lépésmunka-kivételét a 7. fejezet szabályozza.

### 8.2. Szponzor

- Minden függő és átbeszélt téma a szponzormodul tulajdona, ott elérhető.
- Visszaeséskor a témák megmaradnak.
- Függő téma nincs az idővonalon; átbeszélt témára az átbeszélés időszaka hivatkozik.
- Egyes témák törölhetők, a témalista resetelhető.
- Egyedi törlés és listareset eltávolítja a kapcsolódó idővonali hivatkozásokat is.
- A teljes időszaktörlés az oda tartozó átbeszélt tartalmat a szponzormodulból is eltávolítja.
- A szponzori témalista resetje nem jelent automatikusan elérhetőségtörlést.

### 8.3. Gyakorlatkártyák

**Elfogadott alap:** a gyakorlatkártya külön entitás, az alapapp része, nincs kapcsolata az idővonallal. Minden extra kikapcsolása mellett is létrehozható és használható. Saját tulajdonosa a Gyakorlatok, nem a reflexió vagy a lépésmunka.

A HTML `Amit gyakorlok` blokkja és gyakorlatkezelője alapján tervezett működés:
- Saját gyakorlat létrehozása és szerkesztése.
- Cím, kiváltó helyzet és vállalt cselekvés/szándék megadása.
- Aktív, szüneteltetett és archivált állapot.
- Egyszerre legfeljebb egy aktív gyakorlat; új aktiválásakor az előző szüneteltetett lesz.
- Mentés későbbre aktiválás nélkül.
- Egyedi, megerősített törlés.
- Üres állapotban nem keletkezik automatikus gyakorlat vagy bemutatóadat.

Tervezett adatmezők:

| Mező | Jelentés |
| --- | --- |
| practiceId | Stabil saját azonosító |
| title | A gyakorlat címe |
| triggerText | A helyzet, amelyben gyakorolni szeretném |
| intentionText | Amit ebben a helyzetben tenni szeretnék |
| status | active / paused / archived |
| createdAt, updatedAt, activatedAt | Létrehozás, módosítás, aktiválás időpontja |
| sourceKind | Saját gyakorlat vagy opcionálisan lépésválaszból indított gyakorlat |
| sourceReference | Opcionális eredethivatkozás; nem tulajdonosi kapcsolat |
| sourceTextSnapshot | A létrehozáskor átvett forrásszöveg, az eredeti későbbi változásától függetlenül |

Nincs `recoveryPeriodId` és nincs rá mutató `TimelineEntry`. A létrehozási dátum önmagában nem rendeli időszakhoz. A gyakorlat nem egyszerű Content-típus: saját strukturált mezői és állapotgépe vannak; az univerzális dokumentumszerkesztő esetleges használata ettől külön döntés.

Az egyetlen aktív gyakorlat feltételét az adatbázisban is érvényesíteni kell. Az előző szüneteltetése és az új aktiválása egy tranzakció; a UI az adatbázisból olvassa az aktív kártyát. Külön, versengő tartós aktívazonosító nem szükséges.

A HTML lépésválaszból is tud gyakorlatot indítani. Ez opcionális belépési út, nem lépésmodul-függőség. A forrás törlése esetén az eredethivatkozás megszűnik, a gyakorlat és a saját forrásszöveg-pillanatképe megmarad. Lépésmunka- vagy időszaktörlés nem kaszkádolhat a gyakorlatokra.

**Elfogadott kiegészítés: gyakorlat-pillanatkép a napi reflexióban.** A napi reflexió az akkori aktív gyakorlat pillanatképét és az ahhoz opcionálisan írt megfigyelést is tárolja.

- A pillanatkép a reflexióhoz való első hozzárendeléskor rögzíti a gyakorlat címét, kiváltó helyzetét és vállalt cselekvését. Újranyitáskor nem frissül automatikusan az élő gyakorlatból.
- A pillanatkép és a megfigyelés tulajdonosa a Reflection. Nem új Practice entitás és nem külön idővonalesemény.
- Az idővonal továbbra is csak a reflexióra hivatkozik; a gyakorlatkártyára nem.
- A gyakorlat későbbi szerkesztése, állapotváltása vagy törlése nem módosítja és nem törli a korábbi reflexió pillanatképét vagy megfigyelését. A megjelenítéshez nem szükséges élő Practice rekord.
- Aktív gyakorlat hiányában is elkészíthető a napi reflexió; a gyakorlatra vonatkozó megfigyelés nem kötelező.
- A reflexió vagy az azt birtokló időszak törlése törli a reflexió saját pillanatképét és megfigyelését, de az önálló gyakorlatkártyát nem.
- A pillanatkép és a megfigyelés a reflexióval együtt része a teljes biztonsági mentésnek.

A teljes biztonsági mentés minden gyakorlatot és állapotát tartalmazza; a visszaállítás a saját azonosítókat is megőrzi.

## 9. Pánikmód

Mindig elérhető:
- „Miért kezdtem el?” – onboardingban megadható saját szöveg.
- A prototípus jelenlegi 15 perces eljárása.
- Saját írás a közös editorral.

Gyűlések csak aktív gyűlésmodulnál, szponzor csak aktív szponzormodulnál jelenik meg. Kikapcsolt modulhoz nem marad letiltott helykitöltő gomb.

A pánikírás önálló Content, a reflexiók birtokolják pánik flaggel. A reflexiók adattárolási képessége az alapapp része akkor is, ha a napi reflexió extra nincs bekapcsolva.

A 15 perces idő háttérbe lépés közben tovább telik; visszatéréskor az eltelt idő alapján frissítünk. Az idő lejárta nem jelent automatikus befejezést.

A „Miért kezdtem el?” későbbi szerkeszthetősége és közös, resetet túlélő tárolása tervezett működés; a részletes adatkapcsolat még véglegesítendő.

## 10. Univerzális editor

Minden tartalomtípus egy közös szerkesztőalapot használ: szöveges box, alsó rail, automatikus mentés.

| Rail-művelet | Követelmény |
| --- | --- |
| Behúzás növelése/csökkentése | Egész bekezdés egy szinttel beljebb/kijjebb |
| Felsorolás | Bekezdések listává és vissza alakítása |
| Listahierarchia | Többszintű lista; listán belül a behúzás a hierarchiaszintet módosítja |
| Félkövér, dőlt, aláhúzás | Karakterszintű formázás |
| Betűszín | Szövegszín |
| Színes kiemelés | Szöveg mögötti kiemelőszín |
| Szövegigazítás | Bekezdésszintű igazítás |
| Betűméret | Kijelölt szöveg mérete |

Kijelölés nélkül a karakterformázás a következő begépelt szövegre, a bekezdésművelet a kurzor bekezdésére vonatkozik. Több kijelölt bekezdésnél mindegyik érintett.

A behúzás és a listahierarchia strukturált adat, nem szóközsorozat. A dokumentum újranyitás, olvasónézet és export/import után megőrzi szerkezetét és formázását.

Egy bejegyzés tartalmazhat szöveget, több hangmemót, vagy kizárólag hangot. Az üres editor megnyitása önmagában nem hoz létre tartalmas idővonaleseményt.

Az editor motorja még nincs kiválasztva. Saját felületet és railt tervezünk; az alatta lévő motor csak akkor fogadható el, ha az összes követelményt teljesíti. Flutter Quill korábbi jelölt, nem végleges döntés. A dokumentumformátum és verziózása a motorpróbával együtt véglegesítendő.

## 11. Automatikus mentés és hangkezelés

### 11.1. Szöveg

A mentési koordinátor sorrendben kezeli a módosításokat. Régebbi mentés nem írhatja felül az újabb változatot. A „Mentve” állapot csak sikeres tárolást jelezhet.

Rövid késleltetésű és folyamatos gépelés mellett is rendszeres mentés szükséges. Nem támaszkodhatunk kizárólag kilépési callbackre. Hibás mentés látható hibát eredményez; a még nem mentett szerkesztés megőrzendő és újrapróbálható.

Az autosave és a tartalom piszkozat/kész állapota külön fogalom. A konkrét állapotváltási szabályok még pontosítandók.

### 11.2. Diktálás

- Magyar nyelv, teljesen offline, első használatkor is.
- Az alkalmazással szállított modell.
- Szerkeszthető szöveg beszúrása a kurzornál.
- A diktálás hangját nem őrizzük meg automatikusan.
- Megszakításkor a véglegesített szöveg megmarad, a mikrofon nem indul újra magától.
- Meglévő hangmemó utólagos átírása külön, még nem vállalt funkció.

### 11.3. Hangmemó

- Felvétel, leállítás, visszahallgatás és törlés.
- Egy Contenthez több felvétel tartozhat.
- A lezárt felvétel automatikusan mentődik.
- Háttérbe lépéskor vagy hívás miatti megszakításkor a rögzítés leáll, az addigi hang mentendő.
- Feloldás után ugyanahhoz a bejegyzéshez térünk vissza.
- Folytatáshoz kézzel indítható új hangmemó.
- A hangfájl a teljes mentési csomag része.

A hang külön app-private fájl, a metaadat és kapcsolat az adatbázis része. A kész fájl és a késznek jelölt adatbázisrekord összhangját, a félbeszakadt felvételek helyreállítását és az árva fájlok kezelését tervezetten kell megoldani.

## 12. Alkalmazászár

Felhasználó által választható módok:
1. Kikapcsolva.
2. Csak PIN.
3. Biometria, PIN-es tartalék feloldással.
4. PIN és biometria: mindkettő szükséges.

A PIN legalább hat számjegy; hosszabb is megadható.

Aktív zárnál minden indítás és minden valódi háttérből visszatérés az adott mód szerinti azonosítást igényli, türelmi idő nélkül. Ez a tárcsázóból/SMS-ből visszatérésre is érvényes. A szerkesztés állapota megmarad.

A biometrikus rendszerablak saját életciklus-eseményei nem hozhatnak létre újraazonosítási hurkot. A biometrikus képesség hiánya, megváltozása, zárolása és a két azonosítást követelő mód helyreállítási szabályai még technikailag véglegesítendők. Az együttes módot nem lehet csendben csak PIN-re gyengíteni.

Az alkalmazászár és a helyi fájlok titkosítása külön műszaki kérdés; az utóbbi kulcskezelési megoldása még nyitott.

## 13. Biztonsági mentés és telefonváltás

Egyetlen hordozható, titkosított csomag tartalmazza:
- a teljes alkalmazás-adatbázist;
- hangmemókat és saját fájlokat;
- modulválasztást és egyéb hordozható beállításokat;
- a kikapcsolt modulok adatait;
- a visszaállítás ellenőrzéséhez szükséges verzió- és sértetlenségi információt.

A korábbi „RAR” megnevezés hordozható archívumigényt jelent; a konkrét formátum nincs véglegesítve.

### 13.1. Védelem

- Kötelező titkosítás legalább hat számjegyes PIN-nel.
- Exportkor PIN-megadás és megerősítés.
- A PIN a visszafejtéshez szükséges, nem pusztán az importfelület zárolása.
- Mentési PIN és alkalmazás-PIN külön kezelendő.
- Elfelejtett mentési PIN-hez nincs szerveres helyreállítás.
- A PIN nem tárolható visszaolvashatóan a csomagban.
- A rövid numerikus PIN korlátozott keresési tere miatt a kulcsszármaztatás és paraméterezés külön biztonsági tervezési feladat.

### 13.2. Export és import

- Konzisztens adatbázis- és fájlpillanatkép szükséges.
- Hordozható fájlazonosítók/relatív utak; készülékspecifikus abszolút útvonal nem maradhat tartós hivatkozás.
- Androidról iOS-re és vissza is visszaállítható.
- A visszaállítás teljes cserét végez, nem összefésülést.
- Az ellenőrzés és előkészítés a jelenlegi adatok lecserélése előtt történik.
- Hibás PIN, sérült vagy nem támogatott csomag nem módosíthatja a jelenlegi adatállományt.
- Csere előtt helyi biztonsági mentés készül; annak védelmét és megőrzési szabályát még véglegesíteni kell.
- Új készüléken a biometrikus azonosítást újra kell engedélyezni.
- A hordozható mentés nem függhet kizárólag a régi készülékhez kötött kulcstól.

A natív telefonköltöztetés támogatása követelmény, külön Android–Android és iOS–iOS ellenőrzéssel. Minden gyártói klónozó és natív keresztplatformos költöztetés működése nem tekinthető igazoltnak; az alkalmazás saját export/importja biztosítja a tervezett keresztplatformos útvonalat.

## 14. Tervezett architektúra

Tervezett alap: Flutter + Dart; helyi SQLite + Drift; Riverpod az állapotok és függőségek kezelésére. A konkrét csomagverziók és platformintegrációk ellenőrzése az implementáció előtt szükséges.

| Réteg | Felelősség |
| --- | --- |
| UI | Képernyők, közös editor, felhasználói műveletek |
| Alkalmazáslogika | Mentés, időszakváltás, mérföldkő-kezelés, összehangolt törlés |
| Repository/adatkezelés | Lekérdezések, tranzakciók, kapcsolatok, migrációk |
| Platformintegráció | Mikrofon, biometria, fájlmegosztás, életciklus |
| Közös szolgáltatások | Beszédfelismerés, hangkezelés, titkosított export/import |

Adatfolyam: felhasználói művelet → alkalmazáslogika → repository/tranzakció → megváltozott adatok lekérdezése → érintett felületek frissítése.

A tartós adatok forrása az adatbázis. A kurzor, kijelölés és szerkesztés közbeni még nem mentett állapot az editor/szerkesztési munkamenet felelőssége. Nem építünk párhuzamos, versengő teljes adatmásolatot a UI-állapotba.

A hosszabb adatbázis-, archiválási és beszédfelismerési feladatok nem blokkolhatják a UI-t. Az idővonal lapozott/indexelt lekérdezéseket használjon; ne kelljen minden dokumentumot és hangfájlt előre betölteni.

Az adatbázisséma és a szerkesztő dokumentumformátuma verziózott. Minden későbbi változás megőrző migrációval, mentés-visszaállítási teszttel jár.

## 15. Fejlesztési sorrend

1. Technikai próbák: editor és offline magyar diktálás valódi Androidon és iOS-en.
2. Közös alapok: adatmodell, Content, mentési koordinátor, hangéletciklus, alkalmazászár, export/import.
3. Alapapp: onboarding, számláló, időszakok, idővonal, elnyerések, pánikmód, gyakorlatkártyák és gyakorlatkezelő.
4. Napi reflexiók.
5. Szponzor.
6. Gyűlések.
7. Lépésmunka.

A közös editor első változata az alapapphoz szükséges, mert a pánikmód is tartalmaz írást. A későbbi modulok közös szolgáltatásokat használnak, nem külön editorokat és mentési rendszereket.

## 16. Elfogadási feltételek

Ezek követelmények, nem lefuttatott tesztek.

- Első indítástól repülő üzemmódban működik minden vállalt offline képesség, a magyar diktálás is.
- Mai kezdőnap 0; korábbi kezdőnap helyes naptári különbség.
- Éjféli frissítés és háttérből visszatérés nem hoz létre dupla elnyerést.
- Ajándék nem szakítja meg a más képernyőn végzett szerkesztést.
- Több esedékes ajándék egy lapozható átadásban elérhető.
- Visszaesés megőrzi a korábbi időszakot és nem reseteli a lépésmunkát.
- Egyedi törlés minden hivatkozást eltávolít, idegen tulajdonú hivatkozott tartalmat nem töröl.
- Időszaktörlés mindkét lépésmunka-választással helyesen működik.
- Pánikreflexió menthető kikapcsolt napi reflexió extra mellett.
- Gyakorlatkártyák minden extra kikapcsolása mellett használhatók; egyszerre legfeljebb egy aktív.
- Gyakorlatművelet nem hoz létre idővonaleseményt; visszaesés, reset és időszaktörlés nem módosítja a gyakorlatokat.
- Opcionális lépésforrás törlése megőrzi a gyakorlatot és annak forrásszöveg-pillanatképét.
- Export/import megőrzi a gyakorlatkártyák azonosítóit, mezőit és állapotát.
- A napi reflexió gyakorlat-pillanatképe és megfigyelése a gyakorlat módosítása/törlése és export/import után is megmarad; nem keletkezik külön gyakorlat-idővonalesemény.
- Reflexió vagy időszak törlése a hozzá tartozó pillanatképet törli, az önálló gyakorlatot megőrzi.
- Szponzori függő lista nem jelenik meg az idővonalon; átbeszélt téma igen.
- Editorformázás és listahierarchia mentés, újranyitás és visszaállítás után megmarad.
- Régebbi mentés nem ír felül frissebb szöveget.
- Mikrofon-megszakítás és alkalmazászár után a mentett munka elérhető; nincs automatikus újrafelvétel.
- Hibás PIN, sérült csomag vagy félbeszakadt import nem rombolja a jelenlegi adatokat.
- Android→iOS és iOS→Android export/import hangokkal együtt ellenőrzött.
- Többéves adatmennyiségnél az idővonal és keresés teljesítménye mérhető; számszerű célérték még kijelölendő.
- A kiválasztott zárolási mód minden indításkor/visszatéréskor érvényesül, biometrikus hurok nélkül.

## 17. Következő egyeztetések és nyitott döntések

- Mérföldkövek konkrét napértékei és kép-hozzárendelése.
- Editor motorja, dokumentumformátuma, verziózása, pontos formázási értékkészlet.
- Magyar beszédfelismerő motor és modell; pontosság, késleltetés, memória, csomagméret, licenc.
- Minimum Android/iOS-verziók és eszközök, iOS-es fizikai tesztelés útvonala.
- Helyi adattitkosítás, kulcskezelés és összhang a telefonköltöztetéssel.
- Mentési csomag formátuma, kriptográfiai paraméterei, helyi előmentés megőrzése.
- Elfelejtett alkalmazás-PIN és a PIN+biometria mód helyreállítási szabályai.
- Több időszakot érintő lépésmunka pontos törlési egysége és hatáslistája.
- Időzónaváltás, óraállítás, új időszakok dátumütközése.
- Piszkos/piszkozat/kész szerkesztési és tartalomállapotok.
- Kikapcsolt modul korábbi tartalmainak szerkeszthetősége.
- Idővonali csoportosítás, pánikeljárás megszakításának és befejezésének megjelenítése.
- A további modulok részletes képernyőspecifikációi a saját fejlesztési szakaszuk előtt.

A nyitott pontokat nem szabad automatikusan kész döntésként implementálni.

## 18. Dokumentációs ellenőrzési feljegyzés

Forrás: a 2026-11-26-i tervezési beszélgetés, a felhasználó legutolsó korrekcióinak elsőbbségével.

Áttekintett repóreferenciák:
- `AGENTS.md`
- `html-prototypes/app-shell/index.html`: `createPractice`, `createPracticeState`, `renderHomePracticeBlock`, `commitPracticeEditor`, `setPracticeStatus`, `deletePractice`, `createDailyReflectionPracticeSnapshot`.
- `docs/prototypes/REFINEMENT_AND_PRACTICE_MANAGER_ACCEPTANCE_CHECKLIST.md`, különösen RPM-07–09.
- `docs/HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md` teljes szövege, különösen §§1, 5–9, 11–12, 15, 17–20, 22–26.
- `docs/prototypes/ACCEPTANCE_CHECKLIST.md` releváns tulajdonosi, editor-, szponzor- és idővonalbejegyzései.

Eltérések feloldása:
- Régi napi check-in alapú növelés → automatikus, 0-ról induló naptári számláló.
- Régi fiók/felhőszinkron → offline helyi alkalmazás.
- Régi állandó modulstruktúra → felhasználó által választható extrák.
- Régi általános reset-megőrzés → külön visszaesés, reset és megerősített törlés, lépésmunka-kivétellel.
- Korábbi tulajdonlási javaslatok → modulok birtokolnak, idővonal csak hivatkozik.

PNG-vizuális ellenőrzés és HTML-komponensmódosítás: nem alkalmazandó ehhez a dokumentációmentéshez; nincs új vizuális döntés vagy UI-kódváltozás.

Dokumentációs státusz:
- DONE: az elfogadott működési döntések egy helyen rögzítve.
- DONE: a korábbi szabályokat felváltó döntések jelölve.
- DONE: nyitott technikai/termékpontok elkülönítve.
- NOT IMPLEMENTED: a teljes alkalmazás Flutter-funkciói, editor, hang, titkosítás és teljes platformtesztelés. Az S0 starter aktuális állapotát külön elfogadási lista követi.

## 19. S0 starter és időkezelés

Az S0 kizárólag a `docs/implementation/HAJNAL_S0_STARTER_PROMPT.md` szerinti shell, kezdődátum, helyi adattárolás, naptárkövetés és artwork-alap. A teljes alkalmazás további moduljai nem részei az S0-nak. A fix kezdőnapot időzónaváltáskor nem konvertáljuk; a mai nap a készülék helyi dátuma, a kijelzett érték a naptári különbség legalább nullára korlátozva. Az offline készülékóra változtatása visszafelé is módosíthatja a kijelzést. Ez nem manipulációbiztos időhitelesítés.

Az első adatbázis-séma v1. Minden későbbi sémaváltozás megőrző migrációval és korábbi sémafixture-ön végzett teszttel kerülhet be; adatvesztő törlés és újralétrehozás nem elfogadható. Az S0 implementáció készülő állapotát a `docs/implementation/S0_ACCEPTANCE.md` követi.
