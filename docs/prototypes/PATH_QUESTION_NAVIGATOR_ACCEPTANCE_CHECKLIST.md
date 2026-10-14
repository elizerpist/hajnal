# Ösvény kérdésválasztó slide-up sheet – elfogadási ellenőrzőlista

## Architekturális kártya

- **Egyetlen aktív kérdés:** továbbra is `state.path.navigation.questionIndex`. A sheet nem tart saját indexet; ugyanazt az állapotot használja, mint a swipe.
- **Egyetlen válaszforrás:** a megválaszoltságot a meglévő `getTopicWork(stepId, topicId).answers[questionId]` és annak mentett `text` mezője adja. Nincs második kérdés- vagy válaszadatbázis.
- **Egyetlen mentési út:** megnyitáskor és kérdésváltáskor a meglévő `commitPathQuestionAnswer()` flusholja az editor aktuális értékét.
- **Overlay tulajdonos:** a sheet önálló, `path-content`-en kívüli hostban él, ezért nyitáskor nem rendereli újra a hero/editor felületet. A meglévő alkalmazásszintű sheet fókusz- és inert-kezelését használja.
- **Közös kérdésváltás:** a swipe és a direkt ugrás a `movePathQuestionTo` közös átmeneti úton váltanak; nincs egymás után szimulált lapozás.

| ID | Követelmény forrása | Kódrész | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| PQN-01 | Felhasználói specifikáció §2–3 | question editor header | A `n / összes ⌄` egy legalább 44px-es tappolható nyitógomb, nem route | `path_question_navigator_test.js` | DONE |
| PQN-02 | §4–8 | navigator host, CSS | Egyetlen, alulról felcsúszó modal sheet, egy görgethető kérdéslistával; témafejléc, válaszolt számláló, X és drag handle | szerződés-teszt + runtime screenshot | PARTIAL – szerződés zöld, runtime screenshot blokkolt |
| PQN-03 | §8–10 | navigator renderer | A sorok kérdésszöveget, sorszámot és valós megválaszoltságot mutatnak; aktuális és megválaszolt jelzés független | `path_question_navigator_test.js`, `path_shell_test.js` | DONE |
| PQN-04 | §11–14 | navigation/commit controller | Megnyitás és választás előtt flush történik; a direkt választás ugyanazt az indexet frissíti és nem lapoz köztes kérdéseken | `path_shell_test.js` | DONE |
| PQN-05 | §12–13 | question transition + gesture layer | A sheet zárása után egyszeri slide átmenet van; swipe marad, nyitott sheet alatt nem kap inputot | szerződés-teszt + runtime touch ellenőrzés | PARTIAL – controller/szerződés zöld, érintéses runtime blokkolt |
| PQN-06 | §16, §19 | overlay lifecycle | X, háttér, lehúzás, Escape és Android Back zár; fókusz kezelése és safe area megvan | szerződés-teszt + runtime ellenőrzés | PARTIAL – a kódút zöld, Android/keyboard runtime blokkolt |
| PQN-07 | §17–18 | adatvezérelt renderer | Minden lépés/téma a saját kérdéseit kapja, hero és designmód változatlan | `path_question_navigator_test.js`, `path_shell_test.js` | DONE |
| PQN-08 | AGENTS vizuális szabály | Android/browser runtime | Sheet nyitott/zárt, kisebb kijelző és direkt ugrás screenshoton igazolt | screenshot | BLOCKED – jelen környezetben nincs böngésző/Android UI-futtató |
