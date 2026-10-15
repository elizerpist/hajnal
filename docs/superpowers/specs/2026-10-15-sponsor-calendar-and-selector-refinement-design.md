# Sponzor naptárnézetek és selector-finimítások – design specifikáció

**Dátum:** 2026-10-15
**Állapot:** jóváhagyásra vár
**Forrás:** a 2026-10-15-i felhasználói utasítások; `docs/HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md`; `docs/references/source-of-truth/sponzor_profil_beallitasok.png`; `/storage/emulated/0/hajnal/source of truth/gyulesek.png`; `/storage/emulated/0/hajnal/source of truth/history.png`; a jelenlegi `html-prototypes/app-shell/index.html`.
## Cél

Négy, egymáshoz kapcsolódó finomítást vezetünk be, a meglévő app-shell és `HomeInteractionController` megtartásával:

1. A Gyűlések lista-nézet belépése nem animálja külön felfelé a body-t, és a floating selector függőlegesen pontosan a Történetem selectorával egy vonalba kerül.
2. A Sponzor / Közös munkánk selector és a két FAB egyetlen app-lila vizuális rendszert használ. Az Útravalóimhoz nem marad olaj- vagy mentazöld különálló állapot.
3. A Sponzor főmenü `Legközelebb` művelete a bottom sheet helyett teljes képernyős, a Sponzor heroját és hátterét használó naptárnézetet nyit. Dátumot és időpontot is ezen a képernyőn választ a felhasználó, a korábbi alkalmak pedig ugyanitt láthatók.
4. A Sponzor-adatlap `Sponzorom mióta` mezője natív dátumválasztó helyett teljes képernyős naptárnézetet nyit, külön Vissza gombbal.

## Döntések és határok

- A két új naptárnézet nem másolja le a Gyűlések naptárlogikáját. A meglévő `renderMonthCalendarCells()`, `halfHourTimeSlots()`, valamint a szponzori elérhetőséget vizsgáló `isSponsorNextDateAvailable()` / `isSponsorNextTimeAvailable()` közös magját használja.
- Az új route-ok kijelző- és kiválasztási állapota a `HomeInteractionController.state` része. Nem készül második controller, második időpontválasztó vagy új kapcsolattartó-adatbázis.
- A korábbi szponzori alkalmakhoz **külön mock/seed lista** készül. Kifejezetten nem a Gyűlések adatai, nem a Sponzor-profil mezői, és nem módosítható egészségügyi vagy felépülési naplóadatok. A lista csak a teljes képernyős Legközelebb nézet vizuális és navigációs tesztelhetőségét szolgálja.
- Az új mock-lista megjelenítési adatforrás; a következő beszélgetés mentése továbbra is a meglévő `nextConversation` állapotot frissíti. Későbbi, valódi beszélgetési napló külön termékdöntést igényel.
- A Sponzor heroja és a `--screen-background` fade változatlan marad mind a főmenüben, mind a két naptár route-on. Nem készül új artwork és nem változik a Gyűlések heroja.
- A BottomNav mindkét új teljes képernyős naptár route-on látható marad, és a Sponzor aktív. A naptárak nem overlayek és nem slide-up sheetek.

## Vizualitás

### Gyűlések

- `.meetings-inline-view-switch` felső koordinátája megegyezik a `.history-inline-view-switch` felső koordinátájával (`32px` a jelenlegi közös geometriában).
- A Gyűlések body nem kap `meetings-body-in` belépési animációt. A módváltás meglévő, finom tartalmi átmenete ettől elkülönülhet, de a menü route-ra érkezése nem tolhatja fel a body-t.

### Közös munkánk selector és FAB

- A selector sínje és az inaktív fül háttere fehér marad.
- Mindkét fül app-lila irányba kap hangsúlyt: az aktív fül `--hajnal-purple` kitöltést és fehér feliratot kap; az inaktív állapot lila szöveggel/finom lila kontúrral marad a fehér sínen.
- Az `Útravalóim` fül nem kap külön zöld témát.
- Mindkét, új elemet létrehozó FAB `--hajnal-purple` felületet és a meglévő lila CTA karaktert használja, függetlenül a kiválasztott tabtól.
- Az Útravalóim tabhoz nem maradhat olajzöld vagy mentazöld aktív/FAB kivétel.

### Teljes képernyős Sponzor-naptárak

- A Hero ugyanaz a `sponsor_hero_soft.png`; a hero-copy, a fade és az általános háttérválasztás egységes a Sponzor főmenüvel.
- A naptárbody teteje a meglévő `--history-current-card-top` közös geometriát használja, ezért a világos naptárkártya felső éle egy vonalban lesz a Sponzor profilkártyájával.
- A naptárkártya a Gyűlésekéhez hasonló: hónapléptető, hét napjai, naptárrács, kijelölt nap, visszafogott elérhetőségi jelzés. Nem ágyazunk be második vertikális scroll ownert.
- A `Legközelebb` route naptára alatt ugyanabban az egyetlen scroll ownerben jelenik meg az időpontválasztó és a **Korábbi alkalmaink** mock-listája. A múltbeli sorok kompakt kártyák: dátum, idő, opcionális rövid megjegyzés. Nem Gyűlések rekordok.
- A `Sponzorom mióta` route saját címet és Vissza gombot kap. Csak dátumot választ; nincs időválasztó és korábbi alkalmak lista.

## Navigáció és állapot

### Új route-ok

| Route | Belépési pont | Vissza | Adatírás |
| --- | --- | --- | --- |
| `sponsor-next` | Sponzor főmenü / Legközelebb | Sponzor főmenü | Csak a kifejezett Mentés frissíti a meglévő `nextConversation` értéket |
| `sponsor-since-calendar` | Sponzor-adatlap / Sponzorom mióta | Sponzor-adatlap | Csak a `Dátum kiválasztása` frissíti az adatlap draftját; az adatlap saját Mentése marad a profilperzisztencia pontja |

### Állapot tulajdonosai

```text
HomeInteractionController.state
├── sponsorScheduleSelection
│   ├── selectedDate
│   ├── selectedTime
│   └── calendarMonth
├── sponsorSinceCalendarSelection
│   ├── initialDate
│   ├── selectedDate
│   └── calendarMonth
└── sponsorConversationHistory (mock seed lista)
```

- A két kiválasztási állapot lokális UI-state. Elhagyáskor törölhető, és nem ír automatikusan a profilba.
- A `sponsorConversationHistory` seed lista külön konstansból indul, hogy a valós felhasználói profiladat és a demóadat ne keveredjen.
- A `Sponzorom mióta` választása először az `sponsorDraft.since` mezőbe kerül; a tényleges `state.sponsor` módosítás továbbra is csak az adatlap Mentésekor történik.
- A dátum/idő mentésekor a már meglévő elérhetőségi szabályok és félórás idősávok érvényesülnek. Hibás vagy nem elérhető időpont nem menthető.

## Interakciók

### Legközelebb

1. A Sponzor főmenü `Legközelebb` gyorsművelete `sponsor-next` route-ra navigál.
2. A felhasználó naptári napot választ; az időpontszakasz ezután az elérhető félórás idősávokat mutatja.
3. A `Mentés` kizárólag érvényes dátum + idő esetén aktív, majd a `nextConversation` értéket írja és visszavisz a Sponzor főmenübe.
4. Vissza vagy BottomNav navigáció mentés nélkül nem módosít időpontot.
5. A korábbi alkalmak mock-listája olvasható, nincs rajta szerkesztés/törlés/action.

### Sponzorom mióta

1. Az adatlap mezője `sponsor-since-calendar` route-ra vezet; natív `input[type=date]` picker nem nyílik.
2. A kijelölt nap jól látható, a hónap lapozható.
3. A megerősítő CTA az adatlap draftjába ír és visszalép az adatlapra.
4. A Vissza nem írja át a draftot.

## Elfogadási lista

| ID | Követelmény | Kódterület | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- |
| SC-01 | Gyűlések belépési slide-up eltűnik | meetings CSS | nincs route-entry `transform`/`animation`; 412×892 screenshot | NOT DONE |
| SC-02 | Gyűlések selector a History-val azonos magasságban | meetings/history CSS | számított `top` mindkettőn 32px | NOT DONE |
| SC-03 | Közös munkánk selector és mindkét FAB app-lila | sponsor-work CSS | CSS/DOM contract + 412×892 screenshot | NOT DONE |
| SC-04 | Legközelebb teljes képernyős naptár | routes, sponsor render/controller | nincs sheetnyitás; hero + naptárrács + Vissza | NOT DONE |
| SC-05 | Dátum és idő választása meglévő availability core-ral | sponsor schedule controller/render | érvényes dátum/idő menthető; nem elérhető nem menthető | NOT DONE |
| SC-06 | Korábbi alkalmak elkülönített mock-listája | seed constant + next route renderer | nem Meetings rekord; olvasható múltbeli lista | NOT DONE |
| SC-07 | Sponzorom mióta teljes naptár route | sponsor details/controller/render | nincs natív picker; draft-only megerősítés + helyes Back | NOT DONE |
| SC-08 | Egy scroll owner, helyes Back/BottomNav | CSS/navigation | nézetek nem fedik egymást; Sponsor aktív; nincs adatvesztés | NOT DONE |
| SC-09 | Regresszió és vizuális bizonyíték | static/runtime tests + screenshots | célzott + teljes statikus suite; 412×892 képek | NOT DONE |

## Nem része ennek a körnek

- A Gyűlések adatszerkezetének, ismétlődésének vagy saját naptárfunkcióinak átdolgozása.
- Valódi, szerkeszthető szponzori beszélgetésnapló/perzisztens történelem.
- Új Sponzor hero asset készítése.
- A Sponzor elérhetőségi szabályainak üzleti újratervezése.
- Új bottom sheet létrehozása vagy a régi naptár- és időpontlogika duplikálása.
