# Hajnal – részletes alkalmazásspecifikáció

## 1. Az alkalmazás célja

A Hajnal célja a függőségből felépülő emberek tiszta időszakainak követése, támogatása és ösztönzése. Egy egyszerűen használható, látványos mobilalkalmazás készül, amely szemléletében összeegyeztethető a Névtelen Alkoholisták (NA) alapelveivel.

Technikailag a Hajnal egy kiterjesztett naplóalkalmazás. A felhasználó követheti tiszta időszakait, rögzítheti gondolatait és haladását, valamint dolgozhat a 12 lépés írásos feladatain. A rendszer központi eleme a naplózás: a cél egy egyszerű, letisztult, könnyen áttekinthető és később visszanézhető felület.

A naplóhoz egyedi szövegszerkesztő készül hangalapú gépeléssel és eltárolható hangjegyzetekkel. Az alkalmazás elsődleges célja az első 90 nap támogatása, ezt követően pedig a hosszú távú józanság követésének segítése.

Az alkalmazás fő funkcionális területei:

- a tiszta napok követése;
- a gondolatok, haladás és napi élmények naplózása;
- a 12 lépéshez kapcsolódó írás és önreflexió támogatása;
- a napi megtartó rutin és a szponzorral vagy segítő személlyel való kapcsolattartás;
- az első 90 nap, majd a további józanság áttekinthető követése.

Az app nem kezelési eszköz és nem helyettesít addiktológust, pszichológust, orvost, önsegítő közösséget vagy sürgősségi ellátást. A felülete ezt egyértelműen, de nem ijesztő módon kommunikálja.

## 2. Alapkoncepció és képmotor

Az alkalmazás legfontosabb vizuális eleme a képmotor. Minden kép metaforikus, egységes és determinisztikusan előállított. Két képtípus jelenik meg:

- a mérföldköveknél ajándékként kapott képek;
- a főképernyő állandóan változó háttérképe.

### A szereplők jelentése

**Panda:** a felhasználót jelképezi.

**Láma:** a programot és a megtartó, „felsőbb erőt” jelképezi. Jelen van, támogat és elkísér; nem tanít, nem ítélkezik és nem beszél túl sokat.

Az első 90 napban a panda és a láma háttal áll a felhasználónak; a láma kizárólag jelenlétével támogat. A 90. nap után megfordulnak, és közös tevékenységet végeznek: például tónál horgásznak, mezőn énekelnek vagy erdei tisztáson olvasnak.

### A háttér szabályai

- A megjelenített évszak mindig a valós naptár szerinti évszakkal azonos.
- Az első 90 nap alatt a napszak a felhasználó haladásával együtt változik: a sötét éjszaka fokozatosan hajnallá válik.
- A 90. nap után a nehezén túljutást nappali idő jelzi.
- Az időjárás és a táj részletessége az alkalmazásban rögzített aktuális hangulatot követi ötfokú skálán.
- Az 1-es hangulatérték borús, zivataros eget és gyér, kopár növényzetet jelent; az 5-ös tiszta eget vagy holdfényt, napfényt, madarakat és dús, kidolgozott növényzetet.

### A prototípus jelenlegi állapota

A jelenlegi állapot egy megközelítő menüszerkezetet mutat. A gombok végleges helye és a menük részletes elrendezése későbbi tervezési körben készül el.

## 3. Fő navigáció

Az alkalmazás alsó navigációs sávja öt állandó menüpontból áll.

### 3.1. Kezdőlap

Ikon: ház vagy felkelő nap.

Feladata:

- aktuális tiszta nap megjelenítése;
- aznapi vizuális kép;
- napi feladatok;
- esti check-in;
- gyors hozzáférés a pánik gombhoz.

### 3.2. Haladás

Ikon: növekvő grafikon vagy ösvény.

Feladata:

- 90 napos út;
- napok feloldása;
- naptár;
- statisztikák;
- mérföldkövek;
- korábbi napi képek.

### 3.3. Eszközök

Ikon: négy pontból vagy egyszerű szerszámosládából álló jel.

Feladata:

- 12 lépés munkafüzet;
- napló;
- sóvárgásnapló;
- hála lista;
- légzőgyakorlat;
- „Miért kezdtem el?”;
- napi józansági kérdés;
- személyes túlélőcsomag.

### 3.4. Szponzor

Ikon: két ember.

Feladata:

- szponzor adatlapja;
- hívás;
- üzenet;
- kapcsolatnapló;
- következő megbeszélés;
- előre megírt segítségkérő üzenetek.

### 3.5. Profil

Ikon: személy.

Feladata:

- alapadatok;
- célok;
- kezdődátum;
- értesítések;
- adatvédelem;
- megjelenés;
- exportálás;
- támogatási és jogi információk.

## 4. Képernyők száma

Az első teljes verzió körülbelül 38 egyedi képernyőből állhat.

Nem mindegyik külön menüpont. Több képernyő modális ablak, részletező oldal vagy folyamatlépés.

### Képernyőcsoportok

| Terület | Képernyők száma |
|---|---:|
| Regisztráció és beállítás | 7 |
| Kezdőlap és napi check-in | 6 |
| Haladás | 6 |
| Eszközök | 10 |
| Szponzor | 4 |
| Profil és beállítások | 5 |
| **Összesen** | **38** |

Az MVP ennél kisebb lehet, körülbelül 22–24 képernyővel.

## 5. Belépési és kezdő folyamat

### Screen 1 – Splash screen

Megjelenik:

- Hajnal logó;
- alkalmazásnév;
- mottó: „Csak a mai nap.”

2–3 másodperc után automatikusan továbbmegy.

Első használatkor az onboarding nyílik meg. Visszatérő felhasználónál a Kezdőlap.

### Screen 2 – Üdvözlőképernyő

Szöveg:

> Nem kell 90 napot egyszerre végigcsinálnod.
> Csak a mait.

Gombok:

- Kezdjük el
- Már van fiókom

A „Kezdjük el” az adatvédelmi tájékoztatóra vezet.

### Screen 3 – Fontos tájékoztatás

Rövid, könnyen érthető szöveg:

- az app nem helyettesít szakmai segítséget;
- sürgős veszély esetén a felhasználó kérjen azonnali segítséget;
- az adatok érzékeny személyes adatok lehetnek;
- lehetőség van helyi titkosításra vagy PIN-kódra.

Jelölőnégyzet:

- Elolvastam és elfogadom.

Gomb:

- Tovább

### Screen 4 – Kezdődátum beállítása

Kérdés:

> Mikor kezdődött a jelenlegi tiszta időszakod?

Lehetőségek:

- Ma
- Tegnap
- Dátum kiválasztása

Ez alapján számolja ki az aktuális napot.

Fontos: a nap csak akkor válik véglegesen megerősített tiszta nappá, amikor a felhasználó kitölti az esti check-int.

### Screen 5 – Felépülési cél

Választható opciók:

- Alkohol
- Kábítószer
- Gyógyszer
- Szerencsejáték
- Viselkedési függőség
- Nem szeretném megadni
- Egyéb

Ez lehet teljesen opcionális.

Az app alapfunkciói ettől nem változnak, csak a szövegezés személyre szabható.

### Screen 6 – Segítő kapcsolat beállítása

Kérdés:

> Van szponzorod vagy segítő személyed?

Opciók:

- Igen, hozzáadom
- Később
- Nincs még

Megadható:

- név;
- telefonszám;
- üzenetküldési mód;
- mikor érdemes hívni;
- tartalék segítő személy.

### Screen 7 – Napi rutin és értesítések

Beállítható:

- reggeli emlékeztető;
- esti check-in időpontja;
- szponzorhívás emlékeztetője;
- napi írás emlékeztetője;
- meeting emlékeztetője.

Alapértelmezett esti check-in: 21:00.

Gomb:

- Belépek a Hajnalba

Innen a Kezdőlap nyílik meg.

## 6. Kezdőlap

### Screen 8 – Főképernyő

Ez a legfontosabb képernyő.

#### Felső rész

- aktuális nap: „24. nap”;
- rövid mondat: „Csak a mai nap.”;
- értesítés ikon;
- menü vagy gyorsbeállítás ikon.

#### Vizuális rész

A napi illusztráció:

- panda;
- láma;
- aktuális évszak és napszak;
- egyszerű dombok, fák, nap vagy hold.

A kép érintésére megnyílik a napi kép teljes képernyőn.

#### Tiszta napok kártya

Megjelenik:

- jelenlegi sorozat;
- összes tiszta nap;
- „Ma még nincs lezárva” állapot.

Este itt jelenik meg a „Napi check-in” gomb.

#### Mai feladatok

Példák:

- hívd fel a szponzorod;
- írj 10 percet;
- menj el egy meetingre;
- írj 3 dolgot, amiért hálás vagy;
- töltsd ki az esti check-int.

A felhasználó kipipálhatja őket.

#### Pánik gomb

Mindig látható, de nem uralja az egész képernyőt.

Felirat:

- Segítség kell

Innen a Pánik képernyő nyílik.

### Screen 9 – Napi kép teljes képernyőn

Megjelenik:

- napi illusztráció;
- nap száma;
- egy rövid üzenet;
- megosztás opcionálisan;
- mentés a telefonra opcionálisan.

Példa:

> nap
> Nem kell tökéletesnek lenned. Ma elég kitartanod.

Innen vissza a Kezdőlapra.

## 7. Esti check-in folyamat

### Screen 10 – Napi lezárás

Kérdés:

> Hogy sikerült a mai napod?

Alatta:

> Te döntesz. Mi veled maradunk.

Két nagy gomb:

- Igen, ma tiszta maradtam
- Ma visszaestem

Egy kisebb link:

- Most nem szeretnék válaszolni

Az app soha nem választ automatikusan.

### Screen 11 – Sikeres nap megerősítése

Megjelenik:

- a panda és a láma egyszerű animációja;
- számláló +1;
- következő napi kép feloldása;
- rövid üzenet.

Példa:

> Megcsináltad a mai napot.
> Holnap újra csak egy nap következik.

Gomb:

- Napi lezárás befejezése

Ezután opcionálisan megnyílik a rövid esti reflexió.

### Screen 12 – Esti reflexió

Három gyors kérdés:

- Milyen volt a hangulatod?
- Mennyire volt erős a sóvárgásod?
- Mi segített ma?

Nem kötelező.

Gombok:

- Mentés
- Kihagyás

Ezután vissza a Kezdőlapra.

## 8. Visszaesési folyamat

A visszaesési folyamat különösen fontos. Nem használhat szégyenítő nyelvezetet, piros hibaképernyőt vagy büntető animációt.

### Screen 13 – Visszaesés megerősítése

Szöveg:

> Köszönjük, hogy őszinte voltál.
> Egy visszaesés nem törli el azt, amit eddig megtanultál.

Kérdés:

> Szeretnéd most újraindítani a számlálót?

Opciók:

- Igen, újrakezdem
- Később döntök
- Segítséget kérek

A „Segítséget kérek” a Pánik képernyőre vezet.

### Screen 14 – Újrakezdés beállítása

Kérdés:

> Mikor induljon az új tiszta időszak?

Opciók:

- Most
- Holnap
- Másik dátum

A korábbi eredmények nem törlődnek.

Külön tárolandó:

- jelenlegi sorozat;
- leghosszabb sorozat;
- összes korábbi tiszta nap;
- újrakezdések száma.

A felhasználó döntheti el, hogy az újrakezdések száma látszódjon-e.

### Screen 15 – Támogató következő lépés

Az app maximum három lehetőséget mutat:

- Hívd fel a szponzorod
- Írd le, mi történt
- Indíts egy 10 perces túlélőgyakorlatot

Nem jelenik meg túl sok opció egyszerre.

## 9. Haladás menü

A Haladás főmenüből négy irány nyílik.

### Screen 16 – Haladás áttekintés

Kártyák:

- jelenlegi sorozat;
- leghosszabb sorozat;
- összes tiszta nap;
- 90 napos út állapota;
- következő mérföldkő.

Alatta gyorsgombok:

- 90 napos út
- Naptár
- Statisztikák
- Mérföldkövek

### Screen 17 – 90 napos út

Rácsos vagy görgethető nézet.

Minden nap egy csempe.

Állapotok:

- teljesített;
- aktuális;
- még lezáratlan;
- zárolt;
- korábbi újrakezdéshez tartozó nap.

Egy teljesített nap megérintésére megnyílik a napi kép és az aznapi rövid összefoglaló.

### Screen 18 – Napi részlet

Megjelenik:

- dátum;
- nap száma;
- napi kép;
- napi feladatok;
- hangulat;
- sóvárgási érték;
- rövid naplóbejegyzés;
- szponzorral történt-e kapcsolat.

Csak a felhasználó által korábban rögzített adatok láthatók.

### Screen 19 – Naptár

Havi naptár.

Színkódok:

- zöld pont: megerősített tiszta nap;
- lila kör: mai nap;
- szürke: nincs adat;
- halvány rózsaszín: újrakezdés napja.

A visszaesést nem szükséges feltűnően pirossal jelölni.

A dátum megérintésére a napi részlet nyílik.

### Screen 20 – Statisztikák

Mutatók:

- jelenlegi sorozat;
- leghosszabb sorozat;
- összes tiszta nap;
- esti check-in teljesítési arány;
- átlagos sóvárgási szint;
- legtöbbször használt segítség;
- szponzorral való kapcsolatok száma;
- napi feladatok teljesítése.

Grafikonok:

- hangulat;
- sóvárgás;
- tiszta napok;
- kapcsolódások.

A statisztikák elrejthetők azok számára, akiket a számok stresszelnek.

### Screen 21 – Mérföldkövek

Mérföldkövek:

- 1 nap;
- 3 nap;
- 7 nap;
- 14 nap;
- 21 nap;
- 30 nap;
- 45 nap;
- 60 nap;
- 90 nap.

Minden mérföldkőhöz:

- külön minimalista illusztráció;
- rövid üzenet;
- opcionális megosztási kártya.

## 10. Eszközök menü

### Screen 22 – Eszközök főoldal

Lista:

- 12 lépés munkafüzet
- Napló
- Sóvárgásnapló
- Hála lista
- Napi józansági kérdés
- Légzőgyakorlat
- Miért kezdtem el?
- Túlélőcsomag
- Motivációs üzenetek

Minden sor érintésére külön képernyő nyílik.

## 11. 12 lépés munkafüzet

A munkafüzet nem egyetlen hosszú szövegmező. Vezetett kérdésekkel működik.

### Screen 23 – Lépések áttekintése

12 kártya:

- lépés száma;
- cím;
- állapot;
- kitöltött kérdések száma.

A következő lépés csak akkor nyílik meg, ha a felhasználó akarja. Nem szükséges az előzőt befejezni.

### Screen 24 – Lépés bevezető

Megjelenik:

- lépés száma;
- rövid összefoglaló;
- figyelmeztetés, hogy ne egyedül dolgozza fel, ha túl megterhelő;
- kérdések száma;
- becsült idő.

Gomb:

- Elkezdés
- Folytatás

### Screen 25 – Munkafüzet-kérdés

Egy képernyőn egy kérdés.

Elemei:

- kérdés;
- rövid magyarázat;
- szövegmező;
- hangalapú diktálás opcionálisan;
- mentés automatikusan;
- előző és következő gomb.

Példa:

> Mit jelent számodra a tehetetlenség?

### Screen 26 – Lépés összegzése

Megjelenik:

- kitöltött válaszok;
- fontos mondatok megjelölése;
- „Szeretném megbeszélni a szponzorommal” jelölő;
- PDF-export;
- megosztás csak külön megerősítéssel.

Az érzékeny tartalom miatt export előtt PIN-kód vagy biometrikus megerősítés kérhető.

## 12. Napló

### Screen 27 – Naplólista

Megjelenik:

- bejegyzések dátum szerint;
- keresés;
- címkék;
- új bejegyzés gomb.

Címkék például:

- sóvárgás;
- meeting;
- szponzor;
- hála;
- nehéz nap;
- felismerés.

### Screen 28 – Naplóbejegyzés

Lehetőségek:

- szabad írás;
- vezetett kérdés;
- hangulat hozzáadása;
- sóvárgási szint;
- címkék;
- titkosítás;
- szponzornak megmutatható jelölés.

## 13. Sóvárgásnapló

### Screen 29 – Sóvárgás rögzítése

Kérdések:

- Mennyire erős most? 0–10
- Mi váltotta ki?
- Hol érzed a testedben?
- Mit tettél?
- Segített?
- Kapcsolódtál valakihez?

Gyorsgomb:

- Segítség kell

Ez közvetlenül a Pánik képernyőt nyitja.

## 14. Hála lista

### Screen 30 – Napi hála

Három egyszerű mező:

> Ma hálás vagyok azért, hogy…

Nem kell pontosan három elemet írni. A felhasználó egy vagy több választ is menthet.

Korábbi hálaelemek külön listában visszanézhetők.

## 15. Napi józansági kérdés

### Screen 31 – Napi reflexió

Naponta egy rövid kérdés.

Példák:

- Mit tettél ma a felépülésedért?
- Mikor volt ma a legnehezebb?
- Kitől fogadtál el segítséget?
- Mi az az egy dolog, amit holnap másképp csinálnál?

A válasz bekerül a Naplóba.

## 16. Légzőgyakorlat

### Screen 32 – Légzés

Választható gyakorlatok:

- 1 perc;
- 3 perc;
- 5 perc;
- 4–6 légzés;
- dobozlégzés.

A képernyőn csak egy lassan növekvő és csökkenő geometriai kör vagy nap látható.

Szöveg:

- Belégzés
- Tartsd
- Kilégzés

## 17. „Miért kezdtem el?”

### Screen 33 – Személyes motiváció

A felhasználó rögzítheti:

- szöveg;
- képek;
- célok;
- fontos emberek;
- saját hangüzenet.

Ez megjeleníthető a Pánik képernyőn.

Külön gomb:

- Emlékeztess, miért kezdtem el

## 18. Pánik mód

### Screen 34 – Pánik képernyő

Ez minden főképernyőről legfeljebb egy érintéssel elérhető.

Felső szöveg:

> Nem vagy egyedül.
> Most csak a következő néhány perc számít.

Középen nagy gomb:

- Segítség kell

Alatta lehetőségek:

- Hívd a szponzorod
- Küldj segítségkérő üzenetet
- Hívd a tartalék kapcsolattartót
- 15 perces túlélőcsomag
- Légzőgyakorlat
- Olvasd el, miért kezdted el
- Keresd meg a következő meetinget
- Szakmai vagy sürgősségi segítség

#### A Segítség kell gomb működése

Első érintés után nem indít automatikus hívást.

Megnyílik egy alsó panel:

- Szponzor hívása
- Segítő személy hívása
- Előre megírt üzenet küldése
- Sürgősségi segítség

Ezzel csökkenthető a téves hívás veszélye.

#### 15 perces túlélőcsomag

Külön, vezetett folyamat:

1. Állj meg.
2. Vegyél öt lassú levegőt.
3. Igyál vizet.
4. Menj másik helyre.
5. Hívj fel valakit.
6. Várj 10 percet.
7. Értékeld újra a sóvárgást.

A visszaszámláló nem agresszív. Inkább nyugodt kör vagy lassan felkelő nap jelzi az időt.

## 19. Szponzor menü

### Screen 35 – Szponzor adatlap

Megjelenik:

- név;
- telefonszám;
- profilkép vagy egyszerű avatár;
- utolsó kapcsolat;
- következő megbeszélés;
- megjegyzés.

Nagy gombok:

- Hívás
- Üzenet

További opciók:

- Kapcsolat naplózása
- Meeting időpont hozzáadása
- Jegyzet
- Szponzor módosítása

### Screen 36 – Kapcsolatnapló

Rögzíthető:

- dátum;
- hívás vagy személyes beszélgetés;
- időtartam;
- miről beszéltetek;
- van-e következő feladat.

Nem szükséges automatikusan rögzíteni a hívások tartalmát.

### Screen 37 – Gyors üzenetek

Előre beállított, szerkeszthető szövegek:

- „Nehéz helyzetben vagyok. Fel tudnál hívni?”
- „Erős sóvárgásom van.”
- „Ma még nem beszéltünk. Mikor lennél elérhető?”
- „Szükségem lenne egy meetingre.”

Az üzenet elküldése előtt mindig legyen megerősítés.

### Screen 38 – Következő találkozó

Beállítható:

- dátum;
- időpont;
- helyszín;
- online link;
- emlékeztető;
- megbeszélendő témák.

## 20. Profil és beállítások

A Profil menü további részoldalakat nyit.

### Profil főoldal

Megjelenik:

- felhasználónév vagy becenév;
- aktuális tiszta nap;
- profilavatár;
- „Miért kezdtem el?”;
- személyes célok;
- beállítások;
- adatok és biztonság;
- súgó és támogatás.

### Beállítások

#### Értesítések

- reggeli üzenet;
- esti check-in;
- szponzor emlékeztető;
- napi írás;
- meeting;
- mérföldkövek.

#### Megjelenés

- automatikus világos/sötét mód;
- animációk csökkentése;
- statisztikák elrejtése;
- nagyobb betűméret;
- képek hangulata.

#### Adatvédelem

- PIN-kód;
- biometrikus feloldás;
- érzékeny értesítési szöveg elrejtése;
- helyi adattárolás;
- felhőszinkron;
- export;
- fiók és adatok törlése.

#### Nyelvezet

A felhasználó választhat:

- józan;
- tiszta;
- szermentes;
- saját kifejezés.

Ez fontos, mert nem minden közösség ugyanazt a terminológiát használja.

## 21. Navigációs térkép

```text
Splash
└── Onboarding
    ├── Tájékoztatás
    ├── Kezdődátum
    ├── Felépülési cél
    ├── Szponzor hozzáadása
    └── Értesítések
        └── Kezdőlap

Kezdőlap
├── Napi kép
├── Mai feladatok
├── Esti check-in
│   ├── Tiszta maradtam
│   │   └── Esti reflexió
│   └── Visszaestem
│       ├── Újrakezdés
│       └── Segítségkérés
└── Pánik mód

Haladás
├── 90 napos út
│   └── Napi részlet
├── Naptár
│   └── Napi részlet
├── Statisztikák
└── Mérföldkövek

Eszközök
├── 12 lépés
│   ├── Lépés bevezető
│   ├── Kérdések
│   └── Összegzés
├── Napló
├── Sóvárgásnapló
├── Hála lista
├── Napi kérdés
├── Légzőgyakorlat
├── Miért kezdtem el?
└── Túlélőcsomag

Szponzor
├── Adatlap
├── Hívás
├── Gyors üzenet
├── Kapcsolatnapló
└── Következő találkozó

Profil
├── Személyes célok
├── Értesítések
├── Megjelenés
├── Adatok és biztonság
├── Súgó
└── Kijelentkezés
```

## 22. Napi működés

### Reggel

A felhasználó megkapja az új napi képet.

Megjelenik:

- aktuális nap;
- rövid üzenet;
- napi feladatlista.

A számláló ekkor még nem nő automatikusan.

### Napközben

A felhasználó:

- kipipálhat feladatokat;
- írhat;
- rögzíthet sóvárgást;
- hívhatja a szponzort;
- használhatja a pánik módot.

### Este

Az app emlékezteti a napi check-inre.

Ha a felhasználó megerősíti, hogy tiszta maradt:

- a nap lezárul;
- a számláló +1;
- feloldódik a következő kép.

Ha visszaesést jelöl:

- az app támogató folyamatot indít;
- nem törli a történeti adatokat;
- lehetőséget ad az újrakezdésre;
- felajánlja a kapcsolatfelvételt.

Ha nem válaszol:

- a nap „nincs lezárva” állapotban marad;
- másnap visszamenőleg kitölthető;
- az app nem feltételez sem sikert, sem visszaesést.

## 23. MVP-funkciók

Az első kiadásba ezek kerüljenek:

- onboarding;
- kezdődátum;
- napi számláló;
- esti check-in;
- visszaesés és újrakezdés;
- 90 napos vizuális út;
- napi feladatok;
- szponzor hívása és üzenet;
- pánik mód;
- 12 lépés munkafüzet;
- napló;
- hála lista;
- alapértesítések;
- PIN-kód és adatvédelem.

Az MVP körülbelül 22–24 képernyő.

## 24. Későbbi verzió funkciói

Későbbi fejlesztésként:

- meetingkereső;
- naptárintegráció;
- anonim közösségi jelenlét;
- megosztható mérföldkövek;
- szakemberi vagy szponzori kísérőfelület;
- hangalapú napló;
- személyre szabott napi feladatok;
- több felépülési út;
- 90 nap után 6 hónapos és 1 éves út;
- viselhető eszköz integráció;
- offline teljes működés;
- titkosított biztonsági mentés.

## 25. Fontos UX-szabályok

- A visszaesés soha ne jelenjen meg hibaként.
- Ne használjon szégyenítő vagy moralizáló szöveget.
- A számláló ne legyen az egyetlen értékmérő.
- A korábbi fejlődés ne törlődjön resetkor.
- A pánik mód egy érintéssel elérhető legyen.
- Az app ne küldjön érzékeny értesítési szöveget zárolt képernyőre alapértelmezetten.
- A 12 lépéses válaszokat automatikusan mentse.
- Megosztás előtt mindig kérjen megerősítést.
- Az alkalmazás alapfunkciói internet nélkül is működjenek.
- A főképernyő ne tartalmazzon öt-hatnál több egyidejű feladatot.
- Minden képernyőn legyen világos visszalépési lehetőség.
- A felhasználó kikapcsolhassa az animációkat és a statisztikákat.
- A segély- és szakmai segítség menüpont földrajzi helyhez igazítható legyen.

## 26. Ajánlott technikai adatmodell

A fő adatobjektumok:

- User
- RecoveryJourney
- DailyCheckIn
- DailyTask
- CravingEntry
- JournalEntry
- GratitudeEntry
- StepWorkbook
- StepAnswer
- Sponsor
- SponsorContact
- Meeting
- Milestone
- NotificationPreference
- EmergencyContact

A visszaesés ne egyszerűen nullázza a teljes utat. Egy új RecoveryJourney rekord induljon, miközben a korábbi út archiválva megmarad.

Így külön számolható:

- jelenlegi sorozat;
- leghosszabb sorozat;
- összes megerősített tiszta nap;
- korábbi utak;
- 90 napos program aktuális állapota.
