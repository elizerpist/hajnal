# Hajnal egyfájlos offline prototípus – tervezési döntés

## Cél és forrás

- **Felhasználói igény (2026-09-26):** egyetlen HTML-fájl legyen elküldhető e-mailben; a címzett azt bármelyik helyről letöltve és közvetlenül a böngészőben megnyitva lássa.
- **Jelenlegi megvalósítás:** `docs/prototypes/hajnal_ui.html` nyolc helyi SVG-fájlra és a kezdő SVG-labor `fetch()` hívására támaszkodik, ezért nem hordozható egyetlen fájlként.
- **Érintett referenciák:** a teljes `docs/HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md`; a hét `docs/references/source-of-truth/*.png` referencia; a jelenlegi `docs/prototypes/hajnal_ui.html`.

## Elfogadott megoldás

A kanonikus prototípus új, egyetlen fizikai otthona:

```text
html-prototypes/
  hajnal-prototypes-index.html
  offline-ui/
    index.html
    tests/offline_single_file_test.js
```

Az `offline-ui/index.html` az egyetlen szerkesztendő és továbbítandó fájl. Kötelező fejlécmetaadatai:

```html
<meta name="prototype-id" content="hajnal/offline-ui">
<meta name="prototype-status" content="current">
```

Minden jelenleg hivatkozott SVG a HTML-ben `data:image/svg+xml;base64,...` adat-URL-ként jelenik meg. A `welcome_svg.svg`, amelyet a fénylabor eddig `fetch()`-elt, egy beágyazott `<template>` elembe kerül; a futásidő abból olvassa ki az SVG-szöveget, tehát nem indít hálózati vagy fájl-hozzáférési kérést. A megjelenés, képernyők, interakciók és szemantikus vezérlők nem változnak.

## Kompakt architektúra-kapu

| Kérdés | Döntés |
| --- | --- |
| Meglévő tulajdonos | `docs/prototypes/hajnal_ui.html` egyfájlos HTML/CSS/JS prototípus. |
| Újrahasznosítás | Nincs más offline-csomagoló vagy asset-resolver; a nyolc SVG egyetlen, beágyazott HTML-forrásba kerül. |
| Állapothatár | Kizárólag helyi böngészőbeli UI-állapot; nincs tárolási, hálózati vagy domain-adatfolyam. |
| Írási út | A felhasználó az `html-prototypes/offline-ui/index.html` fájlt szerkeszti; az assetek és a fénylabor-forrás is ebben a fájlban van. |
| Ellenőrzés | Node statikus teszt: metaadatok, nincs `assets/` vagy HTTP-hivatkozás, nincs `fetch()`, minden SVG-adat beágyazott; közvetlen `file://` betöltés vizuális ellenőrzése, ha elérhető a helyi böngésző. |

## Nem cél

- Flutter- vagy APK-munka.
- Új UI-képernyő, navigáció vagy szövegezés.
- A vázlat külön exportjának karbantartása: a szerkesztett kanonikus fájl maga a küldhető fájl.

## Hibakezelés és kompatibilitás

A dokumentum nem kér hálózatot, relatív fájlt vagy szervert. Ha egy böngésző nem engedné a helyi JavaScriptet, az oldal vizuális HTML/CSS/SVG tartalma akkor is megjelenik; a dinamikus fénylabor nem használ hálózati API-t.
