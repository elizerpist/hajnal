'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

function includes(value, message) {
  assert.ok(html.includes(value), message || `Missing ${value}`);
}

// This source-level boundary makes the existing meeting collection the only
// meeting source, while the redesigned UI reads its derived occurrences.
includes("const MEETINGS_HERO_ASSET = 'assets/hero/meetings_hero_soft.png'", 'Meetings must own one generated hero asset resolver');
assert.ok(fs.statSync(path.join(__dirname, '..', 'assets', 'hero', 'meetings_hero_soft.png')).size > 0, 'The generated Meetings hero asset must be present');
includes('function meetingOccursOnDate(', 'A single reusable weekly-occurrence resolver is required');
includes('function meetingInstancesForDate(', 'Calendar and list modes must share one instance resolver');
includes('data-component="meetings-hero"', 'Meetings must expose the source-of-truth hero surface');
includes('data-component="meetings-view-switch"', 'Meetings must use the same floating icon-switch primitive as History');
includes('data-action="switch-meetings-view" data-meetings-view="list"', 'The floating switch must select List mode');
includes('data-action="switch-meetings-view" data-meetings-view="calendar"', 'The floating switch must select Calendar mode');
includes('data-component="meeting-form-sheet"', 'New meeting creation must use a reusable slide-up sheet');
includes('meetingDetailOrigin', 'Meeting child navigation must preserve the sibling view it came from');
includes('data-component="meeting-list-statistics"', 'Statistics must have a dedicated List-mode surface');
includes('data-component="meeting-note-card"', 'Meeting child pages must render one editable note card');
includes('data-meeting-recurrence', 'The meeting sheet must expose recurrence editing');
includes('openMeetingFormSheet(', 'Meeting creation and editing must share one sheet controller');
includes('closeMeetingDetail()', 'The meeting child must have an explicit return path to its sibling mode');

// The calendar and the fixed List summary begin at precisely the same vertical
// landmark as History's current-period card.  List mode must then delegate the
// only vertical scroll to its cards, never to that summary card.
includes('--history-current-card-top: 151px', 'History must publish its current-period card top as a shared layout token');
includes('top: var(--history-current-card-top)', 'History must consume the shared current-period card top token');
includes('--meetings-body-top: var(--history-current-card-top)', 'Meetings must reuse History’s card-top token for its body start');
includes('.meetings-main-content[data-meetings-view="list"]', 'List mode needs its own fixed-header/grid layout');
includes('.meetings-list-fixed', 'List statistics need a non-scrolling fixed wrapper');
includes('.meetings-list-scroll', 'List cards need the dedicated vertical scroll owner');
includes('<div class="meetings-list-fixed">${stats}</div><div class="meetings-list-scroll">', 'The List renderer must place statistics outside the list scroll container');

const newMeetingSource = html.match(/        openNewMeeting\([\s\S]*?\n        openMeetingEditor/);
assert.ok(newMeetingSource, 'The new-meeting route adapter must be present');
assert.match(newMeetingSource[0], /openMeetingFormSheet/, 'New meetings must open in the shared sheet');
assert.doesNotMatch(newMeetingSource[0], /navigate\('meeting-editor'\)/, 'New meetings must not navigate to the legacy fullscreen editor');

const helperSource = html.match(/      function normalizedMeetingRecurrence[\s\S]*?\n      function createPractice/);
assert.ok(helperSource, 'Meeting occurrence helpers must be implemented together');
const helpers = new Function(`${helperSource[0].replace(/\n      function createPractice$/, '')}\nreturn { meetingOccursOnDate, meetingInstancesForDate, meetingOccurrenceKey };`)();

const weekly = { id: 'weekly-tuesday', date: '2026-10-06', recurrence: { kind: 'weekly', weekdays: [2] } };
assert.equal(helpers.meetingOccursOnDate(weekly, '2026-10-13'), true, 'Weekly meeting must recur on the configured weekday after its first date');
assert.equal(helpers.meetingOccursOnDate(weekly, '2026-10-14'), false, 'Weekly meeting must not appear on a different weekday');
assert.equal(helpers.meetingOccursOnDate(weekly, '2026-09-29'), false, 'Weekly meeting must not appear before its series starts');
assert.deepEqual(
  helpers.meetingInstancesForDate([weekly, { id: 'once', date: '2026-10-13', recurrence: { kind: 'once', weekdays: [] } }], '2026-10-13').map((item) => item.sourceId),
  ['weekly-tuesday', 'once'],
  'Calendar and List projections must expose original source IDs without cloning meeting state',
);
assert.equal(helpers.meetingOccurrenceKey({ sourceId: 'weekly-tuesday', occurrenceDate: '2026-10-13' }), 'weekly-tuesday:2026-10-13', 'An occurrence needs a stable, source-derived ID');

console.log('PASS meetings redesign domain and UI boundary contract');
