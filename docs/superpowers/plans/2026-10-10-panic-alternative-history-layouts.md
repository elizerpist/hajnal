# Implementációs terv: Pánik Alternative + Történetem path-inspired

**Cél:** Egyetlen `HomeInteractionController`-ben két prezentációs változatot adni a Pániknak és a Történetemnek, a meglévő route-ok, domain-adatok és visszanavigálás megtartásával.

## Módosítandó fájlok

- `html-prototypes/app-shell/index.html`: markup, scoped CSS, controller state/render/action kezelés.
- `html-prototypes/app-shell/tests/panic_alternative_test.js`: Pánik state, view, panel, survival és visszanavigálás tesztek.
- `html-prototypes/app-shell/tests/history_path_inspired_test.js`: History state, density, shared footer és period navigation tesztek.
- `docs/superpowers/specs/2026-10-10-panic-alternative-history-path-inspired-design.md`: elfogadási állapotok és végső bizonyítékok.

## Végrehajtási sorrend

1. Előbb írom meg a célzott, kezdetben hibázó teszteket: state default/persistence, variant render, safe contact panel, shared survival session, History layout/density és period action.
2. Bevezetem a controller-owned `panic` és `historyOverview` state-et, valamint a kicsi, hibatűrő localStorage adaptert; nincs második route/controller.
3. A Classic markupot érintetlenül hagyom (csak a fejléc toggle-ja változik); az Alternative aktuálisan mountolt renderer, ezért az inaktív Pánik UI nem fókuszálható.
4. A segítségpanel a meglévő overlay/fókuszkezelést és Sponsor állapotot használja. A backup ugyanabban a relationship state-ben nullable mező, az üzenet ugyanazt a composer workflow-t használja.
5. A survival session `startedAt` alapú; a renderer az eltelt időt számolja, nincs automatikus hívás vagy tiszta-nap módosítás. A közös help entry a same panelt nyitja.
6. A Történetem alternatív ágát explicit `current/path-inspired` renderer adja. A period data/action egy közös adathalmazon marad; a footer egy fizikai elem és az aktív layout-slotba kerül, nem duplikálódik.
7. A History CSS az Ösvény hero/current/step-card geometriáját közös, szemantikus layout tokenekkel veszi át; saját assetet és rózsaszín–lila színeket használ.
8. Futtatom a célzott és érintett meglévő teszteket, JS szintaxis- és whitespace-ellenőrzést, valamint elindítom a statikus szervert és megkísérlem a 412×892 vizuális validációt.
9. Csak az elfogadási lista frissítése, diff-review és validáció után commitolok/pusholok.

## Fontos invariánsok

- `panicVariant` csak a Pánik megjelenítését váltja; a survival session, sub-route origin és kapcsolat state változatlan marad.
- A Classic rózsaszín gombnak nincs folyamatos animációja.
- Nincs hardcoded új kapcsolattartó; hiányos sponsor/backup esetén üres, biztonságos state jelenik meg.
- A History medalion mindig tiszta napok száma, soha nem sorszám vagy százalék.
- Az Ösvényből vizuális primitiveket, nem Ösvény domain-állapotot használunk.
