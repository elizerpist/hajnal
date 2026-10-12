'use strict';

/*
 * Requires a real Chromium runtime.  Run from Ubuntu/proot, for example:
 * NODE_PATH=/tmp/hajnal-playwright/node_modules \
 * PLAYWRIGHT_CHROMIUM_EXECUTABLE=/root/.cache/ms-playwright/chromium-1228/chrome-linux/chrome \
 * node html-prototypes/app-shell/tests/history_timeline_scroll_runtime_test.js
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
const artifactDirectory = '/tmp/hajnal-history-runtime';
fs.mkdirSync(artifactDirectory, { recursive: true });

function contentType(file) {
  if (file.endsWith('.html')) return 'text/html; charset=utf-8';
  if (file.endsWith('.js')) return 'text/javascript; charset=utf-8';
  if (file.endsWith('.css')) return 'text/css; charset=utf-8';
  if (file.endsWith('.svg')) return 'image/svg+xml';
  if (file.endsWith('.png')) return 'image/png';
  if (file.endsWith('.jpg') || file.endsWith('.jpeg')) return 'image/jpeg';
  return 'application/octet-stream';
}

function startStaticServer() {
  const server = http.createServer((request, response) => {
    const rawPath = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
    const requested = rawPath === '/' ? '/app-shell/index.html' : rawPath.endsWith('/') ? `${rawPath}index.html` : rawPath;
    const resolved = path.resolve(prototypeRoot, `.${requested}`);
    if (!resolved.startsWith(`${prototypeRoot}${path.sep}`)) {
      response.writeHead(403).end('Forbidden');
      return;
    }
    fs.readFile(resolved, (error, body) => {
      if (error) {
        response.writeHead(error.code === 'ENOENT' ? 404 : 500).end('Not found');
        return;
      }
      response.writeHead(200, { 'content-type': contentType(resolved), 'cache-control': 'no-store' }).end(body);
    });
  });
  return new Promise((resolve) => server.listen(0, '127.0.0.1', () => resolve(server)));
}

function rect(rectangle) {
  return {
    top: Number(rectangle.top.toFixed(2)),
    right: Number(rectangle.right.toFixed(2)),
    bottom: Number(rectangle.bottom.toFixed(2)),
    left: Number(rectangle.left.toFixed(2)),
    width: Number(rectangle.width.toFixed(2)),
    height: Number(rectangle.height.toFixed(2))
  };
}

async function inspect(page) {
  return page.evaluate(() => {
    const workspace = document.querySelector('[data-component="history-workspace"]');
    const selectors = {
      appFrame: '.app-frame',
      hero: '.history-screen .history-hero',
      carousel: '.history-screen .history-period-carousel',
      workspace: '[data-component="history-workspace"]',
      content: '.history-detail-content',
      tabs: '.period-detail-tabs',
      slot: '.history-detail-panel-slot',
      timeline: '[data-history-detail-panel="timeline"]',
      events: '.history-detail-events-scroll',
      footer: '.history-number-summary',
      nav: '.bottom-nav'
    };
    const documentOwnedSelectors = new Set([selectors.appFrame, selectors.hero, selectors.carousel, selectors.workspace, selectors.nav]);
    const pick = (selector) => documentOwnedSelectors.has(selector) ? document.querySelector(selector) : workspace?.querySelector(selector);
    const data = {};
    for (const [name, selector] of Object.entries(selectors)) {
      const element = pick(selector);
      if (!element) {
        data[name] = null;
        continue;
      }
      const style = getComputedStyle(element);
      data[name] = {
        rect: { ...element.getBoundingClientRect().toJSON() },
        clientHeight: element.clientHeight,
        scrollHeight: element.scrollHeight,
        scrollTop: element.scrollTop,
        computed: {
          height: style.height,
          minHeight: style.minHeight,
          maxHeight: style.maxHeight,
          overflowX: style.overflowX,
          overflowY: style.overflowY,
          position: style.position,
          top: style.top,
          bottom: style.bottom,
          inset: style.inset,
          display: style.display,
          gridTemplateRows: style.gridTemplateRows,
          touchAction: style.touchAction,
          pointerEvents: style.pointerEvents,
          zIndex: style.zIndex
        }
      };
    }
    return {
      url: location.href,
      viewport: {
        innerHeight: window.innerHeight,
        documentClientHeight: document.documentElement.clientHeight,
        visualViewportHeight: window.visualViewport?.height ?? null
      },
      elements: data
    };
  });
}

async function attachRuntimeProbe(page) {
  await page.evaluate(() => {
    const workspace = document.querySelector('[data-component="history-workspace"]');
    const slot = workspace?.querySelector('.history-detail-panel-slot');
    const probe = {
      initialSlot: slot,
      mutationCount: 0,
      addedNodes: 0,
      removedNodes: 0,
      scrollEvents: 0,
      events: []
    };
    const record = (event) => {
      const target = event.target;
      const touch = event.touches?.[0] || event.changedTouches?.[0];
      const clientX = Number.isFinite(event.clientX) ? event.clientX : (touch?.clientX ?? window.innerWidth / 2);
      const clientY = Number.isFinite(event.clientY) ? event.clientY : (touch?.clientY ?? 0);
      probe.events.push({
        type: event.type,
        defaultPrevented: event.defaultPrevented,
        target: target?.className || target?.tagName || '',
        slotConnected: Boolean(probe.initialSlot?.isConnected),
        hit: document.elementsFromPoint(clientX, clientY)
          .slice(0, 8)
          .map((element) => ({ tag: element.tagName, className: String(element.className), touchAction: getComputedStyle(element).touchAction, pointerEvents: getComputedStyle(element).pointerEvents, zIndex: getComputedStyle(element).zIndex }))
      });
    };
    probe.observer = new MutationObserver((records) => {
      probe.mutationCount += records.length;
      for (const record of records) {
        probe.addedNodes += record.addedNodes.length;
        probe.removedNodes += record.removedNodes.length;
      }
    });
    probe.observer.observe(workspace, { childList: true, subtree: true });
    for (const type of ['pointerdown', 'pointermove', 'pointerup', 'pointercancel', 'touchstart', 'touchmove', 'touchend', 'touchcancel']) {
      workspace.addEventListener(type, record, { capture: true, passive: true });
    }
    slot?.addEventListener('scroll', () => { probe.scrollEvents += 1; }, { passive: true });
    window.__hajnalHistoryRuntimeProbe = probe;
  });
}

async function programmedScroll(page) {
  return page.evaluate(async () => {
    const slot = document.querySelector('[data-component="history-workspace"] .history-detail-panel-slot');
    const maximum = Math.max(0, slot.scrollHeight - slot.clientHeight);
    const samples = [];
    const sample = (label) => samples.push({ label, scrollTop: slot.scrollTop, maximum, connected: slot.isConnected });
    sample('before');
    slot.scrollTop = Math.min(200, maximum);
    sample('immediate');
    await new Promise(requestAnimationFrame);
    await new Promise(requestAnimationFrame);
    sample('two-animation-frames');
    await new Promise((resolve) => setTimeout(resolve, 300));
    sample('300ms');
    await new Promise((resolve) => setTimeout(resolve, 700));
    sample('1000ms');
    return samples;
  });
}

async function touchSwipe(cdp, page, direction = 'vertical') {
  const box = await page.locator('[data-component="history-workspace"] .history-detail-panel-slot').boundingBox();
  const x = Math.round(box.x + box.width / 2);
  const y = Math.round(box.y + Math.max(32, Math.min(box.height - 32, box.height / 2)));
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x, y, id: 1 }] });
  for (let index = 1; index <= 8; index += 1) {
    await cdp.send('Input.dispatchTouchEvent', {
      type: 'touchMove',
      touchPoints: [{ x: direction === 'vertical' ? x : x - (index * 28), y: direction === 'vertical' ? y - (index * 32) : y, id: 1 }]
    });
    await page.waitForTimeout(18);
  }
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await page.waitForTimeout(260);
}

async function carouselTouchSwipe(cdp, page) {
  const box = await page.locator('.history-period-carousel').boundingBox();
  const y = Math.round(box.y + (box.height / 2));
  const startX = Math.round(box.x + (box.width * .22));
  const endX = Math.round(box.x + (box.width * .78));
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: startX, y, id: 2 }] });
  for (let index = 1; index <= 8; index += 1) {
    await cdp.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: startX - (((startX - endX) * index) / 8), y, id: 2 }] });
    await page.waitForTimeout(18);
  }
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await page.waitForTimeout(340);
}

async function heroCarouselTouchSwipe(cdp, page) {
  const box = await page.locator('.history-period-carousel').boundingBox();
  const range = await page.evaluate(() => {
    const carousel = document.querySelector('.history-period-carousel');
    return { left: carousel.scrollLeft, maximum: carousel.scrollWidth - carousel.clientWidth };
  });
  const y = Math.round(box.y + (box.height / 2));
  const delta = Math.round(box.width * .72);
  const moveTowardNext = range.left < range.maximum - 1;
  const startX = Math.round(box.x + (moveTowardNext ? box.width * .84 : box.width * .16));
  const endX = startX + (moveTowardNext ? -delta : delta);
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: startX, y, id: 3 }] });
  for (let index = 1; index <= 10; index += 1) {
    await cdp.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: Math.round(startX + (((endX - startX) * index) / 10)), y, id: 3 }] });
    await page.waitForTimeout(18);
  }
  await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
  await page.waitForTimeout(1000);
}

async function measurePathOverviewReference(page) {
  await page.locator('[data-component="bottom-navigation"] [data-action="open-path"]').click();
  await page.waitForTimeout(120);
  return page.evaluate(() => {
    const measurement = (selector) => {
      const element = document.querySelector(selector);
      const bounds = element?.getBoundingClientRect();
      return bounds ? { top: bounds.top, bottom: bounds.bottom, height: bounds.height, cssHeight: Number.parseFloat(getComputedStyle(element).height) } : null;
    };
    return {
      currentCard: measurement('.path-overview-fast-card'),
      stepHeading: measurement('.path-step-list-card h2')
    };
  });
}

async function measureHistoryPathAlignment(page) {
  return page.evaluate(() => {
    const measurement = (selector) => {
      const element = document.querySelector(selector);
      const bounds = element?.getBoundingClientRect();
      return bounds ? { top: bounds.top, bottom: bounds.bottom, height: bounds.height, cssHeight: Number.parseFloat(getComputedStyle(element).height) } : null;
    };
    const carousel = document.querySelector('.history-period-carousel');
    const carouselCenter = carousel ? carousel.getBoundingClientRect().left + (carousel.getBoundingClientRect().width / 2) : 0;
    const cards = [...document.querySelectorAll('.history-period-carousel-card')].map((card) => {
      const bounds = card.getBoundingClientRect();
      return {
        id: card.dataset.historyPeriodId,
        copy: Number(card.dataset.historyCarouselCopy),
        current: card.getAttribute('aria-current'),
        centerDistance: Math.round(((bounds.left + (bounds.width / 2)) - carouselCenter) * 100) / 100,
        scale: getComputedStyle(card).getPropertyValue('--history-carousel-scale').trim()
      };
    });
    const indicators = [...document.querySelectorAll('.history-period-carousel-indicator')];
    const activeIndicator = indicators.find((indicator) => indicator.classList.contains('is-active'));
    return {
      heroArtwork: document.querySelector('[data-component="history-hero-image"]')?.getAttribute('src') || '',
      activePeriodCard: measurement('.history-period-carousel-card[aria-current="true"]'),
      activeCardArtwork: document.querySelector('.history-period-carousel-card[aria-current="true"] .history-period-carousel-art img')?.getAttribute('src') || '',
      activeCardCopyColor: getComputedStyle(document.querySelector('.history-period-carousel-card[aria-current="true"] .history-period-carousel-copy')).color,
      floatingViewSwitch: measurement('[data-component="history-view-switch"]'),
      carouselCardsAtCenter: cards.filter((card) => card.current === 'true').concat([...cards].sort((first, second) => Math.abs(first.centerDistance) - Math.abs(second.centerDistance)).slice(0, 3)),
      carouselIndicators: {
        count: indicators.length,
        activeCount: indicators.filter((indicator) => indicator.classList.contains('is-active')).length,
        activePeriodId: activeIndicator?.dataset.historyPeriodId || '',
        bounds: activeIndicator ? measurement('.history-period-carousel-indicator.is-active') : null
      }
    };
  });
}

async function runViewport(browser, baseUrl, viewport) {
  console.error(`History runtime: ${viewport.width}x${viewport.height} start`);
  const context = await browser.newContext({ viewport, deviceScaleFactor: 1, isMobile: true, hasTouch: true });
  const page = await context.newPage();
  page.setDefaultTimeout(4000);
  const cdp = await context.newCDPSession(page);
  await page.goto(`${baseUrl}/app-shell/?history-runtime-test=1`, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(120);
  const pathReference = await measurePathOverviewReference(page);
  await page.locator('[data-component="bottom-navigation"] [data-action="open-history"]').click();
  await page.waitForTimeout(800);
  const pathAlignment = await measureHistoryPathAlignment(page);
  await attachRuntimeProbe(page);
  const before = await inspect(page);
  const programmatic = await programmedScroll(page);
  const initialSlot = before.elements.slot;
  const preflight = { viewport, before, programmatic };
  if (!before.elements.content || !(initialSlot.scrollHeight > initialSlot.clientHeight) || !(programmatic.at(-1).scrollTop > 0)) {
    console.log(JSON.stringify({ preflight }, null, 2));
    throw new assert.AssertionError({
      message: `${viewport.width}×${viewport.height}: mounted Timeline must have the shared detail-content grid and a persistent real scroll range`,
      actual: { mountedContent: Boolean(before.elements.content), clientHeight: initialSlot.clientHeight, scrollHeight: initialSlot.scrollHeight, finalScrollTop: programmatic.at(-1).scrollTop },
      expected: 'mounted content; scrollHeight > clientHeight; scrollTop > 0 after 1000 ms'
    });
  }
  console.error(`History runtime: ${viewport.width}x${viewport.height} initial scroll range verified`);
  await page.evaluate(() => { document.querySelector('[data-component="history-workspace"] .history-detail-panel-slot').scrollTop = 0; });
  const activeBeforeTouch = await page.locator('.history-period-carousel-card[aria-current="true"]').getAttribute('data-history-period-id');
  await touchSwipe(cdp, page, 'vertical');
  const afterTouch = await inspect(page);
  const activeAfterTouch = await page.locator('.history-period-carousel-card[aria-current="true"]').getAttribute('data-history-period-id');
  const fixedBefore = Object.fromEntries(['hero', 'carousel', 'tabs', 'footer', 'nav'].map((name) => [name, rect(before.elements[name].rect)]));
  const fixedAfter = Object.fromEntries(['hero', 'carousel', 'tabs', 'footer', 'nav'].map((name) => [name, rect(afterTouch.elements[name].rect)]));
  console.error(`History runtime: ${viewport.width}x${viewport.height} touch gesture sampled`);

  await page.locator('[data-component="history-workspace"] [data-action="toggle-history-metrics"]').click();
  await page.waitForTimeout(360);
  const expanded = await inspect(page);
  const expandedSamples = await programmedScroll(page);
  console.error(`History runtime: ${viewport.width}x${viewport.height} expanded footer sampled`);

  await page.locator('[data-component="history-view-switch"] [data-history-detail-tab="calendar"]').click();
  await page.waitForTimeout(80);
  const calendarState = await page.evaluate(() => {
    const workspace = document.querySelector('[data-component="history-workspace"]');
    const timeline = workspace?.querySelector('[data-history-detail-panel="timeline"]');
    const calendar = workspace?.querySelector('[data-history-detail-panel="calendar"]');
    const oldPill = workspace?.querySelector('.period-detail-tabs');
    const heroSwitch = document.querySelector('[data-component="history-view-switch"]');
    const activeHeroSwitch = heroSwitch?.querySelector('[aria-pressed="true"]');
    const layoutToggle = document.querySelector('[data-component="history-period-presentation-toggle"]');
    return {
      workspaceView: workspace?.dataset.historyDetailView || '',
      timelineDisplay: timeline ? getComputedStyle(timeline).display : '',
      calendarDisplay: calendar ? getComputedStyle(calendar).display : '',
      timelineHeight: timeline?.getBoundingClientRect().height || 0,
      calendarHeight: calendar?.getBoundingClientRect().height || 0,
      oldPillDisplay: oldPill ? getComputedStyle(oldPill).display : '',
      activeHeroSwitchView: activeHeroSwitch?.dataset.historyDetailTab || '',
      heroSwitchBounds: heroSwitch?.getBoundingClientRect().toJSON() || null,
      layoutToggleBounds: layoutToggle?.getBoundingClientRect().toJSON() || null
    };
  });
  await page.screenshot({ path: path.join(artifactDirectory, `history-calendar-${viewport.width}x${viewport.height}.png`), fullPage: false });
  await page.locator('[data-component="history-view-switch"] [data-history-detail-tab="timeline"]').click();
  await page.waitForTimeout(100);
  const afterTabs = await inspect(page);
  const tabSamples = await programmedScroll(page);
  console.error(`History runtime: ${viewport.width}x${viewport.height} tab return sampled`);

  await page.evaluate(() => {
    const slot = document.querySelector('[data-component="history-workspace"] .history-detail-panel-slot');
    slot.scrollTop = slot.scrollHeight - slot.clientHeight;
  });
  await page.waitForTimeout(80);
  const lastEvent = await page.locator('[data-component="history-workspace"] .history-detail-event').last().boundingBox();
  const footerBox = await page.locator('[data-component="history-workspace"] .history-number-summary').boundingBox();

  const carouselBefore = await page.evaluate(() => {
    const carousel = document.querySelector('.history-period-carousel');
    return {
      scrollLeft: carousel.scrollLeft,
      selectedPeriodId: carousel.querySelector('[aria-current="true"]')?.dataset.historyPeriodId || '',
      sourcePeriodCount: new Set([...carousel.querySelectorAll('.history-period-carousel-card')].map((card) => card.dataset.historyPeriodId)).size,
      visualCardCount: carousel.querySelectorAll('.history-period-carousel-card').length
    };
  });
  await carouselTouchSwipe(cdp, page);
  const carouselAfter = await page.evaluate(() => {
    const carousel = document.querySelector('.history-period-carousel');
    return {
      scrollLeft: carousel.scrollLeft,
      selectedPeriodId: carousel.querySelector('[aria-current="true"]')?.dataset.historyPeriodId || '',
      activeIndicatorPeriodId: document.querySelector('.history-period-carousel-indicator.is-active')?.dataset.historyPeriodId || ''
    };
  });
  const afterCarousel = await inspect(page);
  const carouselSamples = await programmedScroll(page);

  await page.locator('[data-component="history-period-presentation-toggle"]').click();
  await page.waitForTimeout(120);
  const heroSwipeBefore = await page.evaluate(() => {
    const screen = document.querySelector('[data-component="sobriety-batch-history"]');
    const carousel = document.querySelector('.history-period-carousel');
    const slide = carousel?.querySelector('.history-period-carousel-card[aria-current="true"]');
    const image = document.querySelector('[data-component="history-hero-image"]');
    const indicators = [...document.querySelectorAll('.history-period-carousel-indicator')];
    const artwork = slide?.querySelector('.history-period-carousel-art');
    return {
      presentation: screen?.dataset.historyPeriodPresentation || '',
      togglePressed: document.querySelector('[data-component="history-period-presentation-toggle"]')?.getAttribute('aria-pressed') || '',
      carouselHeight: carousel?.getBoundingClientRect().height || 0,
      carouselWidth: carousel?.getBoundingClientRect().width || 0,
      slideHeight: slide?.getBoundingClientRect().height || 0,
      slideWidth: slide?.getBoundingClientRect().width || 0,
      slideRadius: slide ? getComputedStyle(slide).borderRadius : '',
      scrollLeft: carousel?.scrollLeft || 0,
      maximumScrollLeft: Math.max(0, (carousel?.scrollWidth || 0) - (carousel?.clientWidth || 0)),
      cardCount: carousel?.querySelectorAll('.history-period-carousel-card').length || 0,
      sourcePeriodCount: new Set([...carousel?.querySelectorAll('.history-period-carousel-card') || []].map((card) => card.dataset.historyPeriodId)).size,
      selectedPeriodId: slide?.dataset.historyPeriodId || '',
      activeIndicatorPeriodId: indicators.find((indicator) => indicator.classList.contains('is-active'))?.dataset.historyPeriodId || '',
      backgroundImageOpacity: image ? getComputedStyle(image).opacity : '',
      artworkFade: artwork ? getComputedStyle(artwork, '::after').backgroundImage : ''
    };
  });
  await page.screenshot({ path: path.join(artifactDirectory, `history-hero-swipe-${viewport.width}x${viewport.height}.png`), fullPage: false });
  await heroCarouselTouchSwipe(cdp, page);
  const heroSwipeAfter = await page.evaluate(() => ({
    scrollLeft: document.querySelector('.history-period-carousel')?.scrollLeft || 0,
    maximumScrollLeft: Math.max(0, (document.querySelector('.history-period-carousel')?.scrollWidth || 0) - (document.querySelector('.history-period-carousel')?.clientWidth || 0)),
    selectedPeriodId: document.querySelector('.history-period-carousel-card[aria-current="true"]')?.dataset.historyPeriodId || '',
    activeIndicatorPeriodId: document.querySelector('.history-period-carousel-indicator.is-active')?.dataset.historyPeriodId || ''
  }));
  await page.locator('[data-component="history-period-presentation-toggle"]').click();
  await page.waitForTimeout(120);
  const cardsRestored = await page.evaluate(() => ({
    presentation: document.querySelector('[data-component="sobriety-batch-history"]')?.dataset.historyPeriodPresentation || '',
    togglePressed: document.querySelector('[data-component="history-period-presentation-toggle"]')?.getAttribute('aria-pressed') || '',
    activeCardHeight: document.querySelector('.history-period-carousel-card[aria-current="true"]')?.getBoundingClientRect().height || 0
  }));

  const probe = await page.evaluate(() => {
    const probe = window.__hajnalHistoryRuntimeProbe;
    const workspace = document.querySelector('[data-component="history-workspace"]');
    return {
      initialSlotConnected: probe.initialSlot?.isConnected,
      currentSlotIsInitial: probe.initialSlot === document.querySelector('[data-component="history-workspace"] .history-detail-panel-slot'),
      renderCount: Number(workspace?.dataset.historyWorkspaceRenderCount || 0),
      mountCount: Number(workspace?.dataset.historyWorkspaceMountCount || 0),
      mutationCount: probe.mutationCount,
      addedNodes: probe.addedNodes,
      removedNodes: probe.removedNodes,
      scrollEvents: probe.scrollEvents,
      events: probe.events
    };
  });
  await page.screenshot({ path: path.join(artifactDirectory, `history-timeline-${viewport.width}x${viewport.height}.png`), fullPage: false });
  console.error(`History runtime: ${viewport.width}x${viewport.height} complete`);
  await context.close();
  return { viewport, pathReference, pathAlignment, before, programmatic, afterTouch, activeBeforeTouch, activeAfterTouch, fixedBefore, fixedAfter, expanded, expandedSamples, calendarState, afterTabs, tabSamples, lastEvent, footerBox, carouselBefore, carouselAfter, afterCarousel, carouselSamples, heroSwipeBefore, heroSwipeAfter, cardsRestored, probe };
}

(async () => {
  const server = await startStaticServer();
  const port = server.address().port;
  const served = await fetch(`http://127.0.0.1:${port}/app-shell/index.html`).then((response) => response.text());
  assert.equal(crypto.createHash('sha256').update(served).digest('hex'), expectedHash, 'the runtime server must serve this worktree’s current app-shell source');
  const browser = await chromium.launch({
    headless: true,
    executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE || undefined,
    args: ['--no-sandbox', '--disable-dev-shm-usage']
  });
  try {
    const allViewports = [{ width: 412, height: 892 }, { width: 390, height: 844 }, { width: 360, height: 800 }];
    const requestedViewports = String(process.env.HISTORY_RUNTIME_VIEWPORTS || '')
      .split(',')
      .filter(Boolean)
      .map((entry) => entry.split('x').map(Number))
      .map(([width, height]) => ({ width, height }));
    const viewports = requestedViewports.length ? requestedViewports : allViewports;
    const results = [];
    for (const viewport of viewports) results.push(await runViewport(browser, `http://127.0.0.1:${port}`, viewport));
    const reportPath = path.join(artifactDirectory, 'history-timeline-runtime-report.json');
    fs.writeFileSync(reportPath, JSON.stringify({ expectedHash, results }, null, 2));
    console.log(JSON.stringify({
      expectedHash,
      reportPath,
      results: results.map((result) => ({
        viewport: result.viewport,
        slot: {
          before: { clientHeight: result.before.elements.slot.clientHeight, scrollHeight: result.before.elements.slot.scrollHeight, scrollTop: result.before.elements.slot.scrollTop },
          afterTouch: { clientHeight: result.afterTouch.elements.slot.clientHeight, scrollHeight: result.afterTouch.elements.slot.scrollHeight, scrollTop: result.afterTouch.elements.slot.scrollTop },
          programmatic: result.programmatic
        },
        footerTop: result.before.elements.footer.rect.top,
        bottomNavigationTop: result.before.elements.nav.rect.top,
        pathAlignment: {
          referenceCard: result.pathReference.currentCard,
          referenceHeading: result.pathReference.stepHeading,
          historyCard: result.pathAlignment.activePeriodCard,
          historyViewSwitch: result.pathAlignment.floatingViewSwitch,
          carouselCardsAtCenter: result.pathAlignment.carouselCardsAtCenter
        },
        carousel: result.carouselAfter,
        heroSwipe: { before: result.heroSwipeBefore, after: result.heroSwipeAfter, cardsRestored: result.cardsRestored },
        workspaceProbe: {
          initialSlotConnected: result.probe.initialSlotConnected,
          currentSlotIsInitial: result.probe.currentSlotIsInitial,
          renderCount: result.probe.renderCount,
          mountCount: result.probe.mountCount,
          mutationCount: result.probe.mutationCount,
          addedNodes: result.probe.addedNodes,
          removedNodes: result.probe.removedNodes,
          scrollEvents: result.probe.scrollEvents,
          eventTypes: result.probe.events.map((event) => event.type)
        }
      }))
    }, null, 2));
    for (const result of results) {
      const slot = result.before.elements.slot;
      assert.ok(result.before.elements.content, `${result.viewport.width}×${result.viewport.height}: mounted workspace must include its detail-content grid wrapper`);
      assert.ok(result.pathReference.currentCard && result.pathReference.stepHeading, `${result.viewport.width}×${result.viewport.height}: Path overview must remain available as an unrelated control surface`);
      assert.ok(result.pathAlignment.activePeriodCard && result.pathAlignment.floatingViewSwitch, `${result.viewport.width}×${result.viewport.height}: History must expose its centred period-card and floating view switch`);
      assert.equal(result.pathAlignment.heroArtwork, 'assets/history/history_hero_soft.png', `${result.viewport.width}×${result.viewport.height}: the quiet History2 hero must use its dedicated generated PNG`);
      assert.match(result.pathAlignment.activeCardArtwork, /^assets\/history\/history_period_card_(?:active_1|side_1|side_2)\.png$/, `${result.viewport.width}×${result.viewport.height}: the active card must use generated full-image History artwork`);
      assert.equal(result.pathAlignment.activeCardCopyColor, 'rgb(255, 255, 255)', `${result.viewport.width}×${result.viewport.height}: the active card's semantic UI overlay must be white`);
      assert.equal(result.pathAlignment.activePeriodCard.cssHeight, 120, `${result.viewport.width}×${result.viewport.height}: the selected source-matched chapter card must be 120px tall`);
      assert.ok(Math.abs(result.pathAlignment.activePeriodCard.height - 120) <= 2, `${result.viewport.width}×${result.viewport.height}: the selected source-matched chapter card must retain its full 120px visual height`);
      assert.ok(Math.abs(result.pathAlignment.activePeriodCard.top - 91) <= 4, `${result.viewport.width}×${result.viewport.height}: the chapter carousel must occupy the reference y-position within the soft hero`);
      assert.ok(Math.abs(result.pathAlignment.floatingViewSwitch.top - 32) <= 4, `${result.viewport.width}×${result.viewport.height}: the floating Timeline/Calendar switch must occupy the former top-right selector position`);
      assert.ok(slot.scrollHeight > slot.clientHeight, `${result.viewport.width}×${result.viewport.height}: Timeline must have a real scroll range`);
      assert.ok(result.programmatic.every((sample) => sample.scrollTop > 0 || sample.label === 'before'), `${result.viewport.width}×${result.viewport.height}: programmatic scrollTop must persist over two frames and 1000 ms`);
      assert.ok(result.afterTouch.elements.slot.scrollTop > 0, `${result.viewport.width}×${result.viewport.height}: a CDP mobile touch swipe must move Timeline scrollTop`);
      assert.equal(result.activeAfterTouch, result.activeBeforeTouch, `${result.viewport.width}×${result.viewport.height}: a vertical Timeline gesture may not change the carousel chapter`);
      assert.deepEqual(result.fixedAfter, result.fixedBefore, `${result.viewport.width}×${result.viewport.height}: hero, carousel, tabs, footer and navigation must stay fixed while Timeline scrolls`);
      assert.ok(result.expanded.elements.slot.scrollHeight > result.expanded.elements.slot.clientHeight, `${result.viewport.width}×${result.viewport.height}: opening the footer must retain a scroll range`);
      assert.ok(result.expandedSamples.at(-1).scrollTop > 0, `${result.viewport.width}×${result.viewport.height}: Timeline must scroll while footer is expanded`);
      assert.equal(result.calendarState.workspaceView, 'calendar', `${result.viewport.width}×${result.viewport.height}: Naptár tab must set the shared workspace state to calendar`);
      assert.equal(result.calendarState.timelineDisplay, 'none', `${result.viewport.width}×${result.viewport.height}: Timeline panel must not occupy the inline workspace while Naptár is selected`);
      assert.notEqual(result.calendarState.calendarDisplay, 'none', `${result.viewport.width}×${result.viewport.height}: Naptár panel must become visible when its tab is selected`);
      assert.ok(result.calendarState.calendarHeight > 0, `${result.viewport.width}×${result.viewport.height}: the visible Naptár panel must receive layout height`);
      assert.equal(result.calendarState.oldPillDisplay, 'none', `${result.viewport.width}×${result.viewport.height}: the old body pill must not remain visible beneath the hero`);
      assert.equal(result.calendarState.activeHeroSwitchView, 'calendar', `${result.viewport.width}×${result.viewport.height}: the floating hero switch must expose its calendar selection`);
      assert.ok(result.calendarState.heroSwitchBounds && result.calendarState.layoutToggleBounds && result.calendarState.layoutToggleBounds.top > result.calendarState.heroSwitchBounds.bottom, `${result.viewport.width}×${result.viewport.height}: the moved layout selector must sit below the floating hero switch`);
      assert.ok(result.afterTabs.elements.slot.scrollHeight > result.afterTabs.elements.slot.clientHeight, `${result.viewport.width}×${result.viewport.height}: Timeline must regain its scroll range after tab return`);
      assert.ok(result.tabSamples.at(-1).scrollTop > 0, `${result.viewport.width}×${result.viewport.height}: Timeline must scroll after tab return`);
      assert.notEqual(result.carouselAfter.selectedPeriodId, result.carouselBefore.selectedPeriodId, `${result.viewport.width}×${result.viewport.height}: horizontal carousel swipe must select another period`);
      assert.ok(result.afterCarousel.elements.slot.scrollHeight > result.afterCarousel.elements.slot.clientHeight, `${result.viewport.width}×${result.viewport.height}: Timeline must retain its scroll range after carousel selection`);
      assert.ok(result.carouselSamples.at(-1).scrollTop > 0, `${result.viewport.width}×${result.viewport.height}: Timeline must scroll after carousel selection`);
      assert.equal(result.carouselBefore.visualCardCount, result.carouselBefore.sourcePeriodCount, `${result.viewport.width}×${result.viewport.height}: the finite carousel must render every period exactly once`);
      assert.equal(result.pathAlignment.carouselIndicators.count, result.carouselBefore.sourcePeriodCount, `${result.viewport.width}×${result.viewport.height}: the dot row must expose one visual position per finite period`);
      assert.equal(result.pathAlignment.carouselIndicators.activeCount, 1, `${result.viewport.width}×${result.viewport.height}: exactly one carousel dot must be active`);
      assert.equal(result.pathAlignment.carouselIndicators.activePeriodId, result.carouselBefore.selectedPeriodId, `${result.viewport.width}×${result.viewport.height}: the initial active dot must match the selected carousel period`);
      assert.ok(result.pathAlignment.carouselIndicators.bounds.top > result.pathAlignment.activePeriodCard.bottom, `${result.viewport.width}×${result.viewport.height}: dots must sit beneath the raised carousel card`);
      assert.ok(result.pathAlignment.carouselIndicators.bounds.bottom <= 238, `${result.viewport.width}×${result.viewport.height}: dots must stay inside the hero rather than overlap the body content`);
      assert.equal(result.carouselAfter.activeIndicatorPeriodId, result.carouselAfter.selectedPeriodId, `${result.viewport.width}×${result.viewport.height}: a horizontal carousel selection must update its active dot`);
      assert.equal(result.heroSwipeBefore.presentation, 'hero-swipe', `${result.viewport.width}×${result.viewport.height}: the right-corner toggle must switch History into hero-swipe presentation`);
      assert.equal(result.heroSwipeBefore.togglePressed, 'true', `${result.viewport.width}×${result.viewport.height}: the presentation toggle must expose its active state`);
      assert.equal(result.heroSwipeBefore.cardCount, result.heroSwipeBefore.sourcePeriodCount, `${result.viewport.width}×${result.viewport.height}: hero-swipe must reuse the one finite period track without duplicated cards`);
      assert.ok(Math.abs(result.heroSwipeBefore.slideWidth - result.heroSwipeBefore.carouselWidth) <= 2, `${result.viewport.width}×${result.viewport.height}: hero-swipe must render one full-width selected slide, not a card`);
      assert.ok(Math.abs(result.heroSwipeBefore.slideHeight - result.heroSwipeBefore.carouselHeight) <= 2, `${result.viewport.width}×${result.viewport.height}: hero-swipe slide must fill the dedicated hero swipe rail`);
      assert.equal(result.heroSwipeBefore.slideRadius, '0px', `${result.viewport.width}×${result.viewport.height}: hero-swipe must remove card corner geometry`);
      assert.equal(result.heroSwipeBefore.backgroundImageOpacity, '0', `${result.viewport.width}×${result.viewport.height}: hero-swipe must use the selected period PNG rather than stacking the static History artwork beneath it`);
      assert.match(result.heroSwipeBefore.artworkFade, /rgb\(255, 249, 252\)/, `${result.viewport.width}×${result.viewport.height}: hero-swipe artwork must fade into the shared body colour instead of ending at a hard seam`);
      assert.equal(result.heroSwipeBefore.selectedPeriodId, result.carouselAfter.selectedPeriodId, `${result.viewport.width}×${result.viewport.height}: changing presentation may not change the selected period`);
      assert.equal(result.heroSwipeBefore.activeIndicatorPeriodId, result.heroSwipeBefore.selectedPeriodId, `${result.viewport.width}×${result.viewport.height}: hero-swipe dot must match its selected period`);
      assert.notEqual(result.heroSwipeAfter.selectedPeriodId, result.heroSwipeBefore.selectedPeriodId, `${result.viewport.width}×${result.viewport.height}: a native horizontal swipe in hero mode must choose another period`);
      assert.equal(result.heroSwipeAfter.activeIndicatorPeriodId, result.heroSwipeAfter.selectedPeriodId, `${result.viewport.width}×${result.viewport.height}: a hero-swipe selection must update the same finite indicator state`);
      assert.equal(result.cardsRestored.presentation, 'cards', `${result.viewport.width}×${result.viewport.height}: the same toggle must restore the original cards presentation`);
      assert.equal(result.cardsRestored.togglePressed, 'false', `${result.viewport.width}×${result.viewport.height}: the restored cards presentation must expose the inactive toggle state`);
      assert.ok(Math.abs(result.cardsRestored.activeCardHeight - 120) <= 2, `${result.viewport.width}×${result.viewport.height}: restoring cards must restore the original card geometry`);
      assert.ok((result.lastEvent.y + result.lastEvent.height) <= result.footerBox.y, `${result.viewport.width}×${result.viewport.height}: final event must be visible above the footer`);
      assert.equal(result.probe.initialSlotConnected, true, `${result.viewport.width}×${result.viewport.height}: initial scroll node must stay connected`);
      assert.equal(result.probe.currentSlotIsInitial, true, `${result.viewport.width}×${result.viewport.height}: normal render interactions may not remount the scroll node`);
      assert.equal(result.probe.mountCount, 1, `${result.viewport.width}×${result.viewport.height}: the shared workspace may mount exactly once`);
      assert.ok(result.probe.scrollEvents > 0, `${result.viewport.width}×${result.viewport.height}: the measured scroll owner must receive scroll events`);
      const gestureEvents = result.probe.events.filter((event) => event.type.startsWith('touch') || event.type.startsWith('pointer'));
      assert.ok(gestureEvents.some((event) => event.hit.some((hit) => hit.className.includes('history-detail-panel-slot'))), `${result.viewport.width}×${result.viewport.height}: touch hit-testing must reach the Timeline scroll owner`);
      assert.ok(gestureEvents.every((event) => !event.defaultPrevented), `${result.viewport.width}×${result.viewport.height}: no observed Timeline gesture may be preventDefault-blocked`);
    }
  } finally {
    await browser.close();
    await new Promise((resolve) => server.close(resolve));
  }
})().then(() => console.log('PASS History Timeline browser touch runtime regression')).catch((error) => {
  console.error(error.stack || error);
  process.exitCode = 1;
});
