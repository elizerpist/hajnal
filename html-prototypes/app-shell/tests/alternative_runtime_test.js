'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

function element() {
  const listeners = new Map();
  return {
    attributes: new Map(), dataset: {}, style: { values: {}, setProperty(name, value) { this.values[name] = value; }, removeProperty(name) { delete this.values[name]; } }, innerHTML: '', textContent: '', hidden: false,
    classList: { add() {}, remove() {}, toggle() {}, contains() { return false; } },
    addEventListener(type, listener) { const handlers = listeners.get(type) || []; handlers.push(listener); listeners.set(type, handlers); }, querySelector() { return null; }, querySelectorAll() { return []; }, focus() {},
    dispatch(type, event = {}) { (listeners.get(type) || []).forEach((listener) => listener({ target: this, currentTarget: this, ...event })); },
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
const historyPager = element();
const historyPagerTrack = element();
historyPager.clientWidth = 412;
historyPagerTrack.children = [];
const historyWorkspace = element();
const historyWorkspaceTemplate = element();
const historyHero = element();
historyWorkspaceTemplate.innerHTML = '<nav><button data-history-detail-tab="timeline">Idővonal</button><button data-history-detail-tab="calendar">Naptár</button></nav><section class="history-number-summary"></section>';
historyHero.getBoundingClientRect = () => ({ top: 0, height: 238 });
historyScreen.querySelector = (selector) => selector === '.history-hero' ? historyHero : null;
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
  if (selector === '[data-component="history-full-page-pager"]') return historyPager;
  if (selector === '[data-component="history-full-page-pager-track"]') return historyPagerTrack;
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
const carouselCentre = controller.historyCarouselScaleForDistance(0, 128);
const carouselEdge = controller.historyCarouselScaleForDistance(128, 128);
assert.equal(carouselCentre.scale, 1, 'the selected full-image card must preserve its source-matched centre size');
assert.equal(carouselEdge.scale, .77, 'a neighbouring History2 card must retain the source-matched side-card proportion');
assert.ok(carouselCentre.opacity > carouselEdge.opacity, 'the centre card must remain visually primary while a neighbour is secondary');
const carouselCards = ['2024-06', 'current', '2024-05'].map((id, index) => {
  const card = element();
  card.dataset.historyPeriodId = id;
  card.offsetWidth = 120;
  card.style = { values: {}, setProperty(name, value) { this.values[name] = value; } };
  card.getBoundingClientRect = () => ({ left: 18 + (index * 128), width: 120 });
  return card;
});
historyCarousel.getBoundingClientRect = () => ({ left: 0, width: 412 });
historyCarousel.querySelectorAll = (selector) => selector === '.history-period-carousel-card' ? carouselCards : [];
controller.syncHistoryCarouselPresentation();
assert.equal(carouselCards[1].style.values['--history-carousel-scale'], '1', 'the card crossing the centre slot must retain the full source-matched emphasis');
assert.equal(carouselCards[0].style.values['--history-carousel-scale'], '0.77', 'a side card must receive the live source-matched side scale');
assert.equal(controller.centeredHistoryCarouselPeriodId(), 'current', 'the centred card must resolve through the existing selected-period identity');
controller.selectHistoryPeriod('2024-05');
controller.toggleHistoryPeriodPresentation();
assert.equal(controller.state.historyPeriodPresentation, 'hero-swipe', 'the presentation toggle must select the controller-owned full-page pager state');
assert.equal(controller.historyPagerDrag, null, 'entering the full-page pager must not leave a partial drag in state');
assert.match(historyPagerTrack.innerHTML, /data-history-pager-role="current"[\s\S]*?Első döntés/, 'the currently selected period must bring its own Timeline body into the shared track');
assert.match(historyPagerTrack.innerHTML, /data-history-pager-role="next"[\s\S]*?Első olvasmány/, 'the entering neighbouring period must already have its own body before a drag begins');
historyPagerTrack.children = [
  { dataset: { historyPeriodId: '2024-05' } },
  { dataset: { historyPeriodId: '2024-06' } }
];
const pagerTarget = { closest() { return null; } };
let horizontalPrevented = false;
controller.historyPagerPointerDown({ pointerId: 9, button: 0, clientX: 350, clientY: 440, timeStamp: 10, target: pagerTarget });
controller.historyPagerPointerMove({ pointerId: 9, clientX: 200, clientY: 444, timeStamp: 26, preventDefault() { horizontalPrevented = true; } });
assert.equal(controller.historyPagerDrag.axis, 'horizontal', 'a mostly horizontal body gesture must lock to the full-page pager');
assert.equal(historyPagerTrack.style.values['--history-pager-track-x'], '-150px', 'a partial left drag must move the one shared track by the matching pointer distance');
assert.equal(horizontalPrevented, true, 'only the confirmed horizontal drag may suppress its native gesture');
controller.historyPagerPointerEnd({ pointerId: 9, clientX: 200, clientY: 444, timeStamp: 42 });
assert.equal(controller.state.historySelectedPeriodId, '2024-06', 'the next period must commit only at the horizontal settle boundary');
const beforeVerticalPeriod = controller.state.historySelectedPeriodId;
let verticalPrevented = false;
controller.historyPagerPointerDown({ pointerId: 10, button: 0, clientX: 180, clientY: 320, timeStamp: 60, target: pagerTarget });
controller.historyPagerPointerMove({ pointerId: 10, clientX: 186, clientY: 400, timeStamp: 76, preventDefault() { verticalPrevented = true; } });
assert.equal(controller.historyPagerDrag.axis, 'vertical', 'a mostly vertical Timeline gesture must remain with the native scroll owner');
controller.historyPagerPointerEnd({ pointerId: 10, clientX: 186, clientY: 400, timeStamp: 90 });
assert.equal(verticalPrevented, false, 'vertical Timeline movement must not be prevented by the pager');
assert.equal(controller.state.historySelectedPeriodId, beforeVerticalPeriod, 'vertical Timeline movement must not change the selected period');
controller.toggleHistoryMetrics('timeline');
assert.equal(controller.state.historyPresentation.timeline.metricsExpanded, true, 'the inline workspace must preserve the existing expandable History footer state');
assert.match(historyWorkspace.innerHTML, /history-number-summary/, 'expanding the metrics footer must keep the shared footer mounted beneath the workspace content');
controller.selectHistoryPeriod('2024-05');
assert.equal(controller.state.historySelectedPeriodId, '2024-05', 'a carousel tap must update the sole selected period ID');
assert.match(historyCarousel.innerHTML, /Első időszak/, 'the carousel must render the selected earlier period');
controller.selectHistoryPeriod('2024-06');
assert.equal(controller.state.historySelectedPeriodId, '2024-06', 'the single selection path must continue to update the carousel state');
controller.openHistoryDetail('calendar');
assert.equal(root.dataset.route, 'history', 'the Timeline and Calendar workspace must remain on the History route');
assert.equal(controller.state.historyDetailView, 'calendar', 'the existing calendar view must still be selectable from the inline workspace');
assert.match(historyPagerTrack.innerHTML, /history-period-pager-calendar/, 'the full-page pager must render a period-specific calendar body when the floating Calendar control is selected');
assert.match(historyPagerTrack.innerHTML, /data-history-pager-calendar-rail/, 'the period calendar must retain its own horizontal daily rail instead of delegating that gesture to chapter paging');
controller.openHistoryCalendarRail('2025-02-14');
assert.equal(root.dataset.route, 'history', 'the calendar rail must return to the same History workspace rather than an intermediate route');
assert.equal(controller.state.historyCalendarView, 'rail', 'the inline workspace must preserve the existing calendar rail state');
controller.navigate('timeline-event-detail');
controller.navigate('history-detail');
assert.equal(root.dataset.route, 'history', 'returning from an event detail must resolve to the inline History workspace');
assert.equal(controller.state.historySelectedPeriodId, '2024-06', 'the selected carousel period must survive detail-route compatibility navigation');

// Regression: a browser normally emits lostpointercapture after pointerup. The
// release-owned settle must remain at the neighboring slot instead of being
// cancelled back to the original slide before its completion callback runs.
const pagerTimers = new Map();
let nextPagerTimerId = 1;
const deferPagerTimer = (callback) => {
  const id = nextPagerTimerId++;
  pagerTimers.set(id, callback);
  return id;
};
const clearDeferredPagerTimer = (id) => pagerTimers.delete(id);
const flushPagerTimers = () => {
  while (pagerTimers.size) {
    const pending = [...pagerTimers.values()];
    pagerTimers.clear();
    pending.forEach((callback) => callback());
  }
};
sandbox.setTimeout = deferPagerTimer;
sandbox.clearTimeout = clearDeferredPagerTimer;
sandbox.globalThis.setTimeout = deferPagerTimer;
sandbox.globalThis.clearTimeout = clearDeferredPagerTimer;
controller.state.historyDetailView = 'timeline';
controller.state.historySelectedPeriodId = 'current';
controller.state.historyPeriodPresentation = 'hero-swipe';
controller.renderHistoryFullPagePager();
historyPagerTrack.children = [
  { dataset: { historyPeriodId: '2025-11' } },
  { dataset: { historyPeriodId: 'current' } }
];
historyPager.dispatch('pointerdown', { pointerId: 41, button: 0, clientX: 190, clientY: 420, timeStamp: 100, target: pagerTarget });
historyPager.dispatch('pointermove', { pointerId: 41, clientX: 350, clientY: 424, timeStamp: 120, preventDefault() {} });
historyPager.dispatch('pointerup', { pointerId: 41, clientX: 350, clientY: 424, timeStamp: 140 });
assert.equal(historyPagerTrack.style.values['--history-pager-track-x'], '0px', 'a right drag from the latest period must preview the already-rendered previous slide before completion');
historyPager.dispatch('lostpointercapture', { pointerId: 41 });
assert.equal(historyPagerTrack.style.values['--history-pager-track-x'], '0px', 'normal lostpointercapture after pointerup must not cancel the completed slide-in');
historyPagerTrack.dispatch('transitionend', { propertyName: 'transform' });
assert.equal(controller.state.historySelectedPeriodId, '2025-11', 'the release-owned settle must commit exactly the previously previewed period');
flushPagerTimers();
assert.equal(controller.state.historySelectedPeriodId, '2025-11', 'the fallback timer must be harmless after transition completion has already committed the period');

// A native vertical scroll/cancel must not put the pager into a settling lock
// that rejects the next genuine horizontal drag.
controller.state.historySelectedPeriodId = 'current';
controller.state.historyPeriodPresentation = 'hero-swipe';
controller.renderHistoryFullPagePager();
historyPagerTrack.children = [
  { dataset: { historyPeriodId: '2025-11' } },
  { dataset: { historyPeriodId: 'current' } }
];
historyPager.dispatch('pointerdown', { pointerId: 42, button: 0, clientX: 200, clientY: 380, timeStamp: 200, target: pagerTarget });
historyPager.dispatch('pointermove', { pointerId: 42, clientX: 204, clientY: 452, timeStamp: 220, preventDefault() {} });
historyPager.dispatch('pointercancel', { pointerId: 42 });
assert.equal(historyPagerTrack.dataset.historyPagerSettling, 'false', 'vertical native scroll cancellation must not start a horizontal settle');
historyPager.dispatch('pointerdown', { pointerId: 43, button: 0, clientX: 190, clientY: 400, timeStamp: 240, target: pagerTarget });
assert.equal(controller.historyPagerDrag?.pointerId, 43, 'a new horizontal gesture must be accepted immediately after native vertical scrolling');
controller.cancelHistoryPagerGesture({ immediate: true });

// Mode changes invalidate a settle callback that was already queued.
controller.state.historySelectedPeriodId = 'current';
controller.state.historyPeriodPresentation = 'hero-swipe';
controller.renderHistoryFullPagePager();
historyPagerTrack.children = [
  { dataset: { historyPeriodId: '2025-11' } },
  { dataset: { historyPeriodId: 'current' } }
];
historyPager.dispatch('pointerdown', { pointerId: 44, button: 0, clientX: 190, clientY: 420, timeStamp: 300, target: pagerTarget });
historyPager.dispatch('pointermove', { pointerId: 44, clientX: 350, clientY: 424, timeStamp: 320, preventDefault() {} });
historyPager.dispatch('pointerup', { pointerId: 44, clientX: 350, clientY: 424, timeStamp: 340 });
controller.toggleHistoryPeriodPresentation();
flushPagerTimers();
assert.equal(controller.state.historyPeriodPresentation, 'cards', 'the explicit presentation toggle must still complete while a settle is pending');
assert.equal(controller.state.historySelectedPeriodId, 'current', 'an obsolete settle callback must not mutate selection after a presentation change');

console.log('PASS alternative controller runtime contract');
