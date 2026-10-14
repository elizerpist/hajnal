# Ösvény – jelölt kérdések gyűjteményei – elfogadási lista

Források: a 2026-10-14-i felhasználói implementációs specifikáció; a legfrissebb Android referencia (`/storage/emulated/0/Pictures/Screenshots/Screenshot_20261014-095900.png`); `html-prototypes/app-shell/index.html`.

## Architecture card – jelölt kérdések gyűjteményei

- Felhasználói cél: a „Fontos nekem” és a „Szponzorral átbeszélendő” két, azonos viselkedésű container legyen; csak a kérdéseditorban állított jelölésük különbözik.
- Egyetlen source of truth: az aktuális ciklus `answers[questionId]` objektuma. A Fontos az `important`, a Szponzor a `discussWithSponsor` mezőt olvassa; nincs külön gyűjtemény-adatbázis vagy másolt válasz.
- Egyetlen írási út: a wizard meglévő `togglePathAnswerFlag(flag)` művelete. A collection core kizárólag olvas, szűr és navigál.
- UI/state owner: `state.path.collections[kind]` birtokolja a lokális kiválasztást, keresést és scrollpozíciót; a semleges `PATH_COLLECTION_CONFIG` köti a két UI-viewt a meglévő flaghez és route-hoz.
- Újrahasznált mechanizmus: `renderPathCollection(kind)` + `getPathCollection*` módszerek birtokolják a carousel-, keresés-, lista-, artwork- és return-context logikát. A két renderer csak a config-kulcsot adja át.
- Réteghatár: ez a futó, egyfájlos HTML-prototípus nem használ repository-t vagy hálózati/persistencia adaptert; a controller a meglévő in-memory prototípus-state egyetlen tulajdonosa. A collection UI nem ír közvetlenül válaszüzenetet.
- Fókuszált szerkezeti/boundary bizonyíték: `html-prototypes/app-shell/tests/path_important_collection_test.js` ellenőrzi a közös configot, a hiányzó lépésspecifikus renderert, a state-source-t és mindkét route navigációját.
- A több ezer soros egyfájlos prototípusnál a collection core szándékosan külön, semleges módszercsoportként marad; éles alkalmazásba migráláskor ez a controller/adatmodell külön modulba bontandó.

| ID | Követelmény | Kódterület | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| PI-01 | A második lépéskártya „Fontos nekem”, szívvel és a fontos elemek számával | chapter-menu renderer | Mind a 12 lépésben a korábbi Válaszaim kártya helyén jelenik meg | DOM teszt | DONE |
| PI-02 | Egyetlen, adatvezérelt gyűjtemény | answers renderer + state | Nincs 4. lépés-specifikus answers renderer; csak `important: true` elemek látszanak | Kód- és DOM teszt | DONE |
| PI-03 | A hero egyezik a wizard kompakt hero magasságával és kifut | CSS + hero renderer | Közös token, 194 px layout, 286 px fade artwork; body közvetlenül utána indul | CSS/DOM teszt | DONE |
| PI-04 | Független scroll ownership | CSS layout | Hero, carousel és kereső fix; kizárólag a lista görget függőlegesen | CSS/interaction teszt | DONE |
| PI-05 | Téma szerinti körkörös carousel | collection controller | Összes + releváns témák; saját artwork; kétirányú wrap és stabil kiválasztás | DOM/interaction teszt | DONE |
| PI-06 | Élő, ékezetfüggetlen keresés | collection controller | A kérdés-, válasz- és témaszöveg szűr; törlés visszaállít | Egységteszt | DONE |
| PI-07 | Kép nélküli kérdéskártyák determinisztikus ikon-körökkel | list renderer | A teljes kártya tappolható; question ID alapján stabil szín/ikon | DOM teszt | DONE |
| PI-08 | Közvetlen editor-nyitás és helyes visszalépés | navigation controller | A kiválasztott kérdés nyílik meg; Back visszaadja a filter-, carousel- és listapozíciót | Interakciós teszt | DONE |
| PI-09 | A meglévő wizard funkciók megmaradnak | existing question editor | Mentés, swipe, hangjegyzet, important/sponsor flag és sheet működik | Regressziós teszt | DONE |
| PI-10 | Determinisztikus prototípus seed mind a 12 lépéshez | createPathState | 5–8 fontos elem / lépés, legalább három téma ahol lehet; nem ír felül létező választ | Állapotteszt | DONE |
| PI-11 | Original/minimal artwork öröklődik | artwork resolvers | Hero és carousel az aktív asset-stílust használja | DOM teszt | DONE |
| PI-12 | Kis Android képernyőn használható | CSS + visual runtime | 412×892-n nincs overflow és a bottom nav nem takar listaelemet | Böngészős screenshot | BLOCKED — ebben a környezetben nincs Playwright/Chromium; a meglévő Android screenshot a korábbi nézetet mutatja, ezért nem tekinthető bizonyítéknak |
| PS-01 | A „Szponzorral átbeszélendő” ugyanaz a közös container legyen, mint a „Fontos nekem” | collection controller + sponsor renderer | Egy semleges, konfigurációs alapú collection core szolgálja ki mindkét nézetet; nincs duplikált list/carousel/search/state mechanizmus | Strukturális és DOM teszt | DONE |
| PS-02 | A szponzor container kizárólag a `discussWithSponsor: true` válaszokat mutassa | collection data selector | A kérdéseditor „Megbeszélem a szponzorommal” kapcsolója be- és kiteszi az elemet a saját gyűjteményéből | Állapot- és interakciós teszt | DONE |
| PS-03 | A szponzor nézet azonos kompozíciójú maradjon | shared collection renderer + CSS | Kompakt fade hero, téma-carousel, fix kereső, egyetlen függőleges kérdéslista, eredeti/minimal artwork öröklés | DOM/CSS teszt; Android screenshot | PARTIAL — DOM/CSS és asset-state ellenőrzés kész; ehhez az új state-hez nincs működő Playwright/Chromium screenshot runner ebben a környezetben |
| PS-04 | A szponzor-kártyáról megnyitott editor visszatérjen a szponzor containerbe | navigation return context | A kiválasztott lépés, téma-szűrő, keresés, carousel- és listapozíció megmarad | Interakciós teszt | DONE |
| PS-05 | Ne maradjon 4. lépés-specifikus sponsor renderer | sponsor renderer | A korábbi `renderPathStepFourSponsorReview` eltűnik; mind a 12 lépés ugyanazt az adatvezérelt renderert használja | Strukturális teszt | DONE |
