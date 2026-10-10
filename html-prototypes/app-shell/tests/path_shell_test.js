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
assert.deepEqual(initialPathState.lastWorked, { cycleId: 'cycle-2026', stepId: 'step-4', topicId: 'step-4-topic-2', questionIndex: 4 }, 'the current-work card must have one explicit last-question pointer');

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
assert.match(pathContent.innerHTML, />12 lépés</, 'root must render the twelve-step chapter list');
assert.match(pathContent.innerHTML, /path-overview-height-toggle/, 'root must render the high/low card-height control');
assert.equal(pathScreen.dataset.pathStep, 'step-4', 'fast-card progress must resolve from the same current step as its matching list row');
assert.equal(pathScreen.dataset.pathOverviewLayout, 'roomy', 'the restored, taller card composition must be the default');
controller.togglePathOverviewLayout();
assert.equal(pathScreen.dataset.pathOverviewLayout, 'compact', 'the root height control must switch to the compact presentation');
assert.match(pathContent.innerHTML, /aria-pressed="false"/, 'compact layout control must expose its selected state');
controller.togglePathOverviewLayout();
assert.equal(pathScreen.dataset.pathOverviewLayout, 'roomy', 'the root height control must switch back to taller cards');
assert.doesNotMatch(pathContent.innerHTML, /path-step-card-state/, 'step rows must not render a separate right-side pie/state circle');
assert.match(pathContent.innerHTML, /path-step-card-number" style="--path-step-progress:/, 'the numbered medalion must own the step progress ring');
assert.match(pathContent.innerHTML, /path-fast-medallion path-fast-medallion--static/, 'the fast-card step number must be a static pink disc, because its linear bar is the sole current-work progress indicator');
assert.equal(controller.pathStepArt(1), 'assets/path-step-4/tile-topics.png', 'step 1 must retain its distinct original artwork');
assert.equal(controller.pathStepArt(2), 'assets/path-step-4/tile-sponsor-review.png', 'step 2 must retain its distinct original artwork');
assert.equal(controller.pathStepArt(3), 'assets/path-step-4/tile-summary.png', 'step 3 must retain its distinct original artwork');
assert.equal(controller.pathStepArt(4), 'assets/path-step-4/hero-onleltar-row.png', 'both root Step 4 cards must use the common landscape adapter rather than the portrait chapter hero');
assert.equal(controller.pathStepArtIsMirrored(1), true, 'Step 1 artwork must mirror into the shared rightward fade composition');
assert.equal(controller.pathStepArtIsMirrored(2), true, 'Step 2 artwork must mirror into the shared rightward fade composition');
assert.equal(controller.pathStepArtIsMirrored(3), true, 'Step 3 artwork must mirror into the shared rightward fade composition');
assert.equal(controller.pathStepArtIsMirrored(4), false, 'Step 4 artwork already has the correct fade direction');
assert.equal(controller.pathStepArtIsMirrored(5), false, 'Step 5 artwork already has the correct fade direction');
assert.equal(controller.pathStepArtIsMirrored(6), false, 'Step 6 artwork already has the correct fade direction');
assert.equal(controller.pathStepArtIsMirrored(7), true, 'Step 7 artwork must mirror into the shared rightward fade composition');
assert.equal(controller.pathStepArtIsMirrored(8), true, 'Step 8 artwork must mirror into the shared rightward fade composition');
assert.equal(controller.pathStepArtIsMirrored(9), true, 'Step 9 artwork must mirror into the shared rightward fade composition');
assert.equal(controller.pathStepArtIsMirrored(10), true, 'Step 10 artwork must mirror into the shared rightward fade composition');
assert.equal(controller.pathStepArtIsMirrored(11), false, 'Step 11 artwork already has the correct fade direction');
assert.equal(controller.pathStepArtIsMirrored(12), false, 'Step 12 artwork already has the correct fade direction');
assert.match(pathContent.innerHTML, /path-step-card-art is-mirrored/, 'mirrored step art must be rendered through the shared image primitive');

executableSteps.forEach((step) => {
  controller.openPathStep(step.id);
  assert.equal(pathScreen.dataset.pathStep, step.id, `Step ${step.number} must keep its selected identity`);
  assert.match(pathContent.innerHTML, new RegExp(`${step.number}\\. lépés`), `Step ${step.number} must render its own chapter kicker`);
  assert.ok(pathContent.innerHTML.includes(step.title), `Step ${step.number} must render its own chapter title`);
  assert.match(pathContent.innerHTML, /path-step-four-art/, `Step ${step.number} must receive the shared chapter hero`);
  assert.ok(pathContent.innerHTML.includes(`data-path-chapter-art="${step.id}"`), `Step ${step.number} must bind its own chapter hero destination`);
  assert.ok(pathContent.innerHTML.includes(`src="${controller.pathChapterHeroAsset(step)}"`), `Step ${step.number} must reuse its own root-card art in the chapter hero`);
  assert.match(pathContent.innerHTML, /path-step-four-progress-ring/, `Step ${step.number} must receive the shared progress card`);
  assert.match(pathContent.innerHTML, /path-step-four-quote/, `Step ${step.number} must receive the shared reflection quote`);
  assert.equal((pathContent.innerHTML.match(/path-step-four-menu-card/g) || []).length, 8, `Step ${step.number} must render four shared functional tiles with their image primitives`);
});

controller.openPathStep('step-5');
controller.openPathTopic('step-5-topic-2');
controller.openPathQuestion();
controller.movePathQuestion(1);
controller.openPathView('overview');
assert.match(pathContent.innerHTML, /Őszinte megosztás/, 'the live current-work card must move to the most recently opened question step');
assert.match(pathContent.innerHTML, /Félelmeim a megosztással kapcsolatban/, 'the live current-work card must move to the most recently opened question topic');
controller.resumePathCurrent();
assert.equal(controller.getPathNavigation().stepId, 'step-5', 'continue must return to the last worked step');
assert.equal(controller.getPathNavigation().topicId, 'step-5-topic-2', 'continue must return to the last worked topic');
assert.equal(controller.getPathNavigation().questionIndex, 1, 'continue must return to the exact last worked question');
controller.openPathStep('step-4');
assert.match(pathContent.innerHTML, /Őszinte önleltár/, 'Step 4 must render its dedicated chapter menu without replacing structured data');
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
assert.match(pathContent.innerHTML, /Ezt a lépésmunkát lezárom/, 'Step 4 summary must preserve its existing close action');
const priorCycleCount = controller.state.path.cycles.length;
controller.startNewPathCycle();
assert.equal(controller.state.path.cycles.length, priorCycleCount + 1, 'starting a new work cycle must preserve prior cycles');

[
  'data-action="open-path"',
  'data-route="path"',
  'class="route-screen path-screen"',
  'data-path-view="overview"',
  "const PATH_VIEWS = Object.freeze(['overview', 'step', 'topics', 'topic', 'question', 'answers', 'sponsor-review', 'step-summary', 'cycles']);",
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
  'Az Ösvény nem ér véget itt.',
].forEach(expectContains);

assert.equal((html.match(/data-action="open-path"/g) || []).length, 2, 'Ösvény must keep its shared BottomNav entry and the Step 4 source-of-truth overview action');
assert.equal((html.match(/data-path-step-id=/g) || []).length, 0, 'steps must be rendered from state, not hardcoded screen markup');
expectContains('--path-step-art-mask: linear-gradient(90deg, transparent 0%, rgba(0,0,0,.42) 10%');
expectContains('-webkit-mask-image: var(--path-step-art-mask);');
expectContains('.path-step-card::before { display: none; }');
expectContains('.path-step-card-art.is-mirrored img { transform: scaleX(-1); }');
expectContains('.path-step-card > .path-step-card-art { position: absolute; z-index: 0; }');
expectContains('--path-step-art-width: 186px;');
expectContains('[data-path-overview-layout="compact"] .path-overview-content { --path-step-art-width: 168px;');
expectContains('.path-step-card[data-step-id="step-4"] .path-step-card-art, .path-screen[data-path-view="overview"][data-path-step="step-4"] .path-fast-visual');
expectContains('.path-step-card[data-step-id="step-4"] .path-step-card-number { --path-step-progress: 12 !important; }');
expectContains('.path-screen[data-path-view="overview"][data-path-step="step-4"] .path-fast-progress > span { width: 12% !important; }');
expectContains('.path-step-card[data-step-id="step-6"] .path-step-card-number, .path-step-card[data-step-id="step-7"] .path-step-card-number');
expectContains('.path-screen[data-path-view="overview"][data-path-overview-layout="compact"] .path-step-card-number { width: 46px; height: 46px;');
expectAbsent(/data-path-overview-layout="compact"\][^{]*\.path-(?:fast-medallion|step-card-number) > span \{ background:/, 'compact mode must never alter the number medallion body');
expectContains('padding: 3px; border: 4px solid #FEFBFA;');
expectContains('.path-fast-medallion > span, .path-step-card-number > span { width: 100%; height: 100%; display: grid; place-items: center; border-radius: 50%; background: #EAE0FA; }');
expectAbsent(/\.path-fast-medallion > span, \.path-step-card-number > span \{[^}]*rgba\(/, 'the number-disc fill must be opaque, so the progress ring cannot appear as pie slices');
expectContains('.path-fast-medallion--static { padding: 0; border: 0; background: #EAE0FA; }');
expectContains('.path-step-card-number { width: 54px; height: 54px; position: relative; justify-self: start; margin-left: -7px; font-size: 21px; }');
expectContains('.path-screen[data-path-view="step"] .path-step-four-scroll { height: calc(100% - var(--bottom-nav-h)); display: flex; flex-direction: column; justify-content: space-between;');
expectContains('.path-step-card[data-path-current="true"] { border-color: rgba(44, 46, 119, .045); background: rgba(254, 251, 250, .94);');
expectContains('.path-step-four-art { height: 276px; background: #F2EAF4; }');
expectContains('.path-step-four-menu-card { min-height: 132px;');
expectContains('lastWorked: { cycleId: current.id');
expectContains('rememberLastPathWork()');
expectContains('getLastPathWork()');
expectContains('pathChapterHeroAsset(step)');
expectContains('renderPathChapterMenu()');
expectContains('renderPathStep() { return this.renderPathChapterMenu(); }');
expectContains('aria-label="${step.number}. lépés menü"');
const pathActions = [...new Set([...html.matchAll(/data-action="([^"]+)"/g)].map((match) => match[1]).filter((action) => action.includes('path') || action === 'continue-path-current'))];
const unhandledPathActions = pathActions.filter((action) => !html.includes(`case '${action}':`));
assert.deepEqual(unhandledPathActions, [], `every visible Ösvény action must resolve through the one controller: ${unhandledPathActions.join(', ')}`);
expectAbsent(/alkohollal szemben/i, 'Step 1 must never use alcohol-specific wording');
expectAbsent(/data-path-step-state="locked"|path-step-locked/i, 'no Ösvény step may be locked');
expectAbsent(/data-path-root-item="(?:journal|gratitude|panic|survival|timeline|milestones|meeting)"/i, 'Ösvény root must contain only step-work destinations');
expectAbsent(/Most keresd fel ezt az embert/i, 'Step 9 must not pressure direct contact');
const pathControllerSource = html.slice(html.indexOf('        getStep('), html.indexOf('        render() {}'));
assert.doesNotMatch(pathControllerSource, /window\.open\(|navigator\.share\(|fetch\s*\(/i, 'Ösvény must not share, call, or fetch private work automatically');

console.log('PASS Ösvény data-driven workspace contract');
