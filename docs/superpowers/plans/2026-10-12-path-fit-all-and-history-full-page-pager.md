# Implementációs terv – Ösvény fit-all és History közös pager

1. [ ] Bővítem a controller-owned Path layout state-et `fit-all` móddal,
   felveszem a felső jobb toggle-t, és scoped CSS grid-geometriával a 12
   meglévő lépéskártyát scroll nélküli területbe foglalom.
2. [ ] Előbb célzott RED tesztet készítek a Path state/toggle/geometria
   szerződésére, majd implementálok és zöldre futtatom.
3. [ ] Kiváltom a full-hero History natív felső carousel + külön body-preview
   mintáját egy előző/aktuális/következő slide-ot tartalmazó közös pager-trackkel.
4. [ ] Előbb RED tesztet írok a common-track, előre renderelt szomszéd,
   irány-lock, commit-after-settle és egy scroll-owner szerződésére.
5. [ ] A controllerbe egyetlen History pager gesture állapotgépet vezetek be;
   drag alatt csak rAF-os `translate3d` fut, az időszakadat és scrollposition
   időszakazonosítóhoz kötve marad.
6. [ ] Ellenőrzöm a Timeline/Naptár, event-tap, rail, footer, cards mode,
   fade és bottom nav regressziót; futtatom a célzott és teljes statikus
   app-shell csomagot, `git diff --check`-et és served-source hash ellenőrzést.
7. [ ] Ha böngészős mobil érintésteszt eszköz nem elérhető, ezt dokumentálom,
   és a vizuális/érintéses kriteriumokat nem jelölöm késznek.
