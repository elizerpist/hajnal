const assert = require('assert');
const fs = require('fs');
const path = require('path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /overviewPresentation:\s*'standard'/, 'Path state must own the standard/fit-all presentation choice.');
assert.match(html, /togglePathOverviewPresentation\(\)/, 'Path needs one controller-owned fit-all toggle.');
assert.match(html, /case 'toggle-path-overview-presentation':\s*this\.togglePathOverviewPresentation\(\)/, 'The new button must use the controller action, not a second route.');
assert.match(html, /data-path-overview-presentation="fit-all"/, 'Path must expose the alternative mode as scoped presentation data.');
assert.match(html, /path-overview-fit-all-toggle/, 'Path overview needs the accessible top-right layout toggle.');
assert.match(html, /data-path-overview-presentation="fit-all"\][\s\S]{0,1000}\.path-overview-fast-card\s*\{[^}]*display:\s*none/, 'Fit-all must remove the upper current-work card from layout.');
assert.match(html, /data-path-overview-presentation="fit-all"\][\s\S]{0,1600}\.path-step-list\s*\{[^}]*grid-template-rows:\s*repeat\(12,\s*minmax\(0,\s*1fr\)\)[^}]*overflow:\s*hidden/, 'Fit-all must use a deterministic twelve-row, non-scrolling grid.');
assert.match(html, /data-path-overview-presentation="fit-all"\][\s\S]{0,2000}\.path-step-card\s*\{[^}]*min-height:\s*0/, 'Fit-all rows must be allowed to consume the measured grid height.');
assert.match(html, /\.path-overview-content \{[^}]*min-width: 0;[^}]*grid-template-columns: minmax\(0, 1fr\);/, 'The overview must own one definite full-width track so its normal and fit-all rows cannot shrink to their artwork width.');
assert.match(html, /\.path-step-list \{ min-width: 0; width: 100%;/, 'The step list must explicitly occupy the whole overview track.');
assert.match(html, /\.path-step-card \{ min-width: 0; justify-self: stretch;/, 'Every step card must stretch across the same full-width list track.');

console.log('path_fit_all_overview_test: PASS');
