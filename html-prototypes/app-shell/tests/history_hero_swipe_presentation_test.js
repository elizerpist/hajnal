'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /historyPeriodPresentation:\s*'cards'/, 'History needs one controller-owned cards/hero-swipe presentation state');
assert.match(html, /data-component="history-period-presentation-toggle"/, 'History needs one top-right presentation toggle');
assert.match(html, /data-action="toggle-history-period-presentation"/, 'the top-right control must use the controller intent');
assert.match(html, /toggleHistoryPeriodPresentation\(\)/, 'the controller must own the presentation switch');
assert.match(html, /data-history-period-presentation/, 'the History screen must expose the selected renderer state for scoped CSS');
assert.match(html, /data-history-period-presentation="hero-swipe"/, 'the alternate renderer must be explicitly scoped to hero-swipe');
assert.match(html, /data-component="history-full-page-pager-track"/, 'hero-swipe must use one physical prev/current/next track rather than a hero-only carousel');
assert.match(html, /\.history-full-page-pager-track \{[^}]*display: flex;[^}]*translate3d\(var\(--history-pager-track-x/, 'hero-swipe must move the complete slide strip with one GPU-friendly transform');
assert.match(html, /data-component="history-view-switch"/, 'the History hero needs the requested floating timeline/calendar switch');
assert.match(html, /class="history-inline-view-switch"[^>]*aria-label="Az időszak nézetei"/, 'the floating view switch must be a labelled, compact two-state control');
assert.match(html, /class="history-inline-view-switch"[\s\S]*data-history-detail-tab="timeline"[\s\S]*data-history-detail-tab="calendar"/, 'the switch must retain both existing History view intents');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.period-detail-tabs \{ display: none; \}/, 'the old text pill must not stay at the top of the inline History body');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-workspace \.history-detail-content \{[^}]*grid-template-rows: minmax\(0, 1fr\) auto;/, 'removing the body pill must also remove its empty grid row');
assert.match(html, /--history-inline-body-surface:\s*var\(--screen-background\);/, 'the inline History screen must share the same semantic body surface as Path');
assert.match(html, /--history-inline-hero-fade-extension:\s*80px;/, 'the inline History artwork needs a bounded body-overlap extension');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\]\s*\{[^}]*background:\s*var\(--history-inline-body-surface\);/, 'the inline History screen itself must expose the same surface behind the artwork and workspace');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-hero\s*\{[^}]*height:\s*var\(--path-overview-hero-height\);[^}]*overflow:\s*visible;[^}]*background:\s*var\(--history-inline-body-surface\);/, 'the fixed-height hero must allow only its decorative artwork to extend into the workspace overlap');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-hero-image\s*\{[^}]*height:\s*calc\(100% \+ var\(--history-inline-hero-fade-extension\)\);[^}]*-webkit-mask-image:\s*var\(--history-inline-hero-fade-mask\);[^}]*mask-image:\s*var\(--history-inline-hero-fade-mask\);/, 'the cards-presentation image must remain one visual owner while fading below the hero boundary');
assert.match(html, /\.history-period-pager-hero \{ height: var\(--path-overview-hero-height\);/, 'each full-page slide must retain the source-matched 238px hero geometry');
assert.match(html, /\.history-period-pager-copy \{[^}]*right: 88px;[^}]*bottom: 13px;[^}]*gap: 5px;/, 'each slide must keep its period and clean-day copy bottom-aligned below the static controls');
assert.doesNotMatch(html, /history-period-pager-dots|historyPagerDots\(/, 'full-hero mode must not duplicate the cards-layout carousel indicators');
assert.match(html, /data-history-period-presentation="hero-swipe"\] \.history-hero-copy\s*\{[^}]*display:\s*block;[^}]*text-align:\s*left;/, 'full-hero mode must retain the static Történetem heading at the upper left');
assert.match(html, /\.history-period-pager-body \{[^}]*top: 244px;[^}]*grid-template-rows: minmax\(0, 1fr\) auto;/, 'the body must retain a definite scroll/footer grid below the hero');
assert.match(html, /--hero-art-vertical-fade-mask:\s*linear-gradient\(180deg,[^;]+transparent 100%\)/, 'one semantic vertical alpha-mask token must own the natural hero-to-body fade');
assert.match(html, /\.history-period-pager-art \{[^}]*height: calc\(100% \+ var\(--history-inline-hero-fade-extension\)\);[^}]*-webkit-mask-image: var\(--history-inline-hero-fade-mask\);[^}]*mask-image: var\(--history-inline-hero-fade-mask\);/, 'History hero-swipe must fade each slide artwork alpha itself rather than paint an opaque body color over it');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-workspace \.history-detail-content\s*\{[^}]*background:\s*transparent;/, 'the workspace content must remain transparent through the artwork overlap');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-workspace\s*\{[^}]*top:\s*calc\(var\(--path-overview-hero-height\) - var\(--history-inline-workspace-overlap\)\);/, 'the overlap must retain the already-proven workspace geometry');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-workspace \.history-detail-panel-slot\s*\{[^}]*overflow-y:\s*auto;[^}]*touch-action:\s*pan-y;/, 'the fade repair may not alter the one direct Timeline scroll owner');
assert.match(html, /data-history-period-current="\$\{Boolean\(period\.current\)\}"/, 'each History period must expose whether it is the actual current chapter, independently from carousel selection');
assert.match(html, /\.history-period-pager-slide\[data-history-period-current="false"\] \.history-period-pager-art img\s*\{[^}]*filter: grayscale\(1\)/, 'an older chapter hero must render in grayscale even when its slide is selected');
assert.doesNotMatch(html, /\.history-period-pager-slide\[data-history-period-current="true"\][^{]*\.history-period-pager-art img\s*\{[^}]*filter:/, 'the current chapter must remain the only vivid hero');
assert.match(html, /\.path-screen\[data-path-view="overview"\]::before\s*\{[^}]*-webkit-mask-image:\s*var\(--hero-art-vertical-fade-mask\);[^}]*mask-image:\s*var\(--hero-art-vertical-fade-mask\);/, 'the Path overview hero must reuse the same natural alpha-mask technique');
assert.doesNotMatch(html, /history-period-body-swipe-translate|syncHistoryPeriodSwipePreview/, 'History hero-swipe may not retain a separately animated body preview');

console.log('PASS History hero-swipe presentation source contract');
