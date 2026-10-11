'use strict';

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
const timelineHero = path.join(root, 'assets', 'hero', 'timelinehero.png');
const historyStart = html.indexOf('<section class="route-screen history-screen" id="home-statistics"');
const historyEnd = html.indexOf('<section class="route-screen history-detail-screen"', historyStart);
const history = html.slice(historyStart, historyEnd);

assert.ok(historyStart >= 0 && historyEnd > historyStart, 'the History route must remain one bounded screen');
assert.equal(
  crypto.createHash('sha256').update(fs.readFileSync(timelineHero)).digest('hex'),
  '796531a3c99b48936199e3355a3ba136b4a2483dab8dd5e27a506818b44268b0',
  'the retained Történetem hero asset must remain source-faithful',
);
assert.match(history, /class="history-hero"/, 'the retained History hero must remain the visual top owner');
assert.match(history, /src="assets\/hero\/timelinehero\.png"/, 'the History hero must retain its established artwork');
assert.match(history, /data-component="history-period-carousel"/, 'period navigation must now live in the hero');
assert.match(history, /data-component="history-workspace"/, 'the Timeline/Calendar body must live directly under the hero');
assert.doesNotMatch(history, /history-period-list/, 'the previous vertical period list must not remain');
assert.doesNotMatch(history, /history-overview-layout-toggle/, 'the old layout-comparison control must not remain');
assert.doesNotMatch(history, /history-overview-density-toggle/, 'the old density control must not remain');

const periodsMatch = html.match(/const HISTORY_PERIODS = Object\.freeze\((\[[\s\S]*?\])\);/);
assert.ok(periodsMatch, 'one structured period source must still serve the History carousel');
const periods = new Function(`return (${periodsMatch[1]});`)();
assert.equal(periods.length, 10, 'all ten real History periods must remain available');
assert.equal(new Set(periods.map((period) => period.id)).size, 10, 'period selection must use stable IDs');
assert.deepEqual(periods.map((period) => period.days), [8, 15, 37, 21, 89, 18, 4, 33, 46, 24], 'the existing clean-day data must remain intact');
assert.equal(periods.find((period) => period.current)?.id, 'current', 'the current period must remain marked in the shared source');
assert.ok(periods.every((period) => /^assets\/milestones\/milestone-[^" ]+\.svg$/.test(period.art)), 'the carousel must continue using local period artwork');

assert.match(html, /<main class="history-detail-content" data-component="history-workspace-template"/, 'one existing Timeline/Calendar body must be the workspace source');
assert.match(html, /data-history-detail-tab="timeline"/, 'the inline body must retain the Timeline tab');
assert.match(html, /data-history-detail-tab="calendar"/, 'the inline body must retain the Calendar tab');
assert.match(html, /class="history-number-summary"/, 'the existing expandable metrics footer must remain available');
assert.doesNotMatch(html, /\bfetch\s*\(/, 'History must stay offline');

console.log('PASS History carousel source-reference contract');
