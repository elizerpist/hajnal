# 15 perces túlélőcsomag – végrehajtási terv

1. **Felmérem és lezárom a szerződést.** A meglévő `survival` route, controller, Pánik overlayek és sponzor-adatforrások maradnak az egyetlen tulajdonosok. Felveszem a `SPK-*` acceptance checklistet. **Állapot: DONE.**
2. **RED teszt.** Egy célzott app-shell szerződést írok a hét állomásra, a 900 mp-es időkeretre, a tartós sessionre, a szabad jegyzet típusára és a régi automatikus „Még nehéz” visszalépés hiányára; a régi ötállomásos teszteket az új viselkedéshez igazítom. **Állapot: DONE.**
3. **Adatmodell és életciklus.** Bevezetem a validált/verziózott `survivalSession` és `freeNotes` tárolást, egyetlen kezdőidővel és DOM-only timer-frissítéssel. **Állapot: DONE.**
4. **Folyamat és integráció.** Elkészítem a hét állomás rendererét, a választási/reassessment ágakat és a meglévő Pánik/szponzor/motiváció integrációkat. **Állapot: DONE.**
5. **Vizuális rendszer.** Lecserélem a statikus survival CSS-t rugalmas képernyővázra, hozzáadom a funkcionális vizuálokat, reduced-motion szabályokat és a várakozási illusztrációt. **Állapot: DONE.**
6. **Ellenőrzés.** Futtatom a célzott majd a teljes statikus suite-ot, JS syntax/whitespace/offline ellenőrzést. Böngészős 412×892 screenshotot megkísérlem; a helyi Chromium hiányát csak ténylegesen dokumentálom, ha továbbra is blokkol. **Állapot: PARTIAL — a 412×892 headless screenshotok és a browser smoke sikeresek, de Android szoftver-billentyűzet és három korábbi Playwright/CDP-regresszió nem elérhető ebben a környezetben.**
