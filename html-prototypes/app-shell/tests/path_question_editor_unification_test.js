'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /openPathTopic\(topicId\)[\s\S]*?navigation\.questionIndex = this\.getTopicResumeQuestionIndex\(topic, step\.id\);[\s\S]*?navigation\.view = 'question';/, 'every topic must enter the common question editor at its resumable question');
assert.doesNotMatch(html, /if \(step\.id === 'step-4'\) return this\.renderPathStepFourQuestionWizard/, 'Step 4 must not own a separate question renderer');
assert.doesNotMatch(html, /renderPathStepFourQuestionWizard/, 'the retired Step 4-only question renderer must not remain alongside the shared editor');
assert.match(html, /renderPathQuestion\(\)[\s\S]*?getPathTopicCardVisual\(step, topic,[\s\S]*?path-question-editor-hero/, 'the common question renderer must resolve the current topic artwork as its hero');
assert.match(html, /path-question-editor-card[\s\S]*?Önreflexiós kérdés[\s\S]*?Automatikusan mentve[\s\S]*?data-path-answer-text[\s\S]*?path-question-formatting-rail/, 'one editor card must contain the label, autosave state, question, answer input and toolbar');
const commonQuestionRenderer = html.match(/renderPathQuestion\(\)[\s\S]*?\n        renderPathAnswers/)[0];
assert.doesNotMatch(commonQuestionRenderer, /data-action="path-previous-question"|data-action="path-next-question"|class="path-question-navigation"/, 'the live common question renderer must not contain navigation buttons');
assert.match(html, /pathQuestionPointerDown\(event\)[\s\S]*?pathQuestionPointerMove\(event\)[\s\S]*?pathQuestionPointerEnd\(event\)/, 'the shared question screen must own an outer swipe lifecycle');
assert.match(html, /pathQuestionPointerDown\(event\)[\s\S]*?closest\('\[data-path-answer-text\][^']*'\)/, 'the question pager must leave text entry gestures to the editor');
assert.match(html, /movePathQuestion\(delta,[\s\S]*?commitPathQuestionAnswer\(\)[\s\S]*?pathQuestionSlideDirection/, 'a question change must commit first and use a slide transition state');
assert.match(html, /data-action="toggle-path-voice-memo"[\s\S]*?data-action="toggle-path-important"[\s\S]*?data-action="toggle-path-sponsor"/, 'the permanent lower actions must toggle their answer containers without navigation');
assert.match(html, /\.path-question-editor-stage\s*\{[^}]*background:\s*transparent;/, 'the question body must stay an airy fade layer rather than one enclosing card');
assert.match(html, /\.path-question-editor-hero-art\s*\{[^}]*mask-image:/, 'the question hero must fade into the body');
assert.match(html, /history-period-pager-art\s*\{[^}]*height:\s*calc\(var\(--path-overview-hero-height\) \+ var\(--history-inline-hero-fade-extension\)\)[^}]*var\(--history-inline-hero-fade-mask\)/, 'History inline hero art must use the shared fade extension and mask');
assert.match(html, /history-period-pager-body\s*\{[^}]*background:\s*transparent;/, 'History body must not cover the fading hero with an opaque surface');

console.log('PASS unified Path question editor and History fade contract');
