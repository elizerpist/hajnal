'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /historySelectedPeriodId:\s*'current'/, 'History needs one controller-owned selected period ID');
assert.match(html, /getSelectedHistoryPeriod\(\)/, 'the selected period must resolve through one helper');
assert.match(html, /selectHistoryPeriod\(periodId\)/, 'tap and gesture selection must use one write path');
assert.match(html, /moveHistoryCarousel\(direction\)/, 'swipe selection must reuse the same selection state');
assert.match(html, /data-component="history-period-carousel"/, 'History must contain one carousel boundary');
assert.match(html, /data-action="select-history-period"/, 'carousel cards must be tappable buttons');
assert.match(html, /aria-current="\$\{period\.id === selected\.id\}/, 'the active carousel card must expose its selected state');
assert.match(html, /data-component="history-workspace"/, 'the Történetem body must contain one inline workspace host');
assert.equal((html.match(/<main class="history-workspace history-detail-screen" data-component="history-workspace"/g) || []).length, 1, 'the visible History route must have one workspace host');
assert.equal((html.match(/<main class="history-detail-content" data-component="history-workspace-template"/g) || []).length, 1, 'Timeline and Calendar markup must have one reusable template source');
assert.match(html, /ensureHistoryWorkspace\(\)[\s\S]*historyWorkspace\.innerHTML = this\.historyWorkspaceTemplate\.innerHTML/, 'the inline body must reuse the existing workspace source instead of owning a second renderer');
assert.match(html, /if \(route === 'history-detail'\) route = 'history';/, 'the former detail route must resolve to the same History workspace');
assert.match(html, /data-component="history-workspace-template"[\s\S]*class="history-number-summary"/, 'the existing expandable metrics footer must remain inside the shared workspace source');
assert.doesNotMatch(html, /data-component="history-period-list"/, 'the vertical History list must be removed');
assert.doesNotMatch(html, /data-component="history-overview-layout-toggle"/, 'the obsolete History comparison control must be removed');
assert.doesNotMatch(html, /data-component="history-overview-density-toggle"/, 'the obsolete History density control must be removed');
assert.match(html, /data-component="path-workspace"/, 'the unrelated Ösvény workspace must remain present');
assert.match(html, /\.history-period-carousel \{[^}]*scroll-snap-type: x mandatory;/, 'carousel must use native horizontal snap');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-hero \{ height: var\(--path-overview-hero-height\);/, 'the original 238px hero geometry must remain explicit');
assert.match(html, /\.history-period-carousel-card \{ flex: 0 0 198px; min-height: 62px;/, 'period tiles must stay compact inside the fixed hero');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-workspace \{[^}]*top: var\(--path-overview-hero-height\);/, 'the inline workspace must begin directly below the hero');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-workspace \.history-detail-content \{[^}]*height: 100%;[^}]*position: relative;[^}]*grid-template-rows: 44px minmax\(0, 1fr\) auto;/, 'tabs, one scrollable content row, and the footer must share one stable workspace grid');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-workspace \[data-history-detail-panel="timeline"\] \.history-detail-events-scroll \{ min-height: 0; overflow-y: auto;/, 'only the timeline content below the tabs may own vertical scrolling');
assert.match(html, /<h2 id="timeline-number-title">Idővonalam számokban<\/h2>/, 'the shared expandable footer must remain visibly named in the inline workspace');

console.log('PASS History carousel workspace source contract');
