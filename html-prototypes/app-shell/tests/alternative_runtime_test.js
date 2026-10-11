'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

function element() {
  return {
    attributes: new Map(), dataset: {}, style: { setProperty() {} }, innerHTML: '', textContent: '', hidden: false,
    classList: { add() {}, remove() {}, toggle() {}, contains() { return false; } },
    addEventListener() {}, querySelector() { return null; }, querySelectorAll() { return []; }, focus() {},
    setAttribute(name, value) { this.attributes.set(name, String(value)); }, getAttribute(name) { return this.attributes.get(name); }, removeAttribute(name) { this.attributes.delete(name); },
    setPointerCapture() {}, releasePointerCapture() {},
  };
}

const root = element();
const summary = element();
const expand = element();
const fullscreen = element();
const typefaceToggle = element();
const navigation = element();
const panicScreen = element();
const panicContent = element();
const panicToggle = element();
const helpHost = element();
const helpContent = element();
const helpDialog = element();
helpHost.hidden = true;
helpHost.querySelector = () => helpDialog;
const historyScreen = element();
const historyCurrent = element();
const historyAlternative = element();
historyAlternative.hidden = true;
const historyPeriodList = element();
const historyLayout = element();
const historyDensity = element();
const survival = element();

root.querySelector = (selector) => {
  if (selector === '[data-component="daily-summary-card"]') return summary;
  if (selector === '[data-action="expand-home-card"]') return expand;
  if (selector === '[data-action="toggle-fullscreen"]') return fullscreen;
  if (selector === '[data-component="global-typeface-toggle"]') return typefaceToggle;
  if (selector === '[data-component="bottom-navigation"]') return navigation;
  if (selector === '[data-component="panic-mode"]' || selector === '[data-route="panic"]') return panicScreen;
  if (selector === '[data-component="panic-content"]') return panicContent;
  if (selector === '[data-component="panic-variant-toggle"]') return panicToggle;
  if (selector === '[data-component="panic-help-sheet"]') return helpHost;
  if (selector === '[data-component="panic-help-sheet-content"]') return helpContent;
  if (selector === '[data-component="sobriety-batch-history"]' || selector === '[data-route="history"]') return historyScreen;
  if (selector === '[data-component="history-current-layout"]') return historyCurrent;
  if (selector === '[data-component="history-path-overview"]') return historyAlternative;
  if (selector === '[data-component="history-period-list"]') return historyPeriodList;
  if (selector === '[data-component="history-overview-layout-toggle"]') return historyLayout;
  if (selector === '[data-component="history-overview-density-toggle"]') return historyDensity;
  if (selector === '[data-component="survival-content"]') return survival;
  if (selector === '[data-app-overlay-sheet]:not([hidden])') return helpHost.hidden ? null : helpHost;
  return null;
};
root.querySelectorAll = () => [];

const storage = new Map();
const documentStub = { fullscreenElement: null, documentElement: { requestFullscreen() {} }, exitFullscreen() {}, activeElement: element(), addEventListener() {}, querySelector: (selector) => selector === '.app-frame' ? root : null };
const globalThisStub = { setTimeout(callback) { callback(); return 1; }, clearTimeout() {}, setInterval() { return 1; }, clearInterval() {} };
const sandbox = {
  console, document: documentStub, globalThis: globalThisStub,
  window: { matchMedia: () => ({ matches: false }), addEventListener() {}, localStorage: { getItem: (key) => storage.get(key) || null, setItem: (key, value) => storage.set(key, value) } },
  setTimeout(callback) { callback(); return 1; }, clearTimeout() {},
  requestAnimationFrame(callback) { callback(); },
};
const script = html.match(/<script>([\s\S]*?)<\/script>\s*<\/body>/)[1]
  .replace("new HomeInteractionController(document.querySelector('.app-frame'));", "globalThis.__controller = new HomeInteractionController(document.querySelector('.app-frame'));");
vm.runInNewContext(script, sandbox);
const controller = globalThisStub.__controller;

assert.equal(controller.state.typefaceMode, 'sponsor', 'the sponsor-style typeface must be the first-use default');
assert.equal(root.dataset.typefaceMode, 'sponsor', 'the app frame must own the global default typeface');
assert.equal(typefaceToggle.getAttribute('aria-pressed'), 'false', 'the home typeface control must expose its initial state');
controller.toggleGlobalTypeface();
assert.equal(controller.state.typefaceMode, 'path', 'one home action must select the Path typeface globally');
assert.equal(root.dataset.typefaceMode, 'path', 'the selected typeface must apply through the shared app frame');
assert.equal(storage.get('hajnal.typefaceMode'), 'path', 'the selected typeface must persist safely');
assert.equal(typefaceToggle.getAttribute('aria-pressed'), 'true', 'the home typeface control must update its pressed state');

assert.equal(controller.state.panicVariant, 'classic', 'Classic must be the first-use default');
assert.match(panicContent.innerHTML, /panic-grid/, 'Classic must keep its six-tile grid');
controller.togglePanicVariant();
assert.equal(controller.state.panicVariant, 'alternative', 'one toggle must select Alternative');
assert.equal(storage.get('hajnal.panicVariant'), 'alternative', 'the selected Pánik variant must persist safely');
assert.match(panicContent.innerHTML, /panic-main-button--pulse/, 'Alternative must mount its animated help affordance');
assert.equal((panicContent.innerHTML.match(/panic-alternative-grid/g) || []).length, 1, 'Alternative must mount one quick-action grid');
assert.equal((panicContent.innerHTML.match(/data-action="start-survival-pack"|data-action="open-meetings"|data-action="open-panic-relapse"/g) || []).length, 3, 'Alternative must expose exactly three quick actions');
controller.openPanicHelpSheet(element());
assert.equal(controller.state.panicHelpSheet, true, 'help tap must open one shared sheet');
assert.equal(helpHost.hidden, false, 'help sheet host must be mounted only while active');
assert.match(helpContent.innerHTML, /Hívj fel valakit|Szponzor/, 'the sheet must render dynamic contact content');
controller.closePanicHelpSheet();
assert.equal(controller.state.panicHelpSheet, false, 'the sheet close path must restore the main Pánik view');
controller.state.sponsor = { name: '', phone: '', since: '', note: '' };
controller.openPanicHelpSheet(element());
assert.match(helpContent.innerHTML, /Szponzor hozzáadása/, 'a missing sponsor must produce a safe empty state instead of a fictitious contact');
assert.match(helpContent.innerHTML, /Nincs beállított tartalék kapcsolattartó/, 'a missing backup must remain explicit rather than be invented');
controller.closePanicHelpSheet();

controller.startSurvivalPack();
const startedAt = controller.state.survivalSession.startedAt;
for (let index = 0; index < 5; index += 1) controller.advanceSurvivalStep();
assert.equal(controller.state.survivalSession.completed, true, 'survival must end in an explicit reassessment state');
assert.equal(controller.state.survivalSession.startedAt, startedAt, 'progressing survival must not reset its actual timer basis');
assert.equal(controller.state.route, 'survival', 'survival completion may not force a contact route');

assert.equal(controller.state.historyOverview.layoutMode, 'current', 'legacy History must remain the default presentation');
assert.equal((historyPeriodList.innerHTML.match(/history-period-card/g) || []).length, 10, 'the current History layout must receive the complete shared period source');
controller.toggleHistoryOverviewLayout();
assert.equal(historyScreen.dataset.historyOverviewLayoutMode, 'path-inspired', 'the History comparison toggle must select the new presentation');
assert.equal(historyDensity.disabled, false, 'density must become available only in the path-inspired presentation');
assert.match(historyAlternative.innerHTML, /history-path-current-card/, 'new History must render the current-period card');
assert.doesNotMatch(historyAlternative.innerHTML, /history-path-day-medallion/, 'the path-inspired History must not render a clean-day progress circle');
assert.match(historyAlternative.innerHTML, /history-period-badge history-path-current-badge">24 nap tiszta</, 'the current period must render its clean-day value in the existing History chip');
assert.match(historyAlternative.innerHTML, /history-path-period-card[^]*history-period-badge">8 nap</, 'prior periods must render their clean-day values in the existing History chip');
assert.equal((historyAlternative.innerHTML.match(/history-path-period-card/g) || []).length, 9, 'new History must render all prior chapters exactly once');
controller.toggleHistoryOverviewDensity();
assert.equal(historyScreen.dataset.historyOverviewDensity, 'compact', 'the density toggle must alter only the new presentation');

console.log('PASS alternative controller runtime contract');
