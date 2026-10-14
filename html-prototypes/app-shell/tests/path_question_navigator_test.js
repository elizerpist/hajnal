'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /data-component="path-question-navigator-sheet"/, 'Path must have a dedicated overlay host outside the editor renderer');
assert.match(html, /data-action="open-path-question-navigator"/, 'the question counter must open the navigator');
assert.match(html, /path-question-count-trigger[\s\S]*?aria-haspopup="dialog"/, 'the question counter must expose a dialog trigger');
assert.match(html, /role="dialog"[\s\S]*?aria-modal="true"[\s\S]*?path-question-navigator-title/, 'the navigator must be an accessible modal dialog');
assert.match(html, /path-question-navigator-list/, 'the navigator must have one scrollable question list');
assert.doesNotMatch(html, /path-question-navigator-number-strip|path-question-navigator-search/, 'the sheet must not duplicate navigation with a number strip or search control');
assert.match(html, /renderPathQuestionNavigator\(\)[\s\S]*?topic\.questions\.map/, 'the list must be derived from the active topic questions');
assert.match(html, /renderPathQuestionNavigator\(\)[\s\S]*?getTopicWork\(step\.id, topic\.id\)\.answers/, 'answered state must come from the persisted topic answer map');
assert.match(html, /openPathQuestionNavigator\(trigger\)[\s\S]*?commitPathQuestionAnswer\(\)[\s\S]*?pathQuestionNavigatorOpen = true/, 'opening the navigator must flush current editor data without changing route');
assert.match(html, /selectPathQuestionFromNavigator\(questionIndex\)[\s\S]*?commitPathQuestionAnswer\(\)[\s\S]*?movePathQuestionTo\(questionIndex/, 'a selected question must flush then use the common direct-transition path');
assert.match(html, /movePathQuestionTo\(nextIndex,[\s\S]*?boundedIndex[\s\S]*?navigation\.questionIndex = boundedIndex/, 'direct selection and swipe must share the navigation index mutation');
assert.match(html, /pathQuestionPointerDown\(event\)[\s\S]*?isPathQuestionNavigatorOpen\(\)/, 'background swipe must be disabled while the sheet is open');
assert.match(html, /case 'close-path-question-navigator': this\.closePathQuestionNavigator\(\)/, 'the sheet must close through its action');
assert.match(html, /case 'select-path-question': this\.selectPathQuestionFromNavigator/, 'list row selection must be wired through the controller');
assert.match(html, /if \(this\.isPathQuestionNavigatorOpen\(\)\) \{ this\.closePathQuestionNavigator\(\); return; \}/, 'platform Back must close the sheet first');
assert.match(html, /event\.key === 'Escape'[\s\S]*?isPathQuestionNavigatorOpen\(\)/, 'Escape must close the sheet first');
assert.match(html, /startPathQuestionNavigatorDrag[\s\S]*?finishPathQuestionNavigatorDrag/, 'the drag handle must support a downward-close gesture');
assert.match(html, /height: min\(74%, 620px\)[\s\S]*?max-height: calc\(90% - env\(safe-area-inset-top, 0px\)\)/, 'sheet height must respect the requested default and maximum safe-area bounds');
assert.match(html, /@media \(prefers-reduced-motion: reduce\)[\s\S]*?path-question-navigator-sheet/, 'navigator motion must honor reduced-motion preference');

console.log('PASS Path question navigator contract');
