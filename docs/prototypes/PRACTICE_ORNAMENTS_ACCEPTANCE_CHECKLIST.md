# Gyakorlatok – `gyakorlat3.png` / `gyakorlat4.png` elfogadási lista

## Kötelező referencia és architektúra

- Kötelező, közvetlenül megnyitott referenciák: `/storage/emulated/0/hajnal/source of truth/gyakorlat3.png` és `/storage/emulated/0/hajnal/source of truth/gyakorlat4.png`.
- A jelenlegi gyakorlattulajdonos marad a `HomeInteractionController`: `state.practice`, `getActivePractice()`, `renderPracticeSheet()` és `renderHomePracticeBlock()`.
- Egyetlen, UI-származtatott assetfeloldó bővül: `practicePickerArtwork(practice)`. Ez szolgáltatja a meglévő ikont és az új kártya-/home-sheet-ornamentet is, ezért nem jön létre párhuzamos témakiosztás.
- A képernyő és a popup csak renderel; nem ír új tárolóba, route-ba vagy domain-állapotba.

## Elfogadási feltételek

| ID | Forrás | Kódterület | Elfogadási feltétel | Ellenőrzés | Státusz |
| --- | --- | --- | --- | --- | --- |
| PO-01 | User + `gyakorlat3.png` | practice manager markup/CSS | A szürke drag handle eltűnik; a címblokk és X megmarad. | Statikus teszt + screenshot. | DONE |
| PO-02 | User | `practiceRow()` | A listaelemek kizárólag névből és forrásból állnak; nincs harmadik előnézeti sor. | Statikus + browser DOM-teszt. | DONE |
| PO-03 | User | manager grid | Kizárólag a gyakorlatlista görgethető; a `＋ Új gyakorlat hozzáadása` CTA és a lótuszos lábléc a scrollon kívül, rögzítve marad. | Browser scroll-geometria. | DONE |
| PO-04 | User + `gyakorlat4.png` + Android screenshot | `renderHomePracticeBlock()` / home CSS | A főmenü felhúzott sheetjén az aktív gyakorlat szövege legfeljebb két sorban olvasható, balra igazítva jelenik meg, és a szürke forrás sora nem jelenik meg. | 412×892 browser screenshot + DOM teszt. | DONE |
| PO-05 | `gyakorlat3.png` §4–10 + user correction | local assets + renderer | Mind az öt témához helyi, átlátszó, gyakorlatonként dinamikus home-sheet-field PNG tartozik; a lista- és aktuális cardok nem használnak ornamentassetet. | RGBA fájl-inspekció + resolver/browser teszt. | DONE |
| PO-06 | User §§2–6 + Android screenshot | home CSS | Az ornament a teljes kijelölt sheet-felületen érzékelhető, homogén mezőként jelenik meg, és nem fed le olvashatatlanul címet, forrást, chevront vagy CTA-t. | 412×892 screenshot + pseudo-layer runtime teszt. | DONE |
| PO-07 | User | existing interaction controller | A részletek, szerkesztés, bezárás és meglévő perzisztencia továbbra is változatlanul működik. | Meglévő manager regressziós teszt. | DONE |
| PO-08 | User + `Screenshot_20261016-111241.png` | practice picker card CSS/markup | A practice picker aktuális és lista-kártyái nem kapnak dekoratív PNG-overlayt; a kártyák kizárólag a szükséges ikonra, szövegre és navigációra koncentrálnak. | Runtime DOM + 412×892 screenshot. | DONE |
| PO-09 | User + `Screenshot_20261016-111241.png` | `practicePickerArtwork()` + `.home-body::after` | A gyakorlat-specifikus sheet asset nem csak a peremeket, hanem a teljes rózsaszín sheetet kitöltő, egyenletesen szétterített, alacsony kontrasztú ornamentikát ad; a szöveg és a CTA olvasható marad. | RGBA asset-inspekció + 412×892 screenshot + browser runtime. | DONE |
| PO-10 | User: „kevesebb de nagyobb legyenek a minták” | `assets/practice/decor/*_sheet_field_v4.png` + resolver | Témánként legfeljebb hat, nagyobb, egymástól távol elhelyezett, halvány motívum díszíti a teljes sheetet; nincs sűrű, apró, ismétlődő mintázat. A cardok dekoráció nélküliek maradnak. | Asset-vizsgálat + resolver/runtime teszt + 412×892 screenshot. | DONE |
| PM-11 | Későbbi userpontosítás: a kártyára koppintás szerkeszt, kizárólag a chevron aktivál; nincs „Gyakorlat váltása” megerősítőnézet | `HomeInteractionController` / practice manager | A listakártya fő felülete a szerkesztőt nyitja; csak a jobb oldali chevron aktiválja a gyakorlatot, és automatikusan szünetelteti az előző aktívat. A visszavont megerősítőnézet sehol nem renderelődik. | Browser runtime + statikus regressziós teszt. | DONE |
| PM-12 | Későbbi userpontosítás: a hárompontos context menu megszűnik, a törlés a szerkesztőből érhető el | `practiceRow()`, szerkesztő-renderelő | A listakártyán nincs hárompontos gomb vagy dropdown; a kártyára koppintás megnyitja a szerkesztőt, amelyben a meglévő megerősítést használó Törlés művelet elérhető. | Browser runtime + 412×892 screenshot. | DONE |
