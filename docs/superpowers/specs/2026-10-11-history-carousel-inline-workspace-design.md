# Történetem – carouseles, inline idővonal workspace

## Cél

A Történetem főmenü a korábbi függőleges időszaklisták helyett egyetlen, összevont felület lesz. A jelenlegi History hero mérete, hero–body aránya és a háttér fokozatos fade-je megmarad. Az időszak kiválasztása a hero alsó részén levő vízszintes carouselben történik; a kiválasztott időszakhoz tartozó Idővonal és Naptár közvetlenül alatta, ugyanazon a route-on jelenik meg.

Az Ösvény meglévő listanézete nem változik.

## Döntések

- A Történetem korábbi `current` és `path-inspired` lista-presentationje megszűnik mint felhasználói nézet; nincs History layout- vagy density-toggle.
- A History hero az eddigi path-inspired geometriát tartja: `238px` hero, azonos hero→body fade és azonos, stabil függőleges arány.
- Az időszak-carousel a hero része. A középre igazított, aktív kártya mutatja a kiválasztott időszakot; a szomszédos kártyák részben láthatók.
- Vízszintes swipe, illetve kártyatapelés váltja a kiválasztott időszakot. A swipe állapotát a controller kezeli; az UI csak intentet küld.
- A natív track a változatlan `HISTORY_PERIODS` adatokat pontosan egyszer tartalmazza. A kiválasztott időszakot a card alatti, nem interaktív indicator-pöttyök jelzik; ezek kizárólag a már meglévő `historySelectedPeriodId` state-ből származnak.
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
| HCS-05 | Superseded user instruction: „a carousel infinite loop legyen” | Removed repeat-track/recentering code. | The withdrawn visual-repeat implementation is absent. | Focused source contract. | NOT DONE — user withdrew this presentation in favour of HCS-06. |
| HCS-06 | Latest user correction | A finite History carousel alatt legyenek indicator-pöttyök, a carousel pedig annyival feljebb kerüljön, hogy a pöttyök és a fix tabsor között maradjon hely. | Existing native `history-period-carousel`, `renderHistoryCarouselIndicators()`, scoped hero CSS | Pontosan a 10 immutable időszak-card és 10 indicator jelenik meg; egy aktív pötty követi a kiválasztott cardot. A 102px active card a Path referenciához képest 14px-szel feljebb van, a dot row pedig a card és a tabsor között fér el. | Source contract + Chromium mobile touch/geometry 412×892, 390×844, 360×800 + 412×892 screenshot. | DONE — mindhárom viewporton 10 finite card/10 dot, egy aktív dot, card y=97/h=102, tabs y=225; a vízszintes swipe a kiválasztást és a dotot együtt frissíti, a Timeline scroll változatlanul működik. |

## Mély scroll-korrekció – 2026-10-11

### Diagnózis

- Az inline Történetem workspace a közös detail markupot klónozza, majd egy rögzített háromsoros gridbe ágyazza.
- Ebben a variánsban a Timeline függőleges scrollja két egymásba tett teljes magasságú grid-elem mélyére került (`panel-slot` → `panel` → `history-detail-events-scroll`). A készüléken ez nem ad megbízható, ténylegesen elérhető scroll-tartományt.
- A javítás egyetlen közvetlen grid-gyerek scroll-tulajdonost használ: az inline `history-detail-panel-slot` lesz a függőleges scroll-container. A tab és az expandable footer marad a grid saját, rögzített sorában. A timeline eseménylista csak a scrollozott tartalom.

| ID | Forrás | Követelmény | Kódbeli terület | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- | --- |
| HDS-01 | Aktuális user feedback: „még mindig nem lehet scrollozni az idővonalat” | A Timeline body a carousel alatti workspace-ben ténylegesen függőlegesen scrollozható. | scoped inline `.history-detail-panel-slot` | Pontosan egy közvetlen, korlátos scroll-owner van a tabok és footer között; az event lista nem kap második scroll-ownert. | RED/GREEN source contract; a friss, fizikai drag-eszközteszt a megnyitott helyi URL-en még visszaigazolásra vár. | PARTIAL |
| HDS-02 | Aktuális user feedback | A felső tab-sor és az „Idővonalam számokban” expandable footer görgetés közben a helyén marad. | `history-detail-content` háromsoros grid | A középső row görget, a két szélső row nem. | source contract + közvetlen CSS-ellenőrzés | DONE |
| HDS-03 | Latest user correction | A kiválasztott History időszakkártya magassága maradjon az Ösvény felső current-work card közös tokenjén, de a dot-row számára kerüljön feljebb. | `history-period-carousel`, `history-period-carousel-card`, shared Path height token | A card explicit `height`/`min-height`/`max-height` értéke a közös `--path-overview-current-card-height`; a carousel alsó insetje 14px vertikális helyet ad a dot rownak. A side-card grow/shrink csak transform. | RED/GREEN valódi böngészős Path–History geometria mérés + source contract | DONE — mindkét base height 102 px; a History card y=97, a Path card y=111, a közéjük tett 10-dot row nem ütközik a rögzített tabsor y=225 koordinátájával 412×892-n. |
| HDS-04 | Latest user feedback and Android screenshot | A History rögzített Idővonal/Naptár tabsor ugyanabban az y-pozícióban induljon, mint az Ösvény „12 lépés” listacíme. | inline `history-workspace` top boundary; shared detail grid | A workspace kizárólag a dokumentált hero-overlappal indul; a tabsor és a Path heading mért top értéke legfeljebb 1 px eltéréssel egyezik, miközben a scroll-owner definitív marad. | RED/GREEN valódi böngészős Path–History geometria + Timeline touch regresszió | DONE — RED: tabs y=247, Path heading y=225. GREEN: tabs/heading y=225/225 px; a Timeline 457/1162 px scrolltérrel és CDP-touch mozgatással zöld maradt. |
| HDS-05 | Latest user correction | A History inline body a hero meglévő fade-jének folytatása, nem önálló lekerekített fehér card. | scoped inline `.history-detail-content` presentation CSS | Az inline body `border-radius: 0` és `background: transparent`; a hero meglévő fade-je az existing History page backgroundba olvad. A grid és egyetlen scroll-owner változatlan. | RED/GREEN source contract, 412×892 browser screenshot, Timeline runtime regression | PARTIAL — a forrás-contract RED volt a 29px/fehér card szabályon, GREEN a transparens/radius-zero szabályon. A 412×892 renderelt böngészőképen a fade folyamatos, a Timeline scroll 457/1162 px és CDP-touch útvonala zöld; fizikai Android Chrome visszaigazolás még nincs. |

## Mért root-cause korrekció – 2026-10-11

### Bizonyíték és döntés

- A friss Android screenshoton az eseménylista a bottom navigation alá fut, miközben a harmadik grid-sorban levő „Idővonalam számokban” footer sem látszik. Ez kizárja azt, hogy kizárólag egy esemény- vagy overlay-listener blokkolná a touchot: a teljes workspace grid nincs korlátos magasságra számolva.
- A működő, önálló detail-route `history-detail-content` eleme abszolút `top`/`bottom` pozícióval kap definitív magasságot. Az inline variant ezt `position: relative; inset: auto; height: 100%` formára írja felül; ez az abszolút `history-workspace` százalékos magasságára támaszkodik, és a mobil böngészőben a klónozott subtree-nél nem képez stabil grid-limittet.
- A root-cause javítás ezért nem új scroll-container: ugyanaz a shared detail markup kapja vissza a közvetlen, abszolút `inset: 0` határait a már korlátos inline workspace-ben. A középső grid-sor így valódi méretet kap; a meglévő `history-detail-panel-slot` marad az egyetlen scroll-owner.

| ID | Forrás | Követelmény | Kódbeli terület | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- | --- |
| HRC-01 | Friss Android screenshot + user feedback | Az inline detail-content ugyanúgy definitív, abszolút réteghatárokat kap, mint a működő standalone detail-content. | scoped inline `.history-detail-content` | `position: absolute; inset: 0; height: auto`; nincs `position: relative`, `inset: auto` vagy százalékos magasság mint második méretforrás. | RED/GREEN regression contract + Android screenshot | PARTIAL — a wrapper hiánya volt a mélyebb root cause; a wrapperrel együtt az abszolút grid-határ már valós Chromium layoutban is mérten működik. A friss fizikai Android screenshot továbbra is nyitott. |
| HRC-02 | Friss Android screenshot + user feedback | A footer a harmadik grid-sorban marad, az eseménylista pedig nem futhat a bottom nav alá. | existing three-row grid + one panel scroll owner | A panel slot kerete és a footer egyaránt a workspace látható magasságán belül van. | Android screenshot + targeted source contract | PARTIAL — a browser touch regresszió minden kötelező méreten igazolta a gridet és az utolsó esemény footer fölötti elérését; a fizikai Android Chrome-paszsz még BLOCKED. |

## Runtime scrollvizsgálat – 2026-10-11

**Felhasznált kötelező források:** a legutóbbi Android Timeline screenshot; a teljes alkalmazásspecifikáció különösen §§3, 9, 21 és 25; valamint `docs/references/source-of-truth/{logo,onboarding,designnkovetelmenyek,checkin_visszaeses_panik,haladas_naptar_stat,eszkozok_12lepes_naplo,sponzor_profil_beallitasok}.png`.

| ID | Forrás | Követelmény | Kódbeli terület | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- | --- |
| HSR-01 | 2026-10-11-i kritikus scrollhiba brief §§2–5 | A futó URL a vizsgált `feat/first-prototype-page` HEAD pontos forrását szolgálja ki, és a mérés a ténylegesen montolt inline workspace DOM-ját vizsgálja. | helyi HTTP-kiszolgálás; browser runtime harness | A kiszolgált `index.html` hash-e egyezik a worktree-vel; a riport tartalmazza a viewportot, a releváns elemek geometriáját és a buildazonosítót. | HTTP hash-összevetés + Playwright runtime riport. | DONE — a jelenlegi worktree SHA-256 értéke `fe5d1678…`; ezt ellenőrizte a valós böngészős teszt saját no-cache szervere. |
| HSR-02 | Brief §§4, 7–8; Android screenshot | A Timeline középső területének valódi, véges scroll-tartománya legyen, a footer és bottom navigation fölött. | inline History workspace mount és grid | A tényleges scroll-owner `scrollHeight > clientHeight`; a programozott `scrollTop` legalább két animation frame, 300 ms és 1000 ms után megmarad; a footer és a nav látható, rögzített helyen marad. | Valódi böngészős geometry/programmatic-scroll teszt 412×892, 390×844 és 360×800. | DONE — az új geometriai igazítás után 412×892: 457/1162 px, 390×844: 409/1185 px, 360×800: 365/1197 px (`clientHeight`/`scrollHeight`). Minden esetben a 200 px programozott pozíció megmaradt két frame, 300 ms és 1000 ms után; a footer/nav top értékei rendre 750/821, 702/773, 658/729 px. |
| HSR-03 | Brief §§5–6 | A workspace DOM-ja nem épül újra scroll alatt, és a Timeline függőleges swipe-ja nem indít carousel-váltást vagy nem ütközik fedőrétegbe. | `ensureHistoryWorkspace()`, `renderHistoryWorkspace()`, carousel és event diagnosztika | MutationObserver és render-számláló igazolja a stable scroll node-ot; a hit-test és touch napló a panelt mutatja célként; egy CDP touch gesture növeli a scrollTopot. | Runtime érintéses regressziós teszt és diagnosztikai riport. | DONE — a három mobil Chromium futásban a scroll node végig kapcsolódva maradt (`mountCount: 1`, `currentSlotIsInitial: true`), a child-list MutationObserver 0 hozzáadást és 0 eltávolítást mért; a CDP-touch swipe 0-ról 418/241/241 px-re mozdította a scrollTopot. A függőleges gesture nem váltotta a kiválasztott carousel-időszakot; a külön vízszintes gesture igen. |
| HSR-04 | Brief §§9–10 | Az inline Timeline érintéses görgetése, carousel, tabváltás és footer együtt regresszió nélkül működik. | `history_timeline_scroll_runtime_test.js`; közös History controller | 412×892, 390×844 és 360×800 esetén az első és utolsó esemény elérhető; a hero/carousel/tabs/footer/nav a specifikált viselkedésben marad; nincs új History adat- vagy route-rendszer. | Playwright mobil-CDP touch teszt, screenshotok és meglévő controller/source tesztek. | DONE — mindhárom viewporton zöld a valós Chromium/CDP-touch regressziós teszt: a footer nyitása után és Idővonal → Naptár → Idővonal után is marad scrolltartomány; az utolsó esemény a footer fölött jelenik meg; a hero, carousel, tabok, footer és bottom nav a Timeline görgetésekor változatlan bounding rectet tartanak. A 412×892 és 360×800 renderelt screenshotok is elkészültek. |
| HSR-05 | Brief §§9, 11–13 | A fizikai Android Chrome-ban végzett ujjas ellenőrzés külön bizonyíték, nem helyettesíthető statikus teszttel. | Android Chrome a `127.0.0.1:8765/app-shell/` URL-en | A teljes Timeline normál ujjas swipe-pal végiggörgethető, fejezet-, tab- és footerállapot-váltás után is. | Fizikai eszközteszt és friss Android screenshot/videó. | BLOCKED — ebből a Termux folyamatból nincs Android input-injektálási vagy Chrome DevTools-engedély; a browser runtime teszt külön lefedi a CDP-touch útvonalat, de a fizikai Chrome-ot nem állíthatja sikeresnek. |

### Mért root cause és a korábbi javítások eredménye

Az első carouseles commit (`cd697e8`) a standalone `<main class="history-detail-content">` sablon **belső** HTML-jét másolta az üres inline hostba. Ezzel a szükséges `.history-detail-content` grid-wrapper lemaradt a ténylegesen futó DOM-ról. A rá épülő, későbbi CSS-szabályok ezért nem a visible inline subtree-t célozták.

| Commit | Mit próbált | Miért nem oldotta meg |
| --- | --- | --- |
| `654cf38` | Visszaállította az inline workspace top/bottom határait és a `.history-detail-content` gridet. | A grid elem nem volt montolva; a szabály nem kapott elemet. |
| `effab35` | A belső timeline-panel/events scrollernek adott teljes magasságot és `pan-y`-t. | A szülő középső grid-sora továbbra sem létezett; a belső 100% nem tudott véges méretből számolni. |
| `79bc3fa` | A közvetlen panel-slotot tette scroll-ownerré. | Jó owner-választás volt, de a slot a hiányzó wrapper miatt 1162 px tartalomméretre nőtt, ezért `scrollHeight === clientHeight`. |
| `fe8866b` | Az inline `.history-detail-content` abszolút `inset: 0` korlátját írta elő. | Ez is a hiányzó `.history-detail-content` elemre vonatkozott, tehát a futó layout nem változott. |

**Javítás:** `ensureHistoryWorkspace()` most egyszer egy valódi `history-workspace-mounted` / `.history-detail-content` wrappert hoz létre a közös sablon belseje köré. A következő `renderHistoryWorkspace()` hívások nem írják felül ezt a DOM-ot; csak state-attribútumokat és célzott tartalmat frissítenek. A live meeting-idővonal írása a template és a montolt példány közös cél-listáján történik, ezért az adatfrissítés továbbra sem igényel teljes remountot.

**Javítás előtti mérés (412×892):** montolt `.history-detail-content` nem volt; a panel-slot `clientHeight=1162`, `scrollHeight=1162`, `scrollTop=0`; a footer top koordinátája 1451 px, miközben a bottom nav 821 px-nél kezdődött. Ez a geometriai A-eset volt a brief szerint, nem touch/hit-test hiba.

## Hibakezelés és akadálymentesség

## History2 asset-alapú vizuális korrekció – 2026-10-11

### Kötelező vizuális forrás és architektúra-kártya

- **Vizuális source of truth:** `/storage/emulated/0/hajnal/source of truth/history2.png` — a képet közvetlenül meg kell nyitni minden további visual change előtt; runtime assetként tiltott.
- **Meglévő állapot-tulajdonos:** `HomeInteractionController.state.historySelectedPeriodId`; a kiválasztást továbbra is kizárólag `selectHistoryPeriod(periodId)` írja.
- **Meglévő mechanizmus:** a véges, natív scroll-snap `history-period-carousel`, a hozzá kötött indicator-pöttyök és az egyetlen Timeline scroll-owner. Nem készül második carousel, router, History-dataforrás vagy scroll-kezelő.
- **Új kizárólagos képi forrás:** `html-prototypes/app-shell/assets/history/*.png`. A hero és a három carousel artwork valós bitmap; dinamikus felirat nincs a PNG-be égetve.
- **Presentation boundary:** a CSS csak az assetek vágását, a text-overlay olvashatóságát és a kiválasztott/inaktív UI-állapotot rendezi. Nem rajzol ki tájat, panda-karaktert vagy illusztrációt CSS/SVG/HTML elemekből.

| ID | Forrás | Követelmény | Kódbeli terület | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- | --- |
| H2-01 | Latest user brief §§0–5; `history2.png` | A History hero finom, alacsony kontrasztú, a carousel cardok mögé húzott atmoszférikus háttér. | History hero `<img>` binding + scoped History CSS | A hero valódi `history_hero_soft.png`, panorámás, pasztelles és a kártyáknál észrevehetően halványabb; a meglevő hero/body fade nem szakad meg. | Asset inspection, source contract, 412×892 screenshot. | DONE — direct PNG inspection plus final 412×892 Chromium screenshot; the hero is a 1918×820 low-saturation PNG at `.78` image opacity beneath the existing fade, while the card art stays full saturation. |
| H2-02 | Latest user brief §§2, 4, 6–8; `history2.png` | `HISTORY_PERIODS[].art`, carousel renderer, scoped carousel CSS | A periodusok három vagy több új, helyi PNG artworköt használnak; a cardok teljes felületét az artwork tölti ki. A title/date/day UI-overlay, az aktív középső kártyán fehér. Nincs split text/image panel vagy SVG card artwork. | RED/GREEN source contract + direct PNG inspection + rendered screenshot. | DONE — RED was the absent asset contract; GREEN verifies three generated 1448×1086 card PNGs, full-bleed art inset, no former 52px split grid, and white active dynamic copy. |
| H2-03 | Latest user brief §§5, 9–10; prior verified History scroll contract | Existing `HomeInteractionController` and inline History workspace | Kiválasztás, finite dots, carousel swipe/tap, tabs, Timeline scroll, footer és bottom nav a már mért viselkedésben maradnak. | Existing mobile Chromium/CDP-touch runtime suite at 412×892, 390×844, 360×800. | DONE — three mobile Chromium/CDP-touch runs pass. Timeline scroll ranges: 449/1162, 401/1185, 357/1197 (`clientHeight`/`scrollHeight`); touch moves scrollTop from 0 to 379/241/241 while carousel selection, footer and BottomNav remain stable. |

- Ha nincs érvényes kiválasztott period ID, a controller a `current` periodra áll vissza.
- A carousel kártyái valódi gombok, aktuális elemük `aria-current="true"`; a swipe nem az egyetlen választási lehetőség.
- A carousel swipe a függőleges body-scrollal nem verseng: csak egyértelmű vízszintes mozdulat aktivál választást.
- A korábbi detail-route nem maradhat csak statikus vagy eltérő adatokkal működő árva képernyő.

## Hero-swipe alternatíva és Naptár panel – 2026-10-11

### Architektúra-kártya

- **Egyetlen period-selection source of truth:** `HomeInteractionController.state.historySelectedPeriodId`; minden tap és natív horizontal scroll a meglévő `selectHistoryPeriod(periodId)` írási úton érkezik.
- **Új, kizárólag presentation state:** `HomeInteractionController.state.historyPeriodPresentation` (`cards` vagy `hero-swipe`). A jobb felső, szemantikusan címkézett toggle ezt a state-et váltja; nem befolyásolja a selected period domain adatát vagy a Timeline/Naptár route-ot.
- **Meglévő mechanizmus újrarenderelése:** mindkét mód a már létező `history-period-carousel` native scroll-snap tracket használja. A `cards` renderer megtartja a három képes kártya ritmusát. A `hero-swipe` renderer ugyanazon periodusok PNG-jét teljes hero slide-ként kompozitálja; nem készül második carousel-gesture engine, perioduslista vagy router.
- **Panel-láthatóság:** az inline workspace ugyanazt a `data-history-detail-view` állapotot használja, mint a shared detail template. A Timeline-specific inline layout override csak Timeline állapotban mutathatja a Timeline panelt; Calendar állapotban a Calendar panel az egyetlen látható panel.
- **Változatlanok:** History hero/body boundary, one owner Timeline scroll, fixed tabs/footer/navigation, `HISTORY_PERIODS` adatok és a meglévő History2 PNG assetek.
