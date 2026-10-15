'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');

assert.match(html, /function createDailyReflectionSession\(/, 'Daily reflection must have an explicit factory independent from clean-day confirmation');
assert.match(html, /function normalizeDailyReflectionSession\(/, 'Persisted legacy evening sessions must normalize through one compatibility boundary');
assert.match(html, /HOME_PRACTICE_EVENING_SCHEMA_VERSION\s*=\s*2/, 'Daily reflection persistence must use a versioned schema');
assert.match(html, /cleanDayRecorded:\s*Boolean\(session\.cleanDayRecorded \|\| saved\.evening\.cleanDates/, 'Legacy clean-day dates must migrate independently from reflection content');
assert.match(html, /cleanDayRecorded:\s*false/, 'Opening a daily reflection must begin without marking the day clean');
assert.match(html, /reflection:\s*\{[\s\S]*?status:\s*'empty'/, 'One daily record must own an explicit independent reflection lifecycle');
assert.match(html, /id:\s*`\$\{sobrietyCycleId\}:\$\{date\}`/, 'Daily reflection identity must remain stable by recovery cycle and local date');
assert.match(html, /openDailyReflection\(origin = 'home'\)/, 'Both entry paths must use one controller-owned daily reflection opener');
assert.match(html, /case 'open-daily-reflection': this\.openDailyReflection\('home'\); break;/, 'Expanded Home must open daily reflection without reward context');
assert.match(html, /data-component="home-daily-reflection-block"/, 'Expanded Home must have one explicit daily-reflection card target');
assert.match(html, /Napi reflexió/, 'Daily reflection must replace evening-only Home copy');
assert.match(html, /data-route="daily-reflection"/, 'Daily reflection must own one shared full-screen route');
assert.match(html, /\.daily-reflection-content\s*\{[^}]*position:\s*absolute;[^}]*top:\s*32px;[^}]*bottom:\s*0;/, 'The daily-reflection stage must occupy the viewport below the visible status bar');
assert.match(html, /route === 'daily-reflection'/, 'Navigation must render the shared reflection route directly');
assert.match(html, /case 'open-clean-reflection-choice': this\.openCleanReflectionChoice\(\); break;/, 'Reward must advance to a separate reflection choice, not directly into writing');
assert.match(html, /Szeretnél ma reflektálni\?/, 'Clean-day flow must show an optional reflection choice');
assert.match(html, /Napi reflexió megnyitása|Reflexió folytatása|Mai reflexió megnyitása/, 'Reward choice must reuse an existing daily reflection rather than creating another');
assert.match(html, /assets\/reflection\/daily_reflection_mood\.png/, 'Mood stage must use a local reflection artwork asset');
assert.match(html, /assets\/reflection\/daily_reflection_writing\.png/, 'Writing stage must use a local reflection artwork asset');
assert.match(html, /assets\/reflection\/daily_reflection_practice\.png/, 'Practice stage must use a local reflection artwork asset');
assert.doesNotMatch(html, /daily-reflection[\s\S]{0,1200}assets\/backgrounds\/index1\.png/, 'Daily reflection must not reuse the Home panda artwork');

console.log('PASS daily reflection separation contract');
