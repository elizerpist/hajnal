# Történetem hero – elfogadási ellenőrzőlista

| ID | Forrás | Kódterület | Elfogadási feltétel | Ellenőrzés | Állapot |
| --- | --- | --- | --- | --- | --- |
| HHR-01 | Felhasználó: „a történetem menu tetejére a hero hasonló legyen mint a gyűlések, generálj újat” | `assets/history-chapter-hero/current_richer.png` | Új, helyi, szöveg és UI nélküli pasztelles tájillusztráció tölti ki a jelenlegi időszak hero-terét; a Gyűlésekhez illő, de saját kompozíció. | PNG metaadat és vizuális asset-inspekció. | DONE |
| HHR-02 | Ugyanaz | `HISTORY_PERIODS`, `HISTORY_CURRENT_PERIOD_HERO_ASSET` | Kizárólag a jelenlegi időszak a gazdagabb hero-assetet használja; a korábbi időszakok saját képei megmaradnak. | `history_chapter_hero_redesign_test.js`. | DONE |
| HHR-03 | Meglévő History architektúra | `renderHistoryPagerSlide()`, meglévő `.history-period-pager-art` | A meglévő hero-fade, period swipe, hero-card geometria és scroll ownership változatlan; nem jön létre második hero-rendszer. | Forrás- és célzott kontraktteszt-inspekció. | DONE |
| HHR-04 | Vizuális ellenőrzési követelmény | Futó app, 412 × 892 viewport | A jelenlegi Történetem hero a teljes renderelt képernyőn is teltebb, olvasható és a kártyát nem zavarja. | Chromium screenshot: `/data/data/com.termux/files/home/.cache/hajnal-history-current-hero/history-pager-0-percent.png`. | DONE |
