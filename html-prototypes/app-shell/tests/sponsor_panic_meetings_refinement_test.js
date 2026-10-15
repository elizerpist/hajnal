'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

function includes(source, message) {
  assert.ok(html.includes(source), message || `Missing ${source}`);
}

// Sponsor details: one controller-owned availability value, rendered inline,
// with native browser controls supplying Android's date/time pickers.
includes('renderSponsorAvailabilityInline()', 'Sponsor details must render the weekly availability editor inline');
includes('data-component="sponsor-availability-day-rail"', 'The inline editor needs the seven-day compact rail');
includes('data-action="toggle-sponsor-inline-anytime"', 'Bármikor must be an inline, persisted mode toggle');
includes('data-action="toggle-sponsor-inline-day"', 'The selected day must have its own inline enabled toggle');
includes('data-action="open-sponsor-inline-time-picker"', 'Styled time fields must delegate to native time inputs');
includes('data-sponsor-inline-native-time', 'The native time input must remain attached to the styled field');
includes('data-action="open-sponsor-since-native-picker"', 'The sponsor-since row must open the native date picker directly');
includes('data-sponsor-since-native', 'The direct native date input must be present');
assert.doesNotMatch(html, /data-action="open-sponsor-availability"/, 'The former availability sheet entrypoint must be removed');
assert.doesNotMatch(html, /data-action="open-sponsor-since-calendar"/, 'The former sponsor-since calendar route entrypoint must be removed');
assert.doesNotMatch(html, /sponsor-availability-sheet/, 'The former availability sheet styles and host must be removed');

// Panic mode is intentionally one focused arrangement, and the next meeting
// expands in place without navigating to the organiser screen.
includes('panicNextMeetingOpen: false', 'Panic needs controller-owned inline meeting-card state');
includes('data-action="toggle-panic-next-meeting"', 'The alternative quick action must toggle the inline meeting card');
includes('data-component="panic-next-meeting-slot"', 'The inline card needs a stable layout slot beneath the three tiles');
includes('renderPanicNextMeetingPanel()', 'Panic must update only its inline meeting panel');
includes('panicRelevantMeetingInstances(', 'Panic must derive the next meeting from shared recurring instances');
includes('data-action="panic-next-meeting-plan"', 'The panic card must use shared occurrence attendance');
assert.doesNotMatch(html, /data-action="toggle-panic-variant"/, 'The removed Panic layout switch must not remain interactive');
assert.doesNotMatch(html, /renderPanicClassic\(/, 'The static six-tile Panic layout must be removed');
const openMeetingMapMethod = html.match(/openMeetingMap\(id\) \{([\s\S]*?)\n        \}\n        createMeetingDraft/);
assert.ok(openMeetingMapMethod, 'The shared meeting map method must remain available');
assert.doesNotMatch(openMeetingMapMethod[1], /navigator\.geolocation\.getCurrentPosition/, 'Meeting directions must open immediately without waiting for location');
includes('data-meeting-occurrence-date="${occurrenceDate}" data-meeting-attendance="${status.id}"', 'Meeting-detail attendance must target the selected recurring occurrence');

// Sponsor's next-conversation screen reuses the Meetings view-switch/calendar
// grammar and keeps its shared BottomNav visible.
includes('data-component="sponsor-next-view-switch"', 'Sponsor next must expose the same floating list/calendar switch');
includes('data-action="switch-sponsor-next-view"', 'Sponsor next view changes must be controller-owned');
includes('sponsorNextView:', 'The selected Sponsor next view must be held in controller state');
includes('renderSponsorNextListView()', 'The list view must render its fixed upcoming card and scrollable past cards');
includes('renderSponsorConversationCardsForDate(', 'Calendar mode must render only selected-day conversation cards');
includes('data-component="sponsor-next-upcoming-card"', 'List mode requires its fixed hero-under upcoming card');

console.log('PASS sponsor, panic and next-meeting refinement source contract');
