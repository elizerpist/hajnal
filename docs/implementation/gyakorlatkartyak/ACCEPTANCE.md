# Amit gyakorlok — architektúra és elfogadás

Forrás: `HAJNAL_GYAKORLATKARTYAK_IMPLEMENTACIOS_PROMPT.md`, a mellette lévő négyoldalas PDF és `html-prototypes/app-shell/index.html` (`renderHomePracticeBlock`, `practicePickerArtwork`, `practiceRow`, `renderPracticeSheet`). A HTML helyi változata referencia, nem implementációs commit része.

## Architektúrakártya

A tartós állapot kizárólagos forrása a közös HajnalDatabase `practice_cards` táblája; az egyetlen író a PracticeRepository. Az aktiválás, illetve aktív létrehozás a korábbi rekord szüneteltetésével egy tranzakció. A SQLite részleges egyedi index védi az egyetlen aktív rekordot. A figyelt repository-kontraktus állapotát egy app-élettartamú PracticeController teszi elérhetővé a főmenü és a kezelő számára. Az editor piszkozata és a billentyűzet/fókusz a megjelenítés élettartamú; a mentési szándék a controlleren keresztül érkezik. A forrás és pillanatkép önálló, időszaktól független domain-adat. A grafikai szerep stabil kártyaazonosítóból egyetlen feloldóban származik. UI → controller → repository-kontraktus → Drift adapter; a widget nem ír adatbázist. Meglévő app shell, témaszerepek, modal és gesztustulajdonos maradnak.

| ID | Forrás | Terület | Elfogadási feltétel | Ellenőrzés | Állapot |
|---|---|---|---|---|---|
| PR-01 | prompt adatbázis | database, repository | v6→v7 megőrző migráció, stabil ID, státusz és UTC idők; üresen nincs minta | migrációs és újranyitási teszt | DONE |
| PR-02 | prompt műveletek | repository | SQLite max. egy aktív; váltás és létrehozás tranzakciós; hiányzó cél nem törli az aktív állapotot | DB-teszt | DONE |
| PR-03 | PDF 1,4 | manager, editor | test szerkeszt, nyíl aktivál; edit csak tartalmat ír; megerősített törlés | widget + DB teszt | DONE |
| PR-04 | PDF 2,3 | editor | saját szöveg, négy gondolatindító, sablonvalidáció, opcionális cím, két mentési mód | widget teszt | DONE |
| PR-05 | HTML + PDF 1 | dashboard, manager | aktív állapot közös figyelése, fix fejléc/lábléc, csak lista gördül | widget + screenshot összevetés | PARTIAL |
| PR-06 | prompt képek | artwork | öt eredeti akvarell és öt panelminta egy determinisztikus feloldóval | asset- és vizuális teszt | PARTIAL |
| PR-07 | prompt forrás és pillanatkép | domain, repository | Ösvény-adatok megőrzése, független snapshot; nincs időszak/idővonal kapcsolat | domain + DB teszt | DONE |
| PR-08 | structuring-apps | application/data/presentation | egy író és állapottulajdonos, réteghatárok | boundary suite | DONE |
| PR-09 | prompt átadás | CI/build | egyetlen záró futás és aláírt APK; a teszteredmények ténylegesek | workflow + checksum | NOT DONE |

A referencia kézzel megnyitva és a két érintési cél kipróbálva. A tényleges Android-képek és az egyetlen CI-futás eredménye a záró ellenőrzésben igazolandó.
