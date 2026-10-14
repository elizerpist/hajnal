#!/usr/bin/env node
'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
const historyStart = html.indexOf('<section class="route-screen history-screen" id="home-statistics"');
const historyEnd = html.indexOf('<section class="route-screen history-detail-screen"', historyStart);
const history = html.slice(historyStart, historyEnd);

assert.ok(historyStart >= 0 && historyEnd > historyStart, 'History must remain one bounded route screen.');
assert.match(history, /class="history-hero"/, 'The History title system must remain above the hero.');
assert.match(history, /data-component="history-view-switch"/, 'Timeline and calendar views remain available from the History hero.');
assert.match(history, /data-component="history-full-page-pager"/, 'The chapter pager owns the History viewport.');
assert.doesNotMatch(history, /history-period-carousel/, 'The reference no longer permits a period-card carousel.');
assert.match(html, /const HISTORY_PERIODS = Object\.freeze\(/, 'Stable chapter data must remain immutable.');
assert.match(html, /data-history-period-current="\$\{Boolean\(period\.current\)\}"/, 'Past/current status must remain data-driven.');
assert.doesNotMatch(html, /\bfetch\s*\(/, 'History remains offline.');
console.log('PASS History chapter reference contract');
