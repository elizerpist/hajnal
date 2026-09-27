'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
const historyDetailStart = html.indexOf('<section class="route-screen history-detail-screen"');
const eventDetailStart = html.indexOf('<section class="route-screen timeline-event-detail-screen"');
const historyDetail = html.slice(historyDetailStart, eventDetailStart);
const calendarGridStart = historyDetail.indexOf('data-history-calendar-grid-view');
const calendarRailStart = historyDetail.indexOf('data-history-calendar-rail-view');
const calendarGrid = historyDetail.slice(calendarGridStart, calendarRailStart);
const calendarRail = historyDetail.slice(calendarRailStart);

assert.ok(historyDetailStart >= 0, 'the existing current-period route must remain the calendar state owner');

[
  'class="calendar-period-hero"',
  'data-component="calendar-hero-image"',
  'data-component="calendar-hero-variant-toggle"',
  'data-history-presentation-surface="calendar"',
  'data-component="calendar-integrated-grid-slot"',
  'data-component="calendar-integrated-selected-slot"',
  "calendar: { heroVariant: 'large', metricsExpanded: false }",
  "const variants = surface === 'calendar' ? ['large', 'compact', 'integrated'] : ['large', 'compact'];",
  "renderCalendarGridPlacement(integrated) {",
  '.history-detail-screen[data-history-detail-view="calendar"][data-history-calendar-view="grid"] .calendar-period-hero { display: block; }',
  '.history-detail-screen[data-history-detail-view="calendar"][data-history-calendar-view="grid"] .screen-header { display: none; }',
  '.history-detail-screen[data-history-detail-view="calendar"][data-history-calendar-view="grid"][data-history-hero-variant="compact"] .calendar-period-hero { height: 185px; }',
  '.history-detail-screen[data-history-detail-view="calendar"][data-history-calendar-view="grid"][data-history-hero-variant="integrated"] .calendar-integrated-grid-slot { display: block; }',
  '.history-detail-screen[data-history-detail-view="calendar"][data-history-calendar-view="grid"][data-history-hero-variant="integrated"] .history-detail-content { top: 270px; padding-top: 18px; }',
  '.history-detail-screen[data-history-detail-view="calendar"][data-history-calendar-view="grid"][data-history-hero-variant="integrated"] .calendar-integrated-grid-slot { top: 132px; bottom: auto; height: 130px; }',
  'transform: scale(.45);',
].forEach((value) => assert.ok(html.includes(value), `the three-state Calendar presentation is missing ${value}`));

assert.ok(!historyDetail.includes('history-metrics-toggle'), 'the Calendar insight card must no longer contain a dedicated arrow button');
assert.ok(historyDetail.includes('data-component="history-metrics-surface"'), 'the Calendar insight card must expose its full-card semantic tap target');
assert.equal((historyDetail.match(/class="history-calendar-month-card"/g) || []).length, 1, 'the integrated Calendar variant must move one monthly grid node rather than duplicate it');
assert.ok(html.includes('.history-metrics-surface { position: absolute; inset: 0; z-index: 3;'), 'the full insight card must own the semantic tap overlay rather than a dedicated arrow');
assert.ok(!historyDetail.includes('history-timeline-filters'), 'the Calendar must not retain the shared removed filter-pill row');
assert.ok(!historyDetail.includes('data-history-timeline-filter'), 'the Calendar must not retain Timeline filter-pill interactions');
assert.ok(html.includes('.history-detail-screen[data-history-detail-view="calendar"][data-history-calendar-view="grid"] .history-detail-content { z-index: 2; top: 224px; grid-template-rows: 44px minmax(0, 1fr) auto; gap: 8px;'), 'the Calendar grid must use the taller shared Timeline tab geometry above the calendar scroll panel');
assert.ok(!html.includes('.history-detail-screen[data-history-detail-view="calendar"] .period-detail-tabs {'), 'the Calendar must not retain its smaller feature-local tab override');

[
  'data-history-calendar-view="grid"',
  'data-history-calendar-grid-view',
  'Február 2025',
  'Febr. 14. • Péntek',
  '3 esemény • 14. tiszta nap',
  'Aznapi emlékek',
  'Elindultam',
  'Jobban vagyok',
  'data-action="open-history-calendar-rail"',
  'data-history-calendar-date="2025-02-14"',
].forEach((value) => assert.ok(historyDetail.includes(value), `grid.png source state is missing ${value}`));

assert.equal((historyDetail.match(/data-action="open-history-calendar-rail"/g) || []).length, 43, 'all 35 monthly cells, the source selected-day summary, and the seven rail days must be semantic and tappable');
assert.ok(html.includes('.history-calendar-month-card {'), 'grid.png requires a source-shaped monthly card rather than the old circle-day stub');
assert.ok(html.includes('.history-calendar-day.is-selected'), 'the source selected day must carry the card geometry and multi-event dot treatment');
assert.ok(html.includes('.history-calendar-day-dots'), 'source calendar event dots must be a reusable visual primitive');
assert.ok(!calendarGrid.includes('Aznapi emlékek'), 'the Grid Calendar must not retain the moved Aznapi emlékek section');

[
  'data-history-calendar-rail-view',
  'class="history-calendar-day-rail"',
  'class="history-calendar-memories"',
  'Aznapi emlékek',
  'Elindultam',
  'Jobban vagyok',
  'A nehéz pillanatok is a történetem részei, és erősebbé tesznek.',
  'src="assets/hero/timelinehero.png"',
].forEach((value) => assert.ok(calendarRail.includes(value), `the reworked rail state is missing ${value}`));
assert.equal((historyDetail.match(/class="history-calendar-memories"/g) || []).length, 1, 'Aznapi emlékek must have one physical owner after moving from Grid to Rail');
assert.ok(!calendarRail.includes('history-day-tabs'), 'the Rail Calendar must not retain the Idővonal/Jegyzetek/Statisztika pill row');
assert.ok(!calendarRail.includes('history-day-event-list'), 'the Rail Calendar must not retain its former day Timeline');
assert.ok(html.includes('[data-history-calendar-view="rail"]'), 'rail.png state must be represented by the existing current-period route state');

[
  '.history-calendar-day-rail { overflow-x: auto;',
  '.history-calendar-memories { margin-top: 12px;',
  '.history-day-quote-card',
  '[data-history-calendar-view="rail"] .history-detail-content',
  '[data-history-calendar-view="rail"] .history-number-summary { display: none; }',
].forEach((value) => assert.ok(html.includes(value), `rail.png geometry contract is missing ${value}`));

[
  "historyCalendarView: 'grid'",
  "historyCalendarDate: '2025-02-14'",
  "const HISTORY_CALENDAR_GRID_REFERENCE_DATE = '2025-02-14'",
  "case 'open-history-calendar-rail': this.openHistoryCalendarRail(event.target.closest('[data-history-calendar-date]')?.dataset.historyCalendarDate); break;",
  "case 'open-history-calendar-grid': this.openHistoryCalendarGrid(); break;",
  "openHistoryCalendarRail(date) {",
  "openHistoryCalendarGrid() {",
  'renderHistoryCalendarRail() {',
  'const HISTORY_CALENDAR_DAY_DOTS = Object.freeze({',
  'this.historyDetailScreen.dataset.historyCalendarView = calendarView;',
].forEach((value) => assert.ok(html.includes(value), `the existing controller must own ${value}`));
assert.ok(!html.includes('HISTORY_CALENDAR_DAY_EVENTS'), 'the controller must not retain data for the removed Rail day Timeline');

assert.ok(!/\bfetch\s*\(/.test(html), 'the calendar/rail source implementation must remain local and offline');

console.log('PASS calendar grid and rail source-reference contract');
