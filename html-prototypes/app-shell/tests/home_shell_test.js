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
  'class="route-screen timeline-screen" id="home-statistics-timeline"',
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
  'data-screen="home-statistics-timeline"',
  'data-screen="progress-milestones"',
  'data-screen="home-statistics"',
  'data-screen="panic-root"',
  'data-screen="daily-image"',
  'data-screen="checkin-clean"',
  'data-action="open-current-period-timeline"',
  'data-action="open-milestones"',
  'data-action="open-history"',
  'data-action="open-panic"',
  'data-action="open-daily-image"',
  'data-action="return-to-milestones"',
  'data-action="mark-clean-today"',
  'data-action="open-history-detail"',
  'data-action="open-panic-why"',
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
  "case 'open-current-period-timeline': this.navigate('timeline'); break;",
  "case 'open-milestones': this.navigate('milestones'); break;",
  "case 'open-history': this.navigate('history'); break;",
  "case 'open-panic': this.navigate('panic'); break;",
  "case 'open-daily-image': this.navigate('daily-image'); break;",
  "case 'return-to-milestones': this.navigate('milestones'); break;",
  'data-component="panic-bottom-navigation"',
  '--bottom-safe-area: env(safe-area-inset-bottom, 0px);',
  '--bottom-nav-h: calc(70px + var(--bottom-safe-area));',
  'background: #FFFCFC;',
  'html:fullscreen .app-frame',
  'height: 100dvh;',
  'html:fullscreen .home-illustration',
  "case 'mark-clean-today': this.navigate('clean-reward'); break;",
  "case 'open-history-detail': this.openHistoryDetail('overview'); break;",
  "case 'open-panic-why': this.navigate('panic-why'); break;",
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
  'data-task-id="sponsor-call"',
  'data-task-id="meeting"',
  'data-task-id="evening-checkin"',
  'Hívd fel a szponzorod',
  'Menj el egy meetingre',
  'Esti check-in',
  'data-task-icon="phone"',
  'data-task-icon="people"',
  'data-task-icon="message"',
  'type="checkbox"',
  'Segítség kell',
  'Nem vagy egyedül.',
  'Hívd a szponzorod',
  'Hívd a tartalék kapcsolattartót',
  '15 perces túlélőcsomag',
  'Olvasd el, miért kezdted el',
  'Keresd meg a következő meetinget',
  'Visszaestem',
  'Fejezeteim és emlékeim',
  'Jelenlegi időszak',
  'Utam számokban',
  'Megcsináltad!',
  '25. nap',
  'Szeretnél pár percet szánni',
  'Most, 2 percet rászánok',
  'assets/milestones/milestone-45.svg',
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
assert.equal((html.match(/data-task-id="/g) || []).length, 3, '8B must contain exactly the three source-of-truth checklist rows');
const homeMarkupStart = html.indexOf('<section class="home-body"');
const homeMarkupEnd = html.indexOf('<nav class="bottom-nav"', homeMarkupStart);
const homeChecklistMarkup = html.slice(homeMarkupStart, homeMarkupEnd);
assert.equal((homeChecklistMarkup.match(/type="checkbox"/g) || []).length, 2, 'only the first two source-of-truth checklist rows are checkbox controls');
assert.equal((html.match(/<nav class="bottom-nav"/g) || []).length, 1, 'the visible reference bottom navigation must be present exactly once');
assert.equal((html.match(/class="bottom-nav-item"/g) || []).length, 5, 'bottom navigation must expose exactly five items');
assert.equal((html.match(/data-panic-option="/g) || []).length, 6, 'source 16 must expose its six panic quick options');
assert.equal((html.match(/class="route-screen meetings-screen"/g) || []).length, 1, 'source 31 must have one shared screen owner for Pánik and Gyűlések');
assert.equal((html.match(/data-history-detail-tab=/g) || []).length, 2, 'source 8D and 8F must be two submenus of one period-detail screen');
assert.ok(html.includes('const SURVIVAL_STEPS = Object.freeze(['), 'the survival renderer must own one structured source 18A–E data model');
assert.equal((html.match(/id: 'survival-/g) || []).length, 5, 'the survival data model must retain all five source 18A–E states');
assert.equal((html.match(/data-component="panic-bottom-navigation"/g) || []).length, 1, 'source 16 must expose one shared bottom navigation');
const historyScreenStart = html.indexOf('<section class="route-screen history-screen" id="home-statistics"');
const historyScreenEnd = html.indexOf('<section class="route-screen history-detail-screen"', historyScreenStart);
const historyScreenMarkup = html.slice(historyScreenStart, historyScreenEnd);
assert.equal((historyScreenMarkup.match(/data-history-batch="/g) || []).length, 4, 'the source History screen must expose its four vertical sobriety periods');
assert.equal((historyScreenMarkup.match(/data-history-stat="/g) || []).length, 5, 'the source History lower section must expose its five compact measures');
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
expectAbsent(/https?:\/\//i, 'app shell must not depend on network URLs');
expectAbsent(/<link\b[^>]*href=/i, 'app shell must not load external stylesheets');
expectAbsent(/<script\b[^>]*\bsrc=/i, 'app shell must not load external scripts');
expectAbsent(/data-component="home-scene"/, 'the hand-recreated home scene must be removed in favor of the approved asset');
expectAbsent(/data-scene-object=/, 'the hand-recreated Panda/láma SVG objects must not remain');
expectAbsent(/if \(event\.target\.closest\('button'\)\) return;/, 'a card swipe must not be rejected merely because it starts on a child button');
expectAbsent(/aria-label="Értesítések"/, 'the Home upper-right bell control must be replaced by the fullscreen control');
expectAbsent(/icon-bell/, 'the obsolete Home bell icon must not remain in the app-shell sprite');
expectAbsent(/data:image\//, 'app-shell source artwork must be local assets, not inline data URIs');

console.log('PASS app-shell 8A → 8B contract');
