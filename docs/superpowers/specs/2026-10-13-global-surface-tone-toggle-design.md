# Globális háttérárnyalat-paletta – design

## Jóváhagyott cél

A főmenü felső vezérlői alatt egyetlen, vízszintes ötszínű paletta választja
az alkalmazás egységes oldal-/képernyőhátterét. A felhasználó választása
újratöltés után is megmarad.

| Mód | Szemantikus háttérszín | Palettaállapot |
| --- | --- | --- |
| `index` | `#FDF5F8` | legvilágosabb |
| `original` (alapértelmezett) | `#F9F3F7` | eredeti |
| `blush` | `#F4E8F1` | enyhén telítettebb |
| `mauve` | `#ECD9E9` | mauve |
| `lavender` | `#E0C9E2` | legerősebb |

Forrás: 2026-10-13-i felhasználói instrukció: „a főmenube kérek egy gombot,
ami vált a kicsit sötétebb index.html árnyalat és az eredeti közt”, majd
„ez legyen befolyásall a hystoryra, összes almenure, azbösvényre összes
almenujére, és a sponzor, és gyűlések menure, tehát az egész appra”, valamint
„a fade out maradjon meg mindenhol, azt ne vedd ki”. A felhasználó a korábbi
egy-gombos tervet 2026-10-13-án jóváhagyta, majd ugyanazon a napon azt
ötszínű, fokozatosan telítettebb palettára cserélte.

## Felhasználói működés

- A `home-top-actions` alatt egyetlen akadálymentes, vízszintes paletta
  jelenik meg pontosan öt kerek színmintával. Nem készül külön Megjelenés
  képernyő, választólista vagy route.
- A minták egy radio-csoportot alkotnak; pontosan egy aktív, azt a kiemelt
  keret, emelés és `aria-checked="true"` jelzi.
- A kiválasztás best-effort `localStorage`-ban marad meg, ugyanazzal a
  biztonságos olvasási/írási mintával, amelyet a meglévő globális betűtípus
  kapcsoló használ. Tárolási hiba vagy ismeretlen érték esetén az `original`
  mód az egyetlen fallback.

## Hatókör és vizuális határ

Az új árnyalat az alkalmazás közös papír-/képernyőfelületére vonatkozik. A
közös felületi tokenen keresztül érinti a kezdőképernyőt, a History fő- és
alnézeteit, az Ösvény overview- és valamennyi résznézetét, valamint a
Szponzor és Gyűlések képernyőit és almenüit. A route-specifikus alapszínek
nem maradhatnak ettől független, nyers másolatok, ha a képernyő tényleges
oldalhátterét adják.

A fehér kártyák, gombok, ikonok, fényképek, illusztrációk és azok saját
szemantikus kontrasztszínei nem válnak második témarendszerré: változatlanok
maradnak. Így a váltás az egész alkalmazás közös hátterét egységesíti, nem
rontja a komponenshierarchiát vagy a kártyák kontrasztját.

## Fade-szerződés

A meglévő természetes alpha-fade-okhoz nem kerül új, fedő színsáv és egyetlen
maszk sem törlődik:

- az Ösvény `--hero-art-vertical-fade-mask` maszkja érintetlen marad;
- a History `--history-inline-hero-fade-mask` maszkja érintetlen marad;
- a Path lépés-illusztrációk és a History hero-k kifutásának végszíne a közös
  háttér-token feloldott értékét követi.

Ezért a két üzemmódban a fade ugyanúgy fokozatos, csak a látható alapszínhez
olvad.

## Architektúra-kártya

| Terület | Tulajdonos / újrahasználat | Egyetlen írási út |
| --- | --- | --- |
| Aktív háttérmód | `HomeInteractionController.state.surfaceTone` | `selectGlobalSurfaceTone(tone)` |
| Tartós felhasználói választás | a meglévő typeface-persistencia mintája | `persistSurfaceTone()` |
| DOM-állapot és vezérlő szemantika | controller `renderSurfaceTone()` + `.app-frame[data-surface-tone]` | kizárólag a renderelő metódus |
| Közös felületi szín | meglévő `--screen-background` mögötti szemantikus tokenek | egy attribútumhoz kötött token-feloldás |
| Route-ok és kifutások | meglévő `--screen-background`, History/Path scoped aliasok | csak a közös token olvasása |

Nem készül második router, feature-szintű paletta, route-onkénti tárolt
választás vagy külön History/Ösvény témavezérlő. A UI csak kattintási
szándékot gyűjt; a mode-váltást, persistenciát és DOM-projekciót a meglévő
központi controller végzi.

## Megvalósítási szerződés

1. A `:root` egyszer deklarálja mind az öt felületi értéket. Az
   `.app-frame[data-surface-tone]` kizárólag a közös szemantikus token
   feloldását cseréli ki.
2. Az összes érintett route és résznézet a meglévő közös tokenen vagy annak
   scoped aliasán keresztül olvassa a háttérszínt; nem kap route-onkénti
   `#FDF5F8` másolatot.
3. A controller induláskor olvassa a `hajnal.surfaceTone` értéket, a paletta
   eseménye csak a meglévő központi action-dispatchen jut el a kiválasztó
   metódusig, majd a render állítja az attribútumot és az ARIA-állapotokat.
4. A meglévő fade-maszkok, History pager-, Timeline-, Calendar-, Ösvény-
   navigáció- és BottomNav-tulajdonosok nem változnak.

## Bizonyíték

TDD-ben új, célzott source-contract teszt készül a globális mód állapotára,
persistenciájára, attribútum-projekciójára, a közös tokenhasználatra és a
History/Ösvény alpha-fade szerződés változatlanságára. A vonatkozó meglévő
History, Ösvény, Szponzor és Gyűlések kontrakttesztek regresszióként futnak.

Vizuális bizonyíték két 412×892-es állapot: `original` és `index`. Mindkét
állapotban History és Ösvény ellenőrzése kötelező, mert itt a háttérhez
futó artwork-maszk is látható.
