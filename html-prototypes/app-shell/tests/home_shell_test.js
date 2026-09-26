'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const appShellPath = path.join(__dirname, '..', 'index.html');

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
  'width: 412px;',
  'height: 892px;',
  'data-screen-state="8a-collapsed"',
  '8b-expanded',
  'data-component="home-scene"',
  'data-component="daily-summary-card"',
  'data-component="checklist-sheet"',
  'data-component="bottom-navigation"',
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
  'data-task-id="write"',
  'data-task-id="meeting"',
  'data-task-id="gratitude"',
  'type="checkbox"',
  'Segítség kell',
].forEach(expectContains);

assert.equal((html.match(/type="checkbox"/g) || []).length, 4, 'checklist must expose exactly four native task controls in the first slice');
assert.equal((html.match(/class="bottom-nav-item"/g) || []).length, 5, 'bottom navigation must expose exactly five items');
expectAbsent(/\bfetch\s*\(/, 'app shell must stay offline and must not call fetch');
expectAbsent(/https?:\/\//i, 'app shell must not depend on network URLs');
expectAbsent(/<link\b[^>]*href=/i, 'app shell must not load external stylesheets');
expectAbsent(/<script\b[^>]*\bsrc=/i, 'app shell must not load external scripts');
expectAbsent(/<img\b/i, 'home scene must be composed from lightweight inline DOM/SVG objects, not image screenshots');

console.log('PASS app-shell 8A → 8B contract');
