'use strict';

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const appShellPath = path.join(__dirname, '..', 'index.html');
const heroAssetPath = path.join(__dirname, '..', 'assets', 'home-hero.svg');
const milestoneAssets = Object.freeze({
  1: '13570cd6daecb1586ee842113dfdb22746c7a1e7582c1ec7a07d4ef16b4a955b',
  3: '824ce28182a7929f3488b293e69c4959a689859c98e4f3962aff3ddd47a292ef',
  7: '42ca641a610f690fbb040109386706f49a35070d56e65df9ed084da9d01b90a7',
  14: 'c6d01d96013aeada14a98519c4afa4d42c93cae6b5a03339ac8c5eef8e58f9ff',
  21: 'ca7d0ef0156c39c2d6ebb09e838f5da1de3e86c7f45d20a428ecd595ae8a61a9',
  30: 'ca7d0ef0156c39c2d6ebb09e838f5da1de3e86c7f45d20a428ecd595ae8a61a9',
  45: 'a5c74a71236a1265246e311a597349dc0600945d6d64fcd505aef322afa6a11f',
  60: '2f7ab47a49ef39f1ea7f74dffc9b203f11cd1345729c88eab8047b1ceb38c832',
  90: '1206a59df76d4a3e7f2808c8e56720d2db2e2c1dfd85e4ffe5895748d3193228',
});
const dailyImageSlideAssets = Object.freeze([
  ['assets/home-hero.svg', 'ca7d0ef0156c39c2d6ebb09e838f5da1de3e86c7f45d20a428ecd595ae8a61a9'],
  ['assets/milestones/milestone-60.svg', '2f7ab47a49ef39f1ea7f74dffc9b203f11cd1345729c88eab8047b1ceb38c832'],
  ['assets/milestones/milestone-45.svg', 'a5c74a71236a1265246e311a597349dc0600945d6d64fcd505aef322afa6a11f'],
]);

assert.ok(fs.existsSync(appShellPath), 'app-shell index.html must exist');

const html = fs.readFileSync(appShellPath, 'utf8');

assert.equal(
  (html.match(/--home-expanded-travel:\s*96px;/g) || []).length,
  2,
  'the expanded Home sheet and its summary card must retain the approved 96px swipe-up travel',
);

function expectContains(value) {
  assert.ok(html.includes(value), `app shell is missing ${value}`);
}

function expectAbsent(pattern, message) {
  assert.ok(!pattern.test(html), message);
}

[
  '<meta name="prototype-id" content="hajnal/app-shell">',
  '<meta name="prototype-status" content="variant">',
  '--screen-w: 412px;',
  '--screen-h: 892px;',
  'data-screen-state="8a-collapsed"',
  '8b-expanded',
  'class="home-illustration"',
  '<img class="home-hero-image" src="assets/backgrounds/index1.png"',
  'data-component="daily-summary-card"',
  'data-component="checklist-sheet"',
  'class="bottom-nav"',
  'data-route="home"',
  'class="route-screen milestone-screen" id="progress-milestones"',
  'class="route-screen history-screen" id="home-statistics"',
  'class="route-screen panic-screen" id="panic-root"',
  'class="route-screen daily-image-screen" id="daily-image"',
  'class="route-screen hurray-screen" id="checkin-clean"',
  'class="route-screen history-detail-screen" id="history-detail"',
  'class="route-screen panic-why-screen" id="panic-why-started"',
  'class="route-screen relapse-screen source-relapse-screen" id="checkin-relapse"',
  'class="route-screen survival-screen" id="panic-survival"',
  'class="route-screen panic-contacts-screen" id="panic-contacts"',
  'class="route-screen meetings-screen" id="meetings"',
  'class="route-screen initialization-screen" id="initialization"',
  'data-screen="progress-milestones"',
  'data-screen="home-statistics"',
  'data-screen="panic-root"',
  'data-screen="daily-image"',
  'data-screen="checkin-clean"',
  'data-action="open-daily-overview"',
  'data-action="open-milestones"',
  'data-action="open-history"',
  'data-action="open-panic"',
  'data-action="open-daily-image"',
  'data-action="return-to-milestones"',
  'data-action="mark-clean-today"',
  'data-action="open-history-detail"',
  'data-action="open-panic-motivation-sheet"',
  'data-action="open-panic-relapse"',
  'data-action="start-survival-pack"',
  'data-action="open-meetings"',
  'data-action="open-initialization"',
  'data-action="return-home"',
  'data-action="toggle-fullscreen"',
  'aria-label="Teljes képernyő"',
  'href="#icon-fullscreen"',
  'navigate(route)',
  'toggleFullscreen()',
  'document.documentElement.requestFullscreen()',
  'document.exitFullscreen()',
  "document.addEventListener('fullscreenchange'",
  'updateFullscreenButton()',
  "case 'open-milestones': this.navigate('milestones'); break;",
  "case 'open-history': this.navigate('history'); break;",
  "case 'open-panic': this.navigate('panic'); break;",
  "case 'open-daily-image': this.navigate('daily-image'); break;",
  "case 'return-to-milestones': this.navigate('milestones'); break;",
  "const NAVIGATION_ROUTES = new Set(['home', 'milestones', 'history', 'history-detail', 'timeline-event-detail', 'meetings', 'meeting-detail', 'path', 'panic', 'sponsor', 'sponsor-work', 'sponsor-next', 'sponsor-details']);",
  '--bottom-safe-area: env(safe-area-inset-bottom, 0px);',
  '--bottom-nav-h: calc(70px + var(--bottom-safe-area));',
  'background: #FFFCFC;',
  'html:fullscreen .app-frame',
  'height: 100dvh;',
  'html:fullscreen .home-illustration',
  "case 'mark-clean-today': this.markCleanToday(); break;",
  "case 'open-history-detail': this.openHistoryDetail('timeline', event.target.closest('[data-history-batch]')?.querySelector('h2')?.textContent); break;",
  "case 'open-panic-motivation-sheet': this.openPanicMotivationSheet(event.target.closest('[data-action=\"open-panic-motivation-sheet\"]')); break;",
  "case 'open-panic-relapse': this.navigate('panic-relapse'); break;",
  "case 'start-survival-pack': this.startSurvivalPack(); break;",
  "case 'open-meetings': this.openMeetings(event.target.closest('[data-meetings-origin]')?.dataset.meetingsOrigin || 'home'); break;",
  "case 'open-initialization': this.openInitialization('splash'); break;",
  'renderHistoryDetail()',
  'renderSurvival()',
  'renderInitialization()',
  'advanceSurvivalStep()',
  'class HomeInteractionController',
  'setProgress(value',
  'settle(target)',
  'pointerdown',
  'pointermove',
  'pointerup',
  'pointercancel',
  'this.summary.addEventListener(\'click\', (event) => this.consumeDragClick(event), true);',
  'this.ignoreNextClick = moved;',
  'consumeDragClick(event)',
  'event.stopImmediatePropagation();',
  "event.key === 'Escape'",
  'prefers-reduced-motion: reduce',
  'Főmenü',
  'Történetem',
  'Ösvény',
  'Gyűlések',
  'Szponzor',
  'data-component="home-practice-block"',
  'Amit gyakorlok',
  'Megfogalmazom',
  'type="checkbox"',
  'Segítség kell',
  'Nem vagy egyedül.',
  '15 perces túlélőcsomag',
  'Visszaestem',
  'Fejezeteim és emlékeim',
  'Jelenlegi időszak',
  'Utam számokban',
  'data-component="evening-wizard"',
  'Ma tiszta maradtam.',
  'Mi volt ma a legjobb?',
  'Napi reflexió',
  'A következő kapu már látszik.',
  'A türelem is haladás.',
  'Nem siettetjük a fényt.',
  'data-carousel-slide="30-1"',
  'data-carousel-slide="30-2"',
  'data-carousel-slide="30-3"',
].forEach(expectContains);

assert.ok(fs.existsSync(heroAssetPath), 'the exact 8A/8B hero asset must live locally in the app-shell prototype');
assert.equal(
  crypto.createHash('sha256').update(fs.readFileSync(heroAssetPath)).digest('hex'),
  'ca7d0ef0156c39c2d6ebb09e838f5da1de3e86c7f45d20a428ecd595ae8a61a9',
  'the local hero asset must remain byte-identical to the approved 8A/8B asset',
);
const homeMarkupStart = html.indexOf('<section class="home-body"');
const homeMarkupEnd = html.indexOf('<nav class="bottom-nav"', homeMarkupStart);
const homePracticeMarkup = html.slice(homeMarkupStart, homeMarkupEnd);
assert.match(homePracticeMarkup, /Amit gyakorlok/, '8B must contain the user-authored practice block');
assert.doesNotMatch(homePracticeMarkup, /home-daily-reflection|A mai napom/, 'The short Home sheet must not contain a second Daily reflection card');
assert.doesNotMatch(homePracticeMarkup, /Mai feladataim|data-task-id=|type="checkbox"/, '8B must not retain checklist rows after the practice replacement');
assert.match(html, /class="metric clean-days-metric"[^>]*data-action="open-daily-overview"[^>]*aria-label="Napi áttekintés megnyitása"/, 'Tiszta napok must open its compact daily-overview chooser rather than a direct route');
assert.match(html, /\.home-metrics\s*\{[^}]*min-height:\s*118px;[^}]*right:\s*58px;[^}]*left:\s*58px;[^}]*grid-template-columns:\s*minmax\(0,\s*1fr\)\s+1px\s+minmax\(0,\s*1fr\);/, 'The summary card must retain its exact two-column 118px geometry');
assert.match(html, /class="metric-goal"[^>]*>\/ 90 nap<\//, 'The 90-day target must share the count line rather than add a row');
assert.match(html, /class="metric-reflection-link"[^>]*>[^<]*<svg[^>]*>[^<]*<use href="#icon-heart"\/>[\s\S]*?Reflexió[\s\S]*?›/, 'The compact left summary must include one reflection affordance inside its existing tap target');
assert.match(html, /data-component="daily-overview-menu"[\s\S]*?role="dialog"[\s\S]*?Napi áttekintés/, 'A compact dismissible Daily overview overlay must remain locally owned by Home');
assert.match(html, /data-component="daily-overview-menu"[^>]*data-app-overlay-sheet/, 'The overview chooser must reuse the app overlay lifecycle instead of changing Home geometry');
assert.match(html, /handlePlatformBack\(\)[\s\S]*?isDailyOverviewMenuOpen\(\)[\s\S]*?closeDailyOverviewMenu\(\); return;/, 'Android Back must dismiss the overview chooser before navigating');
assert.match(html, /event\.key === 'Escape'[\s\S]*?isDailyOverviewMenuOpen\(\)[\s\S]*?closeDailyOverviewMenu\(\); return;/, 'Escape must dismiss the overview chooser before another Home action');
assert.match(html, /data-action="open-current-period-history-timeline"/, 'The overview must offer the canonical current-period Timeline');
assert.match(html, /data-action="open-daily-reflection-from-overview"/, 'The overview must offer the shared daily reflection wizard');
assert.doesNotMatch(html, /open-current-period-timeline|data-route="timeline"|home-statistics-timeline/, 'The retired placeholder Timeline route must not remain reachable or mounted');
assert.match(html, /\.home-body\s*\{[^}]*overflow:\s*hidden;/, 'The compact Home sheet must not become vertically scrollable');
assert.equal((html.match(/<nav class="bottom-nav"/g) || []).length, 1, 'the visible reference bottom navigation must be present exactly once');
assert.equal((html.match(/class="bottom-nav-item"/g) || []).length, 5, 'bottom navigation must expose exactly five items');
assert.equal((html.match(/data-panic-option="/g) || []).length, 0, 'The retired six-tile Pánik layout must not remain mounted');
assert.match(html, /panic-alternative-grid[\s\S]*?toggle-panic-next-meeting/, 'The single fixed Pánik layout must retain the three-tile alternative grid with focus-popup next-meeting access');
assert.equal((html.match(/class="route-screen meetings-screen"/g) || []).length, 1, 'source 31 must have one shared screen owner for Pánik and Gyűlések');
assert.equal((html.match(/data-history-detail-tab=/g) || []).length, 4, 'the two current-period submenus must have one visible hero switch and one retained shared workspace binding');
assert.ok(html.includes('const SURVIVAL_STEPS = Object.freeze(['), 'the survival renderer must own one structured source 18A–E data model');
assert.equal((html.match(/id: 'survival-/g) || []).length, 7, 'the survival data model must declare the seven interactive stations');
assert.equal((html.match(/<nav class="bottom-nav"/g) || []).length, 1, 'Pánik must reuse the one app-frame-owned BottomNav rather than render a route-local copy');
const historyScreenStart = html.indexOf('<section class="route-screen history-screen" id="home-statistics"');
const historyScreenEnd = html.indexOf('<section class="route-screen history-detail-screen"', historyScreenStart);
const historyScreenMarkup = html.slice(historyScreenStart, historyScreenEnd);
assert.equal((historyScreenMarkup.match(/data-component="history-full-page-pager"/g) || []).length, 1, 'History must expose its one full-page chapter pager');
assert.equal((historyScreenMarkup.match(/history-period-carousel/g) || []).length, 0, 'History must not retain the retired period-card carousel');
assert.equal((historyScreenMarkup.match(/data-component="history-workspace"/g) || []).length, 1, 'the Timeline and Calendar body must be in the History route');
const milestoneCardMarkup = html.match(/<button class="milestone-card"[\s\S]*?<\/button>/g) || [];
assert.equal(milestoneCardMarkup.length, 9, 'M must contain exactly nine milestone cards');
assert.equal(milestoneCardMarkup.filter((card) => card.includes('data-milestone-state="active"')).length, 5, 'M must retain its five active source cards');
assert.equal(milestoneCardMarkup.filter((card) => card.includes('data-milestone-state="inactive"')).length, 4, 'M must retain its four inactive source cards');
assert.equal(milestoneCardMarkup.filter((card) => card.includes('data-milestone-state="active"') && card.includes('data-action="open-daily-image"')).length, 5, 'every active M card must use the single daily-image action');
assert.equal(milestoneCardMarkup.filter((card) => card.includes('data-milestone-state="inactive"') && card.includes('data-action="open-daily-image"')).length, 0, 'inactive M cards must stay unbound from daily images');
assert.equal((html.match(/data-carousel-slide=/g) || []).length, 3, 'source Screen 9 must retain its three daily-image slides');
for (const [asset, expectedHash] of dailyImageSlideAssets) {
  const assetPath = path.join(__dirname, '..', asset);
  assert.ok(fs.existsSync(assetPath), `source Screen 9 asset ${asset} must exist locally`);
  assert.equal(
    crypto.createHash('sha256').update(fs.readFileSync(assetPath)).digest('hex'),
    expectedHash,
    `source Screen 9 asset ${asset} must remain byte-identical`,
  );
}
for (const [day, expectedHash] of Object.entries(milestoneAssets)) {
  const milestoneAssetPath = path.join(__dirname, '..', 'assets', 'milestones', `milestone-${day}.svg`);
  assert.ok(fs.existsSync(milestoneAssetPath), `M asset for day ${day} must exist locally`);
  assert.equal(
    crypto.createHash('sha256').update(fs.readFileSync(milestoneAssetPath)).digest('hex'),
    expectedHash,
    `M asset for day ${day} must remain byte-identical to its source-of-truth artwork`,
  );
}
expectAbsent(/\bfetch\s*\(/, 'app shell must stay offline and must not call fetch');
expectAbsent(/<link\b[^>]*href=/i, 'app shell must not load external stylesheets');
expectAbsent(/<script\b[^>]*\bsrc=/i, 'app shell must not load external scripts');
expectAbsent(/data-component="home-scene"/, 'the hand-recreated home scene must be removed in favor of the approved asset');
expectAbsent(/data-scene-object=/, 'the hand-recreated Panda/láma SVG objects must not remain');
expectAbsent(/if \(event\.target\.closest\('button'\)\) return;/, 'a card swipe must not be rejected merely because it starts on a child button');
expectAbsent(/aria-label="Értesítések"/, 'the Home upper-right bell control must be replaced by the fullscreen control');
expectAbsent(/icon-bell/, 'the obsolete Home bell icon must not remain in the app-shell sprite');
expectAbsent(/data:image\//, 'app-shell source artwork must be local assets, not inline data URIs');

console.log('PASS app-shell 8A → 8B contract');
