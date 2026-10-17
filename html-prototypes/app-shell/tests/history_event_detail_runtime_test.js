'use strict';

/* Browser regression for the shared BottomNav inside History event detail. */
const assert = require('node:assert/strict');
const fs = require('node:fs');
const http = require('node:http');
const path = require('node:path');
const { chromium } = require('playwright');

function createServer(root) {
  const types = { '.html': 'text/html; charset=utf-8', '.png': 'image/png', '.svg': 'image/svg+xml' };
  return http.createServer((request, response) => {
    const pathname = decodeURIComponent(new URL(request.url || '/', 'http://127.0.0.1').pathname);
    const filename = path.resolve(root, `.${pathname === '/' ? '/index.html' : pathname}`);
    if (!filename.startsWith(root)) return response.writeHead(403).end();
    fs.readFile(filename, (error, body) => response.writeHead(error ? 404 : 200, { 'content-type': error ? 'text/plain' : (types[path.extname(filename)] || 'application/octet-stream'), 'cache-control': 'no-store' }).end(error ? 'Not found' : body));
  });
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
    page.setDefaultTimeout(4000);
    await page.goto(`http://127.0.0.1:${server.address().port}/index.html`, { waitUntil: 'networkidle' });
    await page.locator('[data-component="bottom-navigation"] [data-action="open-history"]').click();
    await page.locator('[data-history-pager-role="current"] [data-action="open-timeline-event-detail"]').first().click();
    const detail = page.locator('section[data-route="timeline-event-detail"]');
    await detail.waitFor();
    assert.equal(await page.locator('.bottom-nav').isVisible(), true, 'History event detail must keep the shared BottomNav visible');
    assert.equal(await page.locator('.bottom-nav [data-action="open-history"]').getAttribute('aria-current'), 'page', 'History remains the active shared-navigation section in event detail');
    assert.equal(await detail.getByText('Címkék', { exact: true }).count(), 0, 'Event detail must omit the retired tags row');
    assert.equal(await detail.getByText('Képek', { exact: true }).count(), 0, 'Event detail must omit the unsupported image-upload section');
    assert.equal(await detail.locator('.timeline-event-images, .timeline-event-add-image').count(), 0, 'No image or image-upload control remains in event detail');
    assert.equal(await detail.locator('.timeline-event-detail-more, [aria-label="További lehetőségek"]').count(), 0, 'Event detail must not retain an inactive three-dot menu');
    assert.equal(await detail.locator('.timeline-event-hero').evaluate((hero) => Math.round(hero.getBoundingClientRect().height)), 148, 'Event detail hero must use the compact 148px height');
    const geometry = await detail.evaluate((screen) => {
      const content = screen.querySelector('.timeline-event-detail-content')?.getBoundingClientRect();
      const nav = document.querySelector('.bottom-nav')?.getBoundingClientRect();
      return { contentBottom: content?.bottom, navTop: nav?.top };
    });
    assert.ok(geometry.contentBottom <= geometry.navTop, `Event content must stop above BottomNav (${JSON.stringify(geometry)})`);
    if (screenshotDir) await page.screenshot({ path: path.join(screenshotDir, 'history-event-detail-412.png'), fullPage: false });
  } finally {
    await browser.close();
    server.closeAllConnections?.();
    await new Promise((resolve) => server.close(resolve));
  }
})().then(() => console.log('PASS History event detail browser runtime')).catch((error) => {
  console.error(error.stack || error.message);
  process.exitCode = 1;
});
