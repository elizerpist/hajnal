'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

const executableDataMatch = html.match(/      const PATH_QUESTION_OVERRIDES[\s\S]*?\n      class HomeInteractionController/);
assert.ok(executableDataMatch, 'the structured Path data model must remain executable before the controller');
const executableDataSource = executableDataMatch[0].replace(/\n      class HomeInteractionController$/, '');
const { PATH_STEPS, createPathState } = new Function(`${executableDataSource}\nreturn { PATH_STEPS, createPathState };`)();
const initialPathState = createPathState();

assert.match(html, /renderPathImportantCollection\(\)/, 'Fontos nekem must have one shared collection renderer');
assert.match(html, /getPathImportantItems\(/, 'the collection must derive its content from the existing answer model');
assert.doesNotMatch(html, /renderPathStepFourAnswers\(/, 'Step 4 must not retain a separate answers renderer');
assert.match(html, /--path-compact-hero-height:\s*194px/, 'the collection and question editor must share the compact hero token');
assert.match(html, /\.path-important-list-scroll\s*\{[^}]*overflow-y:\s*auto/s, 'only the important-question list must own vertical scrolling');
assert.match(html, /\.path-important-carousel\s*\{[^}]*overflow-x:\s*auto/s, 'the topic carousel must own horizontal scrolling');
assert.match(html, /importantCollection:/, 'collection filter and restoration state must be stored with Path state');
assert.match(html, /openPathImportantQuestion\(/, 'question cards must open the existing wizard with a collection return context');
assert.match(html, /data-action="clear-path-important-search"/, 'the fixed search field must offer a clear action');

PATH_STEPS.forEach((step) => {
  const topicAnswers = initialPathState.cycles.find((cycle) => cycle.id === initialPathState.currentCycleId).steps[step.id].topics;
  const importantEntries = step.themes.flatMap((topic) => Object.entries(topicAnswers[topic.id].answers)
    .filter(([, answer]) => answer.important)
    .map(([questionId]) => ({ topicId: topic.id, questionId })));
  assert.ok(importantEntries.length >= 5 && importantEntries.length <= 8, `Step ${step.number} must seed 5–8 important demo questions`);
  assert.ok(new Set(importantEntries.map((entry) => entry.topicId)).size >= 3, `Step ${step.number} must seed important demo questions in at least three topics`);
  importantEntries.forEach(({ topicId, questionId }) => {
    assert.ok(PATH_STEPS.find((candidate) => candidate.id === step.id).themes.find((topic) => topic.id === topicId).questions.some((question) => question.id === questionId), `Step ${step.number} may seed only stable existing question IDs`);
  });
});

function makeElement() {
  return {
    attributes: new Map(), dataset: {}, innerHTML: '', hidden: true,
    classList: { add() {}, remove() {}, toggle() {}, contains() { return false; } },
    style: { setProperty() {}, removeProperty() {} },
    addEventListener() {}, setAttribute(name, value) { this.attributes.set(name, String(value)); }, removeAttribute(name) { this.attributes.delete(name); },
    setPointerCapture() {}, releasePointerCapture() {}, focus() {}, scrollIntoView() {},
  };
}

const root = makeElement();
const summary = makeElement();
const pathScreen = makeElement();
const pathContent = makeElement();
const navigatorHost = makeElement();
root.querySelector = (selector) => ({
  '[data-component="daily-summary-card"]': summary,
  '[data-action="expand-home-card"]': makeElement(),
  '[data-action="toggle-fullscreen"]': makeElement(),
  '[data-component="path-workspace"]': pathScreen,
  '[data-component="path-content"]': pathContent,
  '[data-component="path-question-navigator-sheet"]': navigatorHost,
  '[data-route="path"]': pathScreen,
}[selector] || null);
root.querySelectorAll = () => [];
const documentStub = { activeElement: { blur() {} }, documentElement: { requestFullscreen() {} }, addEventListener() {}, exitFullscreen() {}, querySelector: (selector) => selector === '.app-frame' ? root : null };
const script = html.match(/<script>([\s\S]*?)<\/script>\s*<\/body>/)[1]
  .replace("new HomeInteractionController(document.querySelector('.app-frame'));", "globalThis.__pathImportantController = new HomeInteractionController(document.querySelector('.app-frame'));");
const immediateTimeout = (callback) => { callback(); return 1; };
const sandbox = { console, document: documentStub, requestAnimationFrame: (callback) => callback(), setTimeout: immediateTimeout, clearTimeout() {}, window: { matchMedia: () => ({ matches: false }) }, globalThis: { setTimeout: immediateTimeout } };
vm.runInNewContext(script, sandbox);
const controller = sandbox.globalThis.__pathImportantController;

controller.openPathStep('step-4');
controller.openPathAnswers();
assert.equal(controller.getPathNavigation().view, 'answers', 'Fontos nekem must use the established answers navigation slot rather than a duplicate route');
assert.match(pathContent.innerHTML, /Fontos nekem/, 'the shared collection must render the new title');
assert.match(pathContent.innerHTML, /path-important-screen/, 'the shared collection must render its compact hero/body screen');
assert.match(pathContent.innerHTML, /path-important-carousel/, 'the collection must render the fixed topic carousel');
assert.match(pathContent.innerHTML, /path-important-question-card/, 'the collection must render direct question cards');
assert.match(pathContent.innerHTML, /path-chapter-minimal|hero-onleltar-mobile/, 'the collection hero must resolve through the existing step artwork resolver');

const importantItem = controller.getPathImportantItems().find((item) => item.topic.id !== 'step-4-topic-2');
assert.ok(importantItem, 'the Step 4 demo collection must contain an important question outside the current default topic');
const collection = controller.getPathImportantCollectionState();
importantItem.answer.text = 'Félelem nélkül is meg tudom nézni ezt a helyzetet.';
collection.query = 'felelem';
assert.ok(controller.getFilteredPathImportantItems().some((item) => item.question.id === importantItem.question.id), 'collection search must match Hungarian accented answer text without accents');
assert.deepEqual(controller.getPathImportantQuestionPresentation(importantItem.question.id), controller.getPathImportantQuestionPresentation(importantItem.question.id), 'a question ID must keep its deterministic icon and colour presentation');
collection.selectedTopicId = importantItem.topic.id;
collection.query = 'minta';
collection.carouselScrollLeft = 144;
collection.listScrollTop = 86;
controller.openPathImportantQuestion(importantItem.topic.id, importantItem.question.id);
assert.equal(controller.getPathNavigation().view, 'question', 'tapping a collection card must reuse the question editor');
assert.equal(controller.getPathNavigation().topicId, importantItem.topic.id, 'the editor must receive the collection card topic ID');
assert.equal(controller.getCurrentQuestion().id, importantItem.question.id, 'the editor must receive the stable selected question ID');
controller.pathBack();
assert.equal(controller.getPathNavigation().view, 'answers', 'Back from a collection-origin editor must return to Fontos nekem');
assert.equal(collection.selectedTopicId, importantItem.topic.id, 'Back must preserve the selected collection topic');
assert.equal(collection.query, 'minta', 'Back must preserve the collection search query');
assert.equal(collection.listScrollTop, 86, 'Back must retain the collection list scroll position');
assert.match(pathContent.innerHTML, /value="minta"/, 'the restored collection must render the preserved search query');
controller.togglePathOverviewAssetStyle();
assert.match(pathContent.innerHTML, /assets\/path-chapter-minimal\/step-04-hero\.png/, 'the collection hero must switch through the established original/minimal artwork state');
assert.match(pathContent.innerHTML, /assets\/path-topic-minimal\/step-04-topic-/, 'the collection topic tiles must switch through the established original/minimal artwork state');

console.log('Path important collection contract test passed.');
