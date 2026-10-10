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
assert.match(html, /history-path-day-medallion/, 'clean-day value must have a dedicated medalion primitive');
assert.match(html, /current\.days\}\s*\/\s*90/, 'the current period must derive its 90-day target progress from the current-period data');
assert.match(html, /data-history-overview-layout-mode/, 'the History root must declare current versus path-inspired state');
assert.match(html, /data-history-overview-density/, 'the History root must declare roomy versus compact state');
assert.match(html, /history-overview-footer-slot/, 'the existing expandable footer must have one movable shared slot');
assert.match(html, /renderHistoryPeriodCards\(/, 'both presentations must derive period cards through the same renderer');

console.log('PASS history path-inspired source contract');
