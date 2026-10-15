#!/usr/bin/env node
'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');
assert.match(
  html,
  /\.history-period-pager-slide\s*\{[^}]*--history-chapter-info-card-height:\s*var\(--path-overview-current-card-height\);/,
  'The collapsed History card must keep the shared Ösvény hero-card height token.'
);
assert.match(
  html,
  /\.history-chapter-info-card\s*\{[^}]*height:\s*var\(--history-chapter-info-card-height\);/,
  'The History card must use the shared geometry variable so its expanded height can move the body without overlaying it.'
);
assert.match(html, /\.history-chapter-info-card \{[^}]*border-radius: 25px;/, 'The shared chapter card must stay within the same rounded-card family as Ösvény.');
assert.match(html, /\.history-chapter-scroll-heading \{/, 'The chapter timeline scroll zone must begin with its own quiet heading.');
assert.doesNotMatch(html, /history-period-carousel/, 'No old card-carousel selector may survive as a dormant fallback.');
console.log('PASS History and Ösvény chapter-card system contract');
