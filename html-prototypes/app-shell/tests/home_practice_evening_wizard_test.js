'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

function contains(value, message = `Missing ${value}`) {
  assert.ok(html.includes(value), message);
}

function absent(pattern, message) {
  assert.ok(!pattern.test(html), message);
}

const homeStart = html.indexOf('<section class="home-body"');
const homeEnd = html.indexOf('<nav class="bottom-nav"', homeStart);
const home = html.slice(homeStart, homeEnd);

const domainMatch = html.match(/      function escapeHtml[\s\S]*?\n      class HomeInteractionController/);
assert.ok(domainMatch, 'Practice and daily reflection state factories must live before the shared controller');
const domainSource = domainMatch[0].replace(/\n      class HomeInteractionController$/, '');
const domain = new Function(`${domainSource}\nreturn { createPracticeState, createPractice, createEveningState, createEveningSession, createDailyReflectionSession, normalizeDailyReflectionSession, resolveRewardArtwork, EVENING_PROMPTS };`)();

contains('createPracticeState()', 'Practice domain must have one explicit state factory');
contains('createDailyReflectionSession(', 'Daily reflection must have one shared daily-session factory');
contains('markCleanToday()', 'Clean-day recording must be a named, testable operation');
contains('resolveRewardArtwork(', 'Reward artwork must be resolved from the clean-day instead of a fixed asset');
contains('openPracticeEditor(', 'Home and Path must enter the same practice editor');
contains('openPracticeDetails(', 'Active Home practice must open one details sheet');
contains('create-practice-from-summary', 'Path summary must expose the source-aware practice action');
contains('data-component="practice-sheet"', 'Practice editor/details must be one reusable app overlay');
contains('data-component="evening-wizard"', 'Clean reward route must host the separate reward/choice flow');
contains("case 'open-daily-reflection': this.openDailyReflection('home'); break;", 'Home must directly open the shared daily reflection');
contains("case 'open-daily-reflection-from-clean': this.openDailyReflection('clean-day'); break;", 'Clean-day choice must enter the same daily reflection');
contains("case 'open-clean-reflection-choice': this.openCleanReflectionChoice(); break;", 'Reward must move to a separate optional reflection choice');
contains("case 'select-practice-observation': this.setPracticeObservation", 'Optional practice observation must be explicit');
contains('Mi volt ma a legjobb?', 'First approved evening reflection prompt must be present');
contains('Mi volt ma a legnehezebb?', 'Second approved evening reflection prompt must be present');
contains('Van valami, amit szeretnél megőrizni ebből a napból?', 'Third approved evening reflection prompt must be present');
contains('no_opportunity', 'Practice reflection must include the no-opportunity state');
contains('localDateIso()', 'Session identity must use a local-date source');
contains('sobrietyCycleId', 'Daily sessions must be associated with a sobriety cycle');
contains('practiceSnapshot', 'Evening sessions must preserve historical practice copy');
contains('flushHomePracticeDraft()', 'Practice changes must flush before navigation');
contains('flushEveningDraft()', 'Evening changes must flush before navigation');
contains('hajnal-home-practice-evening-v1', 'Prototype persistence must have one local storage namespace');

assert.match(home, /Amit gyakorlok/, 'Expanded Home must replace its checklist with the practice block');
assert.match(home, /data-component="home-practice-block"/, 'Home practice block must have an explicit renderer target');
assert.match(home, /data-action="open-practice-editor"/, 'Empty Home state must allow self-authored practice creation');
contains('data-action="open-practice-details"', 'Active Home state must offer practice details');
assert.match(home, /data-component="home-daily-reflection-block"/, 'Expanded Home must always expose the Daily reflection entry point');
assert.match(home, /data-action="open-daily-reflection"/, 'Daily reflection must be available independently of clean-day confirmation');
assert.doesNotMatch(home, /Mai feladataim|Hívd fel a szponzorod|Menj el egy meetingre|Esti check-in|data-task-id=|type="checkbox"/, 'Retired Home checklist controls must not remain in the Home surface');

assert.match(html, /case 'mark-clean-today': this\.markCleanToday\(\); break;/, 'Clean day action must record the day before opening the unified wizard');
assert.doesNotMatch(html, /case 'mark-clean-today': this\.navigate\('clean-reward'\); break;/, 'Clean day action must not keep the former reward-only dead end');
assert.match(html, /practice\.status === 'active'|status: 'active'/, 'Practice state must use an explicit active status');
assert.match(html, /'paused'/, 'Practice state must support pausing');
assert.match(html, /'archived'/, 'Practice state must support archiving');
assert.match(html, /pointer-events:\s*none/, 'Artwork layers must stay non-interactive');
assert.match(html, /prefers-reduced-motion: reduce/, 'Wizard transitions must honor reduced motion');

const practiceState = domain.createPracticeState();
assert.equal(practiceState.practices.filter((practice) => practice.status === 'active').length, 1, 'Prototype practice state must begin with exactly one explicit active practice');
assert.equal(practiceState.practices[0].isDemo, true, 'The visible prototype practice must stay explicitly marked as demo data');
assert.equal(practiceState.practices[0].intentionText, 'Megállok egy pillanatra, és előbb meghallgatom a másikat.', 'The visible prototype practice must be a user-authored intention, not an automatic recommendation');
const paused = domain.createPractice({ status: 'paused' });
assert.equal(paused.status, 'paused', 'Practice factory must preserve paused state');
const rewardEarly = domain.resolveRewardArtwork(1);
const rewardLate = domain.resolveRewardArtwork(120);
assert.equal(rewardEarly.asset, 'assets/milestones/milestone-1.svg', 'Early clean days must use the first available journey artwork');
assert.equal(rewardLate.asset, 'assets/milestones/milestone-90.svg', 'The reward artwork must cap at the existing 90-day artwork instead of restarting');
const evening = domain.createEveningState();
const eveningSession = domain.createEveningSession({
  sobrietyCycleId: evening.sobrietyCycleId,
  date: '2026-10-14',
  dayNumber: 24,
  rewardArtworkId: domain.resolveRewardArtwork(24).asset,
  practiceSnapshot: { id: practiceState.activePracticeId, triggerText: 'Amikor…', intentionText: 'Akkor…' },
});
assert.deepEqual(Object.keys(eveningSession.answers), domain.EVENING_PROMPTS.map((prompt) => prompt.id), 'All three evening prompt answers must have independent storage');
assert.equal(eveningSession.practiceReflection.observationType, null, 'Practice reflection must be optional, never a success score');
assert.equal(eveningSession.id, `${evening.sobrietyCycleId}:2026-10-14`, 'An evening session must be stable by sobriety cycle and local date');
assert.equal(eveningSession.cleanDayRecorded, false, 'Creating a daily reflection record must never pre-record a clean day');
assert.equal(eveningSession.reflection.status, 'empty', 'A new daily reflection must begin empty');
assert.equal(domain.normalizeDailyReflectionSession({ ...eveningSession, answers: { best: 'Megmaradt.' }, status: 'completed' }).reflection.text, 'Megmaradt.', 'Legacy evening answers must migrate into the shared daily reflection content');

function makeElement() {
  return {
    attributes: new Map(), dataset: {}, style: { setProperty() {}, removeProperty() {} }, innerHTML: '', hidden: false,
    classList: { add() {}, remove() {}, toggle() {}, contains() { return false; } },
    addEventListener() {}, setPointerCapture() {}, releasePointerCapture() {}, focus() {}, scrollIntoView() {},
    setAttribute(name, value) { this.attributes.set(name, String(value)); }, removeAttribute(name) { this.attributes.delete(name); },
    getAttribute(name) { return this.attributes.get(name) || null; }, querySelector() { return null; }, querySelectorAll() { return []; },
  };
}

const root = makeElement();
const summary = makeElement();
const expandHotspot = makeElement();
const fullscreenButton = makeElement();
const pathScreen = makeElement();
const pathContent = makeElement();
const pathNavigator = makeElement();
const practiceSheet = makeElement();
const practiceDialog = makeElement();
practiceSheet.hidden = true;
practiceSheet.querySelector = () => practiceDialog;
const eveningWizard = makeElement();
const eveningArtwork = makeElement();
const homePractice = makeElement();
const homeDayCount = makeElement();
const cleanReward = makeElement();
const dailyReflection = makeElement();
root.querySelector = (selector) => ({
  '[data-component="daily-summary-card"]': summary,
  '[data-action="expand-home-card"]': expandHotspot,
  '[data-action="toggle-fullscreen"]': fullscreenButton,
  '[data-component="path-workspace"]': pathScreen,
  '[data-component="path-content"]': pathContent,
  '[data-component="path-question-navigator-sheet"]': pathNavigator,
  '[data-component="practice-sheet"]': practiceSheet,
  '[data-component="evening-wizard"]': eveningWizard,
  '[data-component="evening-reward-artwork"]': eveningArtwork,
  '[data-component="home-practice-block"]': homePractice,
  '[data-component="home-clean-day-count"]': homeDayCount,
  '[data-route="path"]': pathScreen,
  '[data-route="clean-reward"]': cleanReward,
  '[data-component="daily-reflection-content"]': dailyReflection,
}[selector] || (selector === '[data-app-overlay-sheet]:not([hidden])' && !practiceSheet.hidden ? practiceSheet : null));
root.querySelectorAll = () => [];
const storage = new Map();
const documentStub = { activeElement: { blur() {} }, querySelector: (selector) => selector === '.app-frame' ? root : null, addEventListener() {}, fullscreenElement: null, documentElement: { requestFullscreen() {} }, exitFullscreen() {} };
const immediateTimeout = (callback) => { callback(); return 1; };
const runnableScript = html.match(/<script>([\s\S]*?)<\/script>\s*<\/body>/)[1].replace("new HomeInteractionController(document.querySelector('.app-frame'));", 'globalThis.__controller = new HomeInteractionController(document.querySelector(\'.app-frame\'));');
const sandbox = {
  console, document: documentStub, requestAnimationFrame: (callback) => callback(), setTimeout: immediateTimeout, clearTimeout() {},
  globalThis: { setTimeout: immediateTimeout, localStorage: { getItem(key) { return storage.get(key) || null; }, setItem(key, value) { storage.set(key, value); } } },
  window: { matchMedia: () => ({ matches: false }), addEventListener() {}, localStorage: { getItem(key) { return storage.get(key) || null; }, setItem(key, value) { storage.set(key, value); } } },
};
vm.runInNewContext(runnableScript, sandbox);
const controller = sandbox.globalThis.__controller;
controller.openDailyReflection('home');
const directSessionId = controller.state.evening.activeSessionId;
assert.equal(controller.state.route, 'daily-reflection', 'Home must open a dedicated full-screen daily reflection route');
assert.equal(controller.state.evening.sessions[directSessionId].cleanDayRecorded, false, 'Opening the reflection during the day must not record a clean day');
controller.updateDailyReflectionText('Délután megálltam egy pillanatra.');
assert.equal(controller.state.evening.sessions[directSessionId].reflection.status, 'draft', 'Writing must persist a daily reflection draft');
controller.closeDailyReflection();
assert.equal(controller.state.route, 'home', 'Closing a Home-origin reflection must return to Home rather than the reward flow');
controller.markCleanToday();
const firstSessionId = controller.state.evening.activeSessionId;
assert.ok(firstSessionId, 'Marking today clean must immediately create/select one daily evening session');
assert.equal(controller.state.route, 'clean-reward', 'Clean-day recording must open the unified evening wizard route');
assert.equal(firstSessionId, directSessionId, 'Clean-day confirmation must reuse today’s direct reflection record');
assert.equal(controller.state.evening.sessions[firstSessionId].cleanDayRecorded, true, 'The clean-day record must not wait for optional writing');
controller.openCleanReflectionChoice();
assert.equal(controller.state.evening.sessions[firstSessionId].rewardStep, 'choice', 'Reward acknowledgement must reveal an optional reflection choice instead of opening an editor automatically');
controller.openDailyReflection('clean-day');
assert.equal(controller.state.route, 'daily-reflection', 'The clean-day choice must navigate into the shared daily reflection route');
controller.closeDailyReflection();
assert.equal(controller.state.route, 'clean-reward', 'Back from clean-day reflection must return to the clean-day choice context');
assert.ok(storage.get('hajnal-home-practice-evening-v1'), 'The controller test harness must receive the versioned daily-session persistence payload');
const persistedPayload = JSON.parse(storage.get('hajnal-home-practice-evening-v1'));
assert.equal(persistedPayload.version, 2, `Expected versioned persistence payload, got ${JSON.stringify(persistedPayload).slice(0, 180)}`);
assert.ok(Array.isArray(persistedPayload.practice?.practices), 'Versioned persistence must retain practice records');
assert.ok(persistedPayload.evening?.sobrietyCycleId, 'Versioned persistence must retain the sobriety cycle identity');
controller.state.evening = domain.createEveningState();
controller.restorePracticeEveningState();
const restoredSession = controller.state.evening.sessions[directSessionId];
assert.ok(restoredSession, 'Persisted daily sessions must be restored under their stable cycle-and-date identity');
assert.equal(restoredSession.cleanDayRecorded, true, 'The clean-day decision must survive a controller rehydration independently of reflection editing');
assert.equal(restoredSession.reflection.text, 'Délután megálltam egy pillanatra.', 'The daily reflection draft must survive a controller rehydration');
controller.markCleanToday();
assert.equal(Object.keys(controller.state.evening.sessions).length, 1, 'Repeated same-day check-in must not create a duplicate evening session');
controller.openPracticeEditor();
controller.updatePracticeDraft('triggerText', 'Amikor feszült vagyok.');
controller.updatePracticeDraft('intentionText', 'Megállok és figyelek.');
controller.savePracticeEditor();
assert.ok(controller.state.practice.replacementCandidate, 'A different active practice must ask before replacing the current one');
controller.confirmPracticeReplacement();
assert.equal(controller.getActivePractice().intentionText, 'Megállok és figyelek.', 'Confirmed practice replacement must activate the new intention');
assert.equal(controller.state.practice.practices.filter((practice) => practice.status === 'active').length, 1, 'Practice replacement must preserve the one-active-practice invariant');

console.log('PASS Home practice + unified evening wizard contract');
