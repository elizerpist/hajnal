# Történetem · fejezet-hero újratervezés – elfogadási lista

**Elsődleges referencia:** `/storage/emulated/0/hajnal/source of truth/hajnal_tortenetem_redesign.png` (közvetlenül megvizsgálva 2026-10-14)

| ID | Forrás | Kódterület / tulajdonos | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| HCR-01 | Felhasználói brief §0–1, referencia | `index.html` History shell | A Történetem felület hero-alapú fejezetnézet; a referencia arányait, világos alsó információs cardját és idővonalas scroll zónáját követi. | DOM/CSS-inspekció, screenshot | PARTIAL – a képernyőképes összevetés HCR-10-ben blokkolt |
| HCR-02 | Brief §2 | History markup, renderer, CSS | A korábbi kis/közepes `history-period-carousel` nézet és annak vezérlése nem marad az útvonalon. | keresés, viselkedési teszt | DONE |
| HCR-03 | Brief §3, §7B | Meglévő `historySelectedPeriodId` + `historyPager*` | Az egyetlen kiválasztott fejezet a teljes szélességű hero; a meglevő prev/current/next swipe engine vált fejezetet. Nincs párhuzamos carousel-state vagy második swipe mechanizmus. | kódinspekció, teszt | DONE |
| HCR-04 | Brief §5, §9 | `--path-overview-current-card-height`, History pager hero | A hero alsó információs cardja ugyanazt a megosztott Ösvény hero-card magasság tokent használja, világos, lekerekített, és a kiválasztott fejezet metaadatait mutatja. | CSS/DOM-inspekció | DONE |
| HCR-05 | Brief §6, §12 | `assets/history-chapter-hero/`, `HISTORY_PERIODS` | Minden fejezethez új, nagy, egységes, pasztelles, low-detail hero asset tartozik; nincs szöveg az assetekben. | asset-méretek, asset-map teszt, vizuális ellenőrzés | DONE |
| HCR-06 | Brief §7A | Pager slide state/CSS | A nem aktuális (korábbi) fejezethero és idővonal-ikonok tompított/szürkített megjelenést kapnak. | DOM/CSS-inspekció | DONE |
| HCR-07 | Brief §8 | Pager scroll renderer + timeline markup/CSS | A hero utáni görgethető zóna a referencia tiszta, széles timeline-card ritmusát követi; a történeti tartalom és szűrés nem vész el. | teszt, screenshot | PARTIAL – a screenshot ellenőrzés HCR-10-ben blokkolt |
| HCR-08 | Brief §7C | History actions/route state | Idővonal- és naptárfunkció, esemény-szűrés, metrika-kibontás, BottomNav megmarad. | célzott tesztek | DONE |
| HCR-09 | Brief §10 | History presentation state | Az új Történetem állandó végleges design; a leváltott history artwork/layout/card-carousel kapcsolók nem érhetők el. Ez nem az Ösvény asset-style váltójának új fogyasztója. | DOM/action-inspekció | DONE |
| HCR-10 | Felhasználói vizuális követelmény | Referencia és futó HTML | A változott alap- és swipe-állapotok screenshoton összevethetők a referenciascreenshot-tal. | böngészős screenshot | BLOCKED – ebben a környezetben nincs Chromium/Playwright |

## Architektúra-kapu

- **Egyetlen kiválasztási állapot:** `state.historySelectedPeriodId`; kizárólag `selectHistoryPeriod()` írja (a kezdő navigációs beállítást kivéve).
- **Megosztott mechanizmus:** a meglévő `historyPager*` prev/current/next pointer-swipe és settle állapotgép marad a fejezetváltás egyetlen motorja.
- **Megosztott vizuális token:** az információs card magassága `--path-overview-current-card-height`; nem keletkezik History-specifikus másolat.
- **Asset-feloldás:** `HISTORY_PERIODS[].heroArt` lesz a fejezetherók egyetlen asset-mapje. A carousel thumbnail `art` mezője megszűnik.
- **Végleges design-döntés:** a brief engedélye szerint nincs külön History dual-mode; az új referencia az állandó History UI.
