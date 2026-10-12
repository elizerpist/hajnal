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
  /\.history-number-summary\s*\{[^}]*min-width:\s*0;[^}]*max-width:\s*100%;/,
  'The shared metrics footer must opt out of the grid item min-content width that can grow it past the screen.'
);
assert.match(
  html,
  /\.history-period-pager-summary\s*\{[^}]*min-width:\s*0;[^}]*max-width:\s*100%;/,
  'The full-hero pager summary must be constrained by its body grid, never by its rail children.'
);
const metricsRailRule = html.match(/\.history-number-grid\s*\{[^}]*\}/)?.[0] || '';
assert.match(metricsRailRule, /min-width:\s*0;/, 'The metric rail must opt out of min-content expansion.');
assert.match(metricsRailRule, /width:\s*100%;/, 'The metric rail must fill its constrained parent width.');
assert.match(metricsRailRule, /max-width:\s*100%;/, 'The metric rail may not widen its parent.');
assert.match(metricsRailRule, /touch-action:\s*pan-y;/, 'The rail must preserve native vertical scrolling while its scoped controller owns horizontal dragging.');
assert.match(
  html,
  /data-history-metrics-rail/,
  'Metrics rails need a semantic marker so the outer History pager can yield horizontal gestures to them.'
);
assert.match(
  html,
  /event\.target\.closest\([^)]*data-history-metrics-rail[^)]*\)\) return;/,
  'The full-page History pager must explicitly yield a gesture that starts on a metrics rail.'
);
assert.ok(
  !/\.history-number-summary\[aria-expanded="true"\]\s+\.history-metrics-surface\s*\{[^}]*height:\s*52px;/.test(html),
  'Expanded metrics must not use an arbitrary 52px transparent overlay that can cover the rail.'
);
assert.match(
  html,
  /<button class="history-metrics-surface"[^>]*>[\s\S]*?<div class="history-number-summary-heading">/,
  'The metrics heading must be inside its real collapse button so its expanded hit area follows the heading rather than an overlay.'
);
assert.match(
  html,
  /captureHistoryMetricsRailScrollPositions\(\)[\s\S]*?restoreHistoryMetricsRailScrollPositions\(\)/,
  'Controller-owned metrics rail positions must be captured and restored around History rerenders.'
);
assert.match(
  html,
  /historyMetricsRailPointerDown\(event\)[\s\S]*?data-history-metrics-rail[\s\S]*?historyMetricsRailPointerMove\(event\)[\s\S]*?Math\.abs\(deltaX\).*1\.25/,
  'A scoped metrics-rail drag guard must distinguish a horizontal rail drag from an icon tap.'
);
assert.match(
  html,
  /consumeHistoryMetricsRailClick\(event\)[\s\S]*?event\.preventDefault\(\);[\s\S]*?event\.stopPropagation\(\);/,
  'A genuine metrics rail drag must suppress its synthetic icon click without installing a second global gesture engine.'
);
assert.match(
  html,
  /historyMetricsRailPointerMove\(event\)[\s\S]*?drag\.rail\.scrollLeft\s*=\s*Math\.max\(/,
  'The scoped rail gesture must move only the rail scroll position when the ancestor pager reserves horizontal gestures.'
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
