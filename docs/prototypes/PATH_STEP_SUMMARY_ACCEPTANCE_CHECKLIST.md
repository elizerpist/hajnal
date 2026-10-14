# Ösvény – tematikus Összegzés elfogadási lista

Források: a 2026-10-14-i felhasználói specifikáció; `/storage/emulated/0/hajnal/source of truth/stepsummary.png`; a már működő `html-prototypes/app-shell/index.html` Fontos nekem collection core-ja.

## Architecture card

- Source of truth: cikluson belüli `stepWork.topicSummaries[topicId][questionId]` és `stepWork.overallSummary[questionId]`; az eredeti wizard-válaszok ettől külön maradnak.
- Egyetlen írási út: a summary textarea input-kezelője ír a megfelelő summary-válaszba; a témaváltás és navigáció előbb rögzíti az aktuális értéket.
- Megosztott mechanizmus: a semleges Path collection carousel motor kezeli a háromszegmenses végtelen vízszintes scrollt, artwork-feloldást, kiválasztást és megőrzött scrollpozíciót. Az Összegzés csak saját item-adaptert és card body-t ad.
- UI-state owner: `state.path.summary` birtokolja a kiválasztott stabil topic ID-t és a carousel/card scrollpozícióját. A `PATH_SUMMARY_QUESTIONS` csak immutable kérdésregiszter.
- Migráció: a régi `stepWork.summary` és `stepWork.takeaway` a teljes lépés első két stabil mezőjébe látszik, de az eredeti mezők változatlanul megmaradnak.
- Fókuszált bizonyíték: egy új Path summary contract teszt validálja a 12/121/399 regisztert, a stabil ID-kat, a carousel-t, a migrációt és az editor state-et.

| ID | Követelmény | Kódterület | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| PSUM-01 | Source of truth vizuális felépítése | summary CSS + renderer | Kompakt fade hero, fix carousel, egyetlen nagy világos card, három mező | DOM/CSS ellenőrzés; futtatható szerver elérhető, automatizált mobil screenshot-kliens nem volt elérhető | PARTIAL |
| PSUM-02 | Fontos nekem carousel újrahasználása | collection carousel core | Azonos geometria, loop, artwork és input-kezelés; nincs második carousel motor | `renderPathCarouselSegments`, `capturePathInfiniteCarousel` és `positionPathInfiniteCarousel` közös core; teszt | DONE |
| PSUM-03 | 399 explicit, stabil kérdés | registry | 12 lépés, 121 téma × 3 + 12 × 3; nincs hiány, ID-ütközés vagy placeholder | `path_summary_test.js`: tényleges 363 + 36 = 399 számlálás és ID-validáció | DONE |
| PSUM-04 | Témánként és teljes lépésenként elkülönített mentés | step work + input | Három válasz egymástól, wizardtól és más ciklusoktól függetlenül megmarad | `path_shell_test.js`: input-útvonal és scope-váltás | DONE |
| PSUM-05 | Régi summary/takeaway megőrzése | migrációs helper | A korábbi szövegek hozzáférhetők a teljes lépés nézetben, az eredeti mezők sem törlődnek | `path_shell_test.js`: mindkét legacy mező migrációja | DONE |
| PSUM-06 | Read-only és lezárás megőrzése | renderer + navigation | Korábbi ciklus nem szerkeszthető; lépéslezárás külön, visszafogott action | `path_shell_test.js`: readonly textarea és lezáró action | DONE |
| PSUM-07 | Nincs teljesítményértékelés | renderer | Nincs százalék, progress, score vagy automatikus értékelés | Summary renderer közvetlen DOM-ellenőrzése | DONE |
| PSUM-08 | 412×892 mobil visual evidence | browser runtime | Nincs overlap/overflow; a bottom nav nem takarja a harmadik mezőt | Android screenshot | BLOCKED – ebben a környezetben nincs vezérelhető böngésző/Chrome remote-debugging kliens |
