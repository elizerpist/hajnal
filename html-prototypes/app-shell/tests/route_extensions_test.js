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
    classList: { add() {}, remove() {}, toggle() {} },
    dataset: action ? { action } : {},
    style: { setProperty() {} },
    innerHTML: '',
    textContent: '',
    addEventListener() {},
    setAttribute(name, value) { this.attributes.set(name, String(value)); },
    getAttribute(name) { return this.attributes.get(name); },
    removeAttribute(name) { this.attributes.delete(name); },
    querySelectorAll() { return []; },
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
const historyDetailSubtitle = makeElement();
const historyDetailBack = makeElement('open-history');
const historyDetailTopAction = makeElement();
const historyCalendarRail = makeElement();
const historyDayEventList = makeElement();
historyDetailScreen.querySelectorAll = (selector) => ({
  '[data-history-detail-tab]': [historyTimelineTab, historyCalendarTab],
  '[data-component="history-detail-title"]': [historyDetailTitle],
  '[data-component="history-detail-subtitle"]': [historyDetailSubtitle],
  '[data-component="history-detail-back"]': [historyDetailBack],
  '[data-component="history-detail-top-action"]': [historyDetailTopAction],
  '[data-component="history-calendar-rail"]': [historyCalendarRail],
  '[data-component="history-day-event-list"]': [historyDayEventList],
}[selector] || []);
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

root.querySelector = (selector) => ({
  '[data-component="daily-summary-card"]': summary,
  '[data-action="expand-home-card"]': expandHotspot,
  '[data-action="toggle-fullscreen"]': fullscreenButton,
  '[data-component="path-workspace"]': pathScreen,
  '[data-component="path-content"]': pathContent,
  '[data-component="current-period-detail"]': historyDetailScreen,
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

controller.openHistoryDetail('timeline');
assert.equal(root.dataset.route, 'history-detail', '8C current-period card must open the shared 8D/8F route');
assert.equal(historyDetailScreen.dataset.historyDetailView, 'timeline', 'a current-period card must open the source-right Idővonal submenu');
assert.equal(historyTimelineTab.getAttribute('aria-pressed'), 'true', 'timeline tab must expose selected state');
controller.openHistoryDetail('calendar');
assert.equal(historyDetailScreen.dataset.historyDetailView, 'calendar', 'Naptár must be the second current-period submenu');
assert.equal(historyCalendarTab.getAttribute('aria-pressed'), 'true', 'calendar tab must expose selected state');
assert.equal(historyDetailScreen.dataset.historyCalendarView, 'grid', 'opening Naptár must begin with the source monthly grid');
controller.openHistoryCalendarRail('2025-02-14');
assert.equal(historyDetailScreen.dataset.historyCalendarView, 'rail', 'a semantic calendar-day tap must open the focused rail state on the same route');
assert.equal(controller.state.historyCalendarDate, '2025-02-14', 'the controller must retain the selected calendar day for the rail header and selected day treatment');
assert.equal(historyDetailTitle.textContent, 'Február 14.', 'the rail must render the source day heading from the selected calendar state');
assert.equal(historyDetailSubtitle.textContent, '14. tiszta nap', 'the rail must render the source clean-day subtitle from the selected calendar state');
assert.equal(historyDetailBack.dataset.action, 'open-history-calendar-grid', 'the rail back control must be a real controller-owned grid return action');
assert.match(historyCalendarRail.innerHTML, /data-history-calendar-date="2025-02-14"/, 'the source rail must be derived from the selected day state');
controller.openHistoryCalendarGrid();
assert.equal(historyDetailScreen.dataset.historyCalendarView, 'grid', 'the rail header back affordance must return to the exact monthly grid state');
assert.equal(historyDetailBack.dataset.action, 'open-history', 'the grid restores the period header back action');
assert.equal(controller.state.historyCalendarDate, '2025-02-14', 'the grid return restores the exact grid.png reference selection rather than retaining a rail-only selection');
controller.openHistoryCalendarRail('2025-02-24');
assert.equal(historyDetailTitle.textContent, 'Február 24.', 'a non-source calendar day must receive its own rail heading');
assert.match(historyCalendarRail.innerHTML, /data-history-calendar-date="2025-02-24"[^>]*aria-current="date"/, 'the dynamically rendered rail must contain the selected non-source date');
assert.match(historyDayEventList.innerHTML, /Nincs rögzített esemény/, 'a non-source date must not misleadingly render February 14 event content');
assert.equal(historyNav.getAttribute('aria-current'), 'page', 'Történetem stays active within current-period detail');
controller.navigate('timeline-event-detail');
assert.equal(root.dataset.route, 'timeline-event-detail', 'a timeline event must open the distinct source-center event-detail route');
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
assert.equal(root.dataset.route, 'panic-contacts', 'source 18E completion must resolve to source Screen 26');

controller.openMeetings('panic');
assert.equal(root.dataset.route, 'meetings', 'Pánik and shared Gyűlések must resolve to one meetings route');
assert.equal(meetingsNav.getAttribute('aria-current'), 'page', 'Gyűlések must become active on the shared meeting route');
controller.showMeetingSearchNote();
assert.equal(meetingSearchNote.hidden, false, 'source Screen 31 Meeting keresése CTA must have a local response');
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
  "case 'open-history-detail': this.openHistoryDetail('timeline'); break;",
  "case 'open-history-detail-calendar': this.openHistoryDetail('calendar'); break;",
  "case 'open-history-calendar-rail': this.openHistoryCalendarRail(event.target.closest('[data-history-calendar-date]')?.dataset.historyCalendarDate); break;",
  "case 'open-history-calendar-grid': this.openHistoryCalendarGrid(); break;",
  "case 'open-timeline-event-detail': this.navigate('timeline-event-detail'); break;",
  "case 'return-to-history-detail': this.navigate('history-detail'); break;",
  "case 'select-history-timeline-filter': this.selectHistoryTimelineFilter(event.target.closest('[data-history-timeline-filter]')?.dataset.historyTimelineFilter); break;",
  "openHistoryDetail(view = 'timeline') { this.state.historyDetailView = view === 'calendar' ? 'calendar' : 'timeline'; if (this.state.historyDetailView === 'calendar') { this.state.historyCalendarView = 'grid'; this.state.historyCalendarDate = HISTORY_CALENDAR_GRID_REFERENCE_DATE; } this.navigate('history-detail'); }",
  "openHistoryCalendarRail(date) {",
  "openHistoryCalendarGrid() {",
  'const HISTORY_CALENDAR_DAY_EVENTS = Object.freeze({',
  'renderHistoryCalendarRail() {',
  "case 'open-panic-why': this.navigate('panic-why'); break;",
  "case 'open-panic-relapse': this.navigate('panic-relapse'); break;",
  "case 'start-survival-pack': this.startSurvivalPack(); break;",
  "case 'open-meetings': this.openMeetings(event.target.closest('[data-meetings-origin]')?.dataset.meetingsOrigin || 'home'); break;",
  "case 'return-from-meetings': this.returnFromMeetings(); break;",
  "case 'show-meeting-search-note': this.showMeetingSearchNote(); break;",
  "case 'open-initialization': this.openInitialization('splash'); break;",
  "const SURVIVAL_STEPS = Object.freeze([",
  "const INITIALIZATION_SOURCE_VIEW_ORDER = Object.freeze([",
].forEach((value) => assert.ok(html.includes(value), `route controller is missing ${value}`));
[
  'class="survival-card"',
  'class="survival-action"',
  'class="source-splash-background"',
  'class="source-welcome-arch"',
  'class="source-start-date-calendar"',
  'class="source-sponsor-choices"',
  'class="source-why-card"',
  'class="source-notification-list"',
  'Meeting keresése',
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
assert.equal((html.match(/data-action="open-meetings"/g) || []).length, 9, 'Pánik plus all eight shared navigation instances must target the one meeting route');
assert.ok(!/\bfetch\s*\(/.test(html), 'new routes must remain offline without fetch');

console.log('PASS shared route extensions and initialization contract');
