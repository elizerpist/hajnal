# Artwork S0

A `dashboard.default` stabil szerephez tartozó csomagolt placeholder a `lib/core/artwork/artwork_catalog.dart` katalógusban van megadva: a forrás `html-prototypes/app-shell/assets/backgrounds/index1.png`, revíziója `bundle-1`, mérete 853×1843 pixel, kivágása cover, fókusza közép/fent. A végleges kép nem elfogadott. Csomagolt csere új buildet kíván; a telepített bundle nem írható.

Az `ArtworkService` a szerephez app-private verziózott fájlt és adatbázisban tárolt relatív fájlnevet/revíziót kezel. Telepítés előtt méretet és dekódolhatóságot ellenőriz; sérült vagy hiányzó fájlnál a csomagolt kép a fallback. Induláskor az átmeneti fájlokat takarítja. Nincs S0 felhasználói képválasztó vagy hálózati letöltés.
