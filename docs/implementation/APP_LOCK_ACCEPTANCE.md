# Alkalmazászár: architektúra és elfogadás

Forrás: a felhasználó alkalmazászár-megbízása és vizuális kiegészítése; `docs/HAJNAL_FLUTTER_SPECIFIKACIO.md` 12–14.; referencia: `docs/references/source-of-truth/pin.png`; központi eredeti logó: `assets/brand/logo.svg` (forrás: `/storage/emulated/0/hajnal/logo_svg.svg`). Az implementációt a felhasználó jóváhagyta.

Tulajdonosok: egy lock-session controller tulajdonolja a zárolás és hitelesítés állapotát, a meglévő HajnalApp lifecycle observer közvetít. A teljes navigációs fa fölött központi zár takar, az érzékeny indulás nem jelenhet meg az állapot kiolvasása előtt. A beállításváltás lépéseit a LockSettingsCoordinator szervezi; a UI kizárólag navigációt, bemenetet és választ jelenít meg. A tartós beállítás egy repositoryn keresztül módosítható; a DB-ben tranzakciós generációmutató és backupban megmaradó védelmi jelző, a credential és az aktív mód ellenőrző példánya verziózott secure-storage slotban van. Előbb új titkos slot, majd DB-tranzakció váltja a mutatót; kieséskor a régi slot és mutató megmarad. A hiányzó aktív slot hiba, sosem Off. A PIN hash sózott, költséges kriptográfiai könyvtárral és háttér-isolate-ben készül. Biometria és védett tároló platformadapterek; a UI nem hívja őket. A módállapotot és a throttling szabályait tiszta domainkód, a platformközi hibákat típusos adapter kezeli.

| ID | Forrás | Kódterület | Elfogadás | Ellenőrzés | Állapot |
|---|---|---|---|---|---|
| L01 | prompt 1 + pin.png 01 | drawer/settings/tokens | négy kizárólagos kártya, állapotok, akadálymentesség, pontos vizuális egyezés | widget, screenshot/diff | PARTIAL |
| L02 | prompt 3 + pin.png 02 | PIN komponens/use case | 6+ számjegy, 0 megőrzése, explicit gomb, megerősítés, csere, Cancel | unit/widget/screenshot | PARTIAL |
| L03 | prompt 2–4 + pin.png 03 | domain/controller/biometric adapter | négy mód, teljes újrahitelesítés, valós biometria és fallback | unit/widget/natív | PARTIAL |
| L04 | prompt 5 | lifecycle/root | cold start, háttér, privacy, késői eredmény, route, natív dialog és Back | lifecycle/widget/natív | PARTIAL |
| L05 | prompt 6–7 | repository/secure/crypto | sózott költséges PIN, fail-closed és crash-safe mentés, tartós throttle/óraállítás | unit/DB/restart/boundary | PARTIAL |
| L06 | prompt 6 | backup | biztonsági kulcs hiánya nem old; appadatok mentése nincs globálisan tiltva | backup config/restore teszt | PARTIAL |
| L07 | vizuális kiegészítés 2–3 | assets és platform ikon | eredeti SVG, egy hivatkozás, reprodukálható Android/iOS ikonok | asset/launcher screenshot | PARTIAL |
| L08 | prompt 8–9 | CI/release/docs | teljes teszt, képek/diff, aláírt megőrző upgrade és Release/Pages | CI/log/sha | NOT DONE |

Ellenőrzési megjegyzések: a vizuális integrációs teszt valódi Flutter komponenseket renderel, de a biometrikus platformválaszokat szimulálja; a fizikai biometrikus működés külön bizonyítékot igényel. A képernyő-összevetés és a launcher ellenőrzése az emulátoros CI eredménye alapján zárható. A telefonos mentés-visszaállítás és az iOS build/eszköz nincs helyben igazolva.

A `5214daa` képeinek összevetése: a beállítási alsó szöveg már látható; a kulcs körvonala, a visszanyíl formája és a PIN-lakat eltér a referenciától, a PIN szövege és billentyűzete magasabban van. A biometrikus képernyőn a márka felső helyzete, az állapotkártya és az alsó művelet függőleges ritmusa eltér. A visszanyíl a natív és az integrációs képen is látható. A három állapotot az új commit emulátoros képeivel és overlayével együtt kell újra felülvizsgálni; a `5214daa` nem kapott vizuális jóváhagyást.

A `9ccdb25` Android-tesztjei, aláírása és adatmegőrző upgrade-je sikeres. Az overlayeken az elrendezés javult, de a PIN-lakat kulcslyuka hiányzik, és az aláhúzás halványabb a referenciánál, ezért ez a képsor sem kapott jóváhagyást. A logó a felhasználó által előírt SVG, amely a referencia raszteres logójától eltérhet; a fizikai biometria és iOS ellenőrzése nyitott.

A `f347e02` tesztjei és frissítése sikeresek, a PIN-lakat és aláhúzás megjelent. Az overlay további elrendezési különbséget mutatott: a PIN-fejléc, vonal és gomb függőleges pozíciója; a biometrikus kártya magassága, az ikon és a leírás térköze. A három képernyő új commitból készített overlaye szükséges a jóváhagyáshoz.

A `318a1d0` képein a fő elrendezési eltérések javultak, de a PIN-lépésszámláló alakja a referenciában kapszula, az alkalmazásban szögletes volt. Az új állapotot ismét a hozzá tartozó emulátoros képen kell ellenőrizni.

## Réteghatár- és Ponytail-önellenőrzés

- A feloldási munkamenet egyetlen tulajdonosa a `LockController`; a meglévő `HajnalApp` observer továbbítja az életciklust. A beállítási munkafolyamat a `LockSettingsCoordinator` felelőssége, a képernyők bemenetet és navigációt adnak.
- A tartós mód és a próbálkozások írása kizárólag a `LockRepository` útján történik; a PIN-ellenőrző kivonatot a `PinHasher`, a secure-storage és biometria hozzáférést külön adapter kezeli. A módról a credentialbe írt ellenőrző példány megakadályozza a sérült aktív mód csendes gyengítését.
- A production import- és exportgráfot, a konkrét platform- és DB-írástulajdonosokat, a lock kaput, az adatmigrációt és a sérült credentialt automatizált tesztek vizsgálják. A kizárólag a `PredictiveBackEvent` típust importáló lifecycle-root és a secure storage törlési művelete szűk, nevesített kivétel.
- A szerkeszthető SVG egyetlen brand asset; a platform launcher képek ugyanebből generálhatók. Felesleges új téma vagy párhuzamos életciklus-figyelő nem került be. A CI-s vizuális képekhez szimulált platformválasz tartozik, a hardveres biometrikus biztonsági tulajdonságot ez nem igazolja.
- Nyitott ellenőrzés: tényleges natív és iOS biometria, telefonköltöztetési visszaállítás, pontos képi összevetés, aláírt telepítés és frissítés. Ezek státusza a helyi unit/widget tesztektől független.
