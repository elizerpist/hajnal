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
assert.deepEqual(
  executableSteps.slice(0, 5).map((step) => initialPathState.cycles[1].steps[step.id].status),
  Array(5).fill('in-progress'),
  'the seeded Path preview must treat steps 1–5 as started work',
);
assert.deepEqual(
  executableSteps.slice(5).map((step) => initialPathState.cycles[1].steps[step.id].status),
  Array(7).fill('not-started'),
  'the seeded Path preview must keep steps 6–12 unstarted',
);
executableSteps.forEach((step) => {
  const topicWork = initialPathState.cycles[1].steps[step.id].topics;
  const startedCount = Math.ceil(step.themes.length / 2);
  assert.deepEqual(
    step.themes.map((topic) => topicWork[topic.id]?.status),
    step.themes.map((topic, index) => index < startedCount ? 'in-progress' : 'not-started'),
    `Step ${step.number} must seed its first half of topics as started and its remaining topics as not started`,
  );
});

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
executableSteps.slice(5).forEach((step) => {
  assert.match(pathContent.innerHTML, new RegExp(`data-step-id="${step.id}" data-path-state="not-started"`), `Step ${step.number} must initially be marked unstarted`);
});
controller.openPathStep('step-6');
controller.openPathTopic('step-6-topic-1');
assert.equal(controller.getCurrentStepWork().status, 'in-progress', 'opening an unstarted step’s first topic must start that step');
controller.openPathView('overview');
assert.match(pathContent.innerHTML, /data-step-id="step-6" data-path-state="in-progress"/, 'a started Step 6 must render through the coloured state rather than the unstarted art state');
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
assert.doesNotMatch(pathContent.innerHTML, /path-step-four-question-wizard/, 'Step 5 must retain its existing generic question renderer');
controller.movePathQuestion(1);
controller.openPathView('overview');
assert.match(pathContent.innerHTML, /Őszinte megosztás/, 'the live current-work card must move to the most recently opened question step');
assert.match(pathContent.innerHTML, /Félelmeim a megosztással kapcsolatban/, 'the live current-work card must move to the most recently opened question topic');
controller.resumePathCurrent();
assert.equal(controller.getPathNavigation().stepId, 'step-5', 'continue must return to the last worked step');
assert.equal(controller.getPathNavigation().topicId, 'step-5-topic-2', 'continue must return to the last worked topic');
assert.equal(controller.getPathNavigation().questionIndex, 1, 'continue must return to the exact last worked question');
controller.state.path.lastWorked = { cycleId: controller.getCurrentCycle().id, stepId: 'step-4', topicId: 'step-4-topic-2', questionIndex: 4 };
controller.openPathStep('step-4');
assert.match(pathContent.innerHTML, /Őszinte önleltár/, 'Step 4 must render its dedicated chapter menu without replacing structured data');
const stepFour = executableSteps[3];
const stepFourProgress = controller.getStepProgress(stepFour.id);
const chapterHeader = controller.renderPathChapterIdentity(stepFour, stepFourProgress);
assert.ok(pathContent.innerHTML.includes(chapterHeader), 'Step 4 main menu must render the shared hero and step-progress chapter header');
assert.match(chapterHeader, /data-component="path-step-four-chapter-header"/, 'the shared Step 4 chapter header must have one stable component boundary');
assert.match(chapterHeader, /assets\/path-step-4\/hero-onleltar-mobile\.png/, 'the shared Step 4 chapter header must keep its existing hero asset');
assert.match(chapterHeader, /Bátran és félelem nélkül leltárt készítettünk magunkról\./, 'the shared Step 4 chapter header must keep its existing motto');
assert.match(chapterHeader, new RegExp(`${stepFourProgress.answeredTopics} / ${stepFourProgress.totalTopics} téma`), 'the shared Step 4 chapter header must retain global topic progress');
assert.match(chapterHeader, new RegExp(`${stepFourProgress.answeredQuestions} / ${stepFourProgress.totalQuestions} kérdés`), 'the shared Step 4 chapter header must retain global question progress');
controller.openPathTopics();
assert.equal(controller.getPathNavigation().view, 'topics', 'the Step 4 Témák tile must keep the existing topics navigation state');
assert.ok(pathContent.innerHTML.includes(chapterHeader), 'Step 4 Témák must render exactly the same shared hero and step-progress chapter header');
const stepFourTopicVisuals = stepFour.themes.map((topic) => controller.getPathStepFourTopicCardVisual(topic));
assert.equal(stepFourTopicVisuals.length, 11, 'the visual map must cover every existing Step 4 topic');
assert.ok(stepFourTopicVisuals.every((visual) => visual && /^assets\/path-step-4\/.+\.png$/.test(visual.asset)), 'Step 4 topic art must reuse only existing local Step PNG assets');
assert.ok(stepFourTopicVisuals.every((visual) => visual.icon && visual.subtitle && visual.position), 'each source-matched topic card must have an icon, compact navigation copy, and intentional crop position');
stepFourTopicVisuals.forEach((visual) => assert.match(html, new RegExp(`id="icon-${visual.icon}"`), `topic icon ${visual.icon} must reuse the existing project icon sprite`));
assert.ok(stepFourTopicVisuals.some((visual) => visual.asset.endsWith('tile-sponsor-review.png')), 'Neheztelések must be paired with the inspected stone visual');
assert.ok(stepFourTopicVisuals.every((visual, index) => index === 0 || visual.asset !== stepFourTopicVisuals[index - 1].asset), 'adjacent topic cards must not repeat the same image');
assert.equal((pathContent.innerHTML.match(/class="path-step-four-topic-art"/g) || []).length, 11, 'each Step 4 topic row must render one dedicated right-hand PNG band');
assert.equal((pathContent.innerHTML.match(/class="path-step-four-topic-medallion"/g) || []).length, 11, 'each Step 4 topic row must render one source-style state medallion');
assert.equal((pathContent.innerHTML.match(/class="path-step-four-topic-action"/g) || []).length, 11, 'each Step 4 topic row must render its separate circular chevron surface');
assert.equal((pathContent.innerHTML.match(/path-step-four-topic-status/g) || []).length, 0, 'Step 4 visual state must live in the left medalion rather than a second right-side status circle');
assert.match(pathContent.innerHTML, /data-component="path-step-four-topics-body"/, 'Step 4 Témák must render its dedicated body below the shared chapter header');
assert.match(pathContent.innerHTML, /<h1[^>]*>Témák<\/h1>/, 'Step 4 Témák must show one concise body heading');
assert.match(pathContent.innerHTML, />11 témakör</, 'Step 4 Témák must show its real topic count');
assert.equal((pathContent.innerHTML.match(/data-action="open-path-topic" data-topic-id="step-4-topic-/g) || []).length, 11, 'Step 4 Témák must render all eleven existing topic controls');
assert.equal((pathContent.innerHTML.match(/path-step-four-menu-card/g) || []).length, 0, 'Step 4 Témák must not repeat main-menu function tiles');
assert.doesNotMatch(pathContent.innerHTML, /path-step-four-quote/, 'Step 4 Témák must not repeat the large reflection quote');
stepFour.themes.forEach((topic, index) => {
  const answered = controller.getAnsweredCount(topic, stepFour.id);
  assert.match(pathContent.innerHTML, new RegExp(`data-topic-id="${topic.id}"`), `Step 4 topic ${index + 1} must retain its original topic id`);
  assert.ok(pathContent.innerHTML.includes(topic.title), `Step 4 topic ${index + 1} must retain its original title`);
  assert.ok(pathContent.innerHTML.includes(`${answered} / ${topic.questions.length} kérdés`), `Step 4 topic ${index + 1} must show its own answer progress`);
});
assert.match(pathContent.innerHTML, /data-topic-id="step-4-topic-2" data-path-topic-current="true"/, 'Neheztelések must be the sole fixed highlighted Step 4 topic');
executableSteps.forEach((step) => {
  controller.openPathStep(step.id);
  const progress = controller.getStepProgress(step.id);
  const expectedHeader = controller.renderPathChapterIdentity(step, progress);
  controller.openPathTopics();
  const topicMarkup = pathContent.innerHTML;
  const expectedStartedCount = Math.ceil(step.themes.length / 2);
  const topicVisuals = step.themes.map((topic, index) => controller.getPathTopicCardVisual(step, topic, index));

  assert.ok(topicMarkup.includes(expectedHeader), `Step ${step.number} Témák must retain its own shared chapter hero and progress header`);
  assert.ok(topicMarkup.includes(`src="${controller.pathChapterHeroAsset(step)}"`), `Step ${step.number} Témák must use its matching existing hero asset`);
  assert.match(topicMarkup, /data-component="path-step-four-topics-body"/, `Step ${step.number} Témák must use the shared chapter topics body`);
  assert.match(topicMarkup, new RegExp(`>${step.themes.length} témakör<`), `Step ${step.number} Témák must retain its real topic count`);
  assert.equal((topicMarkup.match(/class="path-step-four-topic-art"/g) || []).length, step.themes.length, `Step ${step.number} must give every topic the shared right-hand PNG band`);
  assert.equal((topicMarkup.match(/data-action="open-path-topic"/g) || []).length, step.themes.length, `Step ${step.number} must keep every topic a whole-card action`);
  assert.equal((topicMarkup.match(/data-path-topic-state="not-started"/g) || []).length, (step.themes.length - expectedStartedCount) * 2, `Step ${step.number} must expose its not-started rows and their medalions`);
  assert.ok(topicVisuals.every((visual) => visual && /^assets\/path-step-4\/.+\.png$/.test(visual.asset) && visual.icon && visual.subtitle && visual.position), `Step ${step.number} topic visuals must use existing local assets and complete shared card metadata`);
  topicVisuals.forEach((visual) => assert.match(html, new RegExp(`id="icon-${visual.icon}"`), `Step ${step.number} topic icon ${visual.icon} must reuse the icon sprite`));
  step.themes.forEach((topic, index) => {
    const answered = controller.getAnsweredCount(topic, step.id);
    assert.match(topicMarkup, new RegExp(`data-topic-id="${topic.id}"`), `Step ${step.number} topic ${index + 1} must retain its original id`);
    assert.ok(topicMarkup.includes(topic.title), `Step ${step.number} topic ${index + 1} must retain its original title`);
    assert.ok(topicMarkup.includes(`${answered} / ${topic.questions.length} kérdés`), `Step ${step.number} topic ${index + 1} must retain its live question progress`);
  });
  const highlights = [...topicMarkup.matchAll(/data-topic-id="([^"]+)" data-path-topic-current="true"/g)].map((match) => match[1]);
  assert.deepEqual(highlights, step.id === 'step-4' ? ['step-4-topic-2'] : [], `Step ${step.number} must have ${step.id === 'step-4' ? 'only Neheztelések' : 'no'} highlighted topic card`);
  controller.pathBack();
  assert.equal(controller.getPathNavigation().view, 'step', `Témák back must return to Step ${step.number} main menu`);
});

executableSteps.forEach((step) => {
  controller.openPathStep(step.id);
  controller.openPathTopics();
  const answersBeforeTopics = JSON.stringify(Object.fromEntries(step.themes.map((topic) => [topic.id, controller.getTopicWork(step.id, topic.id).answers])));
  const parentStepStatusBeforeTopics = controller.getCurrentStepWork(step.id).status;
  step.themes.forEach((topic, index) => {
    const wasNotStarted = controller.getTopicVisualState(topic, step.id) === 'not-started';
    const siblingStatusesBeforeTopic = JSON.stringify(Object.fromEntries(step.themes.filter((candidate) => candidate.id !== topic.id).map((candidate) => [candidate.id, controller.getTopicWork(step.id, candidate.id).status])));
    const firstUnanswered = topic.questions.findIndex((question) => !controller.getTopicWork(step.id, topic.id).answers[question.id]?.text.trim());
    const expectedResumeIndex = firstUnanswered === -1 ? topic.questions.length - 1 : firstUnanswered;
    controller.openPathTopic(topic.id);
    assert.equal(controller.getPathNavigation().view, step.id === 'step-4' ? 'question' : 'topic', `Step ${step.number} topic row ${index + 1} must ${step.id === 'step-4' ? 'open the direct question wizard' : 'preserve its existing topic starter destination'}`);
    if (step.id === 'step-4') assert.equal(controller.getPathNavigation().questionIndex, expectedResumeIndex, `Step 4 topic row ${index + 1} must resume at its first unanswered question, or its last question when complete`);
    assert.match(pathContent.innerHTML, new RegExp(topic.title), `Step ${step.number} topic row ${index + 1} must keep its unchanged topic identity`);
    assert.equal(JSON.stringify(Object.fromEntries(step.themes.map((candidate) => [candidate.id, controller.getTopicWork(step.id, candidate.id).answers]))), answersBeforeTopics, `opening Step ${step.number} topic row ${index + 1} must not alter answer state`);
    assert.equal(JSON.stringify(Object.fromEntries(step.themes.filter((candidate) => candidate.id !== topic.id).map((candidate) => [candidate.id, controller.getTopicWork(step.id, candidate.id).status]))), siblingStatusesBeforeTopic, `opening Step ${step.number} topic row ${index + 1} must not alter sibling topic states`);
    if (wasNotStarted) assert.equal(controller.getTopicVisualState(topic, step.id), 'in-progress', `opening an untouched Step ${step.number} topic must make that topic started`);
    controller.pathBack();
    assert.equal(controller.getPathNavigation().view, 'topics', `back from Step ${step.number} topic row ${index + 1} must return to its Témák list`);
  });
  assert.equal(controller.getCurrentStepWork(step.id).status, parentStepStatusBeforeTopics === 'not-started' ? 'in-progress' : parentStepStatusBeforeTopics, `opening a topic may retain the established one-way parent-step transition for Step ${step.number}, but no other step status change`);
  controller.pathBack();
  assert.equal(controller.getPathNavigation().view, 'step', `completed topic-loop back must return to Step ${step.number} main menu`);
});
controller.openPathStep('step-4');
controller.openPathTopics();
controller.openPathTopic('step-4-topic-2');
assert.equal(controller.getPathNavigation().view, 'question', 'Step 4 must omit the topic starter and enter the question wizard directly');
assert.equal(controller.getPathNavigation().questionIndex, 5, 'the partially answered Neheztelések topic must resume at its sixth question');
assert.deepEqual({ ...controller.state.path.lastWorked }, { cycleId: controller.getCurrentCycle().id, stepId: 'step-4', topicId: 'step-4-topic-2', questionIndex: 5 }, 'opening a Step 4 topic directly must retain the existing exact last-work pointer');
const firstAnswer = controller.getCurrentPathAnswer();
firstAnswer.text = 'A prototípusban megőrzött saját gondolat.';
controller.movePathQuestion(1);
controller.movePathQuestion(-1);
assert.equal(controller.getCurrentPathAnswer().text, 'A prototípusban megőrzött saját gondolat.', 'question drafts must survive previous/next navigation');
controller.togglePathAnswerFlag('important');
controller.togglePathAnswerFlag('discussWithSponsor');
assert.equal(controller.getCurrentPathAnswer().important, true, 'important must be independent answer state');
assert.equal(controller.getCurrentPathAnswer().discussWithSponsor, true, 'sponsor discussion must be independent answer state');
assert.match(pathContent.innerHTML, /data-component="path-step-four-question-wizard"/, 'Step 4 must render its dedicated focused journaling question surface');
assert.match(pathContent.innerHTML, /assets\/path-step-4\/hero-onleltar-mobile\.png/, 'the Step 4 question hero must reuse the existing Step 4 hero asset');
assert.match(pathContent.innerHTML, /data-component="path-step-four-formatting-rail"/, 'Step 4 must reserve a formatting rail inside its journal editor');
assert.match(pathContent.innerHTML, /data-component="path-step-four-voice-memo"/, 'Step 4 must render a separate voice memo card');
assert.match(pathContent.innerHTML, /data-action="toggle-path-important"/, 'Step 4 must retain the important-answer action');
assert.match(pathContent.innerHTML, /data-action="toggle-path-sponsor"/, 'Step 4 sponsor tile must toggle the existing answer flag rather than navigate away');
assert.match(pathContent.innerHTML, /data-path-step-four-important="true"/, 'Step 4 must expose the active important tile state from the existing answer object');
assert.match(pathContent.innerHTML, /data-path-step-four-sponsor="true"/, 'Step 4 must expose the active sponsor tile state from the existing answer object');
assert.doesNotMatch(pathContent.innerHTML, /Korábbi válaszaim|send-path-question-to-sponsor-pending/, 'Step 4 direct question flow must not expose the removed topic-starter answers shortcut or sponsor-navigation action');
assert.doesNotMatch(pathContent.innerHTML, /data-action="path-dictation"|>Diktálás</, 'Step 4 must move voice-to-text affordance into the placeholder formatting rail rather than retain a separate Dictation action');
controller.togglePathVoiceMemo();
assert.match(pathContent.innerHTML, /data-path-step-four-voice-state="recorded"/, 'Step 4 voice memo card must expose the existing recorded state');
controller.pathBack();
assert.equal(controller.getPathNavigation().view, 'topics', 'Step 4 question back must return directly to the Step 4 topic list');
const completedStepFourTopic = stepFour.themes[0];
const completedTopicWork = controller.getTopicWork('step-4', completedStepFourTopic.id);
completedStepFourTopic.questions.forEach((question) => {
  completedTopicWork.answers[question.id] = { text: 'Kész válasz.', important: false, discussWithSponsor: false, discussedWithSponsor: false, voiceMemoState: 'none' };
});
controller.openPathTopic(completedStepFourTopic.id);
assert.equal(controller.getPathNavigation().questionIndex, completedStepFourTopic.questions.length - 1, 'a completed Step 4 topic must open its final question rather than reset to its first question');
controller.pathBack();
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
expectContains('.path-step-card[data-path-state="not-started"] .path-step-card-art img { filter: grayscale(1);');
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
expectContains('.path-screen[data-path-view="step"] .path-step-four-scroll { height: 100%; display: flex; flex-direction: column; justify-content: space-between;');
expectContains('.path-step-card[data-path-current="true"] { border-color: rgba(44, 46, 119, .045); background: rgba(254, 251, 250, .94);');
expectContains('.path-step-four-art { height: 276px; background: #F2EAF4; }');
expectContains('.path-screen[data-path-step="step-4"][data-path-view="step"][data-path-step-four-hero-variant="large"] .path-step-four-art, .path-screen[data-path-step="step-4"][data-path-view="topics"][data-path-step-four-hero-variant="large"] .path-step-four-art { height: 270px; }');
expectContains('.path-screen[data-path-step="step-4"][data-path-view="step"][data-path-step-four-hero-variant="large"] .path-step-four-art img, .path-screen[data-path-step="step-4"][data-path-view="topics"][data-path-step-four-hero-variant="large"] .path-step-four-art img { height: 127%; bottom: auto; object-position: center top; }');
expectContains('.path-screen[data-path-step="step-4"][data-path-view="step"][data-path-step-four-hero-variant="large"] .path-step-four-art::after, .path-screen[data-path-step="step-4"][data-path-view="topics"][data-path-step-four-hero-variant="large"] .path-step-four-art::after { height: 42px; }');
expectContains('.path-screen[data-path-step="step-4"][data-path-view="step"][data-path-step-four-hero-variant="large"] .path-step-four-copy, .path-screen[data-path-step="step-4"][data-path-view="topics"][data-path-step-four-hero-variant="large"] .path-step-four-copy { position: relative; z-index: 2; margin-top: -46px; }');
expectContains('.path-step-four-menu-card { min-height: 132px;');
expectContains('lastWorked: { cycleId: current.id');
expectContains('rememberLastPathWork()');
expectContains('getLastPathWork()');
expectContains('pathChapterHeroAsset(step)');
expectContains('renderPathChapterMenu()');
expectContains('renderPathStep() { return this.renderPathChapterMenu(); }');
expectContains('aria-label="${step.number}. lépés menü"');
expectContains('const PATH_STEP_FOUR_TOPIC_CARD_VISUALS = Object.freeze({');
expectContains('getPathStepFourTopicCardVisual(topic)');
expectContains('getPathTopicCardVisual(step, topic, index)');
expectContains('getTopicVisualState(topic, stepId = this.getPathNavigation().stepId)');
expectContains('createTopicWork(status = \'not-started\')');
expectContains('data-path-topic-current="${isHighlighted}"');
expectContains("const isHighlighted = step.id === 'step-4' && topic.id === 'step-4-topic-2';");
expectContains('.path-screen[data-path-view="topics"] .path-step-four-topic-art {');
expectContains('-webkit-mask-image: linear-gradient(90deg, transparent 0%, rgba(0,0,0,.18) 28%, #000 62%);');
expectContains('.path-screen[data-path-view="topics"] .path-step-four-topic-action { width: 38px; height: 38px;');
expectContains('.path-screen[data-path-view="topics"] .path-step-four-topic-medallion[data-path-topic-state="in-progress"] {');
expectContains('.path-screen[data-path-view="topics"] .path-step-four-topic-row[data-path-topic-state="not-started"] .path-step-four-topic-art-image { filter: grayscale(1); }');
expectAbsent(/temak\.png/i, 'the visual source-of-truth screenshot must never become a runtime asset');
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
