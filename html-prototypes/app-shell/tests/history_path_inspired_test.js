'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.doesNotMatch(html, /historyOverview:\s*\{/, 'the retired two-layout History presentation state must not survive');
assert.doesNotMatch(html, /toggleHistoryOverviewLayout\(/, 'the retired comparison toggle must not survive');
assert.doesNotMatch(html, /toggleHistoryOverviewDensity\(/, 'the retired density toggle must not survive');
assert.doesNotMatch(html, /data-history-overview-layout-mode="current"/, 'the route must not expose a dormant list-layout mode');
assert.doesNotMatch(html, /data-history-overview-density="roomy"/, 'the route must not expose a dormant list-density mode');
assert.match(html, /historySelectedPeriodId:\s*'current'/, 'the carousel must begin with the current chapter selected');
assert.match(html, /data-history-workspace="inline"/, 'the History route must explicitly own its inline workspace mode');
assert.match(html, /history-period-carousel-card\[aria-current="true"\]/, 'the centre chapter card needs a selected visual state');
assert.match(html, /\.history-period-carousel \{[^}]*height: var\(--history-carousel-active-card-height\);[^}]*bottom: var\(--history-carousel-card-bottom-inset\);[^}]*padding: 0 calc\(50% - \(var\(--history-carousel-active-card-width\) \/ 2\)\);[^}]*scroll-snap-type: x mandatory;/, 'the History2 carousel must retain native snapping while centring its larger source-matched image card');
assert.match(html, /\.history-period-carousel-card \{[^}]*flex: 0 0 var\(--history-carousel-side-card-width\);[^}]*height: var\(--history-carousel-active-card-height\);[^}]*min-height: var\(--history-carousel-active-card-height\);[^}]*max-height: var\(--history-carousel-active-card-height\);[^}]*transform: scale\(var\(--history-carousel-scale\)\);/, 'the inactive cards must shrink continuously while preserving their full-image card primitive');
assert.match(html, /\.history-period-carousel-card\[aria-current="true"\] \{ --history-carousel-scale: 1; --history-carousel-opacity: 1; flex-basis: var\(--history-carousel-active-card-width\);/, 'the selected period must own the larger source-matched full-image slot');
assert.match(html, /\.history-period-carousel-card:not\(\[aria-current="true"\]\) \.history-period-carousel-art img \{[^}]*filter: saturate\(/, 'side periods must stay image-based but visually quieter without a second data source');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-workspace \.history-detail-content \{[^}]*border-radius: 0;[^}]*background: transparent;/, 'the inline History body must use the same continuous hero-to-body fade language as Path instead of a rounded white body card');

console.log('PASS History carousel presentation contract');
