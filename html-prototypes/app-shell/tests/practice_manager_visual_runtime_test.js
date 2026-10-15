'use strict';

/* Browser geometry/regression for the approved gyakorlat.png manager shell. */
const assert = require('node:assert/strict');
const fs = require('node:fs');
const http = require('node:http');
const path = require('node:path');
const { chromium } = require('playwright');

function createServer(root) {
  const types = { '.html': 'text/html; charset=utf-8', '.png': 'image/png', '.svg': 'image/svg+xml' };
  return http.createServer((request, response) => {
    const requestPath = decodeURIComponent(new URL(request.url || '/', 'http://127.0.0.1').pathname);
    const filename = path.resolve(root, `.${requestPath === '/' ? '/index.html' : requestPath}`);
    if (!filename.startsWith(root)) return response.writeHead(403).end();
    fs.readFile(filename, (error, body) => response.writeHead(error ? 404 : 200, { 'content-type': error ? 'text/plain' : (types[path.extname(filename)] || 'application/octet-stream'), 'cache-control': 'no-store' }).end(error ? 'Not found' : body));
  });
}

function practice(id, title, status, sequence) {
  const createdAt = `2026-10-${String(10 + sequence).padStart(2, '0')}T09:00:00.000Z`;
  return {
    id,
    title,
    source: sequence % 2 ? { type: 'custom' } : { type: 'path-summary', stepId: 'step-4', topicId: 'step-4-topic-2' },
    sourceTextSnapshot: '',
    triggerText: 'Amikor feszültté válok egy beszélgetésben.',
    intentionText: 'Megállok egy pillanatra, és előbb végighallgatom a másikat.',
    status,
    createdAt,
    updatedAt: createdAt,
    activatedAt: status === 'active' ? createdAt : null,
    reflections: []
  };
}

(async () => {
  const root = path.join(__dirname, '..');
  const screenshotDir = process.env.HAJNAL_SCREENSHOT_DIR;
  if (screenshotDir) fs.mkdirSync(screenshotDir, { recursive: true });
  const server = createServer(root);
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const browser = await chromium.launch({ headless: true, executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE, args: ['--no-sandbox', '--disable-dev-shm-usage'] });
  try {
    const context = await browser.newContext({ viewport: { width: 412, height: 892 }, deviceScaleFactor: 1, isMobile: true, hasTouch: true });
    const page = await context.newPage();
    await page.goto(`http://127.0.0.1:${server.address().port}/index.html`, { waitUntil: 'networkidle' });
    await page.evaluate((fixture) => localStorage.setItem('hajnal-home-practice-evening-v1', JSON.stringify(fixture)), {
      version: 3,
      practice: {
        practices: [
          practice('active-listening', 'Figyelmes meghallgatás', 'active', 0),
          practice('positive', 'Pozitív megerősítések', 'paused', 1),
          practice('scan', 'Testszkennelés', 'paused', 2),
          practice('gratitude', 'Hála gyakorlat', 'paused', 3),
          practice('safe-place', 'Képzeletbeli biztonságos hely', 'archived', 4),
          practice('impulses', 'Indulatok kezelése', 'archived', 5)
        ],
        activePracticeId: 'active-listening',
        editorDraft: null,
        listFilter: 'all'
      },
      evening: { sobrietyCycleId: 'practice-visual-cycle', startedAt: '2026-10-01T09:00:00.000Z', cleanDates: [], sessions: {} }
    });
    await page.reload({ waitUntil: 'networkidle' });
    await page.locator('[data-action="expand-home-card"]').click();
    await page.locator('[data-action="open-practice-manager"]').click();
    const manager = page.locator('[data-component="practice-manager"]');
    await manager.waitFor();

    const measure = async (width, height, imageName) => {
      await page.setViewportSize({ width, height });
      await page.waitForTimeout(80);
      const popup = await manager.boundingBox();
      const header = await manager.locator('.practice-popup-header').boundingBox();
      const active = await manager.locator('.practice-active-card').boundingBox();
      const heading = await manager.locator('.practice-manager-list-heading').boundingBox();
      const scroll = await manager.locator('.practice-manager-scroll').boundingBox();
      const create = await manager.locator('.practice-manager-create').boundingBox();
      assert.ok(popup && header && active && heading && scroll && create, 'Every fixed manager region must be measurable');
      assert.ok(Math.abs((popup.x + popup.width / 2) - width / 2) <= 2, 'Manager stays horizontally centered');
      assert.ok(popup.x >= 16 && popup.x + popup.width <= width - 16, 'Manager leaves the reference-like side reveal');
      assert.ok(popup.y > 40 && popup.y + popup.height < height - 18, 'Manager stays a focus popup above the system area');
      assert.ok(header.y < active.y && active.y < heading.y && heading.y < scroll.y && scroll.y < create.y, 'Fixed manager regions retain reference order');
      assert.ok(create.y + create.height <= popup.y + popup.height - 12, 'Create action stays visible inside the popup');
      assert.equal(await manager.locator('.practice-manager-scroll').evaluate((node) => getComputedStyle(node).overflowY), 'auto', 'Only the list owns the manager scroll behavior');
      assert.equal(await manager.locator('.practice-popup-header h2').evaluate((node) => getComputedStyle(node).whiteSpace), 'nowrap', 'Reference heading must remain one compact line');
      if (screenshotDir) await page.screenshot({ path: path.join(screenshotDir, imageName) });
    };

    await measure(412, 892, 'practice-manager-reference-412.png');
    const firstRow = manager.locator('.practice-manager-row').first();
    assert.equal(await firstRow.locator('.practice-row-copy').evaluate((node) => getComputedStyle(node).textAlign), 'left', 'List copy is left aligned like the reference');
    assert.equal(await firstRow.locator('.practice-row-activate').isVisible(), true, 'Every row retains its dedicated activation action');
    assert.equal(await firstRow.locator('.practice-row-menu').isVisible(), true, 'Every row retains its context-menu action');
    await manager.locator('[data-practice-list-filter="paused"]').click();
    assert.equal(await manager.locator('.practice-manager-row').count(), 3, 'Paused filter continues to use the existing practice state');
    await manager.locator('[data-practice-list-filter="all"]').click();
    await manager.locator('.practice-manager-scroll').evaluate((node) => { node.scrollTop = 200; });
    const fixedAfterScroll = await Promise.all([
      manager.locator('.practice-popup-header').boundingBox(),
      manager.locator('.practice-manager-create').boundingBox()
    ]);
    assert.ok(fixedAfterScroll.every(Boolean), 'Header and create action remain visible after list scrolling');
    await manager.locator('.practice-manager-scroll').evaluate((node) => { node.scrollTop = 0; });
    await measure(390, 844, 'practice-manager-reference-390.png');
    await measure(360, 800, 'practice-manager-reference-360.png');
  } finally {
    await browser.close();
    await new Promise((resolve) => server.close(resolve));
  }
})().then(() => console.log('PASS practice manager visual-reference browser runtime')).catch((error) => {
  console.error(error.stack || error.message);
  process.exitCode = 1;
});
