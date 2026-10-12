'use strict';

/*
 * Real Chromium/CDP touch regression for the History full-page pager.
 *
 * Run in Ubuntu/proot:
 * NODE_PATH=/tmp/hajnal-playwright/node_modules \
 * PLAYWRIGHT_CHROMIUM_EXECUTABLE=/home/flutteruser/.cache/ms-playwright/chromium-1169/chrome-linux/chrome \
 * HISTORY_PAGER_RUNTIME_ARTIFACT_DIR=/tmp/hajnal-history-pager-runtime \
 * node html-prototypes/app-shell/tests/history_full_page_pager_runtime_test.js
 */

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const http = require('node:http');
const path = require('node:path');

let chromium;
try {
  ({ chromium } = require('playwright'));
} catch (error) {
  console.error('BLOCKED: this runtime test requires Playwright/Chromium.', error.message);
  process.exit(2);
}

const prototypeRoot = path.resolve(__dirname, '..', '..');
const appShellFile = path.join(prototypeRoot, 'app-shell', 'index.html');
const expectedHash = crypto.createHash('sha256').update(fs.readFileSync(appShellFile)).digest('hex');
const artifactDirectory = process.env.HISTORY_PAGER_RUNTIME_ARTIFACT_DIR || '/tmp/hajnal-history-pager-runtime';
fs.mkdirSync(artifactDirectory, { recursive: true });

function contentType(file) {
  if (file.endsWith('.html')) return 'text/html; charset=utf-8';
  if (file.endsWith('.js')) return 'text/javascript; charset=utf-8';
  if (file.endsWith('.png')) return 'image/png';
  if (file.endsWith('.svg')) return 'image/svg+xml';
  return 'application/octet-stream';
}

function startStaticServer() {
  const server = http.createServer((request, response) => {
    const rawPath = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
    const requested = rawPath === '/' ? '/app-shell/index.html' : rawPath.endsWith('/') ? `${rawPath}index.html` : rawPath;
    const resolved = path.resolve(prototypeRoot, `.${requested}`);
    if (!resolved.startsWith(`${prototypeRoot}${path.sep}`)) return response.writeHead(403).end('Forbidden');
    fs.readFile(resolved, (error, body) => {
      if (error) return response.writeHead(error.code === 'ENOENT' ? 404 : 500).end('Not found');
      response.writeHead(200, { 'content-type': contentType(resolved), 'cache-control': 'no-store' }).end(body);
    });
  });
  return new Promise((resolve) => server.listen(0, '127.0.0.1', () => resolve(server)));
}

async function attachPagerTrace(page) {
  await page.evaluate(() => {
    const pager = document.querySelector('[data-component="history-full-page-pager"]');
    const track = document.querySelector('[data-component="history-full-page-pager-track"]');
    const screen = document.querySelector('[data-component="sobriety-batch-history"]');
    const trace = { events: [], mutations: [], renders: [], snapshots: [] };
    const describe = (element) => element ? {
      tag: element.tagName,
      id: element.id || '',
      className: String(element.className || ''),
      component: element.dataset?.component || '',
      periodId: element.dataset?.historyPeriodId || ''
    } : null;
    const trackX = () => {
      const transform = getComputedStyle(track).transform;
      if (!transform || transform === 'none') return 0;
      return new DOMMatrixReadOnly(transform).m41;
    };
    const snapshot = (label, event = null) => {
      const body = event
        ? document.elementFromPoint(event.clientX, event.clientY)?.closest?.('[data-history-pager-scroll-owner]')
        : track.querySelector('[data-history-pager-role="current"] [data-history-pager-scroll-owner]');
      const slides = [...track.querySelectorAll('.history-period-pager-slide')].map((slide) => {
        const rect = slide.getBoundingClientRect();
        return { id: slide.dataset.historyPeriodId, role: slide.dataset.historyPagerRole, left: rect.left, right: rect.right, width: rect.width, hidden: slide.getAttribute('aria-hidden'), pointerEvents: getComputedStyle(slide).pointerEvents };
      });
      return {
        label,
        now: performance.now(),
        presentation: screen.dataset.historyPeriodPresentation,
        trackX: trackX(),
        trackTransform: getComputedStyle(track).transform,
        trackSettling: track.dataset.historyPagerSettling,
        pagerScrollLeft: pager.scrollLeft,
        bodyScrollTop: body?.scrollTop ?? null,
        activePeriodId: track.querySelector('[data-history-pager-role="current"]')?.dataset.historyPeriodId || '',
        slides,
        hit: event ? document.elementsFromPoint(event.clientX, event.clientY).slice(0, 8).map(describe) : []
      };
    };
    const record = (event) => {
      const eventSnapshot = snapshot(event.type, event);
      trace.events.push({
        ...eventSnapshot,
        type: event.type,
        pointerId: event.pointerId ?? null,
        pointerType: event.pointerType || '',
        isPrimary: event.isPrimary ?? null,
        cancelable: event.cancelable,
        defaultPrevented: event.defaultPrevented,
        target: describe(event.target),
        currentTarget: describe(event.currentTarget),
        clientX: event.clientX ?? null,
        clientY: event.clientY ?? null,
        hasPointerCapture: event.pointerId !== undefined ? pager.hasPointerCapture(event.pointerId) : false
      });
    };
    for (const type of ['pointerdown', 'pointermove', 'pointerup', 'pointercancel', 'gotpointercapture', 'lostpointercapture', 'touchstart', 'touchmove', 'touchend', 'touchcancel']) {
      pager.addEventListener(type, record, { capture: true, passive: true });
    }
    window.addEventListener('resize', () => trace.events.push({ ...snapshot('window-resize'), type: 'window-resize' }), { passive: true });
    window.visualViewport?.addEventListener('resize', () => trace.events.push({ ...snapshot('visual-viewport-resize'), type: 'visual-viewport-resize' }), { passive: true });
    new MutationObserver((records) => {
      trace.mutations.push(...records.map((record) => ({ now: performance.now(), type: record.type, added: record.addedNodes.length, removed: record.removedNodes.length, target: describe(record.target), snapshot: snapshot('mutation') })));
    }).observe(track, { childList: true, subtree: true });
    window.__hajnalHistoryPagerTrace = trace;
    window.__hajnalHistoryPagerSnapshot = (label) => {
      const value = snapshot(label);
      trace.snapshots.push(value);
      return value;
    };
  });
}

async function pagerSnapshot(page, label) {
  return page.evaluate((nextLabel) => window.__hajnalHistoryPagerSnapshot(nextLabel), label);
}

async function touchDrag(cdp, page, {
  selector,
  deltaX = 0,
  deltaY = 0,
  pointerId = 9,
  steps = 5,
  pauseMs = 20,
  snapshotLabel = '',
  screenshotName = ''
}) {
  const box = await page.locator(selector).first().boundingBox();
  assert.ok(box, `A visible target is required for the ${snapshotLabel || 'touch'} gesture.`);
  const startX = Math.round(box.x + (box.width * .50));
  const startY = Math.round(box.y + (box.height * .50));
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: startX, y: startY, id: pointerId }] });
  for (let index = 1; index <= steps; index += 1) {
    await cdp.send('Input.dispatchTouchEvent', {
      type: 'touchMove',
      touchPoints: [{ x: Math.round(startX + ((deltaX * index) / steps)), y: Math.round(startY + ((deltaY * index) / steps)), id: pointerId }]
    });
    await page.waitForTimeout(pauseMs);
  }
  const partial = snapshotLabel ? await pagerSnapshot(page, snapshotLabel) : null;
  if (screenshotName) await page.screenshot({ path: path.join(artifactDirectory, screenshotName), fullPage: false });
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await page.waitForTimeout(420);
  return partial;
}

(async () => {
  const server = await startStaticServer();
  const port = server.address().port;
  const served = await fetch(`http://127.0.0.1:${port}/app-shell/index.html`).then((response) => response.text());
  assert.equal(crypto.createHash('sha256').update(served).digest('hex'), expectedHash, 'The browser runtime server must serve this exact working tree.');
  const browser = await chromium.launch({ headless: true, executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE || undefined, args: ['--no-sandbox', '--disable-dev-shm-usage'] });
  try {
    const context = await browser.newContext({ viewport: { width: 412, height: 892 }, deviceScaleFactor: 1, isMobile: true, hasTouch: true });
    const page = await context.newPage();
    const cdp = await context.newCDPSession(page);
    await page.goto(`http://127.0.0.1:${port}/app-shell/?history-pager-runtime=1&history-pager-debug=1`, { waitUntil: 'domcontentloaded' });
    await page.locator('[data-component="bottom-navigation"] [data-action="open-history"]').click();
    await page.locator('[data-component="history-period-presentation-toggle"]').click();
    await page.waitForTimeout(160);
    await attachPagerTrace(page);
    const before = await pagerSnapshot(page, 'before');
    await page.screenshot({ path: path.join(artifactDirectory, 'history-pager-0-percent.png'), fullPage: false });
    assert.equal(before.presentation, 'hero-swipe', 'The full-page pager test must exercise hero-swipe presentation.');
    assert.equal(before.activePeriodId, 'current', 'The current/latest period is the starting slide and must swipe right to its previous neighbor.');
    const partial = await touchDrag(cdp, page, {
      selector: '[data-history-pager-role="current"] .history-detail-event',
      deltaX: 176,
      pointerId: 9,
      snapshotLabel: 'partial-40-percent-right',
      screenshotName: 'history-pager-40-percent.png'
    });
    const after = await pagerSnapshot(page, 'after-settle');
    await page.screenshot({ path: path.join(artifactDirectory, 'history-pager-100-percent.png'), fullPage: false });
    const initialGestureEvents = await page.evaluate(() => window.__hajnalHistoryPagerTrace.events.slice());

    const reversePartial = await touchDrag(cdp, page, {
      selector: '[data-history-pager-role="current"] .history-detail-event',
      deltaX: -176,
      pointerId: 10,
      snapshotLabel: 'partial-40-percent-left'
    });
    const afterReverse = await pagerSnapshot(page, 'after-reverse-settle');

    const beforeShortDrag = await pagerSnapshot(page, 'before-short-drag');
    await touchDrag(cdp, page, {
      selector: '[data-history-pager-role="current"] .history-detail-event',
      deltaX: 70,
      pointerId: 11,
      steps: 12,
      pauseMs: 70,
      snapshotLabel: 'partial-short-right'
    });
    const afterShortDrag = await pagerSnapshot(page, 'after-short-drag');

    const beforeVertical = await pagerSnapshot(page, 'before-vertical-scroll');
    await touchDrag(cdp, page, {
      selector: '[data-history-pager-role="current"] [data-history-pager-scroll-owner]',
      deltaY: -250,
      pointerId: 12,
      steps: 8,
      snapshotLabel: 'after-vertical-scroll'
    });
    const afterVertical = await pagerSnapshot(page, 'after-vertical-scroll-settle');

    await page.locator('[data-component="history-view-switch"] [data-history-detail-tab="calendar"]').click();
    await page.waitForTimeout(120);
    const beforeRail = await pagerSnapshot(page, 'before-calendar-rail');
    await touchDrag(cdp, page, {
      selector: '[data-history-pager-role="current"] [data-history-pager-calendar-rail]',
      deltaX: -150,
      pointerId: 13,
      snapshotLabel: 'after-calendar-rail'
    });
    const afterRail = await pagerSnapshot(page, 'after-calendar-rail-settle');
    await page.locator('[data-component="history-view-switch"] [data-history-detail-tab="timeline"]').click();
    await page.waitForTimeout(120);

    const beforeModeRace = await pagerSnapshot(page, 'before-mode-toggle-race');
    const raceBox = await page.locator('[data-history-pager-role="current"] .history-detail-event').first().boundingBox();
    assert.ok(raceBox, 'The mode-switch race must start from a visible event card.');
    const raceX = Math.round(raceBox.x + (raceBox.width / 2));
    const raceY = Math.round(raceBox.y + (raceBox.height / 2));
    await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: raceX, y: raceY, id: 14 }] });
    await cdp.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: raceX + 176, y: raceY, id: 14 }] });
    await page.waitForTimeout(35);
    await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
    await page.locator('[data-component="history-period-presentation-toggle"]').click();
    await page.waitForTimeout(420);
    const afterModeRace = await page.evaluate(() => ({
      presentation: document.querySelector('[data-component="sobriety-batch-history"]')?.dataset.historyPeriodPresentation || '',
      activeCard: document.querySelector('.history-period-carousel-card[aria-current="true"]')?.dataset.historyPeriodId || ''
    }));
    await page.locator('[data-component="history-period-presentation-toggle"]').click();
    await page.waitForTimeout(140);

    const diagnostics = await page.evaluate(() => window.__hajnalHistoryPagerDebug);
    const trace = await page.evaluate(() => window.__hajnalHistoryPagerTrace);
    fs.writeFileSync(path.join(artifactDirectory, 'history-pager-touch-trace.json'), JSON.stringify({ expectedHash, before, partial, after, reversePartial, afterReverse, beforeShortDrag, afterShortDrag, beforeVertical, afterVertical, beforeRail, afterRail, beforeModeRace, afterModeRace, diagnostics, trace }, null, 2));

    const previous = partial.slides.find((slide) => slide.role === 'previous');
    const current = partial.slides.find((slide) => slide.role === 'current');
    assert.ok(initialGestureEvents.some((event) => event.type === 'pointerdown'), 'A body event-card touch must reach the pager pointer listener.');
    assert.ok(initialGestureEvents.some((event) => event.type === 'pointermove'), 'A body event-card touch must continue to deliver pointer movement to the pager.');
    assert.equal(initialGestureEvents.some((event) => event.type === 'pointercancel'), false, 'A right swipe from an event card may not be cancelled by native gesture arbitration.');
    assert.ok(partial.trackX > before.trackX + 120, 'At 40% right drag the shared track must follow the finger by a material distance.');
    assert.ok(previous && current && previous.right > 0 && current.left < 412, 'At 40% both the previous and current full slides must be physically visible.');
    assert.ok(Math.abs(previous.right - current.left) < 2, 'The entering and leaving slides may not have a white horizontal gap.');
    assert.equal(after.activePeriodId, '2025-11', 'Releasing a sufficient right drag from the latest period must settle on the immediately previous period.');
    const reverseCurrent = reversePartial.slides.find((slide) => slide.role === 'current');
    const reverseNext = reversePartial.slides.find((slide) => slide.role === 'next');
    assert.ok(reverseCurrent && reverseNext && reverseCurrent.right > 0 && reverseNext.left < 412, 'A left drag from the previous period must preview the next full slide before release.');
    assert.equal(afterReverse.activePeriodId, 'current', 'A left drag from the previous period must return to the latest/current period.');
    assert.equal(afterShortDrag.activePeriodId, beforeShortDrag.activePeriodId, 'A slow drag below the distance and velocity thresholds must naturally return to its original period.');
    assert.ok(Math.abs(afterShortDrag.trackX - beforeShortDrag.trackX) < 2, 'A rejected short drag must restore the shared track origin.');
    assert.equal(afterVertical.activePeriodId, beforeVertical.activePeriodId, 'A vertical Timeline gesture may not change the selected period.');
    assert.ok(afterVertical.bodyScrollTop > beforeVertical.bodyScrollTop, 'A vertical Timeline gesture must move the one period-local native scroll owner.');
    assert.ok(Math.abs(afterVertical.trackX - beforeVertical.trackX) < 2, 'A vertical Timeline gesture may not displace the full-page track.');
    assert.equal(afterRail.activePeriodId, beforeRail.activePeriodId, 'The calendar rail must keep priority over the outer full-page pager.');
    assert.ok(Math.abs(afterRail.trackX - beforeRail.trackX) < 2, 'A calendar-rail pan may not displace the outer full-page track.');
    assert.equal(afterModeRace.presentation, 'cards', 'Changing presentation during an in-flight settle must leave the requested cards presentation active.');
    assert.equal(afterModeRace.activeCard, beforeModeRace.activePeriodId, 'An invalidated settle timer may not commit an obsolete period after the mode changes.');
    assert.ok(Array.isArray(diagnostics?.events), 'The query-gated pager diagnostic must expose a structured runtime event trace without permanent production logging.');
    assert.ok(diagnostics.events.some((event) => event.type === 'lostpointercapture' && event.pagerHasPointerCapture), 'The diagnostic trace must prove the nested implicit-capture hand-off that previously cancelled the drag.');
    assert.ok(diagnostics.operations.some((operation) => operation.type === 'render-history-full-page-pager'), 'The diagnostic trace must record pager rendering without rebuilding the track during drag.');
    console.log(JSON.stringify({ artifactDirectory, before, partial, after, eventTypes: trace.events.map((event) => event.type), diagnosticEventTypes: diagnostics.events.map((event) => event.type) }, null, 2));
    await context.close();
  } finally {
    await browser.close();
    await new Promise((resolve) => server.close(resolve));
  }
})().then(() => console.log('PASS History full-page pager real-touch regression')).catch((error) => {
  console.error(error.stack || error);
  process.exitCode = 1;
});
