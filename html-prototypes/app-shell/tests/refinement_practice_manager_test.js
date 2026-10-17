'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /practicePopupView:\s*null/, 'Practice popup view state must have one controller owner');
assert.match(html, /class="practice-focus-dialog[^"]*"[^>]*aria-modal="true"/, 'Practice manager must use one centered focus dialog');
assert.match(html, /data-component="practice-manager"/, 'Practice manager must render its dedicated view');
assert.match(html, /data-action="open-practice-manager"/, 'The Home practice block must open the manager, not a legacy detail sheet');
assert.match(html, /data-action="save-practice-later"/, 'The editor must allow saving a paused practice');
assert.match(html, /data-action="delete-practice"/, 'The manager must expose explicit practice deletion');
assert.match(html, /data-action="select-practice-source"/, 'The editor must be able to select an Ösvény source inside the popup');
assert.match(html, /getPracticeSourceCandidates\(\)\s*\{[\s\S]*?stepHistory/, 'The source picker must include saved Path runs, not only the current view');
assert.match(html, /practices:\s*\[\],[\s\S]*?activePracticeId:\s*null/, 'A fresh manager must not invent a demonstration exercise');
assert.match(html, /editorDraft/, 'Closing an unfinished editor must preserve a local draft');
assert.match(html, /practicePickerArtwork\(practice\)/, 'The new picker must resolve its generated artwork through one controller owner');
assert.doesNotMatch(html, /data-practice-filter-select/, 'The reference picker must not retain the retired status filter control');
assert.doesNotMatch(html, /align-items:\s*end;[\s\S]*?\.practice-sheet/, 'The retired bottom-aligned practice sheet must not remain active');

assert.match(html, /data-action="open-sponsor-next-native-time-picker"/, 'Sponsor calendar must open the native time picker from its calendar card');
assert.doesNotMatch(html, /data-component="sponsor-calendar-time-wheel"/, 'The retired Sponsor next time wheel must be removed');
assert.match(html, /data-history-calendar-view-switch/, 'History grid must own a Grid/Rail switch');
assert.match(html, /data-action="select-history-calendar-grid-date"/, 'Grid day taps must select in place rather than route to Rail');
assert.match(html, /resetDailyReflectionWizard\(\)/, 'Daily reflection needs an explicit new-entry reset path');
assert.match(html, /data-daily-practice-note/, 'The practice reflection stage must offer one optional note field');
assert.match(html, /updateDailyPracticeNote\(target\.value\)/, 'The optional practice note must use the existing daily-reflection persistence owner');

console.log('PASS refinement and practice-manager contract');
