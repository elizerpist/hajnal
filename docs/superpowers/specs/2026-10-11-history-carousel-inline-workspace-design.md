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

## Hibakezelés és akadálymentesség

- Ha nincs érvényes kiválasztott period ID, a controller a `current` periodra áll vissza.
- A carousel kártyái valódi gombok, aktuális elemük `aria-current="true"`; a swipe nem az egyetlen választási lehetőség.
- A carousel swipe a függőleges body-scrollal nem verseng: csak egyértelmű vízszintes mozdulat aktivál választást.
- A korábbi detail-route nem maradhat csak statikus vagy eltérő adatokkal működő árva képernyő.
