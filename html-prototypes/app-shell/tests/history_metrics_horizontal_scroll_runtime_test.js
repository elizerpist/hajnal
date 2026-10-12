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
    ? '[data-history-pager-role="current"] .history-period-pager-summary'
    : '[data-component="history-workspace"] .history-number-summary';
  return `(() => {
    const summary = document.querySelector(${JSON.stringify(selector)});
    const rail = summary?.querySelector('[data-history-metrics-rail]');
    const body = ${mode === 'hero'
      ? "document.querySelector('[data-history-pager-role=\"current\"] .history-period-pager-body')"
      : "document.querySelector('[data-component=\"history-workspace\"] .history-detail-content')"};
    const rect = (element) => { const value = element?.getBoundingClientRect(); return value ? { left: value.left, right: value.right, width: value.width, top: value.top, bottom: value.bottom } : null; };
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
    ? '[data-history-pager-role="current"] .history-period-pager-summary'
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
  await click(page, '[data-component="history-period-presentation-toggle"]');
  await waitFor(page, "document.querySelector('[data-component=\"sobriety-batch-history\"]')?.dataset.historyPeriodPresentation === 'hero-swipe'", 'full-hero History presentation');
  await click(page, '[data-history-pager-role="current"] [data-action="toggle-history-metrics"]');
  const before = await evalValue(page, metricsSnapshotExpression('hero'));
  await screenshot(page, `history-metrics-${viewport.width}x${viewport.height}-expanded-start.png`);
  assert.ok(before.summary && before.rail && before.body, `${viewport.width}: expanded hero metrics must render.`);
  assert.ok(before.summary.width <= before.body.width + .5, `${viewport.width}: footer width may not exceed its padded body.`);
  assert.ok(before.summary.right <= before.body.right + .5, `${viewport.width}: footer must retain the body right margin.`);
  assert.ok(before.rail.scrollWidth > before.rail.clientWidth, `${viewport.width}: fixed cards must create an inner horizontal range.`);
  assert.equal(before.rail.touchAction, 'pan-y', `${viewport.width}: the rail must preserve the screen's native vertical panning while its scoped controller owns x dragging.`);
  assert.equal(before.hit.some((className) => className.includes('history-metrics-surface')), false, `${viewport.width}: expanded collapse target may not cover the rail.`);
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
  return { before, afterOneDrag, atEnd, afterFilter, afterFilterRelease, countSizing: await verifyMetricCardCountSizing(page, 'hero', viewport) };
}

async function verifyCardsRail(page, viewport) {
  await click(page, '[data-component="history-period-presentation-toggle"]');
  await waitFor(page, "document.querySelector('[data-component=\"sobriety-batch-history\"]')?.dataset.historyPeriodPresentation === 'cards'", 'cards History presentation');
  await click(page, '[data-component="history-workspace"] [data-action="toggle-history-metrics"]');
  const before = await evalValue(page, metricsSnapshotExpression('cards'));
  assert.ok(before.summary && before.rail && before.body, `${viewport.width}: expanded cards metrics must render.`);
  assert.ok(before.summary.width <= before.body.width + .5 && before.summary.right <= before.body.right + .5, `${viewport.width}: cards footer must remain bounded by the body.`);
  assert.ok(before.rail.scrollWidth > before.rail.clientWidth, `${viewport.width}: cards presentation must have the same real horizontal rail.`);
  await touchDrag(page, '[data-component="history-workspace"] [data-history-metrics-rail]', -190, 111);
  const after = await evalValue(page, metricsSnapshotExpression('cards'));
  assert.ok(after.rail.scrollLeft > before.rail.scrollLeft + 20, `${viewport.width}: cards rail must also respond to native touch.`);
  return { before, after, countSizing: await verifyMetricCardCountSizing(page, 'cards', viewport) };
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
      results.push({ viewport, hero: await verifyHeroRail(page, viewport), cards: await verifyCardsRail(page, viewport) });
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
