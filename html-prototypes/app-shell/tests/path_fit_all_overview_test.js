const assert = require('assert');
const fs = require('fs');
const path = require('path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.doesNotMatch(html, /overviewPresentation/, 'The overlapping fit-all presentation state must be removed.');
assert.doesNotMatch(html, /togglePathOverviewPresentation/, 'The controller must not retain the fit-all action.');
assert.doesNotMatch(html, /toggle-path-overview-presentation/, 'The overlapping fit-all control must not render.');
assert.doesNotMatch(html, /data-path-overview-presentation/, 'The removed presentation must not leak a scoped DOM state.');
assert.doesNotMatch(html, /path-overview-fit-all-toggle/, 'No CSS or component boundary may retain the overlapping control.');
assert.doesNotMatch(html, /path-overview-fast-card\s*\{[^}]*display:\s*none/, 'No remaining Overview presentation may hide the upper current-work card.');
assert.match(html, /\.path-overview-content \{[^}]*min-width: 0;[^}]*grid-template-columns: minmax\(0, 1fr\);/, 'The overview must retain one definite full-width track.');
assert.match(html, /\.path-step-list \{ min-width: 0; width: 100%;/, 'The step list must explicitly occupy the whole overview track.');
assert.match(html, /\.path-step-card \{ min-width: 0; justify-self: stretch;/, 'Every step card must stretch across the same full-width list track.');

console.log('path_fit_all_overview_test: PASS');
