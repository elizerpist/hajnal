'use strict';

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
const heroPath = path.join(root, 'assets', 'hero', 'hero_m.png');
const historyStart = html.indexOf('<section class="route-screen history-screen" id="home-statistics"');
const historyEnd = html.indexOf('<section class="route-screen history-detail-screen"', historyStart);
const history = html.slice(historyStart, historyEnd);

assert.ok(historyStart >= 0 && historyEnd > historyStart, 'the Történetem route must remain one bounded screen');
assert.ok(fs.existsSync(heroPath), 'the supplied history hero asset must be copied into the canonical app-shell assets');
assert.equal(
  crypto.createHash('sha256').update(fs.readFileSync(heroPath)).digest('hex'),
  '91046d51167af3d1ec2395791788564c355b8c495f5cf6367e0032c90c7d855d',
  'history hero must remain byte-identical to the supplied hero_m.png',
);

[
  'class="history-hero"',
  'src="assets/hero/hero_m.png"',
  'Fejezeteim és emlékeim',
  'Minden időszak egy külön fejezet az utamból.',
  'Első időszak',
  '2024. máj. 1. – 2024. máj. 8.',
  '8 nap',
  'Nyári szakasz',
  '2024. aug. – 2024. szept.',
  '37 nap',
  'Leghosszabb időszak',
  '2025. jan. – 2025. ápr.',
  '89 nap',
  'Jelenlegi időszak',
  '2026. máj. 1. – jelenleg',
  '24 nap tiszta',
  'Utam számokban',
  'Kisebb lépések. Nagyobb élet.',
  'összes tiszta nap',
  'NA részvétel',
  'esti reflexió',
  'átlagos hangulat',
  'check-in arány',
  'data-action="open-history-detail"',
  'data-action="open-history" aria-current="page"',
].forEach((expected) => assert.ok(history.includes(expected), `history reference content is missing ${expected}`));

assert.equal((history.match(/class="history-period-card"/g) || []).length, 4, 'the source screen has four vertical, tappable sobriety-period cards');
assert.equal((history.match(/data-history-batch=/g) || []).length, 4, 'each history period card must retain its semantic batch identity');
assert.equal((history.match(/data-history-stat=/g) || []).length, 5, 'the source lower section has exactly five history measures');
assert.equal((history.match(/assets\/milestones\/milestone-[^" ]+\.svg/g) || []).length, 4, 'each period card must use a local gallery artwork asset');
assert.ok(history.includes('class="history-number-grid"'), 'the five measures must share one compact lower-row component');
assert.ok(html.includes('grid-template-columns: repeat(5, minmax(0, 1fr));'), 'the lower history measures must use the source one-row five-column layout');
assert.ok(html.includes('.history-hero-copy h1 { font-family: Georgia, "Times New Roman", serif; font-size: 30px;'), 'the history hero title must retain source serif typography');
assert.ok(html.includes('.history-period-card h2 { font-family: Georgia, "Times New Roman", serif;'), 'period card names must retain the source serif typography');
assert.ok(!history.includes('history-batch-carousel'), 'the old horizontal batch circles must not remain in Történetem');
assert.ok(!history.includes('history-current-card'), 'the old dashboard current-period card must not remain in Történetem');
assert.ok(!history.includes('history-stat-grid'), 'the old two-column statistics dashboard must not remain in Történetem');
assert.ok(!history.includes('Válaszd ki az időszakodat'), 'the old History subtitle must be replaced by source copy');
assert.ok(!history.includes('direction-pill'), 'Történetem must not add a direction selector pill');

console.log('PASS history source-reference contract');
