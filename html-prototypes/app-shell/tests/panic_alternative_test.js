'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /panicVariant:\s*(?:this\.readPanicVariant\(\)|'classic')/, 'Pánik must have controller-owned Classic/Alternative state');
assert.match(html, /togglePanicVariant\(\)/, 'Pánik must expose one variant toggle action');
assert.match(html, /renderPanicVariant\(\)/, 'Pánik must render exactly the active variant');
assert.match(html, /data-action="toggle-panic-variant"/, 'the former Panic close affordance must be the view toggle');
assert.match(html, /panic-alternative/, 'Alternative Pánik needs its own scoped view boundary');
assert.match(html, /panic-main-button--pulse/, 'Alternative help button must receive a scoped pulse class');
assert.match(html, /@keyframes\s+panic-help-pulse/, 'Alternative help pulse needs a CSS keyframe');
assert.match(html, /@media\s*\(prefers-reduced-motion:\s*reduce\)/, 'continuous Pánik animation must respect reduced-motion');
assert.match(html, /@media \(max-width: 411px\) \{ \.app-frame \{ width: 100vw; height: 100vh;/, 'the shared shell must fit 320–411px mobile viewports without horizontal frame overflow');
assert.match(html, /openPanicHelpSheet\(/, 'the large help button must open the shared contact sheet');
assert.match(html, /closePanicHelpSheet\(/, 'the help sheet needs a controller close path');
assert.match(html, /Hívj fel valakit/, 'the sheet must explain its safe purpose');
assert.match(html, /Nem indul automatikus hívás vagy üzenet\./, 'the sheet must state that no call or message is automatic');
assert.match(html, /tel:112/, 'emergency dialing must be explicit and scoped to 112');
assert.match(html, /panicHelpContact/, 'help contact selection must remain central controller state');
assert.match(html, /survivalSession/, 'the survival flow must have a resumable timestamped session');
assert.match(html, /startedAt/, 'the survival timer must be based on a real start timestamp');
assert.match(html, /completeSurvivalPack\(/, 'survival must be finishable without compulsory calling');
assert.doesNotMatch(html, /if \(this\.state\.survivalStep >= SURVIVAL_STEPS\.length - 1\) \{ this\.navigate\('panic-contacts'\)/, 'finishing survival may not force the legacy contact route');

console.log('PASS panic alternative source contract');
