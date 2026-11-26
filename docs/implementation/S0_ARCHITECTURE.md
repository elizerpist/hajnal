# Hajnal S0 architektúrakártya

Forrás: `HAJNAL_S0_STARTER_PROMPT.md`, különösen §§3–8; `docs/HAJNAL_FLUTTER_SPECIFIKACIO.md` 0.3. Az állapot és ellenőrzések a `S0_ACCEPTANCE.md` fájlban vannak.

- Tartós igazságforrás: app-private Drift/SQLite. Egyetlen hivatalos időszakírás: onboarding controller → inicializáló use case → repository → tranzakció. Egy aktív rekordot adatbázis-korlát véd. A kezdőnap lokális naptári dátum, a létrehozás UTC pillanat.
- Kiolvasás: repository stream → view-model → megjelenítés. UI-állapot a menü, sheet progress és szerkesztési dátum; tartós időszakállapot a DB-é. Nincs mentett napszámláló vagy onboardingComplete.
- Tiszta naptári motor injektált órával; egy foreground-életciklus tulajdonos kezeli az éjféli és ritka kontextusellenőrző időzítőt. A platformadapter a kompozíciós gyökéren csatlakozik.
- A dátumválasztó közös szerződés mögött platformadapter; a widget nem hív MethodChannelt. A lifecycle és konkurens kérések az adapter felelőssége.
- Egy artwork resolver és renderer; a repository ellenőrzött, verziózott privát fájlt és tartós relatív leírót kezel. Hibánál előző kép vagy bundle fallback; nincs hálózat.
- A dashboard egy progressből számolja a kártya és üres panel helyét. Referencia: `html-prototypes/app-shell/index.html` `.home-metrics`, `.home-body`, `HomeInteractionController`; korábbi statikus állapot: `html-prototypes/offline-ui/index.html`. A helyi app-shell módosított, ezért a vizuális összehasonlításnál ezt az állapotot is külön dokumentálni kell.
- Ellenőrzés: boundary + domain + DB + widget, Android natív emulátor és restart, HTML/Flutter screenshotok, pontos SHA-s CI. iOS fizikai ellenőrzés külön nyitott.

Implementációs ág: `build/starter`; a `feat/first-prototype-page` a prototípus ága.
