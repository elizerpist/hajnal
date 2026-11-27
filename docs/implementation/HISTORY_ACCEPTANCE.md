# Történetem – architektúra és elfogadás

Forrás: felhasználói megbízás, `html-prototypes/app-shell/index.html` History pager és `assets/history-chapter-hero/current_richer.png`.

Az időszak és a jegyzet tulajdonosa változatlanul a RecoveryRepository és a PanicRepository. A jegyzet aktuális időszakhoz kapcsolása ugyanazon adatbázis-tranzakcióban történik, régi kapcsolatlan jegyzetek megmaradnak. A HistoryRepository egy figyelt, összekapcsolt lekérdezésből adja a teljes olvasási pillanatképet. A HistoryController tulajdonolja a kiválasztott stabil időszakazonosítót és az aktuális időszak követését; a widget csak megjelenít és szándékot továbbít. A naptár ugyanazon eseménymodellt használja. UI → controller → olvasási szerződés → Drift adapter. A meglévő témát, navigációt és artwork-katalógust használjuk.

| ID | Forrás | Terület | Elfogadás | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| HIS-01 | Megbízás, HTML pager | dashboard, history UI | Navigáció, hero, vissza, lapozás, aktív/szürke állapot a referencia szerint | Widgetteszt, képi összevetés | DONE |
| HIS-02 | Megbízás | Drift, PanicRepository | Régi adatokat megőrző migráció; új jegyzet aktív időszakhoz, egy tranzakcióban | Migrációs és repository teszt | DONE |
| HIS-03 | Megbízás | HistoryRepository, controller | Egy figyelt pillanatkép, valós időben frissülő események, ID-alapú követés | Adatbázis- és controllerteszt | DONE |
| HIS-04 | Megbízás, HTML | timeline, naptár | Kezdet, lezárás, jegyzet, valódi dátumjelölés, teljes szövegű popup | Widget- és integrációs teszt | DONE |
| HIS-05 | Megbízás, HTML | history UI | Kártyán belül lefelé nyíló statisztika, csak jegyzetek számával | Widgetteszt, képi összevetés | DONE |
| HIS-06 | Megbízás | RecoveryRepository | Restart régi és új időszakot együtt mutatja; hibás vagy dupla restart nem ír új rekordot | Repository- és controller teszt | DONE |
| HIS-07 | Réteghatárok | history, architecture tests | Egy írási út, tiszta domain, UI nem ér el adatbázist | Boundary suite, analyze | DONE |
| HIS-08 | Kiadás | CI, GitHub Release | Teljes helyi ellenőrzés után egy push; ellenőrzött, frissíthető aláírt APK és állandó link | CI és nyilvános letöltés | PARTIAL |

Helyi ellenőrzés: megtekintett 412 × 892 HTML-referencia és Flutter-widgetképek (aktív, lezárt, naptár, nyitott statisztika); kis képernyő és 150%-os szöveg. A képek tesztadatot tartalmaznak. A teljes tesztcsomag 173 teszttel sikerült; az utolsó elrendezésmódosítást követő célzott history- és boundary-csomag 27 tesztje sikeres. Az Android-emulátoros rátelepítés és aláírt kiadás a CI feladata.

A korábbi CI-bizonyítékban az onboarding-kép hiányzó SVG-vel készült. A natív képrögzítés ugyanazon screenshot-műveletet ismétli legfeljebb 15 másodpercig, amíg a háttér és a logó képpontjai ténylegesen megjelennek. A régi üres és a megfelelő korábbi képen a feltételt ellenőriztük; a natív futtatást a CI igazolja.

Önellenőrzés: a HistoryRepository kizárólag egy JOIN-t figyel, a period/jegyzet írások gazdái nem változtak; a UI sem Driftet, sem konkrét repositoryt nem importál. A kiválasztás egyetlen controllerben, a naptári dátumkijelölés képernyőállapotként él. A statisztika kizárólag a kapcsolt jegyzeteket számolja, a régi kapcsolat nélküli jegyzetek változatlanok maradnak.
