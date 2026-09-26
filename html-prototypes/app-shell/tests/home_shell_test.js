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
  '<img class="home-hero-image" src="assets/home-hero.svg"',
  'data-component="daily-summary-card"',
  'data-component="checklist-sheet"',
  'class="bottom-nav"',
  'data-route="home"',
  'class="route-screen timeline-screen" id="home-statistics-timeline"',
  'class="route-screen milestone-screen" id="progress-milestones"',
  'data-screen="home-statistics-timeline"',
  'data-screen="progress-milestones"',
  'data-action="open-current-period-timeline"',
  'data-action="open-milestones"',
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
].forEach(expectContains);

assert.ok(fs.existsSync(heroAssetPath), 'the exact 8A/8B hero asset must live locally in the app-shell prototype');
assert.equal(
  crypto.createHash('sha256').update(fs.readFileSync(heroAssetPath)).digest('hex'),
  'ca7d0ef0156c39c2d6ebb09e838f5da1de3e86c7f45d20a428ecd595ae8a61a9',
  'the local hero asset must remain byte-identical to the approved 8A/8B asset',
);
assert.equal((html.match(/data-task-id="/g) || []).length, 3, '8B must contain exactly the three source-of-truth checklist rows');
assert.equal((html.match(/type="checkbox"/g) || []).length, 2, 'only the first two source-of-truth checklist rows are checkbox controls');
assert.equal((html.match(/<nav class="bottom-nav"/g) || []).length, 1, 'the visible reference bottom navigation must be present exactly once');
assert.equal((html.match(/class="bottom-nav-item"/g) || []).length, 5, 'bottom navigation must expose exactly five items');
const milestoneCardMarkup = html.match(/<button class="milestone-card"[\s\S]*?<\/button>/g) || [];
assert.equal(milestoneCardMarkup.length, 9, 'M must contain exactly nine milestone cards');
assert.equal(milestoneCardMarkup.filter((card) => card.includes('data-milestone-state="active"')).length, 5, 'M must retain its five active source cards');
assert.equal(milestoneCardMarkup.filter((card) => card.includes('data-milestone-state="inactive"')).length, 4, 'M must retain its four inactive source cards');
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
