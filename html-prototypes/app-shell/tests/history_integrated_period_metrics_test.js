'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /renderHistoryChapterMetrics\(period\)\s*\{[\s\S]*?renderHistoryMetricCards\(period\)/, 'The existing period metrics must be rendered once inside the chapter card through the shared metric-card renderer.');
assert.match(html, /class="history-card-metrics-toggle"[\s\S]*?data-action="toggle-history-metrics"[\s\S]*?aria-controls="history-chapter-metrics-\$\{escapeHtml\(period\.id\)\}"/, 'The preserved leaf affordance must be the accessible metrics toggle, with a per-period relationship to its panel.');
assert.match(html, /history-card-metrics-toggle[\s\S]*?<use href="#icon-leaf"\/>[\s\S]*?Számokban[\s\S]*?icon-chevron/, 'The compact card must retain the leaf icon and add a subtle numeric-state affordance with a chevron.');
assert.match(html, /class="history-chapter-metrics-panel" id="history-chapter-metrics-\$\{escapeHtml\(period\.id\)\}" aria-hidden="\$\{String\(!expanded\)\}"\$\{expanded \? '' : ' inert'\}/, 'Collapsed chapter metrics must be semantically hidden and non-focusable without adding a second state owner.');

const pagerRenderer = html.match(/renderHistoryPagerSlide\(period, role\)\s*\{([\s\S]*?)\n        \}\n        renderHistoryFullPagePager/);
assert.ok(pagerRenderer, 'The shared pager slide renderer must remain extractable for the integrated-card contract.');
assert.match(pagerRenderer[1], /history-chapter-info-card[\s\S]*?renderHistoryChapterMetrics\(period\)/, 'The current period identity and metrics must live in one card.');
assert.doesNotMatch(pagerRenderer[1], /renderHistoryPagerSummary/, 'The old lower standalone metrics card must not be rendered below the pager body.');
assert.match(pagerRenderer[1], /history-period-pager-scroll-owner[\s\S]*?\$\{body\}<\/div><\/section>/, 'The body must finish with the one existing vertical scroll owner, without a footer row.');

assert.match(html, /\.history-period-pager-slide\s*\{[^}]*--history-chapter-info-card-height:\s*var\(--path-overview-current-card-height\);[^}]*--history-chapter-body-gap:\s*14px;/, 'Collapsed card geometry must retain the shared 102px card-height token and its original 14px body gap.');
assert.match(html, /data-history-metrics-expanded="true"\]\s+\.history-period-pager-slide\s*\{[^}]*--history-chapter-info-card-height:/, 'Expanded state must change the card-height geometry through one shared slide variable.');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\]\s+\.history-period-pager-body\s*\{[^}]*top:\s*calc\(var\(--history-current-card-top\) \+ var\(--history-chapter-info-card-height\) \+ var\(--history-chapter-body-gap\)\);[^}]*grid-template-rows:\s*minmax\(0,\s*1fr\);/, 'The body must derive its top from the rendered card geometry and must not reserve an old metrics-footer grid row.');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\]\s+\.history-period-pager-body\[data-history-pager-view="timeline"\]\s*\{[^}]*grid-template-rows:\s*43px\s+minmax\(0,\s*1fr\);/, 'Timeline mode must reserve only its fixed heading and its one vertical scroll owner.');
assert.match(html, /historyMetricsRailPointerDown\(event\)[\s\S]*?historyPagerPointerDown\(event\)[\s\S]*?data-history-metrics-rail/, 'The integrated carousel must continue to use the existing scoped rail gesture and pager exclusion.');
assert.match(html, /historyPagerPointerDown\(event\)[\s\S]*?history-card-metrics-toggle/, 'The new leaf toggle must be excluded from the outer period-swipe gesture.');

console.log('PASS integrated History period metrics contract');
