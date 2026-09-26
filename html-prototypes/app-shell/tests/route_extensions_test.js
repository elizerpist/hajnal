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
const historyOverviewTab = makeElement();
historyOverviewTab.dataset.historyDetailTab = 'overview';
const historyTimelineTab = makeElement();
historyTimelineTab.dataset.historyDetailTab = 'timeline';
historyDetailScreen.querySelectorAll = (selector) => selector === '[data-history-detail-tab]' ? [historyOverviewTab, historyTimelineTab] : [];
const survivalContent = makeElement();
const meetingSearchNote = makeElement();
meetingSearchNote.hidden = true;
const periodTimelineFilter = makeElement();
periodTimelineFilter.hidden = true;
const periodTimelineFilterButton = makeElement();
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
  '[data-component="period-timeline-filter"]': periodTimelineFilter,
  '[data-action="toggle-history-timeline-filter"]': periodTimelineFilterButton,
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
const sandbox = { console, document: documentStub, globalThis: {}, window: { matchMedia: () => ({ matches: false }) } };
vm.runInNewContext(runnableScript, sandbox);
const controller = sandbox.globalThis.__routeController;

controller.openHistoryDetail('overview');
assert.equal(root.dataset.route, 'history-detail', '8C current-period card must open the shared 8D/8F route');
assert.equal(historyDetailScreen.dataset.historyDetailView, 'overview', '8D must be the first current-period submenu');
assert.equal(historyOverviewTab.getAttribute('aria-pressed'), 'true', 'overview tab must expose selected state');
controller.openHistoryDetail('timeline');
assert.equal(historyDetailScreen.dataset.historyDetailView, 'timeline', '8F must be the second submenu of the same route');
assert.equal(historyTimelineTab.getAttribute('aria-pressed'), 'true', 'timeline tab must expose selected state');
assert.equal(historyNav.getAttribute('aria-current'), 'page', 'Történetem stays active within current-period detail');
controller.toggleHistoryTimelineFilter();
assert.equal(periodTimelineFilter.hidden, false, '8F timeline filter must be a real local control');
assert.equal(periodTimelineFilterButton.getAttribute('aria-expanded'), 'true', 'timeline filter must expose expanded state');

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
assert.match(initializationContent.innerHTML, /Minden nap/, 'initialization must begin at splash');
for (let index = 0; index < 4; index += 1) controller.advanceInitialization(1);
assert.equal(initializationScreen.dataset.initializationView, 'why-started', 'initialization must include the personal motivation screen');
controller.advanceInitialization(1);
assert.equal(initializationScreen.dataset.initializationView, 'notifications', 'initialization must continue through notifications');
controller.advanceInitialization(1);
assert.equal(root.dataset.route, 'home', 'initialization completion must return to Home');

[
  "case 'open-history-detail': this.openHistoryDetail('overview'); break;",
  "case 'open-panic-why': this.navigate('panic-why'); break;",
  "case 'open-panic-relapse': this.navigate('panic-relapse'); break;",
  "case 'start-survival-pack': this.startSurvivalPack(); break;",
  "case 'open-meetings': this.openMeetings(event.target.closest('[data-meetings-origin]')?.dataset.meetingsOrigin || 'home'); break;",
  "case 'return-from-meetings': this.returnFromMeetings(); break;",
  "case 'show-meeting-search-note': this.showMeetingSearchNote(); break;",
  "case 'toggle-history-timeline-filter': this.toggleHistoryTimelineFilter(); break;",
  "case 'open-initialization': this.openInitialization('splash'); break;",
  "const SURVIVAL_STEPS = Object.freeze([",
  "const INITIALIZATION_VIEWS = Object.freeze([",
].forEach((value) => assert.ok(html.includes(value), `route controller is missing ${value}`));
[
  'class="survival-card"',
  'class="survival-action"',
  'class="init-nav"',
  '.init-progress {',
  '.init-choice-list {',
  '.init-notification-note {',
  'Meeting keresése',
  'data-action="toggle-history-timeline-filter"',
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
