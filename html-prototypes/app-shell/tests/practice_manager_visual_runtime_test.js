'use strict';

/* Browser geometry/regression for the required gyakorlat2 Practice Picker. */
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
          practice('pause', 'Megállok egy pillanatra', 'paused', 1),
          practice('gratitude', 'Hála a jelenért', 'paused', 2),
          practice('patience', 'Türelem a mindennapokban', 'paused', 3),
          practice('needs', 'Saját igények', 'archived', 4),
          practice('stress', 'Stresszkezelés', 'archived', 5)
        ],
        activePracticeId: 'active-listening',
        editorDraft: null,
        listFilter: 'all'
      },
      evening: { sobrietyCycleId: 'practice-visual-cycle', startedAt: '2026-10-01T09:00:00.000Z', cleanDates: [], sessions: {} }
    });
    await page.reload({ waitUntil: 'networkidle' });
    await page.locator('[data-action="expand-home-card"]').click();
    const homePractice = page.locator('[data-component="home-practice-block"]');
    assert.equal(await homePractice.locator('small').count(), 0, 'The expanded Home practice preview must not duplicate a gray source line');
    assert.equal(await homePractice.locator('strong').evaluate((node) => getComputedStyle(node).webkitLineClamp), '2', 'The expanded Home practice preview must reserve two lines for the actual practice text');
    assert.equal(await homePractice.locator('.home-practice-active > span:first-child').evaluate((node) => getComputedStyle(node).textAlign), 'left', 'The actual practice text must not inherit the chevron alignment on the Home sheet');
    assert.match(await page.locator('.home-body').evaluate((node) => node.style.getPropertyValue('--practice-sheet-decoration')), /sprout_sheet_field_v4\.png/, 'The expanded Home sheet resolves the sparse, large-motif v4 practice decoration');
    const homeDecoration = await page.locator('.home-body').evaluate((node) => ({
      size: getComputedStyle(node, '::after').backgroundSize,
      opacity: Number(getComputedStyle(node, '::after').opacity)
    }));
    assert.equal(homeDecoration.size, '100% 100%', 'The sheet decoration stretches across the complete available sheet surface');
    assert.ok(homeDecoration.opacity >= .24 && homeDecoration.opacity <= .36, 'The full-surface sheet field remains visible without competing with its content');
    if (screenshotDir) await page.screenshot({ path: path.join(screenshotDir, 'home-expanded-practice-ornament-412.png') });
    await page.locator('[data-action="open-practice-manager"]').click();
    const manager = page.locator('[data-component="practice-manager"]');
    await manager.waitFor();
    assert.equal(await manager.locator('.practice-current-card').evaluate((node) => node.style.getPropertyValue('--practice-card-decoration')), '', 'The active practice card stays free of decorative background assets');

    const measure = async (width, height, imageName) => {
      await page.setViewportSize({ width, height });
      await page.waitForTimeout(80);
      const popup = await manager.boundingBox();
      const chrome = await manager.locator('.practice-picker-chrome').boundingBox();
      const current = await manager.locator('.practice-current-card').boundingBox();
      const heading = await manager.locator('.practice-list-shell > h3').boundingBox();
      const scroll = await manager.locator('.practice-list-scroll').boundingBox();
      const fixedFooter = await manager.locator('.practice-manager-footer').boundingBox();
      assert.ok(popup && chrome && current && heading && scroll && fixedFooter, 'Every fixed picker region must be measurable');
      assert.ok(Math.abs((popup.x + popup.width / 2) - width / 2) <= 2, 'Picker stays horizontally centered');
      assert.ok(popup.x >= 12 && popup.x + popup.width <= width - 12, 'Picker leaves a visible contextual background reveal');
      assert.ok(popup.y >= 18 && popup.y + popup.height <= height - 18, 'Picker stays above the system area');
      assert.ok(popup.height <= height * .9 + 1, 'Picker remains a centered modal rather than a fullscreen route');
      assert.ok(chrome.y < current.y && current.y < heading.y && heading.y < scroll.y && scroll.y < fixedFooter.y, 'Fixed picker regions retain the source-reference order');
      assert.equal(await manager.locator('.practice-list-scroll').evaluate((node) => getComputedStyle(node).overflowY), 'auto', 'Only the list body owns vertical scrolling');
      assert.equal(await manager.locator('.practice-popup-header h2').textContent(), 'Ezt szeretném gyakorolni', 'Picker uses the exact source-reference heading');
      if (screenshotDir) await page.screenshot({ path: path.join(screenshotDir, imageName) });
    };

    await measure(412, 892, 'practice-picker-gyakorlat2-412.png');
    assert.equal(await manager.locator('.practice-list-card').count(), 5, 'All non-active practices are listed together without status filtering');
    assert.equal(await manager.locator('[data-practice-filter-select]').count(), 0, 'The retired state filter is absent');
    assert.equal(await manager.locator('.practice-list-card em').count(), 0, 'The manager list must not render a third preview row');
    assert.equal(await manager.locator('.practice-list-card img').count(), 5, 'Every listed practice renders its generated artwork asset');
    assert.equal(await manager.locator('.practice-current-card img').count(), 1, 'The current card renders its generated artwork asset');
    assert.ok((await manager.locator('.practice-list-card').evaluateAll((nodes) => nodes.every((node) => node.style.getPropertyValue('--practice-card-decoration') === ''))), 'List cards stay free of decorative background assets');
    assert.equal(await manager.locator('.practice-current-action').count(), 0, 'The current practice has no redundant Details CTA');
    await manager.locator('.practice-current-card').click();
    assert.equal(await manager.locator('.practice-popup-header h2').textContent(), 'Gyakorlat szerkesztése', 'Tapping the active practice card opens the same editor as a list card');
    assert.equal(await page.locator('[data-practice-input="title"]').inputValue(), 'Figyelmes meghallgatás', 'The active card opens its actual practice without changing activation');
    await manager.locator('[data-action="cancel-practice-editor"]').click();
    const firstCard = manager.locator('.practice-list-card').first();
    const firstTitle = await firstCard.locator('strong').textContent();
    assert.equal(await firstCard.locator('.practice-list-menu-trigger').count(), 0, 'The retired three-dot menu trigger is absent from each list card');
    assert.equal(await firstCard.locator('.practice-list-context-menu').count(), 0, 'The retired context dropdown is absent from each list card');
    const editSurface = firstCard.locator('.practice-list-edit');
    const chevron = firstCard.locator('.practice-list-chevron');
    const editBox = await editSurface.boundingBox();
    const chevronBox = await chevron.boundingBox();
    assert.ok(editBox && chevronBox && editBox.x < chevronBox.x, 'The editor tap surface occupies the card body and the activation chevron stays on the right');
    await editSurface.click();
    assert.equal(await manager.locator('.practice-popup-header h2').textContent(), 'Gyakorlat szerkesztése', 'Tapping a list card body opens its existing editor');
    assert.equal(await page.locator('[data-practice-input="title"]').inputValue(), firstTitle, 'The editor receives the tapped practice data without activating it');
    assert.equal(await manager.locator('.practice-editor-delete[data-action="delete-practice"]').count(), 1, 'The existing-practice editor exposes the confirmed delete action');
    await manager.locator('[data-action="cancel-practice-editor"]').click();
    assert.equal(await manager.locator('.practice-current-card strong').textContent(), 'Figyelmes meghallgatás', 'Opening and leaving the editor cannot change the active practice');
    await manager.locator('.practice-list-card').first().locator('.practice-list-chevron').click();
    await page.waitForTimeout(80);
    assert.equal(await manager.locator('.practice-current-card strong').textContent(), firstTitle, 'Tapping only the right chevron immediately switches the active practice');
    assert.equal(await manager.getByText('Gyakorlat váltása', { exact: true }).count(), 0, 'Direct activation never opens the retired replacement confirmation');
    const scroll = manager.locator('.practice-list-scroll');
    const fixedBeforeScroll = await Promise.all([
      manager.locator('.practice-picker-chrome').boundingBox(),
      manager.locator('.practice-current-card').boundingBox(),
      manager.locator('.practice-list-shell > h3').boundingBox(),
      manager.locator('.practice-manager-footer').boundingBox()
    ]);
    await scroll.evaluate((node) => { node.scrollTop = node.scrollHeight; });
    await page.waitForTimeout(60);
    const fixedAfterScroll = await Promise.all([
      manager.locator('.practice-picker-chrome').boundingBox(),
      manager.locator('.practice-current-card').boundingBox(),
      manager.locator('.practice-list-shell > h3').boundingBox(),
      manager.locator('.practice-manager-footer').boundingBox()
    ]);
    fixedBeforeScroll.forEach((before, index) => assert.ok(before && fixedAfterScroll[index] && Math.abs(before.y - fixedAfterScroll[index].y) < 1, `Only list content moves while scrolling (region ${index}: ${JSON.stringify(before)} → ${JSON.stringify(fixedAfterScroll[index])})`));
    assert.equal(await manager.locator('.practice-manager-create').isVisible(), true, 'The fixed add-practice action remains visible while the list scrolls');
    assert.equal(await manager.locator('.practice-picker-footer').isVisible(), true, 'The fixed reference footer decoration remains visible while the list scrolls');
    await manager.locator('.practice-manager-create').click();
    assert.equal(await manager.locator('.practice-popup-header h2').textContent(), 'Új gyakorlat', 'The existing editor continues to open from the add action');
    await manager.locator('[data-action="cancel-practice-editor"]').click();
    await measure(390, 844, 'practice-picker-gyakorlat2-390.png');
    await measure(360, 800, 'practice-picker-gyakorlat2-360.png');
  } finally {
    await browser.close();
    server.closeAllConnections?.();
    await new Promise((resolve) => server.close(resolve));
  }
})().then(() => console.log('PASS gyakorlat2 practice-picker browser runtime')).catch((error) => {
  console.error(error.stack || error.message);
  process.exitCode = 1;
});
