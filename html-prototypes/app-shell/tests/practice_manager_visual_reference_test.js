'use strict';

/* Visual contract for the required gyakorlat2.png Practice Picker reproduction. */
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
const managerStart = html.indexOf('renderPracticeSheet() {');
const managerEnd = html.indexOf('\n        getPracticeSourceCandidates() {', managerStart);
const manager = html.slice(managerStart, managerEnd);

assert.ok(managerStart >= 0 && managerEnd > managerStart, 'The existing controller owns one renderPracticeSheet manager renderer');
assert.match(html, /practicePickerArtwork\(practice\)/, 'Active and list cards must use one shared practice-artwork resolver');
assert.doesNotMatch(manager, /practice-picker-handle/, 'The manager must not retain the retired gray drag handle');
assert.match(manager, /practicePopupHeader\('Ezt szeretném gyakorolni', 'Válassz a gyakorlataid közül, vagy hozz létre újat\.'\)/, 'The reference title and subtitle must be rendered verbatim');
assert.match(manager, /practice-current-card/, 'The fixed current-practice card must be rendered');
assert.match(manager, /practice-current-card[\s\S]*?data-action="edit-practice"/, 'The complete current-practice card must open the editor');
assert.doesNotMatch(html, /practice-current-action|open-practice-details|openPracticeDetails|detailPracticeId|practicePopupView\s*=\s*'details'|open-practice-history|renderPracticeDetailsHistory/, 'The retired Details CTA, renderer, history action and state must not remain beside the editor');
assert.match(manager, /practice-list-shell[\s\S]*?<h3>Gyakorlataim<\/h3>[\s\S]*?practice-list-scroll/, 'The fixed list heading must be above the dedicated list scroller');
assert.match(manager, /const footer = '<footer class="practice-picker-footer"/, 'The reference footer decoration remains part of the manager renderer');
assert.match(manager, /practice-list-scroll[\s\S]*?<\/div><footer class="practice-manager-footer"><button class="practice-manager-create"[\s\S]*?\$\{footer\}<\/footer>/, 'The add action and footer decoration must be fixed outside the list scroller');
assert.match(html, /practice-list-card[\s\S]*?practice-list-artwork[\s\S]*?<strong>[\s\S]*?<small>[\s\S]*?practice-list-chevron/, 'Every list card needs artwork, two-level copy and a chevron');
assert.doesNotMatch(html.slice(html.indexOf('practiceRow(practice) {'), managerStart), /<em>/, 'List cards must not render the retired third preview line');
assert.doesNotMatch(manager, /data-practice-filter-select|Szüneteltetett|Megőrzött|practice-list-filter-select|practice-row-activate|practice-row-menu/, 'The manager must not retain state filters, activation controls or context-menu controls');
assert.doesNotMatch(html, /replacementCandidate|Gyakorlat váltása|confirm-practice-replace|cancel-practice-replace/, 'Selecting a practice must not open the retired replacement-confirmation screen');
assert.doesNotMatch(html, /practice-list-menu-trigger|toggle-practice-menu|practice-list-context-menu|contextMenuPracticeId/, 'The retired three-dot practice dropdown and its view state must be removed');
assert.match(html, /practice-list-card[\s\S]*?practice-list-edit[\s\S]*?data-action="edit-practice"[\s\S]*?practice-list-chevron[\s\S]*?data-action="activate-practice"/, 'The card body must open editing while the dedicated right-side chevron only activates the practice');
assert.match(html, /editor\.mode === 'edit'[\s\S]*?practice-editor-delete[\s\S]*?data-action="delete-practice"/, 'The editor must expose deletion for an existing practice');
assert.match(html, /\.practice-list-shell\s*\{[\s\S]*?min-height:\s*0/, 'The single list container must participate in the constrained popup grid');
assert.match(html, /\.practice-list-scroll\s*\{[\s\S]*?overflow-y:\s*auto/, 'Only the list body may scroll');
assert.match(html, /\.practice-manager-footer\s*\{[\s\S]*?overflow:\s*hidden/, 'The manager footer must form a fixed non-scrolling region');
assert.match(html, /\.practice-manager-create\s*\{[\s\S]*?border:\s*0/, 'The add action must not retain a dashed or heavy border');
assert.doesNotMatch(html, /cardDecoration/, 'Practice cards must not retain decorative asset overlays');
assert.match(html, /sheetDecoration/, 'One practice resolver must expose home-sheet decoration assets');
assert.match(html, /_sheet_field_v4\.png/, 'The shared resolver must select the sparse, large-motif v4 sheet field assets');

for (const asset of ['practice_sprout.png', 'practice_heart_blossom.png', 'practice_wave.png', 'practice_sunrise.png', 'practice_moon.png']) {
  const target = path.join(root, 'assets', 'practice', asset);
  assert.ok(fs.existsSync(target), `Generated local practice artwork is required: ${asset}`);
  assert.ok(fs.statSync(target).size > 10_000, `Generated artwork cannot be a placeholder: ${asset}`);
}

for (const theme of ['heart', 'wave', 'sprout', 'sunrise', 'moon']) {
  const target = path.join(root, 'assets', 'practice', 'decor', `${theme}_sheet_field_v4.png`);
  assert.ok(fs.existsSync(target), `Generated sparse, large-motif sheet field is required: ${theme}`);
  assert.ok(fs.statSync(target).size > 10_000, `Generated v4 sheet field cannot be a placeholder: ${theme}`);
}

console.log('PASS gyakorlat2 practice-picker visual contract');
