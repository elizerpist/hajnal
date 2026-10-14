'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const appShellPath = path.join(__dirname, '..', 'index.html');
const html = fs.readFileSync(appShellPath, 'utf8');

assert.match(html, /'step-work-history'/, 'the Path view registry must expose a dedicated step-work-history view');
assert.match(html, /PATH_STEP_WORK_STORAGE_KEY/, 'step-work history must have a versioned prototype persistence key');
assert.match(html, /archiveCurrentStepWork/, 'archiving must be a shared domain operation, not chapter UI code');
assert.match(html, /startNewStepWorkRun/, 'creating a fresh single-step run must be distinct from startNewPathCycle');
assert.match(html, /data-action="toggle-path-step-context-menu"/, 'each chapter header must render the context-menu trigger');
assert.match(html, /Korábbi lépésmunkáim/, 'the anchored context menu must expose the history action');
assert.match(html, /renderPathStepWorkHistory\(/, 'one data-driven history renderer must serve every step');
assert.match(html, /stepHistory/, 'the cycle model must retain archived work per step');
assert.match(html, /stepWorkReview/, 'reviewing history must use a dedicated display context rather than changing the active cycle');

const executableDataMatch = html.match(/      const PATH_QUESTION_OVERRIDES[\s\S]*?\n      class HomeInteractionController/);
assert.ok(executableDataMatch, 'the Path domain model must remain executable before the controller');
const executableDataSource = executableDataMatch[0].replace(/\n      class HomeInteractionController$/, '');
const { PATH_STEPS, createPathState, startNewStepWorkRun, migratePathStepWorkState } = new Function(`${executableDataSource}\nreturn { PATH_STEPS, createPathState, startNewStepWorkRun, migratePathStepWorkState };`)();
const state = createPathState();
const cycle = state.cycles.find((item) => item.id === state.currentCycleId);
const step = PATH_STEPS.find((item) => item.id === 'step-4');
const previousWork = cycle.steps[step.id];
const unaffectedStep = JSON.stringify(cycle.steps['step-3']);
const previousAnswer = previousWork.topics['step-4-topic-2'].answers['step-4-topic-2-question-1'].text;
const historyCount = cycle.stepHistory[step.id].length;
const { archived, work: freshWork } = startNewStepWorkRun(cycle, step, { startedAt: '2026-10-15T12:00:00.000Z', runId: 'step-4-run-test' });

assert.equal(cycle.stepHistory[step.id].length, historyCount + 1, 'starting a step run must archive exactly the former work of that step');
assert.equal(archived.stepId, step.id, 'the archive record must retain the step identity');
assert.equal(archived.cycleId, cycle.id, 'a step-run archive must not switch full cycles');
assert.equal(archived.work.topics['step-4-topic-2'].answers['step-4-topic-2-question-1'].text, previousAnswer, 'the archived snapshot must preserve the original answer');
assert.equal(freshWork.runId, 'step-4-run-test', 'the new processing run needs its own stable run identity');
assert.equal(freshWork.status, 'not-started', 'a new processing run starts clean, not as an inherited in-progress step');
assert.deepEqual(Object.values(freshWork.topics).map((topic) => Object.keys(topic.answers).length), Array(step.themes.length).fill(0), 'a new processing run must not copy answers');
assert.equal(JSON.stringify(cycle.steps['step-3']), unaffectedStep, 'starting Step 4 again must not change another step');
freshWork.topics['step-4-topic-2'].answers['step-4-topic-2-question-1'] = { text: 'Új válasz' };
assert.equal(archived.work.topics['step-4-topic-2'].answers['step-4-topic-2-question-1'].text, previousAnswer, 'the archived snapshot must remain independent of the fresh run');

const migrated = migratePathStepWorkState({ currentCycleId: cycle.id, cycles: [{ id: 'legacy-cycle', startedAt: '2024', readOnly: true, steps: { [step.id]: { status: 'closed', topics: {}, topicSummaries: {}, overallSummary: {} } } }], navigation: {} });
assert.ok(migrated.cycles[0].steps[step.id].runId, 'migration must give legacy work a stable runId');
assert.ok(Array.isArray(migrated.cycles[0].stepHistory[step.id]), 'migration must create a per-step archive collection without fabricating historic runs');

console.log('Path step work history contracts are present.');
