'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.doesNotMatch(html, /overviewHeroCardVisible/, 'The current-work card must not have a hidden-state owner.');
assert.doesNotMatch(html, /togglePathOverviewHeroCard/, 'The controller must not retain a current-work-card hiding action.');
assert.doesNotMatch(html, /toggle-path-overview-hero-card/, 'The current-work-card hiding control must not render.');
assert.doesNotMatch(html, /path-overview-hero-card-toggle/, 'No CSS or component boundary may retain the removed control.');
assert.doesNotMatch(html, /path-overview-card-quote/, 'The temporary hidden-card replacement surface must be removed with its control.');
assert.doesNotMatch(html, /data-path-overview-hero-card-visible/, 'The Path screen must not expose obsolete card-visibility state.');
assert.match(html, /class="path-overview-fast-card"/, 'The current-work card must remain in the normal Overview renderer.');

console.log('PASS Path overview hero-card toggle source contract');
