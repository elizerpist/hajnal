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
assert.match(html, /\.history-period-carousel \{[^}]*height: 70px;[^}]*padding: 0 calc\(50% - 60px\);[^}]*scroll-snap-type: x mandatory;/, 'three compact carousel slots must use native snapping around the centre');
assert.match(html, /\.history-period-carousel-card \{[^}]*flex: 0 0 120px;[^}]*transform: scale\(var\(--history-carousel-scale\)\);/, 'neighbouring cards must continuously shrink away from the centre slot');
assert.match(html, /\.history-period-carousel-card\[aria-current="true"\] \{ --history-carousel-scale: 1\.14; --history-carousel-opacity: 1;/, 'the selected period must begin as the enlarged centre card');
assert.match(html, /\.history-period-carousel-card:not\(\[aria-current="true"\]\) .history-period-carousel-art img \{ filter: grayscale\(1\);/, 'past periods must remain visually distinct without a second data source');

console.log('PASS History carousel presentation contract');
