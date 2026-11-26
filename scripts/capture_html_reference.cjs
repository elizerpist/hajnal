const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch({headless: true});
  const page = await browser.newPage({viewport: {width: 412, height: 892}, deviceScaleFactor: 1});
  await page.goto('http://127.0.0.1:8768/app-shell/', {waitUntil: 'networkidle'});
  const frame = page.locator('.app-frame');
  await frame.screenshot({path: 'evidence/html-closed.png'});
  const card = page.locator('[data-component="daily-summary-card"]');
  const box = await card.boundingBox();
  if (!box) throw new Error('summary card missing');
  await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
  await page.mouse.down();
  await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2 - 96, {steps: 12});
  await page.mouse.up();
  await page.waitForTimeout(400);
  if (await frame.getAttribute('data-screen-state') !== '8b-expanded') throw new Error('HTML sheet did not expand');
  await frame.screenshot({path: 'evidence/html-open.png'});
  await browser.close();
})().catch(error => { console.error(error); process.exitCode = 1; });
