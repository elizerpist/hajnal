# Pánik mód és főmenü – architektúra és elfogadás

Forrás: a felhasználói feladat és a helyi `html-prototypes/app-shell/index.html` aktuális állapota (`.home-metrics`, `.home-body`, `renderPanicAlternative`, `SURVIVAL_STEPS`, `SURVIVAL_ARTWORKS`, `renderSurvival`, `panic-relapse`). A prototípus más munkája nem része a változtatásnak.

Tulajdonosok: a dashboard meglévő controllere birtokolja a sheet progressét; a recovery repository kizárólagos írási útján tranzakció zárja az aktuális időszakot és nyitja az újat. A túlélőmunkamenet egyetlen controllere kezeli a lépést, kezdőidőt és jegyzetpiszkozatot; a tartós adatot egy repository írja. A motiváció az onboarding tárolt profiljából olvasható. UI → controller → use case/store → repository/platform adapter; a tárcsázás csak külön 112-es intentre indul. A meglévő lifecycle és alkalmazászár védi a teljes navigációt.

| ID | Forrás | Terület | Elfogadás | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| PAN-01 | főmenü, HTML | dashboard | 24-es kártya, 92×70 felső panelív, alul rózsaszín Segítség kell | widget, screenshot | DONE |
| PAN-02 | pánik, HTML | panic | eredeti háttér, 146-os pulzus, reduced motion, alap segítségpanel és külön 112 | widget, screenshot, adapter | DONE |
| PAN-03 | hét állomás, HTML | survival | 7 eredeti kép és teljes lépés, választás, újraértékelés | controller, widget, screenshot | DONE |
| PAN-04 | idő és jegyzet | survival/data | 900 mp kezdőidőből, háttérből folytatódik, nincs auto exit, helyi jegyzet és folytatás | idő-, persistence- és widgetteszt | DONE |
| PAN-05 | motiváció | panic | mentett onboarding szöveg vagy világos üres útmutató | repository és widget | DONE |
| PAN-06 | visszaestem | recovery/panic | megnyitás nem ír; újrakezdés atomikus, régi adatok megmaradnak | tranzakciós és widgetteszt | DONE |
| PAN-07 | alapmodul | panic/survival | szponzor, tartalék és gyűlés rejtve, kapcsolódás továbbjárható | widget | DONE |
| PAN-08 | AGENTS | architektúra | egy állapottulajdonos és egy írási út, dependency irány | boundary suite | DONE |
| PAN-09 | kiadás | CI | teljes csomag és helyi ellenőrzés után egy commit/push, zöld CI és ugyanaz az aláírt APK | analyze, tesztek, CI, upgrade | PARTIAL |

A helyi widgetes és adatbázisos bizonyítékok, valamint a HTML-lel történt képi összevetés: `docs/verification/panic-local/`. A képek widgettesztből származnak; a 112-t a tesztben injektált tárcsázó helyettesítette. A PAN-09 a konkrét commit GitHub-futásáig, aláírt APK-jának rátelepítési próbájáig és publikálásáig nyitott.

Átnézés: a 600 sor feletti `survival_page.dart` kizárólag a hét állomás megjelenítését, lokális animációját és szövegbeviteli eseményeit tartalmazza; az idő, a tartós munkamenet és a jegyzet írása a controller/repository feladata. A tárcsázó egyetlen platformadapteren érhető el. A regressziós és import/írási határtesztek a normál tesztcsomag részei.
