#!/usr/bin/env node
'use strict';

/*
 * No-Playwright Chromium/CDP runtime proof for the History metrics rail.
 *
 * Start Chromium separately, for example in Ubuntu/proot:
 * /home/flutteruser/.cache/ms-playwright/chromium-1169/chrome-linux/chrome \
 *   --headless=new --no-sandbox --remote-debugging-address=127.0.0.1 \
 *   --remote-debugging-port=9222 about:blank
 *
 * Then run:
 * node html-prototypes/app-shell/tests/history_metrics_horizontal_scroll_runtime_test.js
 */

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const http = require('node:http');
const path = require('node:path');

const cdpHttpEndpoint = process.env.HISTORY_METRICS_CDP_HTTP_ENDPOINT || 'http://127.0.0.1:9222';
const prototypeRoot = path.resolve(__dirname, '..', '..');
const appShellFile = path.join(prototypeRoot, 'app-shell', 'index.html');
const expectedHash = crypto.createHash('sha256').update(fs.readFileSync(appShellFile)).digest('hex');
// Termux's shared /tmp can be owned by the Android shell user. Keep evidence
// outside the worktree by default, but in a directory the local test user owns.
const artifactDirectory = process.env.HISTORY_METRICS_RUNTIME_ARTIFACT_DIR || '/data/data/com.termux/files/usr/tmp/hajnal-history-metrics-runtime';

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

class CdpClient {
  constructor(webSocketUrl) {
    this.webSocketUrl = webSocketUrl;
    this.sequence = 0;
    this.pending = new Map();
  }

  async connect() {
    this.socket = new WebSocket(this.webSocketUrl);
    await new Promise((resolve, reject) => {
      this.socket.addEventListener('open', resolve, { once: true });
      this.socket.addEventListener('error', reject, { once: true });
    });
    this.socket.addEventListener('message', (event) => {
      const message = JSON.parse(event.data);
      const pending = this.pending.get(message.id);
      if (!pending) return;
      this.pending.delete(message.id);
      if (message.error) pending.reject(new Error(`${message.error.message} (${pending.method})`));
      else pending.resolve(message.result || {});
    });
  }

  send(method, params = {}) {
    const id = ++this.sequence;
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`Timed out waiting for CDP ${method}`));
      }, 12000);
      this.pending.set(id, {
        method,
        resolve: (result) => { clearTimeout(timeout); resolve(result); },
        reject: (error) => { clearTimeout(timeout); reject(error); }
      });
      this.socket.send(JSON.stringify({ id, method, params }));
    });
  }

  close() { this.socket?.close(); }
}

const delay = (milliseconds) => new Promise((resolve) => setTimeout(resolve, milliseconds));

async function waitFor(page, expression, description) {
  const deadline = Date.now() + 5000;
  let lastValue;
  while (Date.now() < deadline) {
    lastValue = await evalValue(page, expression);
    if (lastValue) return;
    await delay(50);
  }
  throw new Error(`Timed out waiting for ${description}; last value: ${JSON.stringify(lastValue)}`);
}

async function evalValue(page, expression) {
  const { result, exceptionDetails } = await page.send('Runtime.evaluate', { expression, awaitPromise: true, returnByValue: true, userGesture: true });
  if (exceptionDetails) throw new Error(exceptionDetails.text || 'Runtime evaluation failed');
  return result.value;
}

async function click(page, selector) {
  const found = await evalValue(page, `(() => { const element = document.querySelector(${JSON.stringify(selector)}); if (!element) return false; element.click(); return true; })()`);
  assert.equal(found, true, `Expected interactive element: ${selector}`);
  await delay(110);
}

async function openHistory(page) {
  const selector = '[data-component="bottom-navigation"] [data-action="open-history"]';
  const deadline = Date.now() + 5000;
  while (Date.now() < deadline) {
    await click(page, selector);
    if (await evalValue(page, "document.querySelector('.app-frame')?.dataset.route === 'history'")) return;
    await delay(90);
  }
  throw new Error('The app shell did not bind the History navigation action in time.');
}

async function touchDrag(page, selector, deltaX, pointerId) {
  const box = await evalValue(page, `(() => { const element = document.querySelector(${JSON.stringify(selector)}); const rect = element?.getBoundingClientRect(); return rect ? { x: rect.x, y: rect.y, width: rect.width, height: rect.height } : null; })()`);
  assert.ok(box, `A visible touch target is required: ${selector}`);
  const startX = Math.round(box.x + (box.width * .62));
  const startY = Math.round(box.y + (box.height * .5));
  await page.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: startX, y: startY, id: pointerId }] });
  for (let step = 1; step <= 7; step += 1) {
    await page.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: Math.round(startX + ((deltaX * step) / 7)), y: startY, id: pointerId }] });
    await delay(18);
  }
  await page.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await delay(150);
}

async function screenshot(page, filename) {
  const { data } = await page.send('Page.captureScreenshot', { format: 'png', captureBeyondViewport: false });
  fs.writeFileSync(path.join(artifactDirectory, filename), Buffer.from(data, 'base64'));
}

function metricsSnapshotExpression(mode) {
  const selector = mode === 'hero'
    ? '[data-history-pager-role="current"] .history-chapter-info-card'
    : '[data-component="history-workspace"] .history-number-summary';
  return `(() => {
    const summary = document.querySelector(${JSON.stringify(selector)});
    const rail = summary?.querySelector('[data-history-metrics-rail]');
    const body = ${mode === 'hero'
      ? "document.querySelector('[data-history-pager-role=\"current\"] .history-period-pager-body')"
      : "document.querySelector('[data-component=\"history-workspace\"] .history-detail-content')"};
    const rect = (element) => { const value = element?.getBoundingClientRect(); return value ? { left: value.left, right: value.right, width: value.width, height: value.height, top: value.top, bottom: value.bottom } : null; };
    const railRect = rect(rail);
    const hit = railRect ? document.elementsFromPoint(railRect.left + Math.min(18, railRect.width / 2), railRect.top + Math.min(18, (railRect.bottom - railRect.top) / 2)).map((element) => String(element.className || '')) : [];
    return {
      periodId: document.querySelector('[data-history-pager-role="current"]')?.dataset.historyPeriodId || document.querySelector('.history-period-carousel-card[aria-current="true"]')?.dataset.historyPeriodId || '',
      body: rect(body), summary: rect(summary),
      rail: rail ? { ...railRect, clientWidth: rail.clientWidth, scrollWidth: rail.scrollWidth, scrollLeft: rail.scrollLeft, touchAction: getComputedStyle(rail).touchAction } : null,
      lastCard: rect(rail?.querySelector('.history-number-card:last-child')),
      pressed: rail ? [...rail.querySelectorAll('[aria-pressed="true"]')].map((element) => element.dataset.historyEventType || '') : [],
      hit
    };
  })()`;
}

async function verifyMetricCardCountSizing(page, mode, viewport) {
  const summarySelector = mode === 'hero'
    ? '[data-history-pager-role="current"] .history-chapter-info-card'
    : '[data-component="history-workspace"] .history-number-summary';
  const bodySelector = mode === 'hero'
    ? '[data-history-pager-role="current"] .history-period-pager-body'
    : '[data-component="history-workspace"] .history-detail-content';
  const measurements = await evalValue(page, `(() => {
    const summary = document.querySelector(${JSON.stringify(summarySelector)});
    const body = document.querySelector(${JSON.stringify(bodySelector)});
    const rail = summary?.querySelector('[data-history-metrics-rail]');
    if (!summary || !body || !rail) return null;
    const originalMarkup = rail.innerHTML;
    const originalScrollLeft = rail.scrollLeft;
    const rect = (element) => { const value = element?.getBoundingClientRect(); return value ? { left: value.left, right: value.right, width: value.width } : null; };
    const results = [1, 3, 8, 12].map((count) => {
      rail.innerHTML = Array.from({ length: count }, (_, index) => '<article class="history-number-card" aria-label="Test metric ' + (index + 1) + '"></article>').join('');
      rail.scrollLeft = 0;
      const maximumScrollLeft = Math.max(0, rail.scrollWidth - rail.clientWidth);
      rail.scrollLeft = maximumScrollLeft;
      const lastCard = rail.querySelector('.history-number-card:last-child');
      return {
        count,
        body: rect(body),
        summary: rect(summary),
        rail: { ...rect(rail), clientWidth: rail.clientWidth, scrollWidth: rail.scrollWidth, scrollLeft: rail.scrollLeft },
        cardWidth: lastCard?.getBoundingClientRect().width || 0,
        lastCard: rect(lastCard)
      };
    });
    rail.innerHTML = originalMarkup;
    rail.scrollLeft = originalScrollLeft;
    return results;
  })()`);
  assert.ok(measurements, `${viewport.width}: ${mode} metrics rail must be available for count-variation checks.`);
  for (const measurement of measurements) {
    assert.ok(measurement.summary.width <= measurement.body.width + .5, `${viewport.width}: ${mode} ${measurement.count}-card footer must remain bounded by its body.`);
    assert.ok(measurement.summary.right <= measurement.body.right + .5, `${viewport.width}: ${mode} ${measurement.count}-card footer must retain the right margin.`);
    assert.equal(measurement.cardWidth, 76, `${viewport.width}: ${mode} ${measurement.count}-card rail must preserve 76px cards.`);
    if (measurement.count <= 3) {
      assert.ok(measurement.rail.scrollWidth <= measurement.rail.clientWidth + 1, `${viewport.width}: ${mode} ${measurement.count}-card rail must not invent a scroll range.`);
    } else {
      assert.ok(measurement.rail.scrollWidth > measurement.rail.clientWidth, `${viewport.width}: ${mode} ${measurement.count}-card rail must overflow locally.`);
      assert.ok(measurement.lastCard.right <= measurement.rail.right + 1, `${viewport.width}: ${mode} ${measurement.count}-card rail must expose its final card at the end.`);
    }
  }
  return measurements;
}

async function verifyHeroRail(page, viewport) {
  assert.equal(
    await evalValue(page, "document.querySelector('[data-component=\"sobriety-batch-history\"]')?.dataset.historyPeriodPresentation"),
    'hero-swipe',
    `${viewport.width}: History must keep its established full-hero pager presentation.`
  );
  const collapsed = await evalValue(page, metricsSnapshotExpression('hero'));
  const preservedPrimaryCopy = await evalValue(page, `(() => {
    const card = document.querySelector('[data-history-pager-role="current"] .history-chapter-info-card');
    return card ? {
      title: card.querySelector('.history-chapter-info-copy small')?.textContent?.trim(),
      days: card.querySelector('.history-chapter-info-copy strong')?.textContent?.trim(),
      date: card.querySelector('.history-chapter-info-copy > span')?.textContent?.trim(),
      hasLeaf: Boolean(card.querySelector('use[href="#icon-leaf"]'))
    } : null;
  })()`);
  assert.ok(collapsed.summary && collapsed.body, `${viewport.width}: collapsed period card and timeline body must render.`);
  assert.equal(collapsed.summary.height, 102, `${viewport.width}: the collapsed period card must retain its original 102px height.`);
  assert.ok(Math.abs(collapsed.body.top - collapsed.summary.bottom - 14) <= 1, `${viewport.width}: collapsed timeline body must begin after the original card gap.`);
  assert.ok(preservedPrimaryCopy?.title && preservedPrimaryCopy.days && preservedPrimaryCopy.date && preservedPrimaryCopy.hasLeaf, `${viewport.width}: the original period identity and leaf must be present before expanding metrics.`);
  await click(page, '[data-history-pager-role="current"] [data-action="toggle-history-metrics"]');
  const before = await evalValue(page, metricsSnapshotExpression('hero'));
  await screenshot(page, `history-metrics-${viewport.width}x${viewport.height}-expanded-start.png`);
  assert.ok(before.summary && before.rail && before.body, `${viewport.width}: expanded hero metrics must render.`);
  assert.ok(before.summary.height > collapsed.summary.height, `${viewport.width}: expanding metrics must grow the existing top card rather than render a second one.`);
  assert.ok(before.body.top > collapsed.body.top, `${viewport.width}: expanding the card must move the timeline body down.`);
  assert.ok(Math.abs(before.body.top - before.summary.bottom - 14) <= 1, `${viewport.width}: expanded timeline body must start below the actual expanded card, never behind it.`);
  assert.deepEqual(await evalValue(page, `(() => {
    const card = document.querySelector('[data-history-pager-role="current"] .history-chapter-info-card');
    return card ? {
      title: card.querySelector('.history-chapter-info-copy small')?.textContent?.trim(),
      days: card.querySelector('.history-chapter-info-copy strong')?.textContent?.trim(),
      date: card.querySelector('.history-chapter-info-copy > span')?.textContent?.trim(),
      hasLeaf: Boolean(card.querySelector('use[href="#icon-leaf"]'))
    } : null;
  })()`), preservedPrimaryCopy, `${viewport.width}: expanding metrics must preserve all original period-card content.`);
  assert.ok(before.summary.width <= before.body.width + .5, `${viewport.width}: footer width may not exceed its padded body.`);
  assert.ok(before.summary.right <= before.body.right + .5, `${viewport.width}: footer must retain the body right margin.`);
  assert.ok(before.rail.scrollWidth > before.rail.clientWidth, `${viewport.width}: fixed cards must create an inner horizontal range.`);
  assert.equal(before.rail.touchAction, 'pan-y', `${viewport.width}: the rail must preserve the screen's native vertical panning while its scoped controller owns x dragging.`);
  assert.equal(before.hit.some((className) => className.includes('history-card-metrics-toggle')), false, `${viewport.width}: the leaf toggle may not cover the expanded metrics rail.`);
  await touchDrag(page, '[data-history-pager-role="current"] [data-history-metrics-rail]', -190, 101);
  const afterOneDrag = await evalValue(page, metricsSnapshotExpression('hero'));
  await screenshot(page, `history-metrics-${viewport.width}x${viewport.height}-expanded-middle.png`);
  assert.ok(afterOneDrag.rail.scrollLeft > before.rail.scrollLeft + 20, `${viewport.width}: native touch drag must move the inner rail.`);
  assert.equal(afterOneDrag.periodId, before.periodId, `${viewport.width}: rail drag must not change selected period.`);
  assert.deepEqual(afterOneDrag.pressed, [], `${viewport.width}: rail drag must not synthesize a filter activation.`);
  for (let pointerId = 102; pointerId <= 106; pointerId += 1) await touchDrag(page, '[data-history-pager-role="current"] [data-history-metrics-rail]', -190, pointerId);
  const atEnd = await evalValue(page, metricsSnapshotExpression('hero'));
  await screenshot(page, `history-metrics-${viewport.width}x${viewport.height}-expanded-end.png`);
  assert.ok(atEnd.lastCard.right <= atEnd.rail.right + 1, `${viewport.width}: final metric card must be fully reachable at rail end.`);
  await delay(410);
  const clickedFinalIcon = await evalValue(page, `(() => {
    const icons = [...document.querySelectorAll('[data-history-pager-role="current"] [data-history-metrics-rail] .history-number-icon')];
    const icon = icons.at(-1);
    if (!icon) return false;
    icon.click();
    return true;
  })()`);
  assert.equal(clickedFinalIcon, true, `${viewport.width}: the final visible metric icon must remain tappable.`);
  await delay(110);
  const afterFilter = await evalValue(page, metricsSnapshotExpression('hero'));
  assert.equal(afterFilter.pressed.length, 1, `${viewport.width}: tapping a metric icon must apply exactly one event-type filter.`);
  assert.ok(afterFilter.rail.scrollLeft > 20, `${viewport.width}: rerender after a filter tap must retain the rail position.`);
  const releasedFilter = await evalValue(page, `(() => {
    const icon = document.querySelector('[data-history-pager-role="current"] [data-history-metrics-rail] .history-number-icon[aria-pressed="true"]');
    if (!icon) return false;
    icon.click();
    return true;
  })()`);
  assert.equal(releasedFilter, true, `${viewport.width}: the active metric filter must be tappable again to release it.`);
  await delay(110);
  const afterFilterRelease = await evalValue(page, metricsSnapshotExpression('hero'));
  assert.deepEqual(afterFilterRelease.pressed, [], `${viewport.width}: tapping the same metric icon again must release the filter.`);
  assert.ok(afterFilterRelease.rail.scrollLeft > 20, `${viewport.width}: releasing a filter must preserve the rail position.`);
  await click(page, '[data-history-pager-role="current"] [data-action="toggle-history-metrics"]');
  const collapsedAgain = await evalValue(page, metricsSnapshotExpression('hero'));
  assert.equal(collapsedAgain.summary.height, 102, `${viewport.width}: collapsing metrics must restore the original card height.`);
  assert.ok(Math.abs(collapsedAgain.body.top - collapsedAgain.summary.bottom - 14) <= 1, `${viewport.width}: collapsing metrics must restore the original body relationship.`);
  await click(page, '[data-history-pager-role="current"] [data-action="toggle-history-metrics"]');
  const reopened = await evalValue(page, metricsSnapshotExpression('hero'));
  assert.ok(reopened.rail.scrollLeft > 20, `${viewport.width}: reopening metrics must restore its previous horizontal rail position.`);
  // The body target starts at 62% width, so 130px clears the pager's 25%
  // commit threshold at every covered viewport without moving outside it.
  await touchDrag(page, '[data-history-pager-role="current"] .history-period-pager-body', 130, 121);
  // The production pager's settle transition lasts 280ms. The rail helper's
  // 150ms pause is enough for local scrolling but not for a full period swap.
  await delay(320);
  const afterOuterPagerSwipe = await evalValue(page, metricsSnapshotExpression('hero'));
  assert.notEqual(afterOuterPagerSwipe.periodId, reopened.periodId, `${viewport.width}: a horizontal swipe outside the expanded metrics rail must still switch History periods.`);
  assert.ok(Math.abs(afterOuterPagerSwipe.body.top - afterOuterPagerSwipe.summary.bottom - 14) <= 1, `${viewport.width}: the next period must retain the expanded card/body geometry after an outer pager swipe.`);
  return { collapsed, before, afterOneDrag, atEnd, afterFilter, afterFilterRelease, collapsedAgain, reopened, afterOuterPagerSwipe, countSizing: await verifyMetricCardCountSizing(page, 'hero', viewport) };
}

async function verifyCalendarIntegration(page, viewport) {
  await click(page, '[data-component="history-view-switch"] [data-action="open-history-detail-calendar"]');
  await waitFor(page, "document.querySelector('[data-history-pager-role=\"current\"] .history-period-pager-body')?.dataset.historyPagerView === 'calendar'", 'the inline History calendar view');
  const result = await evalValue(page, `(() => {
    const slide = document.querySelector('[data-history-pager-role="current"]');
    const card = slide?.querySelector('.history-chapter-info-card');
    const body = slide?.querySelector('.history-period-pager-body');
    const owner = slide?.querySelector('[data-history-pager-scroll-owner]');
    const calendar = slide?.querySelector('[data-history-pager-calendar-grid]');
    const lastDay = calendar?.querySelector('.history-calendar-day:last-child');
    const rect = (element) => { const value = element?.getBoundingClientRect(); return value ? { top: value.top, right: value.right, bottom: value.bottom, left: value.left, width: value.width, height: value.height } : null; };
    if (owner) owner.scrollTop = owner.scrollHeight;
    return {
      card: rect(card),
      body: rect(body),
      owner: owner ? { ...rect(owner), clientHeight: owner.clientHeight, scrollHeight: owner.scrollHeight, scrollTop: owner.scrollTop } : null,
      calendar: rect(calendar),
      lastDay: rect(lastDay),
      hasStandalonePagerSummary: Boolean(slide?.querySelector('.history-period-pager-summary')),
      rail: card?.querySelector('[data-history-metrics-rail]') ? true : false
    };
  })()`);
  await screenshot(page, `history-metrics-${viewport.width}x${viewport.height}-calendar-expanded.png`);
  assert.ok(result.card && result.body && result.owner && result.calendar && result.lastDay, `${viewport.width}: the calendar must retain the integrated period card and a scrollable calendar body.`);
  assert.ok(Math.abs(result.body.top - result.card.bottom - 14) <= 1, `${viewport.width}: calendar body must also begin below the expanded card.`);
  assert.equal(result.hasStandalonePagerSummary, false, `${viewport.width}: calendar mode must not restore the removed lower metrics summary.`);
  assert.equal(result.rail, true, `${viewport.width}: calendar mode must retain the metrics carousel inside the top card.`);
  assert.ok(result.owner.scrollHeight >= result.owner.clientHeight, `${viewport.width}: calendar content must have a real vertical scroll owner when needed.`);
  assert.ok(result.lastDay.bottom <= result.owner.bottom + 1, `${viewport.width}: the final calendar row must remain reachable above the bottom navigation.`);
  return result;
}

(async () => {
  const server = await startStaticServer();
  fs.mkdirSync(artifactDirectory, { recursive: true });
  let browser;
  let page;
  try {
    const served = await fetch(`http://127.0.0.1:${server.address().port}/app-shell/index.html`).then((response) => response.text());
    assert.equal(crypto.createHash('sha256').update(served).digest('hex'), expectedHash, 'The CDP runtime server must serve the exact worktree under test.');
    let browserVersion;
    try { browserVersion = await fetch(`${cdpHttpEndpoint}/json/version`).then((response) => response.json()); }
    catch (error) { throw new Error(`BLOCKED: Chromium CDP is unavailable at ${cdpHttpEndpoint}. ${error.message}`); }
    browser = new CdpClient(browserVersion.webSocketDebuggerUrl);
    await browser.connect();
    const { targetId } = await browser.send('Target.createTarget', { url: 'about:blank' });
    const targets = await fetch(`${cdpHttpEndpoint}/json/list`).then((response) => response.json());
    const target = targets.find((candidate) => candidate.id === targetId);
    assert.ok(target?.webSocketDebuggerUrl, 'Chromium must expose the new test page through CDP.');
    page = new CdpClient(target.webSocketDebuggerUrl);
    await page.connect();
    await page.send('Page.enable');
    await page.send('Runtime.enable');
    const results = [];
    for (const viewport of [{ width: 412, height: 892 }, { width: 390, height: 844 }, { width: 360, height: 800 }]) {
      await page.send('Emulation.setDeviceMetricsOverride', { width: viewport.width, height: viewport.height, deviceScaleFactor: 1, mobile: true });
      await page.send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 1 });
      await page.send('Page.navigate', { url: `http://127.0.0.1:${server.address().port}/app-shell/?history-metrics-cdp-runtime=1&viewport=${viewport.width}` });
      await waitFor(page, "Boolean(document.querySelector('[data-component=\"bottom-navigation\"] [data-action=\"open-history\"]'))", 'the initialized app shell');
      await openHistory(page);
      await screenshot(page, `history-metrics-${viewport.width}x${viewport.height}-collapsed.png`);
      results.push({ viewport, hero: await verifyHeroRail(page, viewport), calendar: await verifyCalendarIntegration(page, viewport) });
    }
    fs.writeFileSync(path.join(artifactDirectory, 'history-metrics-geometry.json'), JSON.stringify(results, null, 2));
    console.log(JSON.stringify({ artifactDirectory, results }, null, 2));
  } finally {
    page?.close();
    browser?.close();
    await new Promise((resolve) => server.close(resolve));
  }
})().then(() => console.log('PASS History metrics horizontal rail CDP runtime regression')).catch((error) => {
  console.error(error.stack || error);
  process.exitCode = 1;
});
