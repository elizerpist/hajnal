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
includes('<div class="meetings-list-fixed">${stats}${tabs}</div><div class="meetings-list-scroll">', 'The List renderer must keep statistics and its filter outside the list scroll container');
includes("meetingsListTab: 'upcoming'", 'Meetings needs one controller-owned list-tab state');
includes("case 'select-meetings-list-tab': this.setMeetingsListTab", 'The list selector must transition through the existing controller');
includes('data-component="meetings-list-tabs"', 'The list card must expose its own dual selector directly below the hero card');
includes('data-meetings-list-tab="upcoming"', 'The selector must include the upcoming-meetings state');
includes('data-meetings-list-tab="past"', 'The selector must include the past-meetings state');
includes('setMeetingsListTab(tab)', 'The controller must own the upcoming/past selection');
includes('.meetings-list-tabs { min-height: 46px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 4px; padding: 4px; border: 1px solid var(--hairline); border-radius: 17px; background: var(--white);', 'The meetings selector rail must be white');
includes('.meetings-list-tab { min-width: 0; min-height: 38px; padding: 0 7px; border: 0; border-radius: 13px; background: var(--white);', 'Inactive meeting selector tabs must be white');
includes('.meetings-list-tab[aria-selected="true"] { background: var(--hajnal-purple); color: var(--white);', 'The active meetings selector tab must use the application purple');
includes('.meetings-inline-view-switch { position: absolute; z-index: 8; top: var(--main-menu-hero-view-switch-top);', 'Meetings selector must use the same shared vertical coordinate as History');
assert.doesNotMatch(html, /\.meetings-main-content\s*\{[^}]*animation:\s*meetings-body-in/, 'Meetings body must not slide upward when entering the route');
assert.doesNotMatch(html, /@keyframes meetings-body-in/, 'The obsolete Meetings route-entry keyframes must be removed');

const listRenderer = html.match(/        renderMeetingsListView\(\) \{[\s\S]*?\n        renderMeetingTimelineEvents\(\)/);
assert.ok(listRenderer, 'The list renderer must be present');
assert.doesNotMatch(listRenderer[0], /meetings-list-add|data-action="open-new-meeting"/, 'List mode must not create meetings; add actions belong exclusively to the calendar-day view');

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
