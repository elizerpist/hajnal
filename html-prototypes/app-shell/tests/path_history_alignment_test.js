#!/usr/bin/env node
'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.doesNotMatch(html, /path-overview-height-toggle/, 'The Path overview must not expose a redundant high/low card control.');
assert.match(html, /case 'toggle-path-overview-layout': break;/, 'Any legacy unmounted markup must resolve only to a no-op, not a layout state transition.');
assert.match(html, /this\.pathScreen\.dataset\.pathOverviewLayout\s*=\s*'compact';/, 'The Path overview must always use the lower compact alignment.');
assert.match(html, /data-path-overview-layout="compact"\]\s+\.path-overview-content\s*\{[\s\S]*?grid-template-rows:\s*var\(--path-overview-current-card-height\)\s+minmax\(0,\s*1fr\)/, 'The fixed Path fast card must keep the shared History card-height token.');
assert.match(html, /data-path-overview-layout="compact"\]\s+\.path-step-list-card\s*\{[\s\S]*?gap:\s*8px/, 'The fixed Path heading must reserve the same non-scrolling heading rhythm as History.');
assert.match(html, /data-path-overview-layout="compact"\]\s+\.path-step-list-card\s+h2\s*\{[\s\S]*?min-height:\s*43px/, 'The fixed Path twelve-step heading must have a stable non-scrolling row.');
assert.match(html, /\.path-step-list\s*\{[^}]*overflow-y:\s*auto/, 'Only the Path step list may own vertical list scrolling.');
assert.match(html, /\.path-screen\[data-path-view="overview"\]::before\s*\{[\s\S]*?-webkit-mask-image:\s*var\(--hero-art-vertical-fade-mask\)[\s\S]*?mask-image:\s*var\(--hero-art-vertical-fade-mask\)/, 'The Path hero artwork must preserve its shared vertical fade mask.');

assert.match(html, /const timelineHeading = this\.renderHistoryChapterScrollHeading\(events\.length\);/, 'The History heading must be derived once and remain visible in both Timeline and Calendar views.');
assert.match(html, /history-period-pager-body" data-history-pager-view="\$\{pagerView\}">\$\{timelineHeading\}<div class="history-period-pager-scroll-owner"/, 'The History heading must render before, not inside, the pager scroll owner.');
assert.match(html, /history-period-pager-body\[data-history-pager-view="timeline"\](?:\s*,\s*\.history-screen\[data-history-workspace="inline"\]\s+\.history-period-pager-body\[data-history-pager-view="calendar"\])?\s*\{[\s\S]*?grid-template-rows:\s*43px\s+minmax\(0,\s*1fr\);/, 'Timeline and Calendar headings must reserve the same fixed body-level row while the former lower stats row is removed.');
assert.match(html, /renderHistoryPagerCalendarRail\(period, timeline\)[\s\S]*?const selectedEvents = this\.historyEventsForCalendarDate\(events, period, this\.state\.historyCalendarDate, timeline\);[\s\S]*?const timelineCards = this\.renderHistoryTimelineEventMarkup\(selectedEvents\);/, 'The pager calendar rail must reuse the shared, date-filtered History timeline-card renderer.');
assert.match(html, /data-component="history-calendar-rail-timeline-events"/, 'The tapped-day calendar rail must own a target for shared timeline markup.');
assert.match(html, /renderSelectedHistoryCalendarRailTimeline\(selected\)[\s\S]*?history-calendar-rail-timeline-events[\s\S]*?renderHistoryTimelineEventMarkup\(/, 'The existing calendar rail must hydrate the shared timeline card renderer through its shared updater.');
assert.match(html, /renderHistoryCalendarRail\(\)[\s\S]*?renderSelectedHistoryCalendarRailTimeline\(this\.getSelectedHistoryPeriod\(\)\)/, 'The existing calendar rail must request its shared timeline-card updater after a day selection.');
assert.doesNotMatch(html, /history-period-pager-calendar-event/, 'The pager calendar rail must not retain the duplicate non-filterable event-card renderer.');

console.log('Path/History hero alignment and shared calendar rail timeline contract passes.');
