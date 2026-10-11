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
const historyCarousel = element();
const historyWorkspace = element();
const historyWorkspaceTemplate = element();
historyWorkspaceTemplate.innerHTML = '<nav><button data-history-detail-tab="timeline">Idővonal</button><button data-history-detail-tab="calendar">Naptár</button></nav><section class="history-number-summary"></section>';
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
  if (selector === '[data-component="history-period-carousel"]') return historyCarousel;
  if (selector === '[data-component="history-workspace"]') return historyWorkspace;
  if (selector === '[data-component="history-workspace-template"]') return historyWorkspaceTemplate;
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

assert.equal(controller.state.historySelectedPeriodId, 'current', 'the current period must seed the carousel selection');
assert.match(historyCarousel.innerHTML, /Jelenlegi időszak/, 'the active carousel tile must render the current chapter');
assert.match(historyWorkspace.innerHTML, /data-history-detail-tab="timeline"/, 'the existing Timeline markup must mount beneath the carousel');
controller.toggleHistoryMetrics('timeline');
assert.equal(controller.state.historyPresentation.timeline.metricsExpanded, true, 'the inline workspace must preserve the existing expandable History footer state');
assert.match(historyWorkspace.innerHTML, /history-number-summary/, 'expanding the metrics footer must keep the shared footer mounted beneath the workspace content');
controller.selectHistoryPeriod('2024-05');
assert.equal(controller.state.historySelectedPeriodId, '2024-05', 'a carousel tap must update the sole selected period ID');
assert.match(historyCarousel.innerHTML, /Első időszak/, 'the carousel must render the selected earlier period');
controller.moveHistoryCarousel(1);
assert.equal(controller.state.historySelectedPeriodId, '2024-06', 'a horizontal carousel move must reuse selection state');
controller.openHistoryDetail('calendar');
assert.equal(root.dataset.route, 'history', 'the Timeline and Calendar workspace must remain on the History route');
assert.equal(controller.state.historyDetailView, 'calendar', 'the existing calendar view must still be selectable from the inline workspace');
controller.openHistoryCalendarRail('2025-02-14');
assert.equal(root.dataset.route, 'history', 'the calendar rail must return to the same History workspace rather than an intermediate route');
assert.equal(controller.state.historyCalendarView, 'rail', 'the inline workspace must preserve the existing calendar rail state');
controller.navigate('timeline-event-detail');
controller.navigate('history-detail');
assert.equal(root.dataset.route, 'history', 'returning from an event detail must resolve to the inline History workspace');
assert.equal(controller.state.historySelectedPeriodId, '2024-06', 'the selected carousel period must survive detail-route compatibility navigation');

console.log('PASS alternative controller runtime contract');
