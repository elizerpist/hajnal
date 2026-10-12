'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /historySelectedPeriodId:\s*'current'/, 'History needs one controller-owned selected period ID');
assert.match(html, /getSelectedHistoryPeriod\(\)/, 'the selected period must resolve through one helper');
assert.match(html, /selectHistoryPeriod\(periodId(?:, \{ source = 'tap' \} = \{\})?\) \{/, 'tap and gesture selection must use the one controller-owned finite-track write path');
assert.match(html, /historyWorkspace\.dataset\.historyPeriodCurrent = String\(Boolean\(selected\.current\)\);/, 'the inline workspace must expose the selected period’s existing current flag for visual state only');
assert.match(html, /--history-past-timeline-node-surface:\s*#E6E6E6;/, 'one scoped semantic surface token must own the gray earlier-period Timeline-node background');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-workspace\[data-history-period-current="false"\] \.history-event-node:not\(\[aria-pressed="true"\]\)\s*\{[^}]*background:\s*var\(--history-past-timeline-node-surface\);[^}]*color:\s*var\(--history-past-timeline-node-icon\);/, 'Timeline node background and icon must both be neutral gray only for a selected earlier History period while an actively filtered type keeps its clear selected treatment');
assert.match(html, /\.history-period-pager-slide\[data-history-period-current="false"\] \.history-event-node:not\(\[aria-pressed="true"\]\)\s*\{[^}]*background:\s*var\(--history-past-timeline-node-surface\);[^}]*color:\s*var\(--history-past-timeline-node-icon\);/, 'earlier-period Timeline nodes in the full-hero pager must restore the same gray surface and darker gray icon treatment');
assert.match(html, /const HISTORY_PERIOD_TIMELINES = Object\.freeze\(/, 'all History chapter Timeline content must have one immutable period-keyed data owner');
assert.match(html, /renderSelectedHistoryTimeline\(selected\)\s*\{/, 'the existing History controller needs one neutral renderer for period-specific Timeline events');
assert.match(html, /this\.renderSelectedHistoryTimeline\(selected\);/, 'the selected period must update the already-mounted Timeline through the one renderer');
assert.match(html, /data-component="history-period-timeline-events"/, 'the shared Timeline markup needs one stable event mount rather than a duplicate screen');
['2024-05', '2024-06', '2024-08', '2024-10', '2025-01', '2025-05', '2025-06', '2025-08', '2025-11', 'current'].forEach((periodId) => {
  assert.match(html, new RegExp(`'${periodId}': Object\\.freeze\\(\\{[\\s\\S]{0,120}events: freezeHistoryPeriodTimelineEvents\\(\\[`), `period ${periodId} must own distinct immutable Timeline prototype data`);
});
const timelinePeriodIds = ['2024-05', '2024-06', '2024-08', '2024-10', '2025-01', '2025-05', '2025-06', '2025-08', '2025-11', 'current'];
const timelineSource = html.slice(html.indexOf('const HISTORY_PERIOD_TIMELINES ='), html.indexOf('const HISTORY_CALENDAR_WEEKDAYS ='));
timelinePeriodIds.forEach((periodId, index) => {
  const start = timelineSource.indexOf(`'${periodId}': Object.freeze({`);
  const nextPeriodId = timelinePeriodIds[index + 1];
  const end = nextPeriodId ? timelineSource.indexOf(`'${nextPeriodId}': Object.freeze({`, start + 1) : timelineSource.length;
  const periodSource = timelineSource.slice(start, end);
  const eventCount = (periodSource.match(/\{ id: '/g) || []).length;
  assert.ok(eventCount >= 8, `period ${periodId} must provide at least eight real Timeline events so its Timeline has a meaningful vertical scroll range`);
});
assert.doesNotMatch(html, /data-component="history-period-timeline-month"/, 'History Timeline bodies must not include a redundant period/month heading');
const historyPagerSlideRenderer = html.slice(html.indexOf('renderHistoryPagerSlide(period, role)'), html.indexOf('renderHistoryFullPagePager()', html.indexOf('renderHistoryPagerSlide(period, role)')));
assert.doesNotMatch(historyPagerSlideRenderer, /history-detail-month|aria-label="Előző hónap"|aria-label="Következő hónap"/, 'full-hero Timeline bodies must start directly with events, without month chevrons');
assert.doesNotMatch(html, /beginHistoryCarousel\(/, 'the carousel must not retain a second pointer-swipe state machine beside native scrolling');
assert.match(html, /data-component="history-period-carousel"/, 'History must contain one carousel boundary');
assert.match(html, /data-action="select-history-period"/, 'carousel cards must be tappable buttons');
assert.match(html, /aria-current="\$\{period\.id === selected\.id\}/, 'the active carousel card must expose its selected state on the one finite period track');
assert.match(html, /data-component="history-workspace"/, 'the Történetem body must contain one inline workspace host');
assert.equal((html.match(/<main class="history-workspace history-detail-screen" data-component="history-workspace"/g) || []).length, 1, 'the visible History route must have one workspace host');
assert.equal((html.match(/<main class="history-detail-content" data-component="history-workspace-template"/g) || []).length, 1, 'Timeline and Calendar markup must have one reusable template source');
assert.match(html, /ensureHistoryWorkspace\(\)[\s\S]*history-workspace-mounted[\s\S]*historyWorkspace\.innerHTML = `<section class="history-detail-content"/, 'the inline body must mount the shared workspace source beneath its required grid wrapper');
assert.doesNotMatch(html, /ensureHistoryWorkspace\(\)[\s\S]*historyWorkspace\.innerHTML = this\.historyWorkspaceTemplate\.innerHTML/, 'the inline workspace may not drop the shared detail-content wrapper while mounting');
assert.match(html, /mountedContent = this\.historyWorkspace\.querySelector\?\.\('\[data-component="history-workspace-mounted"\]'\)[\s\S]*if \(mountedContent\) return mountedContent;/, 'a normal History render must retain its existing workspace node rather than remount it');
assert.match(html, /historyWorkspaceRenderCount \+= 1/, 'the controller must count History workspace renders for runtime diagnostics');
assert.match(html, /historyWorkspaceMountCount \+= 1/, 'the controller must count actual History workspace mounts separately from renders');
assert.match(html, /if \(route === 'history-detail'\) route = 'history';/, 'the former detail route must resolve to the same History workspace');
assert.match(html, /data-component="history-workspace-template"[\s\S]*class="history-number-summary"/, 'the existing expandable metrics footer must remain inside the shared workspace source');
assert.doesNotMatch(html, /data-component="history-period-list"/, 'the vertical History list must be removed');
assert.doesNotMatch(html, /data-component="history-overview-layout-toggle"/, 'the obsolete History comparison control must be removed');
assert.doesNotMatch(html, /data-component="history-overview-density-toggle"/, 'the obsolete History density control must be removed');
assert.match(html, /data-component="path-workspace"/, 'the unrelated Ösvény workspace must remain present');
assert.match(html, /\.history-period-carousel \{[^}]*scroll-snap-type: x mandatory;/, 'carousel must use native horizontal snap');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-hero \{ height: var\(--path-overview-hero-height\);/, 'the source-matched History hero geometry must remain explicit');
assert.match(html, /\.history-period-carousel-card \{ --history-carousel-scale: \.77; --history-carousel-opacity: \.82; flex: 0 0 var\(--history-carousel-side-card-width\); height: var\(--history-carousel-active-card-height\); min-height: var\(--history-carousel-active-card-height\); max-height: var\(--history-carousel-active-card-height\);/, 'History2 side cards must remain narrow/subdued while the centre card can occupy its larger source-matched slot');
assert.match(html, /\.history-period-carousel-card\[aria-current="true"\] \{ --history-carousel-scale: 1; --history-carousel-opacity: 1; flex-basis: var\(--history-carousel-active-card-width\);/, 'the selected centre card must own the wider full-image slot');
assert.match(html, /\.history-period-carousel-card:not\(\[aria-current="true"\]\) \{ margin-inline: -8px; \}/, 'the two smaller neighbouring image cards must sit close to the active source-matched centre card without a wide rail gap');
assert.match(html, /\.history-period-carousel \{[^}]*height: var\(--history-carousel-active-card-height\);[^}]*bottom: var\(--history-carousel-card-bottom-inset\);/, 'the carousel rail must reserve the source-matched active-card height and a separate dot row');
assert.match(html, /<div class="history-period-carousel-pagination" data-component="history-period-carousel-pagination" aria-hidden="true"><\/div>/, 'the History hero must provide one decorative carousel indicator host');
assert.match(html, /\.history-period-carousel-pagination \{[^}]*bottom: var\(--history-carousel-indicator-bottom-inset\);/, 'the indicator dots must occupy their own lower-hero row');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-workspace \{[^}]*top: calc\(var\(--path-overview-hero-height\) - var\(--history-inline-workspace-overlap\)\);/, 'the inline workspace must overlap the lower hero so the artwork can fade continuously into its body');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-workspace \.history-detail-content \{[^}]*position: absolute;[^}]*inset: 0;[^}]*height: auto;[^}]*grid-template-rows: minmax\(0, 1fr\) auto;/, 'the inline workspace must remove the obsolete pill row while retaining a definite two-row scroll/footer grid');
assert.doesNotMatch(html, /\.history-screen\[data-history-workspace="inline"\] \.history-workspace \.history-detail-content \{[^}]*position: relative;[^}]*inset: auto;[^}]*height: 100%;/, 'the inline workspace may not fall back to the unbounded relative 100%-height layer chain');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-workspace \.history-detail-panel-slot \{ min-height: 0; overflow-y: auto;[^}]*touch-action: pan-y;/, 'the direct middle grid row must own the inline Timeline scroll range');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-workspace\[data-history-detail-view="timeline"\] \[data-history-detail-panel="timeline"\] \{ display: block; min-height: 100%; height: auto; \}/, 'only the active Timeline state may make the Timeline panel ordinary content inside the direct scroll owner');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-workspace\[data-history-detail-view="timeline"\] \[data-history-detail-panel="timeline"\] \.history-detail-events-scroll \{ min-height: 0; height: auto; overflow: visible; \}/, 'only the active Timeline state may expose its nested event list as ordinary content beneath the direct scroll owner');
assert.match(html, /historyCarouselScaleForDistance\(distance, slotWidth\)/, 'one controller-owned helper must resolve continuous carousel card scales');
assert.match(html, /onHistoryCarouselScroll\(\)/, 'native carousel scroll must drive live card presentation');
assert.match(html, /settleHistoryCarouselScroll\(\)\s*\{[^]*?selectHistoryPeriod\(centeredPeriodId, \{ source: 'swipe' \}\)/, 'settled native swipe selection must commit through the existing selected-period write path');
assert.match(html, /renderHistoryFullPagePager\(\)[\s\S]*?\[\[previous, 'previous'\], \[current, 'current'\], \[next, 'next'\]\]/, 'full-hero mode must pre-render the neighbouring period bodies before movement begins');
assert.match(html, /historyPagerPointerMove\(event\)[\s\S]*?queueHistoryPagerTrack\(clamped\)/, 'full-hero drag must move only its shared pager track in response to the pointer');
assert.doesNotMatch(html, /history-period-body-swipe-translate|syncHistoryPeriodSwipePreview|data-history-period-swipe-commit/, 'full-hero mode may not retain the old separately translated workspace preview');
assert.match(html, /\.history-screen\[data-history-period-presentation="hero-swipe"\] \.history-workspace \{ display: none; \}/, 'the reusable workspace must be inactive while full-page pager slides own their bodies');
assert.doesNotMatch(html, /HISTORY_CAROUSEL_REPEAT_COUNT|data-history-carousel-copy|recenterHistoryCarousel/, 'the withdrawn infinite visual track must not remain in the finite History carousel');
assert.match(html, /renderHistoryCarouselIndicators\(\)[\s\S]*HISTORY_PERIODS\.map\(\(period\) =>/, 'the one carousel controller must derive indicator dots from the immutable source periods');
assert.match(html, /history-period-carousel-indicator\$\{period\.id === selected\.id \? ' is-active' : ''\}/, 'exactly the selected period must receive the active dot style');
assert.match(html, /<h2 id="timeline-number-title">Idővonalam számokban<\/h2>/, 'the shared expandable footer must remain visibly named in the inline workspace');

const historyAssetDirectory = path.join(__dirname, '..', 'assets', 'history');
const requiredHistoryArtwork = [
  'history_hero_soft.png',
  'history_period_2024_05_flat.png',
  'history_period_2024_06_flat.png',
  'history_period_2024_08_flat.png',
  'history_period_2024_10_flat.png',
  'history_period_2025_01_flat.png',
  'history_period_2025_05_flat.png',
  'history_period_2025_06_flat.png',
  'history_period_2025_08_flat.png',
  'history_period_2025_11_flat.png',
  'history_period_current_flat.png'
];
requiredHistoryArtwork.forEach((assetName) => {
  assert.ok(fs.existsSync(path.join(historyAssetDirectory, assetName)), `the History2 visual source requires a real local PNG asset: ${assetName}`);
});
assert.match(html, /const HISTORY_PRESENTATION_HERO_ASSET = 'assets\/history\/history_hero_soft\.png';/, 'the History hero must bind the dedicated soft PNG asset instead of the generic timeline artwork');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-hero-image \{[^}]*opacity: \.78;[^}]*filter: saturate\(\.72\) contrast\(\.88\);/, 'the generated hero must stay visibly atmospheric while remaining less vivid than the card artwork');
assert.match(html, /art: 'assets\/history\/history_period_card_(?:active_1|side_1|side_2)\.png'/, 'the small History carousel must retain its established project-local PNG artwork');
assert.match(html, /heroArt: 'assets\/history\/history_period_(?:\d{4}_\d{2}|current)_flat\.png'/, 'full History heroes must consume their dedicated generated project-local PNG artwork');
const historyPeriodsSource = html.slice(html.indexOf('const HISTORY_PERIODS ='), html.indexOf('const freezeHistoryPeriodTimelineEvents ='));
assert.doesNotMatch(historyPeriodsSource, /assets\/milestones\//, 'the History carousel must not keep milestone SVG art as its card artwork source');
assert.match(html, /\.history-period-carousel-card \{[^}]*position: relative;[^}]*overflow: hidden;/, 'a History2 carousel card must be one full-bleed visual surface, not a split image/text card');
assert.doesNotMatch(html, /\.history-period-carousel-card \{[^}]*grid-template-columns: 52px/, 'a History2 carousel card may not retain the former split image/text grid');
assert.match(html, /\.history-period-carousel-art \{ position: absolute; inset: 0;[^}]*overflow: hidden;[^}]*border-radius: inherit;/, 'the artwork must cover the complete card surface');
assert.match(html, /\.history-period-carousel-card\[aria-current="true"\] \.history-period-carousel-copy \{ color: #fff;/, 'semantic copy on the selected History card must overlay the image in white rather than become baked-in artwork');
assert.match(html, /\.history-period-carousel-card:not\(\[aria-current="true"\]\) \.history-period-carousel-art img \{[^}]*filter: saturate\(/, 'side cards must remain image-based but visually quieter than the active centre card');
assert.doesNotMatch(html, /history2\.png/, 'the visual source reference may never be used as a runtime implementation asset');

console.log('PASS History carousel workspace source contract');
