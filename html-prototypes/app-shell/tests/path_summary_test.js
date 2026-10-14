'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

const executableDataMatch = html.match(/      const PATH_QUESTION_OVERRIDES[\s\S]*?\n      class HomeInteractionController/);
assert.ok(executableDataMatch, 'The executable Path data model must include the summary registry.');
const executableDataSource = executableDataMatch[0].replace(/\n      class HomeInteractionController$/, '');
const { PATH_STEPS, PATH_SUMMARY_QUESTIONS } = new Function(`${executableDataSource}\nreturn { PATH_STEPS, PATH_SUMMARY_QUESTIONS };`)();

assert.match(html, /const PATH_SUMMARY_QUESTIONS = Object\.freeze\(/, 'Summary needs one immutable, explicit question registry');
assert.match(html, /renderPathSummary\(/, 'Summary needs one shared, data-driven renderer');
assert.match(html, /renderPathStepSummary\(\)\s*\{\s*return this\.renderPathSummary\(\);/, 'The established summary route must delegate to the shared renderer');
assert.doesNotMatch(html, /renderPathStepFourSummary\(/, 'Step 4 must not retain a separate summary renderer');
assert.match(html, /--path-compact-hero-height/, 'Summary must reuse the compact hero height token');
assert.match(html, /path-summary-carousel/, 'Summary must render the shared carousel geometry');
assert.match(html, /overall-step-reflection/, 'Summary carousel needs the distinct full-step item');
assert.match(html, /topicSummaries/, 'Summary answers must be separated from question-wizard answers');
assert.match(html, /overallSummary/, 'The full-step answers need their own persistent branch');
assert.match(html, /data-path-summary-answer/, 'Each summary question needs an independent editable field');
assert.doesNotMatch(html, /Mit ismertem fel a\(z\)|Mit látok most másképp a\(z\)|témából továbbvinni a következő időszakba/, 'No generated fallback question may replace the supplied registry.');

const questionIds = new Set();
let topicQuestionCount = 0;
let overallQuestionCount = 0;
assert.equal(PATH_STEPS.length, 12, 'The registry must follow all twelve Path steps.');
PATH_STEPS.forEach((step) => {
  const registry = PATH_SUMMARY_QUESTIONS[step.id];
  assert.ok(registry, `${step.id} needs a summary registry entry`);
  assert.equal(Object.keys(registry.topics).length, step.themes.length, `${step.id} must cover every original topic`);
  step.themes.forEach((topic) => {
    const questions = registry.topics[topic.id];
    assert.equal(questions.length, 3, `${topic.id} must have exactly three unique reflection questions`);
    questions.forEach((question) => {
      assert.ok(question.id && question.text.trim(), `${topic.id} has a stable, non-empty question`);
      assert.ok(!questionIds.has(question.id), `duplicate summary question ID: ${question.id}`);
      questionIds.add(question.id); topicQuestionCount += 1;
    });
  });
  assert.equal(registry.overall.length, 3, `${step.id} needs three full-step reflections`);
  registry.overall.forEach((question) => {
    assert.ok(question.id && question.text.trim(), `${step.id} has a stable, non-empty full-step question`);
    assert.ok(!questionIds.has(question.id), `duplicate overall summary question ID: ${question.id}`);
    questionIds.add(question.id); overallQuestionCount += 1;
  });
});
assert.equal(topicQuestionCount, 363, '121 themes × 3 topic reflections must be present.');
assert.equal(overallQuestionCount, 36, '12 steps × 3 full-step reflections must be present.');
assert.equal(questionIds.size, 399, 'The registry must expose all 399 stable questions exactly once.');

console.log('Path summary contract test passed.');
