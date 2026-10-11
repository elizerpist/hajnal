'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /historyOverview:\s*\{\s*layoutMode:\s*'current',\s*density:\s*'roomy'\s*\}/, 'History must own its comparison and density state separately');
assert.match(html, /toggleHistoryOverviewLayout\(\)/, 'History must expose a current/path-inspired layout action');
assert.match(html, /toggleHistoryOverviewDensity\(\)/, 'History must expose a density action for the alternative');
assert.match(html, /renderHistoryOverviewLayout\(\)/, 'History must explicitly render its active presentation branch');
assert.match(html, /data-action="toggle-history-overview-layout"/, 'History needs the comparison toggle');
assert.match(html, /data-action="toggle-history-overview-density"/, 'History needs the density toggle');
assert.match(html, /history-path-overview/, 'History must have a scoped path-inspired layout boundary');
assert.match(html, /history-path-current-card/, 'the new layout needs its current-period card');
assert.match(html, /history-path-period-card/, 'the new layout needs Path-shaped prior-period cards');
assert.doesNotMatch(html, /history-path-day-medallion/, 'the path-inspired layout must not retain the clean-day progress circle');
assert.match(html, /history-period-badge history-path-current-badge/, 'the current period must use the normal History chip primitive');
assert.match(html, /history-path-period-card[\s\S]*?history-period-badge/, 'prior periods must use the normal History chip primitive');
assert.match(html, /current\.days\}\s*\/\s*90/, 'the current period must derive its 90-day target progress from the current-period data');
assert.match(html, /data-history-overview-layout-mode/, 'the History root must declare current versus path-inspired state');
assert.match(html, /data-history-overview-density/, 'the History root must declare roomy versus compact state');
assert.match(html, /\.history-path-current-card, \.history-path-period-card \{[^}]*border-radius: 17px;/, 'every path-inspired History card must use the original History card radius');
assert.match(html, /\.history-path-current-art, \.history-path-period-art \{[^}]*top: 6px; bottom: 6px; left: 6px; width: 91px;[^}]*border-radius: 12px;[^}]*mask-image: none;/, 'artwork must be an inset image card with rounded corners and no fade mask');
assert.match(html, /\.history-path-current-card \{ min-height: var\(--path-overview-current-card-height\); display: grid; grid-template-columns: 117px minmax\(0,1fr\) 18px;/, 'current-period copy must begin after the sharp artwork panel');
assert.match(html, /\.history-path-period-card \{ min-height: 76px; display: grid; grid-template-columns: 111px minmax\(0,1fr\) 12px;/, 'prior-period copy must begin after the sharp artwork panel');
assert.match(html, /\.history-path-period-card \.history-path-copy \{ grid-column: 2; grid-row: 1; \}/, 'prior-period copy must stay in the second grid column, outside the absolute artwork');
assert.match(html, /\.history-path-period-card \.history-path-chevron \{ grid-column: 3; grid-row: 1; \}/, 'prior-period chevrons must stay in the third grid column');
assert.match(html, /history-overview-footer-slot/, 'the existing expandable footer must have one movable shared slot');
assert.match(html, /renderHistoryPeriodCards\(/, 'both presentations must derive period cards through the same renderer');
assert.match(html, /\.history-path-overview \{ position: relative; grid-row: 1; min-height: 0;/, 'the alternative list must remain a grid item so it reserves space above the footer');
assert.match(html, /data-history-overview-layout-mode="path-inspired"\] \.history-number-summary \{ grid-row: 2;/, 'the shared expandable footer must remain in the bottom grid row in the alternative layout');

console.log('PASS history path-inspired source contract');
