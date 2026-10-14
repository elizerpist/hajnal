# Ösvény – lépésenkénti feldolgozástörténet – elfogadási lista

Források: a 2026-10-15-i felhasználói implementációs specifikáció; [`/storage/emulated/0/hajnal/source of truth/lepesmunka.png`](/storage/emulated/0/hajnal/source%20of%20truth/lepesmunka.png); `html-prototypes/app-shell/index.html`.

## Architecture card

- Felhasználói cél: ugyanazt a lépést önálló, dátumozott feldolgozásokban lehessen újrakezdeni anélkül, hogy a teljes 12 lépéses ciklus vagy bármely másik lépés adata megváltozna.
- Domain source of truth: a meglévő `cycle.steps[stepId]` az aktív feldolgozás; `cycle.stepHistory[stepId]` kizárólag változatlan, archivált futás-snapshotokat tart. A futást a stabil `runId` azonosítja.
- Közös motor: a semleges `archiveCurrentStepWork()` és `startNewStepWorkRun()` végzi az archiválást és az új, üres run létrehozását. Nem hívja a teljes ciklust létrehozó `startNewPathCycle()`-t.
- Megjelenítési kontextus: `navigation.stepWorkReview` választja ki az archivált futást. A meglévő question-, collection- és summary-rendererek a közös `getCurrentStepWork()` accessoron keresztül ezt az adatforrást látják.
- Perzisztencia: a versionált Path-state browser-localStorage adapter menti a lépés-run történetet; ez a prototípus adaptere, nem production titkosítási állítás.
- UI: a chapter menu hárompontos, horgonyzott context menüje kizárólag a történetnézethez vezet. A history screen ugyanazt a meglévő hero-artwork resolvert használja, ezért az original/minimal mód együtt marad.

| ID | Követelmény | Kódterület | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| PWH-01 | Hárompontos gomb és horgonyzott context menu minden lépésben | chapter renderer + CSS + action handler | A régi `open-path` helyett 44 px-es horizontal ellipsis nyitja a „Korábbi lépésmunkáim” menuitemet; kívül/Escape/Back zárja | DOM/interaction teszt | DONE |
| PWH-02 | Lépésspecifikus history view | `PATH_VIEWS`, renderer, navigation | Kizárólag az aktuális `stepId` runjai láthatók; Back a pontos chapter menübe tér | DOM/interaction teszt | DONE |
| PWH-03 | Referenciahű history UI | history renderer + CSS | `lepesmunka.png` hero-fade, current/history cards és CTA arányai és hierarchiája követett | CSS/Android screenshot | PARTIAL — a referencia és CSS közvetlen ellenőrzése kész, de az új állapothoz nem áll rendelkezésre Chromium/Playwright vagy Android screenshot runner |
| PWH-04 | Egyedi step-run modell | Path data core | Aktív work + `stepHistory[stepId]` snapshotok; külön `cycleId` és `runId` | domain teszt | DONE |
| PWH-05 | Új feldolgozás csak a kiválasztott lépést érinti | archive/new-run core + confirmation UI | A régi work archiválódik; az új üres; másik 11 step és current cycle érintetlen | domain/interaction teszt | DONE |
| PWH-06 | Archivált run read-only | central accessor + write guards | Editor, flag, summary és close művelet nem módosíthat archive snapshotot | interaction/regression teszt | DONE |
| PWH-07 | A collection, summary, sponsor és practice hivatkozás run-aware | accessors + source keys | A megjelenített runhoz tartozó választ/jelölést mutatják, a source megtartja `runId`-t | domain/DOM teszt | DONE |
| PWH-08 | Adatmegőrző migráció és perszisztencia | migration + localStorage adapter | Régi cycle work runId-t kap; csak tartalmas historic work kerül a listába; újraindítás után megmarad | domain test + code inspection | DONE |
| PWH-09 | Original/minimal artwork és bottom nav változatlan | existing resolvers + shared shell | History screen a közös resolverből rajzol, bottom nav Ösvény aktív | DOM/CSS teszt | DONE |
| PWH-10 | 412×892 referencia-ellenőrzés | runtime/browser | Nincs overflow, dropdown nem takaródik ki, CTA/lista elérhető | Android/browser screenshot | BLOCKED — jelen környezetben nincs elérhető Chromium/Playwright runtime |
