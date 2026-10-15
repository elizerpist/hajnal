# Főmenü hero-címsorok – elfogadási ellenőrzőlista

| ID | Forrás | Kódterület | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| MHC-01 | Felhasználó: „az összes menu neve ugyanabban a pozícióban méretben és színben legyen, mint a sponzor menu neve” | `index.html` `:root` hero-tokenek; Sponzor, Történetem, Ösvény, Gyűlések hero-címsorai | A négy herót használó főmenü címe közös, Sponzor által meghatározott bal felső pozíciót, 32 px-es méretet és `#07132C` színt használ. | RED/GREEN forráskontraktteszt; 412 × 892 Chromium computed-style- és pozíciómérés. | DONE |
| MHC-02 | Felhasználó: „alatta a secunder szöveg” | Ugyanezek a hero-copy adapterek | A címhez közvetlenül kapcsolódó másodlagos szöveg azonos 7 px-es távolságot, színt és 14 px-es méretet használ; az útvonali tartalom és a jobb felső vezérlők nem változnak. | Forráskontraktteszt; 412 × 892 screenshotok. | DONE |
| MHC-03 | Felhasználó: „az ösvény menu heroba nem kell idézet” | `renderPathOverview()` és a csak ehhez tartozó CSS | Az Ösvény overview hero nem renderel önálló idézetet; a hero továbbra is címet, másodlagos szöveget és a meglévő jobb felső vezérlőket tartalmazza. | Forráskontraktteszt; Ösvény 412 × 892 screenshot. | DONE |
| MHC-04 | Meglévő route- és artwork-architektúra; `docs/references/source-of-truth/*.png` mind a hét kötelező referencia | `index.html` hero-adapterek | Nem változik a Főmenü saját dashboard-kompozíciója, a hero-artworkök, a route-ok, a bottom navigation vagy a Sponzor által már használt geometria. | Releváns route- és hero-regressziós tesztek; célzott runtime-ellenőrzés. | DONE |

## Referenciák és döntés

- Kötelező designreferenciák: `docs/references/source-of-truth/logo.png`, `onboarding.png`, `designnkovetelmenyek.png`, `checkin_visszaeses_panik.png`, `haladas_naptar_stat.png`, `eszkozok_12lepes_naplo.png`, `sponzor_profil_beallitasok.png`.
- A felhasználó legutóbbi, explicit utasítása elsőbbséget élvez: a Sponzor hero-copy a közös főmenü-hero címsor geometriai mintája.
- A Főmenü nem kapott külön hero-címet; a saját dashboard-kompozícióját ez a változás szándékosan nem érinti.
