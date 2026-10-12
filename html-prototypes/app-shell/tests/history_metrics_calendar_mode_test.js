#!/usr/bin/env node
'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(
  html,
  /\.history-screen\[data-history-workspace="inline"\]\s*\{\s*--history-inline-body-surface:\s*var\(--screen-background\);/,
  'History must share the Path body-surface token rather than own a near-white copy.'
);

assert.match(
  html,
  /\.history-number-grid\s*\{[^}]*display:\s*flex;[^}]*overflow-x:\s*auto;[^}]*scroll-snap-type:\s*x\s+(?:proximity|mandatory);/,
  'Expanded History metrics must use one native horizontal rail, not a multi-row grid.'
);
assert.match(
  html,
  /\.history-number-card\s*\{[^}]*flex:\s*0\s+0\s+auto;[^}]*scroll-snap-align:\s*start;/,
  'Each metric card must remain a stable horizontally scrollable item.'
);
assert.match(
  html,
  /data-history-metrics-expanded="true"\][^{}]*\.history-number-grid\s*\{[^}]*max-height:\s*(?:8[0-9]|9[0-9])px;/,
  'The expanded metrics summary must reserve only one card-row height.'
);

assert.match(
  html,
  /renderHistoryPagerCalendar\(period, timeline\)\s*\{[\s\S]*?const railActive = this\.state\.historyCalendarView === 'rail';[\s\S]*?railActive \? this\.renderHistoryPagerCalendarRail\(period, timeline\) : this\.renderHistoryPagerCalendarGrid\(period, timeline\);/,
  'Full-hero Calendar must default to the grid and use the rail only after the existing day-selection state is active.'
);
assert.match(
  html,
  /renderHistoryPagerCalendarGrid\(period, timeline\)[\s\S]*?history-calendar-month-card[\s\S]*?data-action="open-history-calendar-rail"/,
  'Full-hero Calendar grid must reuse the existing monthly-card and day-selection primitives.'
);
assert.match(
  html,
  /renderHistoryPagerCalendarRail\(period, timeline\)[\s\S]*?history-period-pager-calendar-rail/,
  'The rail remains a dedicated, state-selected view after tapping a calendar day.'
);

console.log('PASS history metrics rail and full-hero calendar-mode contract');
