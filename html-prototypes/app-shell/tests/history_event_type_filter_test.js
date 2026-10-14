#!/usr/bin/env node
'use strict';

const assert = require('assert');
const fs = require('fs');
const path = require('path');

const appShell = path.resolve(__dirname, '..');
const html = fs.readFileSync(path.join(appShell, 'index.html'), 'utf8');

assert.match(html, /historyEventTypeFilter:\s*null/, 'History must own one nullable event-type filter state');
assert.match(html, /historyEventTypeDefinition\(event\s*=\s*\{\}\)/, 'event type metadata must resolve from event data');
assert.match(html, /event\.eventType\s*\|\|\s*event\.type\s*\|\|\s*event\.icon/, 'explicit future event types must fall back to the existing event icon');
assert.match(html, /historyEventTypes\(\)/, 'both Timeline and summary must consume one event-type catalogue');
assert.match(html, /filteredHistoryTimelineEvents\(events\s*=\s*\[\]\)/, 'the Timeline must have one shared event filter resolver');
assert.match(html, /toggleHistoryEventFilter\(eventType\)/, 'one controller action must toggle the active type');
assert.match(html, /this\.state\.historyEventTypeFilter\s*=\s*this\.state\.historyEventTypeFilter\s*===\s*normalizedType\s*\?\s*null\s*:\s*normalizedType/, 'tapping the active icon must clear the filter');
assert.match(html, /case 'toggle-history-event-filter': this\.toggleHistoryEventFilter\(/, 'the delegated action handler must reach the filter state owner');
assert.match(html, /data-action="toggle-history-event-filter"[^]*?data-history-event-type=/, 'metric icon controls must expose event type filter actions');
assert.match(html, /class="history-event-node[^]*?data-action="toggle-history-event-filter"/, 'Timeline event icons must be tappable type filters');
assert.match(html, /const events = this\.filteredHistoryTimelineEvents\(timeline\.events\s*\|\|\s*\[\]\);[\s\S]*?renderHistoryTimelineEventMarkup\(events\)/, 'the permanent full-hero Timeline must filter through the shared resolver before rendering');
assert.match(html, /aria-pressed="\$\{String\(metric\.id === this\.state\.historyEventTypeFilter\)\}"/, 'summary filter controls must announce their selected state');
assert.match(html, /aria-pressed="\$\{String\(type\.id === this\.state\.historyEventTypeFilter\)\}"/, 'Timeline icon controls must announce their selected state');

console.log('history event-type filter contract: PASS');
