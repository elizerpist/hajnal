# Pánik Alternative és Történetem path-inspired – elfogadási lista

## Kötelező vizuális és termékforrások

- Feladatleírások: a 2026-10-10-i felhasználói briefek (Pánik Alternative és Történetem alternatív layout).
- Kötelező alkalmazásspecifikáció: `docs/HAJNAL_RESZLETES_ALKALMAZASSPECIFIKACIO.md`.
- Vizuális referenciák: `assets/references/{logo,onboarding,designnkovetelmenyek,checkin_visszaeses_panik,haladas_naptar_stat,eszkozok_12lepes_naplo,sponzor_profil_beallitasok}.png`.
- Meglévő Pánik forrása: `assets/backgrounds/panik1.png` és a `#panic-root` meglévő Classic CSS-e.
- Meglévő Ösvény overview forrása: `html-prototypes/app-shell/index.html` Path hero/current/step-card szabályai.

## Architektúra-kártya

| Terület | Tulajdonos | Újrafelhasznált mag | Nem szabad duplikálni |
| --- | --- | --- | --- |
| Pánik nézetválasztás | `HomeInteractionController` | meglévő `panic` route, overlay és sponsor state | Pánik router, kapcsolat-adatbázis, túlélő wizard |
| Pánik segítségpanel | `HomeInteractionController` | app overlay, sponsor üzenetszerkesztő, kapcsolat-state | második SMS/hívás folyamat |
| Túlélőcsomag | `HomeInteractionController` | meglévő survival route | második wizard vagy automatikus visszaesési/tiszta-nap logika |
| Történetem presentation | `HomeInteractionController` | History route, period-detail action, Ösvény vizuális tokenek | Ösvény domain/progress state |
| Sponzor tartalék kapcsolatok | `HomeInteractionController` | `sponsorBackups` state és egyetlen contact-key feloldó a Pánik/SMS adapterhez | második kapcsolat-adatbázis vagy párhuzamos Pánik-kapcsolat state |

## Követelmények

| ID | Forrás | Kódterület | Elfogadás | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| PAN-01 | Pánik §1, §9 | `#panic-root`, controller | Classic az alapértelmezett; a jobb felső X helyén perzisztens, akadálymentes Classic/Alternative toggle van; Classic tartalma/stílusa egyébként változatlan. | `alternative_runtime_test.js` | DONE |
| PAN-02 | Pánik §2–3 | scoped Pánik CSS | Alternative megtartja a jelenlegi hátteret, címet és nagy gombméretet; a gomb csak Alternative-ben finom CSS pseudo-element pulse/glow-t kap, reduced-motion támogatással. | CSS/source teszt; Android screenshot kísérlet sikertelen (rendszer `screencap` tiltás) | PARTIAL |
| PAN-03 | Pánik §2, §5 | Pánik alternative renderer | Pontosan három, teljes felületükön tappolható gyorscsempe és egy alsó, mentett motivációt mutató kártya jelenik meg. | `alternative_runtime_test.js` | DONE |
| PAN-04 | Pánik §4 | közös overlay/contact adapter | A segítség gomb slide-up panelt nyit; csak valós sponsor/backup state-et használ, explicit `tel:`/SMS composer akciókkal, 112-vel, üres állapotokkal; nincs automatikus küldés/hívás. | source + runtime empty-state teszt | DONE |
| PAN-05 | Pánik §4.5, §7 | overlay lifecycle | backdrop, close, Escape, vissza/Android back és lehúzás bezár; fókusz visszatér; a háttér inaktív. | source/controller lifecycle teszt; eszközszintű gesture screenshot nem elérhető | PARTIAL |
| PAN-06 | Pánik §6 | survival state/render | Mindkét főképernyő közös, tényleges 15 perces időmérésű, megszakítás után folytatható wizardot nyit; minden szakaszból ugyanaz a help panel nyílik; hívás nélkül lezárható és nem ír tiszta napot. | `alternative_runtime_test.js` | DONE |
| PAN-07 | Pánik §7–10 | navigáció | Meeting, relapse, motivation és survival visszatérése megtartja a kiválasztott Pánik változatot; nincs fókuszálható inaktív változat vagy JS hiba. | controller + affected route checks | DONE |
| PAN-08 | 2026-10-11 Pánik mód finomítás | Alternative Pánik CSS/header | A látható Pánik header-copy eltűnik; az Alternative segítségkörén nincs külön border-gyűrű vagy pulzáló külső kör, csak a gombbal együtt pulzáló, fokozatosan kifutó rózsaszín glow. A gyorscsempék lejjebb, a motivációs kártya közvetlenül alattuk van. | célzott source review | PARTIAL |
| PAN-09 | 2026-10-11 Pánik mód finomítás | közös app overlay / Alternative renderer | A „Miért kezdtem el?” Alternative kártya route-váltás nélkül, a meglévő app-overlay core-t újrahasználó slide-up panelen jeleníti meg a mentett motivációt. Backdrop, bezáró gomb, Escape, Android-vissza és lehúzás visszavisz azonos Pánik nézetre. | célzott source review | PARTIAL |
| SPN-01 | 2026-10-11 Sponzor Alternative | Sponsor renderer/CSS/detail state | Alternative nézetben a gyorsműveletek: Hívás, Üzenet, Legközelebb; a „Beszélnem kell vele” nem látható. Utánuk egy teljes szélességű „Tartalék kapcsolattartók” card jelenik meg, az alsó két lista pedig kitölti a rendelkezésre álló függőleges teret. A két lista azonos, saját cardon belüli scroll-area: az alsóban a teljes útravalólista görgethető. | screenshot + célzott source review | PARTIAL |
| SPN-02 | 2026-10-11 Sponzor adatai finomítás | Sponsor detail CSS/markup | A „Sponzorom mióta” copy balra igazított; a Megjegyzés editor eltűnik; az idézet a meglévő lila cardban marad, de chevron nélkül. | célzott source review | PARTIAL |
| SPN-03 | 2026-10-11 Tartalék kapcsolattartók | Sponsor backup manager/state/Pánik adapter | A kapcsolattartó-kezelő alapállapotban üres; plusz gombbal több, generikus fej ikonos card adható hozzá. A cardok kibontva név- és elérhetőségmezőt, valamint névjegyfrissítés műveletet mutatnak. Az első kitöltött kapcsolat marad a Pánik mód tartaléka. | célzott source review + inline JS syntax | DONE |
| PATH-01 | 2026-10-11 Ösvény lépésállapot | Ösvény overview step-card CSS | A már elkezdett vagy lezárt, tehát nem szürke artworköt mutató lépéscardok az Őszinte önleltár aktív cardjával azonos halvány levendula felületet kapnak; nincs látható border, a content a felületen marad. | célzott CSS/source review; friss screenshot nem elérhető | PARTIAL |
| PAN-10 | 2026-10-11 Pánik glow finomítás | Alternative Pánik CTA CSS | A nagy Alternative „Segítség kell” kör körül erősebb, minden irányban azonos kiterjedésű, folyamatosan fade-outoló glow van; nincs külön pulzáló gyűrű. A kör és glow együtt pulzál. | célzott CSS/source review; friss screenshot nem elérhető | PARTIAL |
| PAN-11 | 2026-10-11 Pánik tartalék hívás/SMS | Pánik help renderer + közös contact resolver | A „Segítség kell” panel minden névvel kitöltött tartalék kapcsolattartót megjelenít, és mindegyikhez a meglévő Hívás és Üzenet útvonalakat használja. | inline JS/source contract + szintaxis | DONE |
| HIS-01 | Történetem §1–4 | history state/header | A jelenlegi layout érintetlen alternatívaként megmarad; a két kör gomb a `current/path-inspired` layoutot, illetve csak az új layout `roomy/compact` sűrűségét vezérli, korrekt ARIA-val. | `alternative_runtime_test.js` | DONE |
| HIS-02 | Történetem §5 | scoped History CSS | A path-inspired hero Ösvény-azonos geometriát, header-kompozíciót és fade-et használ, miközben a timelinehero és a rózsaszín–lila hangulat marad. | CSS/source teszt; Android screenshot kísérlet sikertelen (rendszer `screencap` tiltás) | PARTIAL |
| HIS-03 | Történetem §6–7 | Path-inspired history renderer | A „Jelenlegi időszak” card Ösvény current-card geometriájú: napok a medalionban, dátum/meta, 24/90 progress bar és chevron; a medalion nem index/pie/százalék. | `alternative_runtime_test.js` + source test | DONE |
| HIS-04 | Történetem §8 | Path-inspired history renderer/CSS | Minden korábbi fejezet Ösvény step-card geometriájú, a saját History assettel és tiszta nap-medallal; mindkét density mód csak a méretet/sűrűséget változtatja. | `alternative_runtime_test.js` + source test; screenshot nem elérhető | PARTIAL |
| HIS-05 | Történetem §2, §9–10 | shared history footer/actions | Az egyetlen meglévő „Utam számokban” footer mindkét layoutban megmarad és azonos expand/collapse, period-tap/detail, route és adatlogikát használ. | `history_reference_test.js` + source review | DONE |
| HIS-06 | 2026-10-10 Android screenshot regresszió | path-inspired History grid | Az alternatív Történetem lista a felső grid-sorban marad, az egyetlen közös „Utam számokban” footer pedig mindig az alsó grid-sorban marad; nem takarhatja ki a kártyákat. | `history_path_inspired_test.js` zöld; utólagos készülékes screenshot nem készíthető a rendszer `screencap` korlátozása miatt | PARTIAL |
| REG-01 | mindkét brief §8/§10 | full shell | 320/360/390–412 szélességen nincs overflow vagy eltakart CTA; cél a 412×892 screenshotos validáció, ismert renderer-korlát őszinte jelzésével. | 320–411px responsive CSS/static check; local HTTP OK; Android `screencap` hibával leállt | PARTIAL |

## Validációs napló

- 2026-10-10: célzott source/controller tesztek sikeresek: `panic_alternative_test.js`, `history_path_inspired_test.js`, `alternative_runtime_test.js`, `history_reference_test.js`, `path_shell_test.js`, `relapse_source_test.js`.
- 2026-10-10: inline JavaScript szintaxis és `git diff --check` sikeres.
- 2026-10-10: a helyi HTTP szerver válaszolt a `http://127.0.0.1:4173/app-shell/index.html` címen.
- 2026-10-10: az Androidos screenshot kísérlet a rendszer korlátozása miatt sikertelen: `screencap` státusz `-1`; ezért a képernyőképes elfogadási elemeket nem jelöltem késznek.
- 2026-10-10: a felhasználó két Android screenshotja igazolta a path-inspired History footer regresszióját: az abszolút lista miatt a footer az első, teljes magasságú grid-sorba auto-placementtel került. A lista ismét normál, első grid-soros elem, a footer explicit második soros; az új regressziós source-teszt zöld. A friss screenshotot a rendszer eszközoldali korlátozása miatt nem lehetett rögzíteni.
- 2026-10-11: célzott source review: az Alternative Sponzor nézet három eredeti gyorsművelete megmarad, a valós „Legközelebb” card rejtett, a teljes szélességű tartalék-kapcsolat card a közös `sponsor-details` rendererrel nyílik meg, és a két lista kompakt. A Pánik Alternative segítségköre továbbra sem használ külön gyűrűt; a saját fade-je és árnyéka erősebb.
- 2026-10-11: felhasználói Android-screenshot ellenőrzése után az Alternative Sponzor harmadik gyorsművelete ismét a kompakt „Legközelebb”; a „Beszélnem kell vele” rejtett. A két lista a fő konténer szabad magasságát rugalmasan tölti ki, ezért a lista alatti üres sáv megszűnik.
