'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const appShellPath = path.join(__dirname, '..', 'index.html');
const html = fs.readFileSync(appShellPath, 'utf8');

function makeElement(action = '') {
  return {
    attributes: new Map(),
    classList: { add() {}, remove() {}, toggle() {}, contains() { return false; } },
    dataset: action ? { action } : {},
    style: { setProperty() {} },
    innerHTML: '',
    textContent: '',
    children: [],
    addEventListener() {},
    setAttribute(name, value) { this.attributes.set(name, String(value)); },
    getAttribute(name) { return this.attributes.get(name); },
    removeAttribute(name) { this.attributes.delete(name); },
    querySelectorAll() { return []; },
    querySelector() { return null; },
    appendChild(child) { if (child.parentElement?.children) child.parentElement.children.splice(child.parentElement.children.indexOf(child), 1); this.children.push(child); child.parentElement = this; return child; },
    prepend(child) { if (child.parentElement?.children) child.parentElement.children.splice(child.parentElement.children.indexOf(child), 1); this.children.unshift(child); child.parentElement = this; return child; },
    setPointerCapture() {},
    releasePointerCapture() {},
  };
}

const root = makeElement();
const summary = makeElement();
const expandHotspot = makeElement();
const fullscreenButton = makeElement();
const pathScreen = makeElement();
const pathContent = makeElement();
const historyDetailScreen = makeElement();
const historyTimelineTab = makeElement();
historyTimelineTab.dataset.historyDetailTab = 'timeline';
const historyCalendarTab = makeElement();
historyCalendarTab.dataset.historyDetailTab = 'calendar';
const historyDetailTitle = makeElement();
const timelineHeroTitle = makeElement();
const calendarHeroTitle = makeElement();
const historyDetailSubtitle = makeElement();
const historyDetailBack = makeElement('open-history');
const historyDetailTopAction = makeElement();
const historyCalendarRail = makeElement();
const historyScreen = makeElement();
const historyHeroImage = makeElement();
const historyHeroVariantToggle = makeElement('toggle-history-hero-variant');
const historyMetricsToggle = makeElement('toggle-history-metrics');
const timelineHeroImage = makeElement();
const timelineHeroVariantToggle = makeElement('toggle-history-hero-variant');
timelineHeroVariantToggle.dataset.historyPresentationSurface = 'timeline';
const timelineMetricsToggle = makeElement('toggle-history-metrics');
timelineMetricsToggle.dataset.historyPresentationSurface = 'timeline';
const calendarHeroImage = makeElement();
const calendarHeroVariantToggle = makeElement('toggle-history-hero-variant');
calendarHeroVariantToggle.dataset.historyPresentationSurface = 'calendar';
const calendarMonthCard = makeElement();
const calendarMonthCardOrigin = makeElement();
const calendarSelectedDay = makeElement();
calendarMonthCardOrigin.appendChild(calendarMonthCard);
calendarMonthCardOrigin.appendChild(calendarSelectedDay);
const calendarIntegratedGridSlot = makeElement();
const timelineMetricsTitle = makeElement();
historyDetailScreen.querySelectorAll = (selector) => ({
  '[data-history-detail-tab]': [historyTimelineTab, historyCalendarTab],
  '[data-component="history-detail-title"]': [historyDetailTitle, timelineHeroTitle, calendarHeroTitle],
  '[data-component="history-detail-subtitle"]': [historyDetailSubtitle],
  '[data-component="history-detail-back"]': [historyDetailBack],
  '[data-component="history-detail-top-action"]': [historyDetailTopAction],
  '[data-component="history-calendar-rail"]': [historyCalendarRail],
}[selector] || []);
historyDetailScreen.querySelector = (selector) => ({
  '.history-calendar-month-card': calendarMonthCard,
  '[data-component="calendar-month-card-origin"]': calendarMonthCardOrigin,
  '[data-component="calendar-integrated-grid-slot"]': calendarIntegratedGridSlot,
  '#timeline-number-title': timelineMetricsTitle,
}[selector] || null);
const survivalContent = makeElement();
const meetingSearchNote = makeElement();
meetingSearchNote.hidden = true;
const initializationScreen = makeElement();
const initializationContent = makeElement();
const panicMotivationCopy = makeElement();
const homeNav = makeElement('return-home');
const historyNav = makeElement('open-history');
const pathNav = makeElement('open-path');
const meetingsNav = makeElement('open-meetings');
const mainNavigation = makeElement();

root.querySelector = (selector) => ({
  '[data-component="daily-summary-card"]': summary,
  '[data-action="expand-home-card"]': expandHotspot,
  '[data-action="toggle-fullscreen"]': fullscreenButton,
  '[data-component="bottom-navigation"]': mainNavigation,
  '[data-component="path-workspace"]': pathScreen,
  '[data-component="path-content"]': pathContent,
  '[data-component="current-period-detail"]': historyDetailScreen,
  '[data-component="sobriety-batch-history"]': historyScreen,
  '[data-component="history-hero-image"]': historyHeroImage,
  '[data-component="history-hero-variant-toggle"]': historyHeroVariantToggle,
  '[data-component="history-metrics-toggle"]': historyMetricsToggle,
  '[data-component="timeline-hero-image"]': timelineHeroImage,
  '[data-component="timeline-hero-variant-toggle"]': timelineHeroVariantToggle,
  '[data-component="history-metrics-surface"][data-history-presentation-surface="history"]': historyMetricsToggle,
  '[data-component="history-metrics-surface"][data-history-presentation-surface="timeline"]': timelineMetricsToggle,
  '[data-component="calendar-hero-image"]': calendarHeroImage,
  '[data-component="calendar-hero-variant-toggle"]': calendarHeroVariantToggle,
  '[data-component="survival-content"]': survivalContent,
  '[data-component="meeting-search-note"]': meetingSearchNote,
  '[data-component="initialization-flow"]': initializationScreen,
  '[data-component="initialization-content"]': initializationContent,
  '[data-component="panic-motivation-copy"]': panicMotivationCopy,
}[selector] || null);
root.querySelectorAll = (selector) => selector.includes("button[data-action='return-home']") ? [homeNav, historyNav, pathNav, meetingsNav] : [];

const documentStub = {
  fullscreenElement: null,
  documentElement: { requestFullscreen() {} },
  exitFullscreen() {},
  addEventListener() {},
  querySelector(selector) { return selector === '.app-frame' ? root : null; },
};
const runnableScript = html.match(/<script>([\s\S]*?)<\/script>\s*<\/body>/)[1]
  .replace("new HomeInteractionController(document.querySelector('.app-frame'));", "globalThis.__routeController = new HomeInteractionController(document.querySelector('.app-frame'));");
const sandbox = { console, document: documentStub, globalThis: { setTimeout() { return 1; }, clearTimeout() {} }, window: { matchMedia: () => ({ matches: false }) } };
vm.runInNewContext(runnableScript, sandbox);
const controller = sandbox.globalThis.__routeController;

assert.equal(mainNavigation.hidden, false, 'Home must expose the one app-frame-owned BottomNav');
controller.navigate('history');
assert.equal(mainNavigation.hidden, false, 'History must retain the same BottomNav instead of mounting a route-local copy');
controller.navigate('timeline');
assert.equal(mainNavigation.hidden, false, 'Timeline must retain the same BottomNav above its route layer');
controller.navigate('timeline-event-detail');
assert.equal(mainNavigation.hidden, true, 'the full-height event detail must hide the one shared BottomNav');
controller.navigate('panic');
assert.equal(mainNavigation.hidden, false, 'Pánik root must reuse the same BottomNav');
controller.navigate('panic-why');
assert.equal(mainNavigation.hidden, true, 'Pánik child routes must hide the one shared BottomNav');

controller.openHistoryDetail('timeline', 'Téli kitartás');
assert.equal(root.dataset.route, 'history', 'period selection must keep the unified History route active');
assert.equal(controller.state.historySelectedPeriodTitle, 'Téli kitartás', 'the controller must preserve the period selected by the carousel');
assert.equal(controller.state.historyDetailView, 'timeline', 'the inline workspace defaults to the Timeline tab');
controller.openHistoryDetail('calendar');
assert.equal(root.dataset.route, 'history', 'switching to Calendar must keep the same route active');
assert.equal(controller.state.historyDetailView, 'calendar', 'Calendar must remain the second workspace tab');
assert.equal(controller.state.historyCalendarView, 'grid', 'Calendar must start in the monthly grid state');
controller.openHistoryCalendarRail('2025-02-14');
assert.equal(root.dataset.route, 'history', 'the focused calendar rail must stay inside History');
assert.equal(controller.state.historyCalendarView, 'rail', 'the existing rail state must be retained');
controller.openHistoryCalendarGrid();
assert.equal(controller.state.historyCalendarView, 'grid', 'the rail back path must return to the grid state');
assert.equal(historyNav.getAttribute('aria-current'), 'page', 'Történetem stays active inside its inline workspace');
controller.navigate('timeline-event-detail');
assert.equal(root.dataset.route, 'timeline-event-detail', 'a timeline event must still open the distinct event-detail route');
assert.equal(historyNav.getAttribute('aria-current'), 'page', 'Történetem stays active inside event detail');

controller.navigate('panic-why');
assert.equal(root.dataset.route, 'panic-why', 'Pánik why option must open source Screen 30');
controller.handleInput({ target: { value: 'A kapcsolataimért és a nyugalmamért.', matches: (selector) => selector === '[data-initial-motivation]' } });
assert.match(panicMotivationCopy.textContent, /kapcsolataimért/, 'onboarding motivation and Screen 30 must share one state owner');
controller.navigate('panic-relapse');
assert.equal(root.dataset.route, 'panic-relapse', 'Pánik relapse option must open source Screen 15');

controller.startSurvivalPack();
assert.equal(root.dataset.route, 'survival', '15 perces csomag must open one data-driven survival route');
assert.match(survivalContent.innerHTML, /1 \/ 5/, 'survival must begin at source 18A');
for (let index = 0; index < 5; index += 1) controller.advanceSurvivalStep();
assert.equal(root.dataset.route, 'survival', 'the shared survival flow must stay on its own reassessment ending rather than forcing a contact route');
assert.equal(controller.state.survivalSession.completed, true, 'the final survival step must expose an explicit reassessment state');

controller.openMeetings('panic');
assert.equal(root.dataset.route, 'meetings', 'Pánik and shared Gyűlések must resolve to one meetings route');
assert.equal(meetingsNav.getAttribute('aria-current'), 'page', 'Gyűlések must become active on the shared meeting route');
controller.returnFromMeetings();
assert.equal(root.dataset.route, 'panic', 'the single meetings page must preserve its Pánik return origin');
controller.openMeetings('home');
controller.returnFromMeetings();
assert.equal(root.dataset.route, 'home', 'the same meetings page must return to Home when entered from shared navigation');

controller.openInitialization('splash');
assert.equal(root.dataset.route, 'initialization', 'Home hamburger must start the initialization simulator');
assert.match(initializationContent.innerHTML, /Csak a mai nap\./, 'initialization must begin at the source Splash screen');
for (let index = 0; index < 4; index += 1) controller.advanceInitialization(1);
assert.equal(initializationScreen.dataset.initializationView, 'why-started', 'initialization must include the personal motivation screen');
controller.advanceInitialization(1);
assert.equal(initializationScreen.dataset.initializationView, 'notifications', 'initialization must continue through notifications');
controller.advanceInitialization(1);
assert.equal(root.dataset.route, 'home', 'initialization completion must return to Home');

[
  "case 'open-history-detail': this.openHistoryDetail('timeline', event.target.closest('[data-history-batch]')?.querySelector('h2')?.textContent); break;",
  "case 'open-history-detail-calendar': this.openHistoryDetail('calendar'); break;",
  "case 'open-history-calendar-rail': this.openHistoryCalendarRail(event.target.closest('[data-history-calendar-date]')?.dataset.historyCalendarDate); break;",
  "case 'open-history-calendar-grid': this.openHistoryCalendarGrid(); break;",
  "case 'toggle-history-hero-variant': this.toggleHistoryHeroVariant(event.target.closest('[data-history-presentation-surface]')?.dataset.historyPresentationSurface); break;",
  "case 'toggle-history-metrics': this.toggleHistoryMetrics(event.target.closest('[data-history-presentation-surface]')?.dataset.historyPresentationSurface); break;",
  "case 'open-timeline-event-detail': this.navigate('timeline-event-detail'); break;",
  "case 'return-to-history-detail': this.navigate('history'); break;",
  'historySelectedPeriodTitle:',
  "const HISTORY_PRESENTATION_HERO_ASSET = 'assets/hero/timelinehero.png';",
  "openHistoryCalendarRail(date) {",
  "openHistoryCalendarGrid() {",
  "toggleHistoryHeroVariant(surface = 'history') {",
  "toggleHistoryMetrics(surface = 'history') {",
  'renderHistoryLayout() {',
  'renderHistoryPresentation(surface) {',
  'renderHistoryCalendarRail() {',
  'const HISTORY_CALENDAR_RAIL_DAY_COUNT = 21;',
  "case 'open-panic-why': this.navigate('panic-why'); break;",
  "case 'open-panic-relapse': this.navigate('panic-relapse'); break;",
  "case 'start-survival-pack': this.startSurvivalPack(); break;",
  "case 'open-meetings': this.openMeetings(event.target.closest('[data-meetings-origin]')?.dataset.meetingsOrigin || 'home'); break;",
  "case 'return-from-meetings': this.returnFromMeetings(); break;",
  "case 'open-initialization': this.openInitialization('splash'); break;",
  "const SURVIVAL_STEPS = Object.freeze([",
  "const INITIALIZATION_SOURCE_VIEW_ORDER = Object.freeze([",
].forEach((value) => assert.ok(html.includes(value), `route controller is missing ${value}`));
assert.ok(!html.includes('HISTORY_CALENDAR_DAY_EVENTS'), 'the route controller must not retain data for the removed Rail day Timeline');
assert.ok(!html.includes('select-history-timeline-filter'), 'the shared route controller must not retain the removed Timeline filter action');
assert.ok(!html.includes('historyTimelineFilter'), 'the shared route controller must not retain state for removed Timeline filter pills');
[
  'class="survival-card"',
  'class="survival-action"',
  'class="source-splash-background"',
  'class="source-welcome-arch"',
  'class="source-start-date-calendar"',
  'class="source-sponsor-choices"',
  'class="source-why-card"',
  'class="source-notification-list"',
  'data-action="open-timeline-event-detail"',
  'Idővonalam számokban',
  'Állj meg.',
  'Lélegezz.',
  'Igyál vizet.',
  'Menj ki.',
  'Írj egy mondatot.',
].forEach((value) => assert.ok(html.includes(value), `dynamic route renderer must reuse a defined visual class: ${value}`));
assert.equal((html.match(/class="route-screen meetings-screen"/g) || []).length, 1, 'Screen 31 must be defined once for both entry points');
assert.equal((html.match(/data-history-detail-tab=/g) || []).length, 2, 'Screens 8D and 8F must stay as the only two current-period submenus');
assert.equal((html.match(/id: 'survival-/g) || []).length, 5, 'the source 18A–E pack must have exactly five data states');
assert.ok((html.match(/data-action="open-meetings"/g) || []).length >= 2, 'the shared BottomNav and Pánik variants must target the one meeting route');
assert.ok(!/\bfetch\s*\(/.test(html), 'new routes must remain offline without fetch');

console.log('PASS shared route extensions and initialization contract');
