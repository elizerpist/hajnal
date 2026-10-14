#!/usr/bin/env node
'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /data-action="toggle-path-overview-layout"/, 'The Path hero must expose a controller-owned alternate-layout action.');
assert.match(html, /path-overview-height-toggle[\s\S]*?top:\s*40px[\s\S]*?right:\s*157px/, 'The Path layout action must keep its own hero slot, outside the existing action buttons.');
assert.match(html, /data-path-overview-layout="compact"\]\s+\.path-overview-content[\s\S]*?top:\s*39px[\s\S]*?height:\s*calc\(100%\s*-\s*39px\)/, 'The alternate Path layout must place its card at the History chapter-card top without creating a second layout state.');
assert.match(html, /data-path-overview-layout="compact"\]\s+\.path-overview-content\s*\{[\s\S]*?grid-template-rows:\s*var\(--path-overview-current-card-height\)\s+minmax\(0,\s*1fr\)/, 'The alternate Path fast card must keep the shared History card-height token.');
assert.match(html, /data-path-overview-layout="compact"\]\s+\.path-step-list-card\s*\{[\s\S]*?gap:\s*8px/, 'The alternate Path heading must reserve the same non-scrolling heading rhythm as History.');
assert.match(html, /data-path-overview-layout="compact"\]\s+\.path-step-list-card\s+h2\s*\{[\s\S]*?min-height:\s*43px/, 'The alternate Path twelve-step heading must have a fixed non-scrolling row.');
assert.match(html, /\.path-step-list\s*\{[^}]*overflow-y:\s*auto/, 'Only the Path step list may own vertical list scrolling.');
assert.match(html, /\.path-screen\[data-path-view="overview"\]::before\s*\{[\s\S]*?-webkit-mask-image:\s*var\(--hero-art-vertical-fade-mask\)[\s\S]*?mask-image:\s*var\(--hero-art-vertical-fade-mask\)/, 'The Path hero artwork must preserve its shared vertical fade mask.');

assert.match(html, /const timelineHeading = pagerView === 'timeline' \? this\.renderHistoryChapterScrollHeading\(events\.length\) : '';/, 'The History heading must be derived once for Timeline and calendar-rail timeline-card states.');
assert.match(html, /history-period-pager-body" data-history-pager-view="\$\{pagerView\}">\$\{timelineHeading\}<div class="history-period-pager-scroll-owner"/, 'The History heading must render before, not inside, the pager scroll owner.');
assert.match(html, /history-period-pager-body\[data-history-pager-view="timeline"\]\s*\{[\s\S]*?grid-template-rows:\s*43px\s+minmax\(0,\s*1fr\)\s+auto/, 'Timeline heading must reserve a fixed body-level row.');
assert.match(html, /renderHistoryPagerCalendarRail\(period, timeline\)[\s\S]*?renderHistoryTimelineEventMarkup\(this\.filteredHistoryTimelineEvents\(events\)\)/, 'The pager calendar rail must reuse the shared filtered History timeline-card renderer.');
assert.match(html, /data-component="history-calendar-rail-timeline-events"/, 'The tapped-day calendar rail must own a target for shared timeline markup.');
assert.match(html, /renderSelectedHistoryCalendarRailTimeline\(selected\)[\s\S]*?history-calendar-rail-timeline-events[\s\S]*?renderHistoryTimelineEventMarkup\(/, 'The existing calendar rail must hydrate the shared timeline card renderer through its shared updater.');
assert.match(html, /renderHistoryCalendarRail\(\)[\s\S]*?renderSelectedHistoryCalendarRailTimeline\(this\.getSelectedHistoryPeriod\(\)\)/, 'The existing calendar rail must request its shared timeline-card updater after a day selection.');
assert.doesNotMatch(html, /history-period-pager-calendar-event/, 'The pager calendar rail must not retain the duplicate non-filterable event-card renderer.');

console.log('Path/History hero alignment and shared calendar rail timeline contract passes.');
