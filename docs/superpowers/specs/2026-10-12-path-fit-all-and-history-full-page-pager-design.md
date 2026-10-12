# Ösvény egyképernyős nézet és Történetem közös teljesoldalas pager – design

## Jóváhagyott cél

Két, kizárólag a meglévő `app-shell` prototípust érintő változat készül.

1. Az Ösvény overview új, kapcsolható `fit-all` elrendezése a felső
   jelenlegi-munka kártya nélkül, a hero dekorációjába olvadó bodyval, ahol
   a 12 meglévő lépéskártya egy 412×892-es képernyő használható területére
   fér. A jelenlegi roomy/compact nézet érintetlen alternatíva marad.
2. A Történetem `hero-swipe` alternatívája egy valódi, három elemet előre
   renderelő teljesoldalas pager. Egy slide tartalmazza ugyanannak az
   időszaknak a hero-artworkjét, metaadatait, fade-jét, Timeline/Naptár
   bodyját és számokban paneljét. Egyetlen track transform mozgatja őket.

## Architektúra-kártya

| Terület | Tulajdonos / újrahasználat | Egyetlen írási út |
| --- | --- | --- |
| Ösvény layout mód | `state.path.overviewPresentation` | `togglePathOverviewPresentation()` |
| Ösvény adatok/navigáció | meglévő `PATH_STEPS`, `currentCycle`, `open-path-step` | változatlan |
| History kiválasztott időszak | `state.historySelectedPeriodId` és `selectHistoryPeriod()` | csak sikeres pager-settle után |
| History pager drag/preview | `HomeInteractionController.historyPeriodPager` | pointer események → rAF transform |
| History időszakadatok | meglévő `HISTORY_PERIODS` + `HISTORY_PERIOD_TIMELINES` | csak olvasott renderer-adat |
| History scrollpozíciók | controller-owned `Map(periodId → scrollTop)` | közvetlen slide scroll-listener |

Nem készül második router, második periodus-adatforrás, második Timeline
state vagy külön hero/body swipe-controller. A cards módban megmarad a
meglévő natív carousel; a teljes hero módban kizárólag a pager a vízszintes
gesture-tulajdonos.

## Géometria

Az Ösvény 412×892 referenciafelületéből a 70px-es bottom nav feletti hasznos
magasság 822px. A fit-all mód felső státusz+hero fejlécére 104px, az alsó
paddingre 8px jut, így a 12 soros lista nettó 710px. Ez 12×54px kártya és
11×5px gap = 703px; a cím nélküli listakártya ezért scroll nélkül belefér,
miközben a lépések sorrendje és tappolhatósága változatlan.

History `hero-swipe` alatt a pager viewport az app frame bottom nav feletti
része. A trackben pontosan előző / aktuális / következő slide van. A track
alaphelyzete `-viewportWidth`, preview közben `-viewportWidth + dragX`.
Minden slide saját 238px layout-hero és ugyanarra a body-surface tokenre
kifutó dekoratív alpha-fade réteget hordoz.

## Gesture-állapotgép

`pending → horizontal | vertical → settle | cancelled`

- 12px előtt nincs döntés.
- vízszintes: `abs(dx) > abs(dy) * 1.25`; kizárólag ekkor kap pointer capturet
  és mozog a közös track.
- függőleges: `abs(dy) > abs(dx) * 1.25`; a natív, slide-on belüli Timeline
  scroll tulajdonos marad aktív.
- küszöb: a szélesség 25%-a vagy `0.45px/ms` sebesség; 280ms ease-out settle.
- a kiválasztott periodus csak a célba érés után íródik. Cancel/blur/resize
  visszaállítja a középső slide helyzetét.

## Bizonyíték

Új célzott source/runtime-contract tesztek ellenőrzik a két állapot- és
gesture-owner szerződést. Statikus és Node-tesztek nem minősülnek vizuális
bizonyítéknak. A helyi környezetben jelenleg nincs Playwright/Chromium, ezért
a 412×892 0%/részleges/100% képernyőkép és fizikai Android touch ellenőrzés
külön `PARTIAL` marad, amíg valódi runtime-eszköz nem áll rendelkezésre.
