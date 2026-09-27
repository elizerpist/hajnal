'use strict';

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const appShellDirectory = path.join(__dirname, '..');
const repositoryRoot = path.join(appShellDirectory, '..', '..');
const appShell = fs.readFileSync(path.join(appShellDirectory, 'index.html'), 'utf8');
const sourcePrototype = fs.readFileSync(path.join(repositoryRoot, 'html-prototypes', 'offline-ui', 'index.html'), 'utf8');
const sourceRelapse = sourcePrototype.match(/<article class="phone-screen checkin-fullscreen relapse-state no-nav" id="checkin-relapse"[\s\S]*?<\/article>/)?.[0];

assert.ok(sourceRelapse, 'source Screen 15 must remain available for the fidelity contract');
const sourceAsset = sourceRelapse.match(/<img class="checkin-bg" src="([^"]+)"/)?.[1];
assert.ok(sourceAsset?.startsWith('data:image/svg+xml;base64,'), 'source Screen 15 must define its concrete background asset');

const sourceAssetHash = crypto.createHash('sha256').update(Buffer.from(sourceAsset.slice(sourceAsset.indexOf(',') + 1), 'base64')).digest('hex');
const appAssetPath = path.join(appShellDirectory, 'assets', 'milestones', 'milestone-60.svg');
const appAssetHash = crypto.createHash('sha256').update(fs.readFileSync(appAssetPath)).digest('hex');
assert.equal(appAssetHash, sourceAssetHash, 'the already-local Screen 15 asset must be byte-identical to the source background');

assert.match(appShell, /class="source-relapse-background" src="assets\/milestones\/milestone-60\.svg"/, 'panic-relapse must render the exact local source background asset');
assert.match(appShell, /class="[^"]*source-relapse-screen[^"]*"/, 'panic-relapse must use its dedicated source-faithful full-screen component');
assert.match(appShell, /class="source-relapse-top-actions"/, 'panic-relapse must retain the source top action geometry');
assert.match(appShell, /class="source-relapse-copy"/, 'panic-relapse must retain the source centered copy block');
assert.match(appShell, /<h3 id="relapse-title">Köszönjük,<br>hogy őszinte voltál.<br><br>Holnap újra<br>indulhatunk\.<\/h3>/, 'panic-relapse copy must exactly match Screen 15');
assert.match(appShell, /class="source-relapse-action primary"[^>]*data-action="return-home"/, 'source primary relapse action must return Home');
assert.match(appShell, /class="source-relapse-action outline"[^>]*data-action="open-panic"/, 'source outline relapse action must return to Panic');
assert.match(appShell, /\.source-relapse-screen::after \{[^}]*rgba\(12,14,42,\.30\)[^}]*rgba\(12,13,36,\.94\)/, 'panic-relapse must retain the source darkening overlay');
assert.match(appShell, /\.source-relapse-background \{[^}]*filter: saturate\(\.34\) brightness\(\.64\);/, 'panic-relapse must retain the source background treatment');
assert.match(appShell, /\.source-relapse-copy h3 \{[^}]*font-size: 24px;[^}]*line-height: 1\.18;/, 'panic-relapse must retain the source copy hierarchy');
assert.match(appShell, /\.source-relapse-bottom-actions \{[^}]*padding: 0 34px 25px;/, 'panic-relapse must retain the source bottom action geometry');

const relapseSection = appShell.match(/<section class="route-screen relapse-screen[^\"]*"[\s\S]*?<\/section>/)?.[0] || '';
assert.ok(relapseSection, 'the source-relapse no-navigation assertion must inspect the real Screen 15 section');
assert.doesNotMatch(relapseSection, /route-bottom-nav/, 'source Screen 15 must remain a no-bottom-nav screen');

console.log('PASS source-faithful Screen 15 relapse contract');
