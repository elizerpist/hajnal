'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
const historyDetailStart = html.indexOf('<section class="route-screen history-detail-screen"');
const eventDetailStart = html.indexOf('<section class="route-screen timeline-event-detail-screen"');
const historyDetail = html.slice(historyDetailStart, eventDetailStart);

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
assert.ok(html.includes('.history-detail-screen[data-history-detail-view="calendar"][data-history-calendar-view="grid"] .history-detail-content { z-index: 2; top: 224px; grid-template-rows: 36px minmax(0, 1fr) auto;'), 'the Calendar grid must retain only its tabs above the calendar scroll panel');

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
assert.ok(html.includes('.history-calendar-grid-memories'), 'source Aznapi emlékek cards must be a dedicated grid state section');

[
  'data-history-calendar-rail-view',
  'Február 14.',
  '14. tiszta nap',
  'class="history-calendar-day-rail"',
  'class="history-day-tabs"',
  'Idővonal',
  'Jegyzetek',
  'Statisztika',
  'Reggeli gondolatok',
  'AA meeting – Belváros',
  'Séta a Duna-parton',
  'Erős késztetés',
  'Esti check-in',
  'A nehéz pillanatok is a történetem részei, és erősebbé tesznek.',
  'src="assets/hero/timelinehero.png"',
].forEach((value) => assert.ok(historyDetail.includes(value), `rail.png source state is missing ${value}`));
assert.ok(html.includes('[data-history-calendar-view="rail"]'), 'rail.png state must be represented by the existing current-period route state');

[
  '.history-calendar-day-rail { overflow-x: auto;',
  '.history-day-event-list::before',
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
  'const HISTORY_CALENDAR_DAY_EVENTS = Object.freeze({',
  'const HISTORY_CALENDAR_DAY_DOTS = Object.freeze({',
  'this.historyDetailScreen.dataset.historyCalendarView = calendarView;',
].forEach((value) => assert.ok(html.includes(value), `the existing controller must own ${value}`));

assert.ok(!/\bfetch\s*\(/.test(html), 'the calendar/rail source implementation must remain local and offline');

console.log('PASS calendar grid and rail source-reference contract');
