'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const appShellPath = path.join(__dirname, '..', 'index.html');
const html = fs.readFileSync(appShellPath, 'utf8');

function expectContains(value) {
  assert.ok(html.includes(value), `Ösvény shell is missing ${value}`);
}

function expectAbsent(pattern, message) {
  assert.ok(!pattern.test(html), message);
}

const seedMatch = html.match(/const PATH_STEP_SEEDS = Object\.freeze\(([\s\S]*?)\n      \);\n      const PATH_STEPS/);
assert.ok(seedMatch, 'PATH_STEP_SEEDS must be a structured, locally declared data source');
const stepSeeds = new Function(`return (${seedMatch[1]});`)();

const executableDataMatch = html.match(/      const PATH_QUESTION_OVERRIDES[\s\S]*?\n      class HomeInteractionController/);
assert.ok(executableDataMatch, 'the executable Ösvény data model must precede the shared controller');
const executableDataSource = executableDataMatch[0].replace(/\n      class HomeInteractionController$/, '');
const { PATH_STEPS: executableSteps, createPathState } = new Function(`${executableDataSource}\nreturn { PATH_STEPS, createPathState };`)();
const initialPathState = createPathState();

assert.equal(stepSeeds.length, 12, 'Ösvény must define exactly twelve steps');
assert.deepEqual(stepSeeds.map((step) => step.number), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 'steps must remain in canonical numeric order');
assert.equal(stepSeeds.reduce((total, step) => total + step.themes.length, 0), 121, 'all user-specified Hajnal theme definitions must exist');
assert.ok(stepSeeds.every((step) => step.id && step.title && step.summary && Array.isArray(step.themes) && step.themes.length > 0), 'every step must be structured data, not a duplicate DOM tree');
assert.equal(executableSteps[3].themes[1].questions.length, 11, 'Step 4 Neheztelések must exercise the full repeated question editor');
assert.equal(initialPathState.cycles.length, 2, 'the initial prototype state must represent historical and current work cycles');
assert.equal(initialPathState.currentCycleId, 'cycle-2026', 'the current cycle must be explicit rather than overwriting history');

function makeElement() {
  return {
    attributes: new Map(),
    classList: { add() {}, remove() {}, toggle() {}, contains() { return false; } },
    dataset: {},
    style: { setProperty() {} },
    innerHTML: '',
    addEventListener() {},
    setAttribute(name, value) { this.attributes.set(name, String(value)); },
    removeAttribute(name) { this.attributes.delete(name); },
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
root.querySelector = (selector) => ({
  '[data-component="daily-summary-card"]': summary,
  '[data-action="expand-home-card"]': expandHotspot,
  '[data-action="toggle-fullscreen"]': fullscreenButton,
  '[data-component="path-workspace"]': pathScreen,
  '[data-component="path-content"]': pathContent,
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
  .replace("new HomeInteractionController(document.querySelector('.app-frame'));", "globalThis.__pathController = new HomeInteractionController(document.querySelector('.app-frame'));");
const sandbox = { console, document: documentStub, globalThis: {}, window: { matchMedia: () => ({ matches: false }) } };
vm.runInNewContext(runnableScript, sandbox);
const controller = sandbox.globalThis.__pathController;
controller.openPathView('overview');
assert.equal(root.dataset.route, 'path', 'Ösvény must own the shared path route');
assert.match(pathContent.innerHTML, /Jelenleg ezen dolgozol/, 'root must render Current Work');
assert.match(pathContent.innerHTML, /A 12 lépés/, 'root must render all stations');
controller.openPathStep('step-4');
assert.match(pathContent.innerHTML, /Neheztelések/, 'the generic Step view must render structured topics');
controller.openPathTopic('step-4-topic-2');
controller.openPathQuestion();
const firstAnswer = controller.getCurrentPathAnswer();
firstAnswer.text = 'A prototípusban megőrzött saját gondolat.';
controller.movePathQuestion(1);
controller.movePathQuestion(-1);
assert.equal(controller.getCurrentPathAnswer().text, 'A prototípusban megőrzött saját gondolat.', 'question drafts must survive previous/next navigation');
controller.togglePathAnswerFlag('important');
controller.togglePathAnswerFlag('discussWithSponsor');
assert.equal(controller.getCurrentPathAnswer().important, true, 'important must be independent answer state');
assert.equal(controller.getCurrentPathAnswer().discussWithSponsor, true, 'sponsor discussion must be independent answer state');
controller.openPathSponsorReview('all');
assert.match(pathContent.innerHTML, /nem küld el és nem oszt meg automatikusan/, 'sponsor review must state its privacy boundary');
controller.openPathSummary();
assert.match(pathContent.innerHTML, /Ezt a munkakört lezárom/, 'generic step summary must render');
const priorCycleCount = controller.state.path.cycles.length;
controller.startNewPathCycle();
assert.equal(controller.state.path.cycles.length, priorCycleCount + 1, 'starting a new work cycle must preserve prior cycles');

[
  'data-action="open-path"',
  'data-route="path"',
  'class="route-screen path-screen"',
  'data-path-view="overview"',
  "const PATH_VIEWS = Object.freeze(['overview', 'step', 'topic', 'question', 'answers', 'sponsor-review', 'step-summary', 'cycles']);",
  'const PATH_STEPS = Object.freeze(PATH_STEP_SEEDS.map',
  'createPathState()',
  'renderPath()',
  'syncMainNavigation()',
  "case 'open-path': this.openPathView('overview'); break;",
  "case 'open-path-step': this.openPathStep(event.target.closest('[data-step-id]').dataset.stepId); break;",
  "case 'open-path-topic': this.openPathTopic(event.target.closest('[data-topic-id]').dataset.topicId); break;",
  "case 'open-path-question': this.openPathQuestion(); break;",
  "case 'path-next-question': this.movePathQuestion(1); break;",
  "case 'path-previous-question': this.movePathQuestion(-1); break;",
  "case 'toggle-path-important': this.togglePathAnswerFlag('important'); break;",
  "case 'toggle-path-sponsor': this.togglePathAnswerFlag('discussWithSponsor'); break;",
  "case 'open-path-sponsor-review':",
  'openPathSponsorReview(',
  "case 'open-path-answers': this.openPathAnswers(); break;",
  "case 'open-path-summary': this.openPathSummary(); break;",
  "case 'open-path-cycles': this.openPathCycles(); break;",
  "case 'start-new-path-cycle': this.startNewPathCycle(); break;",
  '<textarea',
  'aria-pressed=',
  'data-path-answer-text',
  'data-path-step-summary',
  'data-path-step-takeaway',
  'data-path-read-only',
  'discussedWithSponsor',
  'voiceMemoState',
  'Napi gyakorlat',
  'A napi önleltár az Esti reflexió része.',
  'Az Ösvény nem ér véget itt.',
].forEach(expectContains);

assert.equal((html.match(/data-action="open-path"/g) || []).length, 1, 'Ösvény must be reachable from the one app-frame-owned BottomNav, not copied into route-local navigation');
assert.equal((html.match(/data-path-step-id=/g) || []).length, 0, 'steps must be rendered from state, not hardcoded screen markup');
const pathActions = [...new Set([...html.matchAll(/data-action="([^"]+)"/g)].map((match) => match[1]).filter((action) => action.includes('path') || action === 'continue-path-current'))];
const unhandledPathActions = pathActions.filter((action) => !html.includes(`case '${action}':`));
assert.deepEqual(unhandledPathActions, [], `every visible Ösvény action must resolve through the one controller: ${unhandledPathActions.join(', ')}`);
expectAbsent(/alkohollal szemben/i, 'Step 1 must never use alcohol-specific wording');
expectAbsent(/data-path-step-state="locked"|path-step-locked/i, 'no Ösvény step may be locked');
expectAbsent(/data-path-root-item="(?:journal|gratitude|panic|survival|timeline|milestones|meeting)"/i, 'Ösvény root must contain only step-work destinations');
expectAbsent(/Most keresd fel ezt az embert/i, 'Step 9 must not pressure direct contact');
expectAbsent(/window\.open\(|navigator\.share\(|fetch\s*\(/i, 'Ösvény must not share, call, or fetch private work automatically');

console.log('PASS Ösvény data-driven workspace contract');
