'use strict';

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const appShellPath = path.join(__dirname, '..', 'index.html');
const heroAssetPath = path.join(__dirname, '..', 'assets', 'home-hero.svg');

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
  'class HomeInteractionController',
  'setProgress(value',
  'settle(target)',
  'pointerdown',
  'pointermove',
  'pointerup',
  'pointercancel',
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
expectAbsent(/\bfetch\s*\(/, 'app shell must stay offline and must not call fetch');
expectAbsent(/https?:\/\//i, 'app shell must not depend on network URLs');
expectAbsent(/<link\b[^>]*href=/i, 'app shell must not load external stylesheets');
expectAbsent(/<script\b[^>]*\bsrc=/i, 'app shell must not load external scripts');
expectAbsent(/data-component="home-scene"/, 'the hand-recreated home scene must be removed in favor of the approved asset');
expectAbsent(/data-scene-object=/, 'the hand-recreated Panda/láma SVG objects must not remain');

console.log('PASS app-shell 8A → 8B contract');
