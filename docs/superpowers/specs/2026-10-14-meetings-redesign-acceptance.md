# Hajnal – Gyűlések: architektúra és elfogadási ellenőrzőlista

## Gyűlések redesign architecture card

### Scope and sources

- User requirement: Naptár és Lista sibling nézet, source-of-truth-hű hero/fade, új gyűlés sheet, child részletoldal és szerkeszthető, időfüggő jegyzet.
- Accepted reference: `/storage/emulated/0/hajnal/source of truth/gyulesek.png`.
- Existing implementation: `html-prototypes/app-shell/index.html`, különösen `MEETING_SEED_ITEMS`, `HomeInteractionController`, a meeting detail/editor rendererek, `openAppOverlaySheet()` és a History floating switch.

### Single source and write path

- Source of truth: `state.meetings`; az ismétlődő sorozat és az egyedi alkalom ugyanazon meeting rekordhoz tartozik.
- Read model: a közös occurrence-resolver állítja elő a naptári napok és a Lista mód elemeit.
- Only write path: meeting sheet/editor intent → `HomeInteractionController` meeting mutator → `state.meetings` → `renderMeetings()`.
- Error and retry owner: a meeting draft állapota; mező- és időintervallum-validáció mentéskor, az input draft megőrzésével.

### State ownership

| State | Owner | Lifetime | Publication rule |
| --- | --- | --- | --- |
| Lista/Naptár sibling mód | `state.meetingsView` | Gyűlések screen | Egyetlen floating switch írhatja. |
| Kiválasztott nap/hónap | `state.meetingsSelectedDate`, `state.meetingsCalendarMonth` | Gyűlések screen | Naptár intent frissíti, nem route-váltás. |
| Részletoldal visszatérési kontextus | `state.meetingDetailOrigin` | Child page | Card megnyitásakor rögzül; Back ezt állítja helyre. |
| Form draft/sheet | `state.meetingEditor` | Sheet életciklus | Mentéskor csak a közös meeting write path módosít adatot. |
| Ismétlődésből számított alkalom | Pure occurrence resolver | Render | Nem tárol külön, duplikált meeting-listát. |

### Reuse and centralization decision

| Candidate | Existing owner | Shared invariant | Decision | Proof |
| --- | --- | --- | --- |
| Floating icon switch | `.history-inline-view-switch` | pozíció, méret, state motion | Megosztott CSS primitive, meetings adapterrel | Statikus contract teszt |
| Sheet layering/focus | `openAppOverlaySheet()` | overlay, inert háttér, Back/Escape | Meglévő engine használata | Contract teszt |
| Havi grid | `renderMonthCalendarCells()` | hónapváltás, kiválasztás, accessibility | Meglévő builder kibővítése meeting-occurrence adapterrel | Domain teszt |
| Meeting occurrence | `state.meetings` | egyszeri és heti sorozat következetes megjelenése | Egyetlen pure resolver | Domain teszt |

### Layer flow

Meeting UI → `HomeInteractionController` → meeting domain helper/resolver → `state.meetings` → existing static-prototype state adapter.

### Verification

- Domain/unit: a `meetings_redesign_test.js` ellenőrzi az egyszeri és heti alkalomfeloldást, a stabil occurrence ID-t, az assetet és a sheet-boundaryt.
- UI/integration: a renderer egyetlen `state.meetings` source-of-truthból épít; a child origin, a sheet és az Android/Escape Back kezelés közvetlenül a controllerben van.
- Screenshot/reference: `/storage/emulated/0/hajnal/source of truth/gyulesek.png`, 412×892. A referenciafájlt közvetlenül megvizsgáltam; a friss, vezérelhető Android/Chromium screenshot-készítés ebben a környezetben blokkolt.
- Performance: a naptár csak az aktuális grid napjait oldja fel; a Lista mód korlátozott előre- és visszatekintő időablakot használ.

## Elfogadási ellenőrzőlista

| ID | Forrás | Kódterület | Elfogadási feltétel | Igazolás | Állapot |
| --- | --- | --- | --- | --- | --- |
| MTG-01 | source of truth | Meetings hero/CSS | Új, generált hero a referenciához illő pasztell világban; hero–body fade, kemény határ nélkül. | Asset-inspection kész; friss alkalmazásképernyőkép blokkolt. | PARTIAL |
| MTG-02 | §3–4 | Main meetings renderer | A History-val azonos helyű floating icon switch Lista és Naptár sibling state-et vált. | Megosztott History CSS primitive + contract teszt; alkalmazásképernyőkép blokkolt. | PARTIAL |
| MTG-03 | §5 | Calendar mode | Havi grid, halvány átnyúló napok, finom meeting-indikátorok, kiválasztott napi lista és napi add action. | Domain teszt zöld; vizuális Android-ellenőrzés blokkolt. | PARTIAL |
| MTG-04 | §6 | List mode | Csak Lista módban látható nyugodt stat-card, Közelgő és Korábbi szekciók. | Renderer- és contract-teszt zöld; vizuális Android-ellenőrzés blokkolt. | PARTIAL |
| MTG-05 | §7, §10 | Meeting sheet + meeting state | Új és szerkeszthető meeting sheet: idő, típus, nyitottság, helyszín/link, note, egyszeri/heti ismétlődés. | Közös sheet-controller és domain teszt zöld. | DONE |
| MTG-06 | §8–9 | Child detail page | Card → részletoldal → pontos előző sibling mód; részvételi státuszok és időfüggő jegyzet-helper. | Controller-útvonal és state-inspection kész; interakciós böngészőteszt hiányzik. | PARTIAL |
| MTG-07 | §11 | occurrence resolver | A heti sorozat valamennyi megfelelő napon megjelenik; Lista nézet közelgő/korábbi bontása stabil. | `meetings_redesign_test.js` zöld. | DONE |
| MTG-08 | §12 | CSS/motion | Puha mód-, sheet- és child-transition; reduced-motion támogatott; nincs gesture vagy scroll ownership hiba. | Reduced-motion CSS és egyértelmű scroll owner kész; gesture/screenshot runtime blokkolt. | PARTIAL |
| MTG-09 | §13 | Architecture boundary | Nem keletkezik párhuzamos meeting-adatbázis, picker vagy overlay engine; egy write path marad. | Architecture card + boundary contract zöld. | DONE |
| MTG-10 | §14–16 | Seeds/tests | Azonnal tesztelhető egyszeri/heti, múltbeli/közelgő, jegyzetes/jegyzet nélküli seedek; minden előző feltétel igazolva. | Seedek és célzott teszt kész; teljes suite 35 passz, 3 régi History runtime blokk. | PARTIAL |
| MTG-11 | 2026-10-14 user request | History/Meetings shared layout token; Meetings main renderer | A Naptár-rács és a Lista „Gyűléseim” card felső éle ugyanott indul, mint a Történetem jelenlegi időszak-kártyája; Lista módban a stat-card nem görgethető, csak az alatta lévő gyűléslista. | `--history-current-card-top` közös token, külön `.meetings-list-fixed` + egyetlen `.meetings-list-scroll` owner; célzott contract teszt zöld. Friss Android/Chromium képernyőkép továbbra is blokkolt. | PARTIAL |

## 2026-10-14 – Meetings body alignment compact architecture gate

- **MTG-11 ownership:** a History current-period card pozíciójának egyetlen szemantikus tulajdonosa a `--history-current-card-top` token; a Meetings kizárólag ezt fogyasztja a `--meetings-body-top` adapteren keresztül.
- **Megosztott primitive:** nincs második pozíciószám vagy új scroll-motor. Calendar módban a meglévő Meetings body a vertikális scroll owner; Lista módban a fix stat-card mellett csak `.meetings-list-scroll` kezel függőleges scrollt.
- **Állapot/adatút:** változatlan. A `state.meetings`, a meglévő Lista renderer és a meeting occurrence resolver marad az egyetlen adatforrás.
- **Ellenőrzés:** a `meetings_redesign_test.js` rögzíti a közös top tokent, a fix lista-wrapper és az egyetlen Lista-scroll owner jelenlétét; a teljes képernyős vizuális ellenőrzéshez továbbra sincs vezérelhető Android/Chromium runtime ebben a környezetben.
