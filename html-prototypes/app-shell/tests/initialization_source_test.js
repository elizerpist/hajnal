'use strict';

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const appShellDirectory = path.join(__dirname, '..');
const appShellPath = path.join(appShellDirectory, 'index.html');
const repositoryRoot = path.join(appShellDirectory, '..', '..');
const html = fs.readFileSync(appShellPath, 'utf8');

function hash(file) {
  return crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
}

function makeElement(action = '') {
  return {
    attributes: new Map(),
    classList: { add() {}, remove() {}, toggle() {} },
    dataset: action ? { action } : {},
    style: { setProperty() {} },
    innerHTML: '',
    textContent: '',
    addEventListener() {},
    setAttribute(name, value) { this.attributes.set(name, String(value)); },
    getAttribute(name) { return this.attributes.get(name); },
    removeAttribute(name) { this.attributes.delete(name); },
    querySelector() { return null; },
    querySelectorAll() { return []; },
    setPointerCapture() {},
    releasePointerCapture() {},
  };
}

assert.match(html, /const INITIALIZATION_SOURCE_VIEW_ORDER = Object\.freeze\(\['splash', 'onboarding', 'start-date', 'sponsor-setup', 'why-started', 'notifications'\]\);/, 'source-derived initialization order must be explicit');
assert.match(html, /class="source-splash-background" src="assets\/initialization\/welcome_svg\.svg"/, 'Splash must use the copied source landscape asset');
assert.match(html, /class="source-splash-logo" src="assets\/initialization\/logo_svg\.svg"/, 'Splash must use the copied source logo asset');
assert.match(html, /class="source-welcome-arch"/, 'Screen 2 must retain the source welcome arch');
assert.match(html, /class="source-start-date-calendar"/, 'Screen 4 must retain the source calendar component');
assert.match(html, /class="source-sponsor-choices"/, 'Screen 6 must retain source sponsor choices');
assert.match(html, /class="source-why-card"/, 'Screen 6B must retain the source motivation card');
assert.match(html, /class="source-notification-list"/, 'Screen 7 must retain the five source notification settings');
assert.match(html, /const INITIALIZATION_SPLASH_DELAY_MS = 2500;/, 'Splash must retain the source 2–3 second automatic transition');
assert.match(html, /\.source-splash-brand \{[^}]*padding-top: 56px;/, 'Splash lockup must keep the source vertical metric');
assert.match(html, /\.source-splash-logo \{[^}]*box-shadow: 0 12px 28px rgba\(44,46,119,\.16\);/, 'Splash icon must keep the source shadow treatment');
assert.match(html, /\.source-why-card \{[^}]*min-height: 252px;[^}]*padding: 26px 24px;[^}]*text-align: center;/, 'Screen 6B must retain its source card geometry');
assert.match(html, /\.source-why-card blockquote \{[^}]*font-size: 25px;[^}]*line-height: 1\.22;[^}]*font-weight: 820;/, 'Screen 6B quotation must retain the source hierarchy');
assert.match(html, /<use href="#source-character-llama"/, 'Welcome must reuse the copied source llama symbol instead of a handwritten replacement');
assert.match(html, /data-action="select-initialization-calendar-date" data-date="\$\{date\}"/, 'Calendar days must retain a concrete date action');
assert.match(html, /\.source-notification-setting input:checked ~ \.source-switch \{/, 'Notification toggle visuals must follow the native checkbox state');

const sourceAssets = [
  ['welcome_svg.svg', 'assets/initialization/welcome_svg.svg'],
  ['logo_svg.svg', 'assets/initialization/logo_svg.svg'],
];
for (const [sourceName, appAsset] of sourceAssets) {
  const sourcePath = path.join(repositoryRoot, 'docs', 'references', 'source-of-truth', sourceName);
  const targetPath = path.join(appShellDirectory, appAsset);
  assert.ok(fs.existsSync(targetPath), `app-shell must own copied ${sourceName}`);
  assert.equal(hash(targetPath), hash(sourcePath), `${sourceName} must exactly match its source asset`);
}

const root = makeElement();
const summary = makeElement();
const expandHotspot = makeElement();
const fullscreenButton = makeElement();
const initializationScreen = makeElement();
const initializationContent = makeElement();
const panicMotivationCopy = makeElement();
root.querySelector = (selector) => ({
  '[data-component="daily-summary-card"]': summary,
  '[data-action="expand-home-card"]': expandHotspot,
  '[data-action="toggle-fullscreen"]': fullscreenButton,
  '[data-component="initialization-flow"]': initializationScreen,
  '[data-component="initialization-content"]': initializationContent,
  '[data-component="panic-motivation-copy"]': panicMotivationCopy,
}[selector] || null);
root.querySelectorAll = () => [];

const documentStub = {
  fullscreenElement: null,
  documentElement: { requestFullscreen() {} },
  exitFullscreen() {},
  addEventListener() {},
  querySelector(selector) { return selector === '.app-frame' ? root : null; },
};
const runnableScript = html.match(/<script>([\s\S]*?)<\/script>\s*<\/body>/)[1]
  .replace("new HomeInteractionController(document.querySelector('.app-frame'));", "globalThis.__controller = new HomeInteractionController(document.querySelector('.app-frame')); ");
const scheduled = [];
const sandbox = {
  console,
  document: documentStub,
  globalThis: {
    setTimeout(callback, delay) { scheduled.push({ callback, delay }); return scheduled.length; },
    clearTimeout() {},
  },
  window: { matchMedia: () => ({ matches: false }) },
};
vm.runInNewContext(runnableScript, sandbox);
const controller = sandbox.globalThis.__controller;

const expectedViews = [
  ['splash', /Csak a mai nap\./, /source-splash-background/, /source-splash-logo/],
  ['onboarding', /Üdv a Hajnalban!/, /Nem kell 90 napot egyszerre végigcsinálnod\./, /source-welcome-arch/],
  ['start-date', /Mikor kezdődött a jelenlegi tiszta időszakod\?/, /Július 2026/, /calendar-grid/],
  ['sponsor-setup', /Van szponzorod vagy segítő személyed\?/, /Igen, hozzáadom/, /Nincs még/],
  ['why-started', /Miért kezdted el\?/, /Adj magadnak egy mondatot/, /Saját emlékeztetőd/],
  ['notifications', /Értesítések beállítása/, /Reggeli emlékeztető/, /Meeting emlékeztetője/],
];
for (const [view, ...markers] of expectedViews) {
  controller.openInitialization(view);
  assert.equal(initializationScreen.dataset.initializationView, view, `${view} must be active in the same initialization route`);
  for (const marker of markers) assert.match(initializationContent.innerHTML, marker, `${view} must render its source component`);
}
assert.equal(root.dataset.route, 'initialization', 'Hamburger flow must stay in the existing shared route');
assert.equal(scheduled[0].delay, 2500, 'source Splash must schedule its 2.5-second automatic progression');
controller.openInitialization('splash');
scheduled.at(-1).callback();
assert.equal(initializationScreen.dataset.initializationView, 'onboarding', 'source Splash timer must advance to the welcome screen');
controller.openInitialization('start-date');
controller.setInitializationCalendarDate('2026-07-20');
assert.equal(controller.state.initialization.selectedCalendarDate, '2026-07-20', 'calendar taps must retain the selected source date');
assert.match(initializationContent.innerHTML, /data-date="2026-07-20"[^>]*aria-current="date"/, 'selected calendar day must expose the source selected state');

console.log('PASS source-faithful initialization contract');
