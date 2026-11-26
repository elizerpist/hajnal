# S0 elfogadási lista

Forrás minden sornál: `docs/implementation/HAJNAL_S0_STARTER_PROMPT.md` megjelölt fejezete; további forrás: `docs/HAJNAL_FLUTTER_SPECIFIKACIO.md` 0.3. Állapot: DONE / PARTIAL / BLOCKED / NOT DONE. A vizsgálati mód az elfogadási feltétel része; a nem futtatott teszt nem bizonyíték.

| ID | Forrás | Kódterület | Elfogadási feltétel | Ellenőrzés | Állapot |
|---|---|---|---|---|---|
| S0-01 | §2, §8 | gyökér, android, ios | Flutter Android/iOS váz, rögzített kompatibilis függőségek és lockfile; más funkció nincs | scaffold és konfiguráció ellenőrzése | NOT DONE |
| S0-02 | §3 | dashboard, tokenek, layout | Referencia szerinti kétosztatú kártya, egyetlen progress mozgatja az üres panellel, reszponzív, nincs tiltott tartalom | widgettesztek, HTML és Flutter screenshot összevetése | NOT DONE |
| S0-03 | §3 | dashboard gesture | Tap, drag, snap, cancel, Back, akadálymentesség és reduced motion | widgetteszt és emulátor | NOT DONE |
| S0-04 | §4 | dashboard, onboarding | Menü/scrim/Back; első indítás onboarding; mentés nélküli kilépés üres számlálóval; mentett dátum zárolt | widget és emulátor | NOT DONE |
| S0-05 | §4 | platform adapter, android, ios | Natív Android DatePickerDialog, iOS adapter; dátumkomponensek, cancel/error, egyszeres pending és lifecycle | natív UI teszt, adapterteszt; iOS eszközön külön | NOT DONE |
| S0-06 | §4–5 | recovery use case/repository, Drift | Tranzakciós egyszeri létrehozás, egy aktív időszak DB-korláttal, immutable helyi dátum, UTC létrehozás, mentési hiba nem navigál | DB- és flow-tesztek | PARTIAL — kezdeti tranzakciós és újranyitási teszt zöld; további rétegek és hibautak hiányoznak |
| S0-07 | §5 | core database | App-private DB, v1 sémaexport, integritás, újranyitás; biztonságos hiba és retry, nincs destruktív migráció | sémateszt, integritás, hibateszt | NOT DONE |
| S0-08 | §6 | calendar engine, lifecycle | Naptári különbség, max 0, DST/helyi időzóna, éjfél/resume/óraváltozás; egy foreground timer-tulajdonos | fake clock/timer domain tesztek | PARTIAL — naptári napkülönbség tesztelve; életciklus és timer nincs kész |
| S0-09 | §7 | artwork catalog/service/renderer | Egy placeholder, típusos katalógus, validált tartós privát verziózott override, atomikus descriptor, fallback és cleanup | katalógus-, fájl-, restart-, race- és cache-teszt | NOT DONE |
| S0-10 | §5, §8–9 | app/core/features/test | Egy írási út és réteghatárok, UI nem kezel DB-t/platformcsatornát; boundary suite CI-ben | külön boundary teszt | NOT DONE |
| S0-11 | §9 | test/integration_test | Teljes megadott domain, DB, widget, méretezési, natív és relaunch tesztkészlet | helyi teszt és CI log | NOT DONE |
| S0-12 | §9 | HTML és Flutter screenshotok | Friss 412×892 HTML, csukott/nyitott Flutter és onboarding képek, szemrevételezett összevetés | screenshot artifact és vizuális ellenőrzés | NOT DONE |
| S0-13 | §10 | .github/workflows/hajnal-ci.yml | Rögzített toolchain, verify → emulátor → human APK kapuk, teljes teszt és artifactok | pontos commit Actions futás | NOT DONE |
| S0-14 | §10 | CI signing/release | Tartós fejlesztői aláírás, ellenőrzött profile HUMAN APK és megbízható ágról prerelease | aláírásvizsgálat és letöltés | PARTIAL — külön Hajnal-kulcs és CI-secretek létrejöttek, aláírás és kiadás még nem ellenőrzött |
| S0-15 | §8, §11 | docs | Architektúrakártya, journal, artwork guide, termékspecifikáció S0 és dátumkiegészítés; iOS korlátok | dokumentáció review | NOT DONE |
| S0-16 | §1, §11 | Git/worktree | Helyi változtatások megőrzése, kizárólag S0 commit és push, futás követése | git diff/status és Actions | PARTIAL — biztonságos fast-forward `c9c0afe`-re; meglévő munka megmaradt |

Implementációs ág: `build/starter`; a `feat/first-prototype-page` a prototípus ága.
