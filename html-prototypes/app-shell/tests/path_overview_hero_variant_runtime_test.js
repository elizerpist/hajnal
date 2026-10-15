'use strict';

/*
 * Visual/runtime contract for the optional richer Ösvény overview hero.
 * Run in Ubuntu/proot with the project-local Playwright Chromium.
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
const artifactDirectory = process.env.PATH_OVERVIEW_HERO_VARIANT_ARTIFACT_DIR || '/tmp/hajnal-path-overview-hero-variant';
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
    await page.locator('[data-component="bottom-navigation"] [data-action="open-path"]').click();
    await page.locator('[data-component="path-overview-hero-variant-toggle"]').waitFor();
    await page.waitForTimeout(120);

    const defaultState = await page.evaluate(() => {
      const screen = document.querySelector('[data-component="path-workspace"]');
      const toggle = document.querySelector('[data-component="path-overview-hero-variant-toggle"]');
      const actionCluster = document.querySelector('.path-overview-actions');
      const currentWork = document.querySelector('.path-overview-fast-card');
      const stepList = document.querySelector('.path-step-list-card');
      return {
        variant: screen?.dataset.pathOverviewHeroVariant || '',
        hero: screen?.style.getPropertyValue('--path-overview-hero-art') || '',
        pressed: toggle?.getAttribute('aria-pressed') || '',
        actionTop: actionCluster?.getBoundingClientRect().top ?? -1,
        toggleTop: toggle?.getBoundingClientRect().top ?? -1,
        heroLayerHeight: Number.parseFloat(getComputedStyle(screen, '::before').height),
        baseHeroHeight: Number.parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--path-overview-hero-height')),
        currentWorkTop: currentWork?.getBoundingClientRect().top ?? -1,
        currentWorkHeight: currentWork?.getBoundingClientRect().height ?? -1,
        stepListTop: stepList?.getBoundingClientRect().top ?? -1
      };
    });
    await page.screenshot({ path: path.join(artifactDirectory, 'path-overview-default-412x892.png'), fullPage: false });
    assert.equal(defaultState.variant, 'default', 'Ösvény must start with the retained default hero');
    assert.match(defaultState.hero, /assets\/path-step-4\/hero-onleltar-mobile\.png/, 'default mode must retain the original overview hero');
    assert.equal(defaultState.pressed, 'false', 'the optional hero button must report its initial state');
    assert.ok(Math.abs(defaultState.toggleTop - defaultState.actionTop) < 2, 'the optional hero button must share the existing right-top action alignment');
    assert.equal(defaultState.heroLayerHeight, defaultState.baseHeroHeight, 'the retained default hero must keep the original bounded hero height');

    await page.locator('[data-component="path-overview-hero-variant-toggle"]').click();
    await page.waitForTimeout(160);
    const richerState = await page.evaluate(() => {
      const screen = document.querySelector('[data-component="path-workspace"]');
      const toggle = document.querySelector('[data-component="path-overview-hero-variant-toggle"]');
      const currentWork = document.querySelector('.path-overview-fast-card');
      const stepList = document.querySelector('.path-step-list-card');
      return {
        variant: screen?.dataset.pathOverviewHeroVariant || '',
        hero: screen?.style.getPropertyValue('--path-overview-hero-art') || '',
        pressed: toggle?.getAttribute('aria-pressed') || '',
        heroLayerHeight: Number.parseFloat(getComputedStyle(screen, '::before').height),
        baseHeroHeight: Number.parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--path-overview-hero-height')),
        fadeMask: getComputedStyle(screen, '::before').maskImage || getComputedStyle(screen, '::before').webkitMaskImage || '',
        currentWorkTop: currentWork?.getBoundingClientRect().top ?? -1,
        currentWorkHeight: currentWork?.getBoundingClientRect().height ?? -1,
        stepListTop: stepList?.getBoundingClientRect().top ?? -1
      };
    });
    await page.screenshot({ path: path.join(artifactDirectory, 'path-overview-richer-412x892.png'), fullPage: false });
    assert.equal(richerState.variant, 'richer', 'the optional hero button must select the generated richer hero');
    assert.match(richerState.hero, /assets\/path-hero\/overview_richer\.png/, 'the richer option must bind the local generated asset to the existing hero layer');
    assert.equal(richerState.pressed, 'true', 'the optional hero button must report the selected state');
    assert.equal(richerState.heroLayerHeight, richerState.baseHeroHeight + 80, 'the richer hero must continue 80px below the fixed hero to match the History fade rhythm');
    assert.match(richerState.fadeMask, /linear-gradient/, 'the richer hero continuation must fade into the shared workspace surface');
    assert.equal(richerState.currentWorkTop, defaultState.currentWorkTop, 'the decorative richer hero must not move the current-work card');
    assert.equal(richerState.currentWorkHeight, defaultState.currentWorkHeight, 'the decorative richer hero must not resize the current-work card');
    assert.equal(richerState.stepListTop, defaultState.stepListTop, 'the decorative richer hero must not move the twelve-step scroll owner');

    await page.locator('[data-component="path-overview-asset-style-toggle"]').click();
    const richerMinimalState = await page.evaluate(() => {
      const screen = document.querySelector('[data-component="path-workspace"]');
      return { style: screen?.dataset.pathAssetStyle || '', hero: screen?.style.getPropertyValue('--path-overview-hero-art') || '' };
    });
    assert.equal(richerMinimalState.style, 'minimal', 'the existing original/minimal control must continue to work');
    assert.match(richerMinimalState.hero, /assets\/path-hero\/overview_richer\.png/, 'the richer hero must remain independent from the existing original/minimal selector');
  } finally {
    await browser.close();
    await new Promise((resolve) => server.close(resolve));
  }
  console.log(`PASS Ösvény richer hero runtime contract (${artifactDirectory})`);
})().catch((error) => {
  console.error(error.stack || error);
  process.exitCode = 1;
});
