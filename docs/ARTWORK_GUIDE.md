# Artwork S0

A `dashboard.default` stabil szerephez tartozó csomagolt placeholder a `lib/core/artwork/artwork_catalog.dart` katalógusban van megadva: a forrás `html-prototypes/app-shell/assets/backgrounds/index1.png`, revíziója `bundle-1`, mérete 853×1843 pixel, kivágása cover, fókusza közép/fent. A végleges kép nem elfogadott. Csomagolt csere új buildet kíván; a telepített bundle nem írható.

A renderer a stabil szerepet adja át; az `ArtworkSource.resolve(role)` szerződés az ismeretlen szerepet elutasítja. Az `ArtworkService.install(role, file)` és `clear(role)` a szerephez app-private verziózott fájlt és adatbázisban tárolt relatív fájlnevet/revíziót kezel. Telepítés előtt legfeljebb 8 MiB fájlméretet, legfeljebb 8192 pixeles éleket és 32 megapixelt, valamint dekódolhatóságot ellenőriz; sérült vagy hiányzó fájlnál a csomagolt kép a fallback. Induláskor az átmeneti fájlokat takarítja. Nincs S0 felhasználói képválasztó vagy hálózati letöltés.
