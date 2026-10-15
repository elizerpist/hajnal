'use strict';

/*
 * Browser regression for the centered Practice manager/editor overlay.
 *
 * Run in Ubuntu/proot:
 * NODE_PATH=/tmp/hajnal-playwright/node_modules \
 * PLAYWRIGHT_CHROMIUM_EXECUTABLE=/home/flutteruser/.cache/ms-playwright/chromium-1169/chrome-linux/chrome \
 * HAJNAL_SCREENSHOT_DIR=docs/prototypes/verification/refinement-current \
 * node html-prototypes/app-shell/tests/practice_manager_runtime_test.js
 */

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
    fs.readFile(filename, (error, body) => {
      if (error) return response.writeHead(404).end();
      response.writeHead(200, { 'content-type': types[path.extname(filename)] || 'application/octet-stream', 'cache-control': 'no-store' }).end(body);
    });
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
    await page.goto(`http://127.0.0.1:${server.address().port}/index.html`, { waitUntil: 'networkidle' });

    // Closing reflection must reset its wizard and release the Home interaction layer.
    await page.locator('.clean-days-metric').click();
    await page.locator('[data-component="daily-overview-menu"] [data-action="open-daily-reflection-from-overview"]').click();
    await page.locator('.app-frame[data-route="daily-reflection"]').waitFor();
    assert.match(await page.locator('.daily-reflection-header-copy small').textContent(), /^1\s*\//, 'A fresh reflection entry must always start from its first stage');
    await page.locator('[data-action="daily-reflection-next"]').click();
    assert.match(await page.locator('.daily-reflection-header-copy small').textContent(), /^2\s*\//, 'The reflection must still advance normally before exit');
    await page.locator('[data-action="close-daily-reflection"]').click();
    await page.locator('.app-frame[data-route="home"]').waitFor();
    await page.waitForTimeout(220);
    assert.equal(await page.locator('[data-component="daily-overview-menu"]').isHidden(), true, 'Closing reflection must not leave an inert daily-overview overlay above Home');
    await page.locator('[data-action="expand-home-card"]').click();
    await page.locator('.app-frame[data-screen-state="8b-expanded"]').waitFor();
    await page.keyboard.press('Escape');
    await page.locator('.app-frame[data-screen-state="8a-collapsed"]').waitFor();
    await page.locator('.clean-days-metric').click();
    await page.locator('[data-component="daily-overview-menu"] [data-action="open-current-period-history-timeline"]').click();
    await page.locator('.app-frame[data-route="history"]').waitFor();
    await page.waitForTimeout(220);
    await page.locator('.bottom-nav [data-action="return-home"]').click();
    await page.locator('.app-frame[data-route="home"]').waitFor();
    await page.locator('[data-action="expand-home-card"]').click();
    await page.locator('.app-frame[data-screen-state="8b-expanded"]').waitFor();
    await page.keyboard.press('Escape');

    await page.locator('[data-action="expand-home-card"]').click();
    await page.locator('.app-frame[data-screen-state="8b-expanded"]').waitFor();
    await page.locator('[data-action="open-practice-manager"]').click();
    const manager = page.locator('[data-component="practice-manager"]');
    await manager.waitFor();
    const managerBox = await manager.boundingBox();
    assert.ok(managerBox, 'Practice manager must be rendered as a measurable focus popup');
    assert.ok(Math.abs((managerBox.x + managerBox.width / 2) - 206) <= 2, 'Practice manager must remain horizontally centered in the 412px viewport');
    assert.ok(managerBox.y > 20 && managerBox.y + managerBox.height < 872, 'Practice manager must remain inside the safe visible viewport');
    assert.equal(await manager.getAttribute('role'), 'dialog');
    assert.equal(await manager.getAttribute('aria-modal'), 'true');
    if (screenshotDir) await page.screenshot({ path: path.join(screenshotDir, '13-practice-manager-empty.png') });

    await page.locator('[data-action="open-practice-editor"]').click();
    await page.locator('[data-practice-input="title"]').fill('Figyelmes meghallgatás');
    await page.locator('[data-practice-input="triggerText"]').fill('Amikor feszült vagyok, és rögtön reagálnék.');
    await page.locator('[data-practice-input="intentionText"]').fill('Megállok egy pillanatra, és előbb végighallgatom a másikat.');
    const focusStyle = await page.locator('[data-practice-input="intentionText"]').evaluate((node) => {
      const style = getComputedStyle(node);
      return { outlineStyle: style.outlineStyle, outlineWidth: style.outlineWidth };
    });
    assert.deepEqual(focusStyle, { outlineStyle: 'solid', outlineWidth: '2px' }, 'Focused practice fields must use the Hajnal focus treatment rather than the browser-default outline');
    const editor = page.locator('[data-component="practice-manager"]');
    const editorBox = await editor.boundingBox();
    assert.ok(editorBox && editorBox.y > 16 && editorBox.y + editorBox.height < 878, 'Practice editor must remain usable above the system navigation area');
    assert.equal(await page.locator('[data-action="save-practice-editor"]').isVisible(), true, 'Editor must retain its primary action');
    if (screenshotDir) await page.screenshot({ path: path.join(screenshotDir, '14-practice-editor-filled.png') });

    await page.locator('[data-action="save-practice-editor"]').click();
    await page.getByRole('button', { name: 'Vissza a gyakorlataimhoz' }).click();
    await page.locator('.practice-active-card').waitFor();
    assert.equal(await page.locator('.practice-active-card strong').textContent(), 'Figyelmes meghallgatás', 'Saving a new practice must place it in the single active-card slot');
    assert.equal(await page.locator('.practice-manager-row').count(), 0, 'An active practice must not be duplicated in the remaining-practices list');
    if (screenshotDir) await page.screenshot({ path: path.join(screenshotDir, '15-practice-manager-active.png') });

    // A reflection that was opened earlier in the day can safely attach a
    // practice chosen later, including its one optional experience note.
    await page.locator('[data-action="close-practice-sheet"]').click();
    await page.locator('[data-component="practice-sheet"]').waitFor({ state: 'hidden' });
    await page.locator('.clean-days-metric').click();
    await page.locator('[data-component="daily-overview-menu"] [data-action="open-daily-reflection-from-overview"]').click();
    assert.match(await page.locator('.daily-reflection-header-copy small').textContent(), /^1\s*\/\s*3$/, 'A newly attached active practice must make the reflection’s practice step available');
    await page.locator('[data-action="daily-reflection-next"]').click();
    await page.locator('[data-action="daily-reflection-next"]').click();
    await page.locator('[data-daily-practice-note]').fill('Ma sikerült előbb meghallgatnom a másikat.');
    await page.locator('[data-practice-observation="attempted"]').click();
    assert.equal(await page.locator('[data-daily-practice-note]').inputValue(), 'Ma sikerült előbb meghallgatnom a másikat.', 'The optional practice note must remain in the shared daily record while the stage is open');
    if (screenshotDir) await page.screenshot({ path: path.join(screenshotDir, '16-daily-reflection-practice-note.png') });
    await page.locator('[data-action="daily-reflection-next"]').click();
    await page.locator('.app-frame[data-route="home"]').waitFor();
  } finally {
    await browser.close();
    await new Promise((resolve) => server.close(resolve));
  }
})().then(() => console.log('PASS practice manager browser runtime')).catch((error) => {
  console.error(error.stack || error.message);
  process.exitCode = 1;
});
