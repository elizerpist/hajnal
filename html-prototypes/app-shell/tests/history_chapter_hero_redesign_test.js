#!/usr/bin/env node
'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const shellPath = path.resolve(__dirname, '..', 'index.html');
const source = fs.readFileSync(shellPath, 'utf8');
const heroDirectory = path.resolve(__dirname, '..', 'assets', 'history-chapter-hero');
const periodIds = ['2024-05', '2024-06', '2024-08', '2024-10', '2025-01', '2025-05', '2025-06', '2025-08', '2025-11', 'current'];

assert.match(source, /historyPeriodPresentation:\s*'hero-swipe'/, 'History must start in the permanent hero-swipe presentation.');
assert.doesNotMatch(source, /history-period-carousel/, 'The retired History card carousel must not remain in markup, styles, or runtime code.');
assert.doesNotMatch(source, /toggle-history-period-presentation/, 'The carousel/hero presentation toggle must be removed with the carousel.');
assert.match(source, /class="history-chapter-info-card"/, 'Each chapter hero needs the overlapping light information card.');
assert.match(source, /history-chapter-scroll-heading/, 'The scroll zone needs its own timeline heading.');
assert.match(source, /var\(--path-overview-current-card-height\)/, 'The chapter card must use the shared Ösvény hero-card height token.');
assert.match(source, /renderHistoryLayout\(\)\s*\{[\s\S]*?this\.renderHistoryFullPagePager\(\);[\s\S]*?\}/, 'History layout must render through the one existing full-page pager.');
assert.match(source, /assets\/history-chapter-hero\/2024-05\.png/, 'History periods must point to the regenerated chapter hero assets.');
assert.match(source, /history-period-pager-slide\[data-history-period-current="false"\][\s\S]*?grayscale\(1\)/, 'Past chapters must remain visually subdued.');

for (const id of periodIds) {
  const assetPath = path.join(heroDirectory, `${id}.png`);
  assert.ok(fs.existsSync(assetPath), `Missing generated hero asset for ${id}.`);
  assert.ok(fs.statSync(assetPath).size > 10000, `Hero asset for ${id} is unexpectedly small.`);
}

console.log('History chapter-hero redesign contract passes.');
