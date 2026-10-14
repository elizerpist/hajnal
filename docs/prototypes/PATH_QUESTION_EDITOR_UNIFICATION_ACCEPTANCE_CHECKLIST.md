# Ösvény kérdéseditor és Történetem fade – elfogadási ellenőrzőlista

## Architekturális kártya

- **Egyetlen állapotforrás:** `state.path.navigation` őrzi a lépést, témát és kérdésindexet; a válaszok továbbra is a cikluson belüli `getTopicWork(...).answers` térképben vannak.
- **Egyetlen írási út:** a kérdésválasz `handleInput` → `getCurrentPathAnswer`, a jelölések a meglévő `togglePathAnswerFlag`, a hangjegyzet a meglévő `togglePathVoiceMemo` útján módosulnak.
- **Újrahasznált vizuális forrás:** a hero a már központilag kezelt `getPathArtworkSet().chapters.topics` térképből, `getPathTopicCardVisual` útján érkezik; így az original/minimal váltó minden témaképre hat.
- **Gesztus határa:** a kérdésoldal saját, csak külső felületen működő horizontális lapozása nem másolja a Történetem háromslide-os pagerének state machine-jét. A két felület eltérő tulajdonosa és renderelési modellje miatt csak a vízszintes-vs-függőleges döntési küszöb lesz semleges, közös helperben.
- **Fókuszált ellenőrzés:** statikus szerződés-teszt, teljes HTML tesztkészlet, inline script parse, `git diff --check`, HTTP elérhetőség. Vizuális screenshot csak Android/Chromium runtime-mal ellenőrizhető.

| ID | Követelmény forrása | Kódrész | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| PQE-01 | Felhasználói kérés – Történetem fade | History hero pager CSS | A hero a body mögé kifut, a body nem vágja el átlátszatlan réteggel | `path_question_editor_unification_test.js` + screenshot | PARTIAL – CSS szerződés zöld, runtime screenshot blokkolt |
| PQE-02 | Last screenshot + felhasználói leírás | `renderPathQuestion` | Minden lépés/téma egy közös question editorba nyílik | `path_shell_test.js` | DONE |
| PQE-03 | Felhasználói kérés | Path topic artwork resolver | A question hero a konkrét téma original/minimal artworkje | `path_question_editor_unification_test.js`, `path_topic_minimal_assets_test.js` | DONE |
| PQE-04 | Felhasználói kérés | question renderer + CSS | A hero után kifutó háttér van; csak az editor egy nagy card, benne kérdés, segítő szöveg, válasz és toolbar | CSS/DOM + screenshot | PARTIAL – CSS/DOM szerződés zöld, runtime screenshot blokkolt |
| PQE-05 | Felhasználói kérés | question pager controller | Nincs Előző/Következő gomb; külső vízszintes swipe mentés után slide átmenettel lapoz, inputon nem | szerződés + interaction teszt | PARTIAL – szerződés és controller state zöld, érintéses runtime ellenőrzés blokkolt |
| PQE-06 | Felhasználói kérés | permanent question actions | Hangjegyzet, Fontos, Szponzor permanens, kompakt hozzárendelő action; nem navigál el | `path_shell_test.js` | DONE |
| PQE-07 | Korábbi kötelezettség + felhasználói kérés | `renderPath` / BottomNav | BottomNav a question screenen is látszik és az alsó actionök fölött tér marad | `path_bottom_navigation_submenus_test.js` | DONE |
| PQE-08 | AGENTS vizuális szabály | Android screenshot | A minimal és original kérdéshero, History fade és question swipe állapot is vizuálisan ellenőrzött | Android screenshot | BLOCKED – ebben a környezetben nincs böngésző/Android screenshot futtató |
