# Napi reflexió: architektúra és elfogadás

Forrás: felhasználói megbízás és `html-prototypes/app-shell/index.html`, `renderDailyReflection()` / `dailyReflectionSteps()`.

Vizuális források: `html-prototypes/app-shell/assets/reflection/daily_reflection_mood.png`, `daily_reflection_writing.png`, `daily_reflection_practice.png`; általános design: `docs/references/source-of-truth/designnkovetelmenyek.png`, `checkin_visszaeses_panik.png`, `haladas_naptar_stat.png`, `eszkozok_12lepes_naplo.png` és az ugyanott található többi alapreferencia. A Flutter-képek a téma beállításait is követik.

Tulajdonosok: a véglegesített modulválasztást az onboarding profilja, a reflexió és piszkozat tartós állapotát egy Drift repository, a képernyő munkamenetét egy controller, az idővonal olvasását a HistoryRepository/HistoryController birtokolja. Az UI intentet továbbít; a gyakorlat pillanatképe a létező PracticeSnapshot. A kész bejegyzés és a piszkozat nem ugyanaz a közzétételi állapot. A dashboard meglévő gesztusgazdája változatlan.

| ID | Terület | Elfogadás | Ellenőrzés | Állapot |
|---|---|---|---|---|
| DR-01 | dashboard, onboarding | véglegesített modul kapcsolja a belépőt, tap és húzás elkülönül | figyelt profil és widget/gesztusteszt | DONE |
| DR-02 | reflection UI | HTML szerinti hangulat, írás, opcionális gyakorlat, artwork | háromlépéses widgetteszt és helyben megtekintett képek | DONE: a fejléc és főgomb a közös téma értékeivel igazítva |
| DR-03 | Drift | v7→v8 megőrző migráció; egy időszak/nap egy stabil ID | migráció, SQLite-egyediség, újranyitás | DONE |
| DR-04 | reflection repository/controller | automatikus piszkozatmentés, újraindítás, snapshot megmarad | DB- és kilépéskori gépelésteszt, gyakorlatcsere/átírás/törlés | DONE |
| DR-05 | history | csak tartalmas befejezés hoz létre egy élő eseményt, régi bejegyzés szerkeszthető, saját dátuma látszik | figyelt repository- és timeline/naptár-widgetteszt | DONE |
| DR-06 | teljes felület | 220×320, 3× betűméret és alsó inset mellett használható | dashboard- és reflexió-widgetteszt | DONE |
| DR-07 | release | teljes ellenőrzés, egy push, aláírt APK és adatmegőrző rátelepítés | CI, screenshot, SHA-256 | PARTIAL: a helyi ellenőrzések zöldek; a CI és az upgrade hátravan |

A modul kikapcsolása sem reflexiót, sem piszkozatot nem töröl; nem módosítja a pánikjegyzeteket vagy gyakorlatokat. Az adatírás kizárólag a reflexió repository útján történik, a history csak olvas. A képernyőképek és az upgrade eredménye nélkül a kiadás nem igazolt.
