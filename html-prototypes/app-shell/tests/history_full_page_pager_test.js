const assert = require('assert');
const fs = require('fs');
const path = require('path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /data-component="history-full-page-pager"/, 'Hero-swipe needs one dedicated full-page pager viewport.');
assert.match(html, /data-component="history-full-page-pager-track"/, 'Hero-swipe needs one common movable track.');
assert.match(html, /renderHistoryFullPagePager\(\)/, 'The controller must render prev/current/next slides before a gesture.');
assert.match(html, /renderHistoryPagerSlide\(period, role\)/, 'One renderer must project a period into a pager slide.');
assert.match(html, /historyPagerPreviousPeriod\(/, 'Pager must resolve a previous period without duplicating selection state.');
assert.match(html, /historyPagerNextPeriod\(/, 'Pager must resolve a next period without duplicating selection state.');
assert.match(html, /historyPagerPointerDown\(event\)/, 'Pager needs a controller-owned pointer gesture start.');
assert.match(html, /historyPagerPointerMove\(event\)/, 'Pager needs interactive drag preview.');
assert.match(html, /historyPagerPointerEnd\(event\)/, 'Pager must settle the track from pointer release.');
assert.match(html, /Math\.abs\(deltaX\)\s*>\s*Math\.abs\(deltaY\)\s*\*\s*1\.25/, 'Horizontal gesture intent must have a stable directional lock.');
assert.match(html, /Math\.abs\(deltaY\)\s*>\s*Math\.abs\(deltaX\)\s*\*\s*1\.25/, 'Vertical gesture intent must preserve native scroll.');
assert.match(html, /historyPagerTrackX/, 'Only the shared track transform should be updated during drag.');
assert.match(html, /translate3d\(var\(--history-pager-track-x(?:,\s*-100%)?\)/, 'Pager motion must be transform-based.');
assert.match(html, /data-history-pager-scroll-owner/, 'Each pager slide needs the one explicit vertical scroll owner.');
assert.match(html, /historyPagerScrollPositions/, 'Period-local scroll positions must have one controller-owned map.');
assert.match(html, /finishHistoryPagerSettle\(token = this\.historyPagerSettle\?\.token\)[\s\S]*?selectHistoryPeriod\(settle\.targetId,\s*\{\s*source:\s*'pager'\s*\}\)/, 'The selected period must commit only from the lifecycle-guarded pager settle.');
assert.match(html, /history-period-pager-slide/, 'A slide must contain hero and body together, not two synchronized sibling animations.');
assert.match(html, /data-history-pager-role="\$\{role\}"\$\{role === 'current' \? '' : ' aria-hidden="true" inert'\}/, 'Offscreen slides must be pre-rendered but neither focusable nor tappable.');
assert.match(html, /historyPagerPointerDown\(event\)[\s\S]*?history-pager-calendar-rail/, 'The calendar rail must retain priority over the outer chapter pager.');
assert.match(html, /historyPagerPointerMove\(event\)[\s\S]*?Math\.max\(Math\.abs\(deltaX\), Math\.abs\(deltaY\)\) >= 12/, 'The pager must defer axis commitment through a small initial touch threshold.');
assert.match(html, /historyPagerPointerEnd\(event\)[\s\S]*?drag\.width \* \.25[\s\S]*?\.45/, 'Settle must use both distance and velocity thresholds.');
assert.match(html, /clearHistoryPagerTrackFrame\(\)[\s\S]*?cancelAnimationFrame/, 'A shared cleanup must cancel a queued drag frame before it can overwrite a settled position.');
assert.match(html, /settleHistoryPager\(target\)[\s\S]*?clearHistoryPagerTrackFrame\(\)/, 'Settling must clear a stale drag frame before its final transform is written.');
assert.match(html, /cancelHistoryPagerGesture\([\s\S]*?clearHistoryPagerTrackFrame\(\)/, 'Pointer cancellation must restore the track without a stale queued transform race.');
assert.match(html, /historyPagerLostPointerCapture\(event\)[\s\S]*?!drag \|\| drag\.pointerId !== event\.pointerId \|\| this\.historyPagerLifecycle === 'settling'/, 'A normal post-pointerup lost capture must not cancel a release-owned settle.');
assert.match(html, /clearHistoryPagerSettle\(\)[\s\S]*?historyPagerSettleToken \+= 1[\s\S]*?historyPagerSettle = null/, 'Cancelling, resizing, or mode switching must invalidate stale settle callbacks.');
assert.match(html, /historyPagerPointerCancel\(event\)[\s\S]*?drag\.axis === 'horizontal'[\s\S]*?historyPagerLifecycle = 'idle'/, 'Vertical native cancellation must not create a horizontal settling lock.');
assert.match(html, /\.history-period-pager-scroll-owner \{ min-height: 0; overflow-y: auto;[^}]*touch-action: pan-y;/, 'The pager must preserve one native vertical Timeline scroll owner per active slide.');
assert.match(html, /data-history-period-presentation="hero-swipe"\][\s\S]{0,1200}\.history-full-page-pager\s*\{[^}]*display:\s*block/, 'The common pager must be visible only in hero-swipe mode.');
assert.match(html, /data-history-period-presentation="hero-swipe"\][\s\S]{0,1800}\.history-workspace\s*\{[^}]*display:\s*none/, 'The old detached workspace must not run in parallel in hero-swipe mode.');

console.log('history_full_page_pager_test: PASS');
