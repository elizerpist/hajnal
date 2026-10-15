/*
 * Run with a local Playwright installation, for example:
 * HAJNAL_PLAYWRIGHT_MODULE=file:///tmp/hajnal-playwright/node_modules/playwright/index.mjs \
 * PLAYWRIGHT_CHROMIUM_EXECUTABLE=/tmp/hajnal-playwright/browsers/chromium-1187/chrome-linux/chrome \
 * HAJNAL_SCREENSHOT_DIR=docs/prototypes/verification/sponsor-contact \
 * node html-prototypes/app-shell/tests/sponsor_contact_workspace_runtime_test.js
 */
const assert = require('node:assert/strict');
const fs = require('node:fs');
const http = require('node:http');
const path = require('node:path');

async function loadChromium() {
  try {
    const moduleName = process.env.HAJNAL_PLAYWRIGHT_MODULE || 'playwright';
    const imported = await import(moduleName);
    return imported.chromium;
  } catch (error) {
    throw new Error(`BLOCKED: this runtime test requires Playwright/Chromium. ${error.message}`);
  }
}

function createServer(root) {
  const contentType = (file) => file.endsWith('.html') ? 'text/html; charset=utf-8' : file.endsWith('.png') ? 'image/png' : 'application/octet-stream';
  const server = http.createServer((request, response) => {
    const pathname = decodeURIComponent(new URL(request.url || '/', 'http://127.0.0.1').pathname);
    const filename = path.resolve(root, `.${pathname === '/' ? '/index.html' : pathname}`);
    if (!filename.startsWith(root)) { response.writeHead(403).end(); return; }
    fs.readFile(filename, (error, body) => {
      if (error) { response.writeHead(404).end(); return; }
      response.writeHead(200, { 'content-type': contentType(filename) });
      response.end(body);
    });
  });
  return server;
}

async function run() {
  const chromium = await loadChromium();
  const appRoot = path.join(__dirname, '..');
  const screenshotDir = process.env.HAJNAL_SCREENSHOT_DIR;
  if (screenshotDir) fs.mkdirSync(screenshotDir, { recursive: true });
  const server = createServer(appRoot);
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const { port } = server.address();
  const browser = await chromium.launch({ headless: true, executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE || undefined, args: ['--no-sandbox', '--disable-dev-shm-usage'] });
  const context = await browser.newContext({ viewport: { width: 412, height: 892 }, deviceScaleFactor: 1, isMobile: true, hasTouch: true });
  const page = await context.newPage();
  const pageErrors = [];
  page.on('pageerror', (error) => pageErrors.push(error.message));
  const shot = async (name) => { if (screenshotDir) await page.screenshot({ path: path.join(screenshotDir, `${name}.png`) }); };

  try {
    await page.goto(`http://127.0.0.1:${port}/index.html`, { waitUntil: 'networkidle' });
    await page.locator('.bottom-nav button[data-action="open-meetings"]').click();
    await page.locator('[data-component="meetings-view-switch"] [data-meetings-view="list"]').click();
    const meetingsTop = await page.locator('[data-component="meeting-list-statistics"]').evaluate((node) => node.getBoundingClientRect().top);

    await page.locator('.bottom-nav button[data-action="open-sponsor"]').click();
    await page.locator('[data-component="sponsor-contact-card"]').waitFor();
    const sponsorTop = await page.locator('[data-component="sponsor-contact-card"]').evaluate((node) => node.getBoundingClientRect().top);
    const sponsorHeroGeometry = await page.locator('section[data-route="sponsor"] .sponsor-hero-copy h1').evaluate((node) => {
      const rect = node.getBoundingClientRect();
      return { top: rect.top, left: rect.left, fontSize: getComputedStyle(node).fontSize };
    });
    assert.ok(Math.abs(meetingsTop - sponsorTop) <= 2, `Sponsor card (${sponsorTop}) and Meetings card (${meetingsTop}) must share the 151px body top`);
    console.log(`Sponsor geometry: Meetings ${meetingsTop}px; Sponsor ${sponsorTop}px; delta ${Math.abs(meetingsTop - sponsorTop)}px`);
    assert.equal(await page.locator('.sponsor-hero img').getAttribute('src'), 'assets/hero/sponsor_hero_soft.png');
    await shot('01-sponsor-empty');

    await page.locator('[data-component="sponsor-backup-preview"] [data-action="open-sponsor-backups"]').first().click();
    await page.locator('[data-action="add-sponsor-backup"]').click();
    await page.locator('input[data-sponsor-backup-input="name"]').fill('Anna');
    await page.locator('input[data-sponsor-backup-input="phone"]').fill('+36 20 555 0101');
    await page.locator('[data-action="close-sponsor-backups"]').click();
    await page.locator('[data-component="sponsor-backup-preview"] a[href="tel:+36205550101"]').waitFor();
    const sponsorMainGeometry = await page.locator('.sponsor-main-content').evaluate((owner) => {
      const backup = owner.querySelector('[data-component="sponsor-backup-preview"]');
      const summary = owner.querySelector('[data-component="sponsor-work-summary"]');
      const bottomNav = document.querySelector('.bottom-nav');
      return {
        ownerOverflow: getComputedStyle(owner).overflowY,
        backupOverflow: getComputedStyle(backup.querySelector('.sponsor-backup-preview-list')).overflowY,
        backupHeight: backup.getBoundingClientRect().height,
        summaryBottom: summary.getBoundingClientRect().bottom,
        bottomNavTop: bottomNav.getBoundingClientRect().top
      };
    });
    assert.equal(sponsorMainGeometry.ownerOverflow, 'hidden', 'the Sponsor main screen must not become a second vertical scroll owner');
    assert.equal(sponsorMainGeometry.backupOverflow, 'auto', 'the fixed backup card must own its contact-list scroll');
    assert.ok(sponsorMainGeometry.backupHeight > 140, 'the backup card must grow into the space above the fixed shared-work card');
    assert.ok(sponsorMainGeometry.summaryBottom <= sponsorMainGeometry.bottomNavTop, 'the shared-work card must remain above the BottomNav');
    await shot('02-sponsor-backup');

    await page.locator('[data-action="open-sponsor-work"]').click();
    await page.locator('section[data-route="sponsor-work"]').waitFor();
    assert.equal(await page.locator('.app-frame').getAttribute('data-route'), 'sponsor-work');
    assert.equal(await page.locator('.bottom-nav button[data-action="open-sponsor"]').getAttribute('aria-current'), 'page');
    assert.equal(await page.locator('[data-sponsor-work-tab="pending"]').getAttribute('aria-selected'), 'true');
    const sharedWorkGeometry = await page.locator('section[data-route="sponsor-work"]').evaluate((screen) => {
      const title = screen.querySelector('.sponsor-hero-copy h1');
      const profile = screen.querySelector('.sponsor-work-profile');
      const hero = screen.querySelector('.sponsor-hero img');
      const titleRect = title.getBoundingClientRect();
      return { titleTop: titleRect.top, titleLeft: titleRect.left, titleFontSize: getComputedStyle(title).fontSize, profileTop: profile.getBoundingClientRect().top, hero: hero.getAttribute('src') };
    });
    assert.deepEqual({ top: sharedWorkGeometry.titleTop, left: sharedWorkGeometry.titleLeft, fontSize: sharedWorkGeometry.titleFontSize }, sponsorHeroGeometry, 'Shared work must reuse the Sponsor hero title geometry exactly');
    assert.equal(sharedWorkGeometry.hero, 'assets/hero/sponsor_hero_soft.png', 'Shared work must reuse the Sponsor hero artwork');
    assert.ok(Math.abs(sharedWorkGeometry.profileTop - sponsorTop) <= 2, 'Shared work profile and Sponsor contact card must share the same body top');
    await shot('03-sponsor-work-pending');
    await page.locator('section[data-route="sponsor-work"] [data-action="open-sponsor-details"]').click();
    await page.locator('section[data-route="sponsor-details"]').waitFor();
    await page.locator('[data-action="close-sponsor-details"]').click();
    assert.equal(await page.locator('.app-frame').getAttribute('data-route'), 'sponsor-work');
    assert.equal(await page.locator('[data-sponsor-work-tab="pending"]').getAttribute('aria-selected'), 'true');
    const pendingScrollGeometry = await page.locator('.sponsor-work-list-scroll').evaluate((owner) => {
      const fab = document.querySelector('[data-component="sponsor-work-fab"]');
      owner.scrollTop = owner.scrollHeight;
      const rows = owner.querySelectorAll('[data-pending-id]');
      const last = rows[rows.length - 1];
      return {
        clientHeight: owner.clientHeight,
        scrollHeight: owner.scrollHeight,
        overflow: getComputedStyle(owner).overflowY,
        parentOverflow: getComputedStyle(owner.parentElement).overflowY,
        lastBottom: last?.getBoundingClientRect().bottom || 0,
        fabTop: fab?.getBoundingClientRect().top || Infinity
      };
    });
    assert.equal(pendingScrollGeometry.overflow, 'auto', 'the pending collection must own vertical overflow when its content becomes long');
    assert.equal(pendingScrollGeometry.parentOverflow, 'hidden', 'the fixed selector shell must not become a competing vertical scroll owner');
    assert.ok(pendingScrollGeometry.lastBottom <= pendingScrollGeometry.fabTop, 'the final pending item must remain reachable above the add button');
    await page.locator('.sponsor-work-list-scroll').evaluate((owner) => { owner.scrollTop = 0; });
    await page.locator('[data-pending-id]').first().click();
    await page.locator('section[data-route="sponsor-takeaway-editor"]').waitFor();
    await page.locator('[data-action="close-sponsor-takeaway-editor"]').click();
    assert.equal(await page.locator('.app-frame').getAttribute('data-route'), 'sponsor-work');
    assert.equal(await page.locator('[data-sponsor-work-tab="pending"]').getAttribute('aria-selected'), 'true');
    await page.locator('[data-component="sponsor-work-fab"]').click();
    await page.locator('[data-pending-inline-input]').fill('Egy új, saját téma');
    await page.locator('[data-pending-inline-input]').press('Enter');
    await page.getByText('Egy új, saját téma', { exact: true }).waitFor();

    await page.locator('[data-sponsor-work-tab="takeaways"]').click();
    assert.equal(await page.locator('[data-sponsor-work-tab="takeaways"]').getAttribute('aria-selected'), 'true');
    const takeawayAccent = await page.locator('section[data-route="sponsor-work"]').evaluate((screen) => ({
      tabBackground: getComputedStyle(screen.querySelector('[data-sponsor-work-tab="takeaways"]')).backgroundColor,
      fabBackground: getComputedStyle(screen.querySelector('[data-component="sponsor-work-fab"]')).backgroundColor
    }));
    assert.equal(takeawayAccent.tabBackground, 'rgb(106, 86, 180)', 'The selected takeaway tab must use the application-purple pill surface');
    assert.equal(takeawayAccent.fabBackground, 'rgb(106, 86, 180)', 'The new-takeaway pill must use the same purple as the pending CTA');
    await shot('04-sponsor-work-takeaways');
    const takeawayOrderBefore = await page.locator('[data-takeaway-row-id]').evaluateAll((rows) => rows.map((row) => row.dataset.takeawayRowId));
    const dragHandle = page.locator('[data-takeaway-drag-handle]').first();
    const finalRow = page.locator('[data-takeaway-row-id]').last();
    const dragBox = await dragHandle.boundingBox();
    const finalBox = await finalRow.boundingBox();
    assert.ok(dragBox && finalBox, 'takeaway reordering requires visible drag endpoints');
    await page.mouse.move(dragBox.x + (dragBox.width / 2), dragBox.y + (dragBox.height / 2));
    await page.mouse.down();
    await page.mouse.move(finalBox.x + (finalBox.width / 2), finalBox.y + (finalBox.height / 2), { steps: 5 });
    await page.mouse.up();
    const takeawayOrderAfter = await page.locator('[data-takeaway-row-id]').evaluateAll((rows) => rows.map((row) => row.dataset.takeawayRowId));
    assert.notDeepEqual(takeawayOrderAfter, takeawayOrderBefore, 'the existing takeaway reorder handler must also work from shared work');
    await page.locator('[data-component="sponsor-work-fab"]').click();
    await page.locator('section[data-route="sponsor-takeaway-editor"]').waitFor();
    await page.locator('[data-takeaway-title-input]').fill('Új, közös útravaló');
    await page.locator('[data-action="save-sponsor-takeaway"]').click();
    assert.equal(await page.locator('.app-frame').getAttribute('data-route'), 'sponsor-work');
    assert.equal(await page.locator('[data-sponsor-work-tab="takeaways"]').getAttribute('aria-selected'), 'true');
    await page.getByText('Új, közös útravaló', { exact: true }).waitFor();
    await page.getByText('Új, közös útravaló', { exact: true }).click();
    await page.locator('[data-takeaway-title-input]').fill('Szerkesztett közös útravaló');
    await page.locator('[data-action="save-sponsor-takeaway"]').click();
    await page.getByText('Szerkesztett közös útravaló', { exact: true }).waitFor();
    await page.getByText('Szerkesztett közös útravaló', { exact: true }).click();
    page.once('dialog', (dialog) => dialog.accept());
    await page.locator('[data-action="toggle-takeaway-delete-menu"]').click();
    await page.locator('[data-action="delete-sponsor-takeaway"]').click();
    assert.equal(await page.locator('.app-frame').getAttribute('data-route'), 'sponsor-work');
    assert.equal(await page.getByText('Szerkesztett közös útravaló', { exact: true }).count(), 0);
    await page.locator('[data-takeaway-id]').first().click();
    await page.locator('[data-action="close-sponsor-takeaway-editor"]').click();
    assert.equal(await page.locator('.app-frame').getAttribute('data-route'), 'sponsor-work');
    assert.equal(await page.locator('[data-sponsor-work-tab="takeaways"]').getAttribute('aria-selected'), 'true');

    await page.locator('[data-action="close-sponsor-work"]').click();
    await page.locator('.bottom-nav button[data-action="open-meetings"]').click();
    await page.locator('[data-component="meetings-view-switch"] [data-meetings-view="list"]').click();
    await page.locator('[data-component="meetings-list-tabs"]').waitFor();
    assert.equal(await page.locator('[data-meetings-list-tab="upcoming"]').getAttribute('aria-selected'), 'true');
    assert.equal(await page.locator('.meetings-main-content[data-meetings-view="list"] [data-action="open-new-meeting"]').count(), 0, 'List mode must not expose a meeting-add action');
    await page.locator('[data-meetings-list-tab="past"]').click();
    assert.equal(await page.locator('[data-meetings-list-tab="past"]').getAttribute('aria-selected'), 'true');
    await page.locator('[data-component="meetings-view-switch"] [data-meetings-view="calendar"]').click();
    assert.ok(await page.locator('.meetings-main-content[data-meetings-view="calendar"] [data-action="open-new-meeting"]').count() > 0, 'Calendar-day view must retain the only meeting-add action');
    await page.locator('.bottom-nav button[data-action="open-sponsor"]').click();
    await page.locator('[data-action="open-sponsor-next-calendar"]').click();
    await page.locator('section[data-route="sponsor-next"] [data-component="sponsor-calendar-content"]').waitFor();
    assert.equal(await page.locator('.app-frame').getAttribute('data-route'), 'sponsor-next');
    assert.equal(await page.locator('.bottom-nav button[data-action="open-sponsor"]').getAttribute('aria-current'), 'page');
    assert.ok(await page.locator('[data-component="sponsor-calendar-history"] .sponsor-calendar-history-item').count() > 0, 'The full-screen appointment calendar must render its dedicated mock prior-appointments list');
    await shot('05-sponsor-next-calendar');
    await page.locator('[data-action="close-sponsor-calendar"]').click();
    await page.locator('section[data-route="sponsor"]').waitFor();

    await page.locator('[data-action="open-sponsor-details"]').click();
    await page.locator('[data-action="open-sponsor-since-calendar"]').click();
    await page.locator('section[data-route="sponsor-since-calendar"] [data-component="sponsor-since-calendar-content"]').waitFor();
    assert.equal(await page.locator('.app-frame').getAttribute('data-route'), 'sponsor-since-calendar');
    await shot('06-sponsor-since-calendar');
    await page.locator('[data-action="close-sponsor-calendar"]').click();
    assert.equal(await page.locator('.app-frame').getAttribute('data-route'), 'sponsor-details');
    assert.deepEqual(pageErrors, [], `unexpected browser errors: ${pageErrors.join('; ')}`);
  } finally {
    await browser.close();
    await new Promise((resolve) => server.close(resolve));
  }
}

run().then(() => console.log('PASS Sponsor contact workspace browser runtime')).catch((error) => {
  console.error(error.stack || error.message);
  process.exitCode = 1;
});
