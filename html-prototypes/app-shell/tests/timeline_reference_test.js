#!/usr/bin/env node
'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');
assert.match(html, /class="timeline-period-hero"/, 'The dedicated Timeline route must remain available.');
assert.match(html, /data-component="history-period-timeline-events"/, 'Timeline events retain their stable semantic mount.');
assert.match(html, /const HISTORY_PERIOD_TIMELINES = Object\.freeze\(/, 'Period timeline data remains centrally owned.');
assert.match(html, /const eventDateTime = \[event\.date, event\.day, event\.time\]/, 'Event date metadata remains in the wide event card.');
assert.doesNotMatch(html, /history-event-date/, 'The retired left-side date column must not return.');
assert.match(html, /\.history-detail-event-list \{[^}]*--history-event-node-size: 32px;[^}]*--history-event-node-inline-offset: 2px;/, 'Timeline nodes use shared compact geometry so their adjacent cards have more width.');
assert.match(html, /\.history-event-node \{[^}]*align-self: center;/, 'Timeline nodes remain vertically centred beside their cards.');
assert.match(html, /\.history-period-pager-slide\[data-history-period-current="false"\][\s\S]*?grayscale\(1\)/, 'Past chapter timelines remain visually subdued.');
console.log('PASS Timeline reference contract');
