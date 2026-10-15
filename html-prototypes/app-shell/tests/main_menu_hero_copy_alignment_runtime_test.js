'use strict';

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
const artifactDirectory = process.env.MAIN_MENU_HERO_COPY_ARTIFACT_DIR || '/tmp/hajnal-main-menu-hero-copy';
fs.mkdirSync(artifactDirectory, { recursive: true });

function contentType(file) {
  if (file.endsWith('.html')) return 'text/html; charset=utf-8';
  if (file.endsWith('.png')) return 'image/png';
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

async function titleMetrics(page, selector) {
  return page.locator(selector).evaluate((title) => {
    const subtitle = title.parentElement.querySelector('p');
    const titleRect = title.getBoundingClientRect();
    const subtitleRect = subtitle.getBoundingClientRect();
    const style = getComputedStyle(title);
    const subtitleStyle = getComputedStyle(subtitle);
    return {
      x: titleRect.x,
      y: titleRect.y,
      fontSize: style.fontSize,
      color: style.color,
      subtitleY: subtitleRect.y,
      subtitleFontSize: subtitleStyle.fontSize,
      subtitleColor: subtitleStyle.color,
      subtitleGap: Math.round((subtitleRect.y - (titleRect.y + titleRect.height)) * 100) / 100
    };
  });
}

(async () => {
  const server = await startStaticServer();
  const port = server.address().port;
  const served = await fetch(`http://127.0.0.1:${port}/app-shell/index.html`).then((response) => response.text());
  assert.equal(crypto.createHash('sha256').update(served).digest('hex'), expectedHash, 'runtime verification must serve this exact working tree');
  const browser = await chromium.launch({
    headless: true,
    executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE || undefined,
    args: ['--no-sandbox', '--disable-dev-shm-usage']
  });
  try {
    const context = await browser.newContext({ viewport: { width: 412, height: 892 }, deviceScaleFactor: 1, isMobile: true, hasTouch: true });
    const page = await context.newPage();
    await page.goto(`http://127.0.0.1:${port}/app-shell/`, { waitUntil: 'domcontentloaded' });

    const menuCases = [
      { action: 'open-sponsor', title: '#sponsor .sponsor-hero-copy h1', screenshot: 'sponsor-412x892.png' },
      { action: 'open-history', title: '.history-screen[data-history-workspace="inline"] .history-hero-copy h1', screenshot: 'history-412x892.png' },
      { action: 'open-path', title: '.path-overview-heading h1', screenshot: 'path-412x892.png' },
      { action: 'open-meetings', title: '.meetings-hero-copy h1', screenshot: 'meetings-412x892.png' }
    ];
    const results = {};
    for (const current of menuCases) {
      await page.locator(`[data-component="bottom-navigation"] [data-action="${current.action}"]`).click();
      await page.locator(current.title).waitFor();
      await page.waitForTimeout(90);
      results[current.action] = await titleMetrics(page, current.title);
      await page.screenshot({ path: path.join(artifactDirectory, current.screenshot), fullPage: false });
    }

    const sponsor = results['open-sponsor'];
    assert.deepEqual(
      { x: sponsor.x, y: sponsor.y, fontSize: sponsor.fontSize, color: sponsor.color },
      { x: 26, y: 47, fontSize: '32px', color: 'rgb(7, 19, 44)' },
      'Sponsor remains the concrete shared hero-title reference'
    );
    for (const [action, result] of Object.entries(results)) {
      assert.ok(Math.abs(result.x - sponsor.x) <= 1, `${action} title left edge must align with Sponsor`);
      assert.ok(Math.abs(result.y - sponsor.y) <= 1, `${action} title top must align with Sponsor`);
      assert.equal(result.fontSize, sponsor.fontSize, `${action} title size must match Sponsor`);
      assert.equal(result.color, sponsor.color, `${action} title color must match Sponsor`);
      assert.equal(result.subtitleFontSize, '14px', `${action} secondary text must use the shared 14px size`);
      assert.equal(result.subtitleColor, sponsor.subtitleColor, `${action} secondary text color must match Sponsor`);
      assert.ok(Math.abs(result.subtitleGap - sponsor.subtitleGap) <= 1, `${action} secondary text must sit directly below the title with the shared gap`);
    }

    const pathQuoteCount = await page.locator('.path-overview-quote').count();
    assert.equal(pathQuoteCount, 0, 'Ösvény overview must not render a separate hero quote');
  } finally {
    await browser.close();
    await new Promise((resolve) => server.close(resolve));
  }
  console.log(`PASS main-menu hero title runtime contract (${artifactDirectory})`);
})().catch((error) => {
  console.error(error.stack || error);
  process.exitCode = 1;
});
