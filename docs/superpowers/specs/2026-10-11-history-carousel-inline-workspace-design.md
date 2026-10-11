# Történetem – carouseles, inline idővonal workspace

## Cél

A Történetem főmenü a korábbi függőleges időszaklisták helyett egyetlen, összevont felület lesz. A jelenlegi History hero mérete, hero–body aránya és a háttér fokozatos fade-je megmarad. Az időszak kiválasztása a hero alsó részén levő vízszintes carouselben történik; a kiválasztott időszakhoz tartozó Idővonal és Naptár közvetlenül alatta, ugyanazon a route-on jelenik meg.

Az Ösvény meglévő listanézete nem változik.

## Döntések

- A Történetem korábbi `current` és `path-inspired` lista-presentationje megszűnik mint felhasználói nézet; nincs History layout- vagy density-toggle.
- A History hero az eddigi path-inspired geometriát tartja: `238px` hero, azonos hero→body fade és azonos, stabil függőleges arány.
- Az időszak-carousel a hero része. A középre igazított, aktív kártya mutatja a kiválasztott időszakot; a szomszédos kártyák részben láthatók.
- Vízszintes swipe, illetve kártyatapelés váltja a kiválasztott időszakot. A swipe állapotát a controller kezeli; az UI csak intentet küld.
- A body a már létező Idővonal/Naptár nézet közös History-workspace renderelését kapja. A tabok, naptár-rail, események, visszanavigálás és az „Utam számokban” tartalom nem kap párhuzamos implementációt.
- A korábbi részlet-route kompatibilitásként megmaradhat, de ugyanazt a közös workspace renderer/state-et használja. Carouselből nem történik köztes detail-route navigáció.

## Architektúra

| Terület | Tulajdonos | Egyetlen forrás / mag | Tiltott duplikáció |
| --- | --- | --- | --- |
| Kiválasztott időszak | `HomeInteractionController` | `HISTORY_PERIODS` + `historySelectedPeriodId` | carousel-lokális vagy DOM-ból leolvasott state |
| Carousel swipe / kiválasztás | `HomeInteractionController` | semleges History carousel gesture/választás metódus | második, detail-specifikus swipe állapotgép |
| Idővonal/Naptár | `HomeInteractionController` | közös `historyDetailView`, `historyCalendarView`, calendar renderer | külön overview-idővonal vagy másolt naptármarkup |
| Hero artwork állapot | History period renderer | `period.current` és selected period | kézzel hardcode-olt színezési lista |
| Footer | meglévő History footer/metrics state | egyetlen expandable metrics primitive | carouselhez új, második footer |

## Interakciós modell

1. A Történetem route megnyitásakor a jelenlegi időszak középre kerül a carouselben.
2. Swipe vagy tap másik időszakot választ; az aktív carousel-card középre igazodik, a body címe és adata azonnal ahhoz igazodik.
3. A bodyban az Idővonal az alapértelmezett tab; a Naptár ugyanazon közös state-tel vált.
4. Naptár-railből vissza a naptár gridjére érkezik a felhasználó, majd a carouseles Történetem workspace-re. Nincs köztes lista route.
5. A személyes, historical period adatok és a korábbi fejezetek megmaradnak; a módosítás kizárólag presentation/navigációs összevonás.

## Elfogadási lista

| ID | Követelmény | Ellenőrzés | Állapot |
| --- | --- | --- | --- |
| HCW-01 | Az Ösvény képernyő és listanézet változatlan. | `path_shell_test.js` | DONE |
| HCW-02 | A Történetem hero 238px, a jelenlegi fade-del és arányokkal marad. | célzott CSS/source contract | DONE |
| HCW-03 | Függőleges History-lista helyett hero-beli, vízszintes carousel látszik; az aktív card középen van. | source + controller runtime contract | DONE |
| HCW-04 | Swipe és tap egyetlen controller-owned selection state-et ír, és a body azonnal a kiválasztott időszakot tükrözi. | `alternative_runtime_test.js` | DONE |
| HCW-05 | A body a közös Idővonal/Naptár tartalmat jeleníti meg, nem másolt rendererből. | reusable template/workspace source contract | DONE |
| HCW-06 | Calendar grid/rail, esemény-részlet és back navigáció nem jut zsákutcába, és nem tér vissza lista-route-ra. | `alternative_runtime_test.js` route-alias checks | DONE |
| HCW-07 | Az „Utam számokban” footer változatlanul működik a carouseles workspace-ben. | reusable template source contract | DONE |
| HCW-08 | 320–412px szélességen nincs vízszintes overflow, a carousel és a body scrollja elkülönül. | snap/overflow CSS contract | DONE |

## Javítási elfogadási lista – 2026-10-11

| ID | Forrás | Követelmény | Kódbeli terület | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| HWF-01 | Legutóbbi Android screenshot + user feedback | A kisebb időszak-csempék a hero alsó sávjában maradnak, a hero magasságának növelése nélkül. | `history-period-carousel` CSS | célzott CSS contract + közvetlen CSS-ellenőrzés | DONE |
| HWF-02 | Legutóbbi Android screenshot + user feedback | Az Idővonal/Naptár tabok a body legfelső, nem scrollozó sora. | inline `history-workspace` layout | célzott CSS contract + közvetlen CSS-ellenőrzés | DONE |
| HWF-03 | Legutóbbi Android screenshot + user feedback | A tabok alatti Idővonal/Naptár tartalom önállóan scrollozható; nincs második, egymásra helyezett scroll owner. | existing `history-detail-events-scroll` / calendar scroll | source/runtime contract + közvetlen CSS-ellenőrzés | DONE |
| HWF-04 | Legutóbbi Android screenshot + user feedback | Az összehajtható „Utam számokban” footer az inline workspace alsó, rögzített grid-sora. | shared `history-number-summary` | source/runtime contract + controller runtime teszt | DONE |

## Carousel- és scroll-korrekció – 2026-10-11

### Architektúra-kártya

- **Tulajdonos:** `HomeInteractionController` és annak meglévő `historySelectedPeriodId` state-je.
- **Egyetlen írási út:** `selectHistoryPeriod(periodId)`; a scroll csak ideiglenes vizuális középpontot számol, nem ír külön carousel-state-et.
- **Meglévő mechanizmus bővítése:** a natív, snap-pontokat használó `history-period-carousel`; nem készül második carousel/router.
- **Scroll-tulajdonos:** a timeline panel egyetlen függőleges scroll-tulajdonosa a meglévő `history-detail-events-scroll`; a közvetlen grid-szülő rögzített `minmax(0, 1fr)` pályát kap.
- **Vizuális átmenet:** a controller a meglévő cardokon CSS custom propertyt frissít a card-középpont és a viewport-középpont távolsága alapján. Ez csak átmeneti presentation adat, nem tartós domain-state.

| ID | Forrás | Követelmény | Kódbeli terület | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| HCS-01 | User feedback | A Timeline body valóban a panelen belül scrolloz, miközben a tabok és a footer rögzítve maradnak. | timeline panel grid + `history-detail-events-scroll` | célzott source contract | PARTIAL — a korábbi, egymásba ágyazott scroll-terület a készüléken továbbra sem görgethető. |
| HCS-02 | User feedback | Három kompakt carousel-slot látszik: középen nagyobb aktív card, két oldalt kisebb szomszéd. | carousel CSS | célzott source contract | DONE |
| HCS-03 | User feedback | Scroll közben a card a középponthoz közeledve nő, távolodva zsugorodik; a megálló card lesz a kiválasztott időszak. | existing History carousel controller | controller runtime + source contract | DONE |
| HCS-04 | Architekturális korlát | A selection state továbbra is csak `historySelectedPeriodId`; nem kerül be második carousel state vagy router. | `HomeInteractionController` | boundary/source contract | DONE |

## Mély scroll-korrekció – 2026-10-11

### Diagnózis

- Az inline Történetem workspace a közös detail markupot klónozza, majd egy rögzített háromsoros gridbe ágyazza.
- Ebben a variánsban a Timeline függőleges scrollja két egymásba tett teljes magasságú grid-elem mélyére került (`panel-slot` → `panel` → `history-detail-events-scroll`). A készüléken ez nem ad megbízható, ténylegesen elérhető scroll-tartományt.
- A javítás egyetlen közvetlen grid-gyerek scroll-tulajdonost használ: az inline `history-detail-panel-slot` lesz a függőleges scroll-container. A tab és az expandable footer marad a grid saját, rögzített sorában. A timeline eseménylista csak a scrollozott tartalom.

| ID | Forrás | Követelmény | Kódbeli terület | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- | --- |
| HDS-01 | Aktuális user feedback: „még mindig nem lehet scrollozni az idővonalat” | A Timeline body a carousel alatti workspace-ben ténylegesen függőlegesen scrollozható. | scoped inline `.history-detail-panel-slot` | Pontosan egy közvetlen, korlátos scroll-owner van a tabok és footer között; az event lista nem kap második scroll-ownert. | RED/GREEN source contract; a friss, fizikai drag-eszközteszt a megnyitott helyi URL-en még visszaigazolásra vár. | PARTIAL |
| HDS-02 | Aktuális user feedback | A felső tab-sor és az „Idővonalam számokban” expandable footer görgetés közben a helyén marad. | `history-detail-content` háromsoros grid | A középső row görget, a két szélső row nem. | source contract + közvetlen CSS-ellenőrzés | DONE |
| HDS-03 | Aktuális user feedback | A carousel-card alapmagassága pontosan az Ösvény felső „Őszinte önleltár” / current-work card közös tokenjét használja. | `history-period-carousel` CSS | A card `min-height` a `--path-overview-current-card-height` értékére hivatkozik; a középső grow effekt csak transformmal nagyít. | RED/GREEN source contract + közvetlen CSS-ellenőrzés | DONE |

## Hibakezelés és akadálymentesség

- Ha nincs érvényes kiválasztott period ID, a controller a `current` periodra áll vissza.
- A carousel kártyái valódi gombok, aktuális elemük `aria-current="true"`; a swipe nem az egyetlen választási lehetőség.
- A carousel swipe a függőleges body-scrollal nem verseng: csak egyértelmű vízszintes mozdulat aktivál választást.
- A korábbi detail-route nem maradhat csak statikus vagy eltérő adatokkal működő árva képernyő.
