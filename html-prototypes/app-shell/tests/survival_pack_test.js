'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const appRoot = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(appRoot, 'index.html'), 'utf8');

function requireSource(fragment, message) {
  assert.ok(html.includes(fragment), message || `Missing source contract: ${fragment}`);
}

function requirePattern(pattern, message) {
  assert.match(html, pattern, message);
}

const expectedSteps = [
  'survival-stop',
  'survival-breathe',
  'survival-water',
  'survival-environment',
  'survival-connect',
  'survival-wait',
  'survival-reassess',
];

requireSource('const SURVIVAL_DURATION_SECONDS = 900;', 'the whole survival session must use one 900-second duration constant');
requireSource("const SURVIVAL_SESSION_STORAGE_KEY = 'hajnal.survival-session.v1';", 'survival needs a versioned, local persistence boundary');
requireSource("const FREE_NOTE_STORAGE_KEY = 'hajnal.free-notes.v1';", 'the optional writing must use a reusable free-note store');
assert.equal((html.match(/id: 'survival-/g) || []).length, 7, 'the data model must declare exactly seven survival stations');
expectedSteps.forEach((id) => requireSource(`id: '${id}'`, `${id} must be a declared station`));
assert.doesNotMatch(html, /id: 'survival-note'/, 'writing is an optional free note, not a survival station/category');

[
  'createSurvivalSession(',
  'isValidSurvivalSession(',
  'restoreSurvivalState()',
  'persistSurvivalState()',
  'survivalRemainingSeconds()',
  'updateSurvivalSession(',
  'toggleSurvivalBreathing()',
  'selectSurvivalChoice(',
  'openSurvivalNoteSheet(',
  'saveSurvivalFreeNote()',
  'startSurvivalReassessment(',
  'selectSurvivalOutcome(',
].forEach((symbol) => requireSource(symbol, `${symbol} must be controller-owned`));

requirePattern(/Math\.max\(\s*0,\s*SURVIVAL_DURATION_SECONDS\s*-\s*this\.survivalElapsedSeconds\(\)/, 'remaining time must derive from one real elapsed clock and never go negative');
requirePattern(/source:\s*'survival-pack'/, 'saved writing must retain only a non-routing source context');
requirePattern(/type:\s*'free'/, 'saved writing must be a generic free note');
requireSource('data-action="open-panic-help-sheet"', 'every station keeps the existing help-sheet action available');
requireSource('data-action="toggle-survival-breathing"', 'breathing must be truly pausable');
requireSource('data-action="select-survival-choice"', 'water and environment choices must be explicit, optional choices');
requireSource('data-action="open-survival-note-sheet"', 'the waiting station must open a real note editor');
requireSource('data-action="survival-reassess-now"', 'the user can reassess before the timer expires');
requireSource('data-action="select-survival-outcome"', 'reassessment must have explicit outcome choices');
requireSource('data-action="survival-still-hard-wait"', 'still-hard must continue at the waiting station, not restart earlier work');
assert.doesNotMatch(html, /session\.step\s*=\s*Math\.max\(0,\s*SURVIVAL_STEPS\.length\s*-\s*2\)/, 'the retired still-hard behavior may not rewind the whole pack');
const visualAssets = [
  'survival_stop_bg.png',
  'survival_breathe_bg.png',
  'survival_water_bg.png',
  'survival_environment_bg.png',
  'survival_contact_bg.png',
  'survival_wait_bg.png',
  'survival_reassess_bg.png',
];
visualAssets.forEach((asset) => {
  requireSource(`assets/survival/${asset}`, `each survival station must bind its own local decorative asset: ${asset}`);
  assert.ok(fs.existsSync(path.join(appRoot, 'assets', 'survival', asset)), `missing local survival visual asset ${asset}`);
});
requireSource('class="survival-artwork"', 'survival artwork must be an explicit, pointer-inert rendering layer');
requirePattern(/\.survival-artwork\s*\{[^}]*pointer-events:\s*none/, 'decorative survival artwork must never block an action');
requireSource('15 perces túlélőcsomag', 'the fixed survival header must name the current support flow');
requireSource('data-survival-step-count', 'the visible header must expose the current station count');
requireSource('data-survival-header-remaining', 'the visible header must expose the remaining time independently of the step count');
requirePattern(/\.survival-shell\s*\{[^}]*grid-template-rows:\s*auto\s+minmax\(0,\s*1fr\)\s+auto/, 'the survival shell must reserve header, flexible stage and footer grid zones');
requirePattern(/\.survival-header\s*\{[^}]*position:\s*relative/, 'the header must remain in the layout rather than being positioned above the viewport');

[
  '.survival-shell',
  '.survival-header',
  '.survival-footer',
  '.survival-action { width: 100%; min-height: 54px;',
  '.survival-breath-orb',
  '.survival-note-sheet-host',
  '@media (prefers-reduced-motion: reduce)',
].forEach((fragment) => requireSource(fragment, `missing responsive survival visual contract: ${fragment}`));

console.log('PASS seven-station survival-pack source contract');
