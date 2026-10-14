# Ösvény – „Fontos nekem” elfogadási lista

Források: a 2026-10-14-i felhasználói implementációs specifikáció; a legfrissebb Android referencia (`/storage/emulated/0/Pictures/Screenshots/Screenshot_20261014-095900.png`); `html-prototypes/app-shell/index.html`.

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
