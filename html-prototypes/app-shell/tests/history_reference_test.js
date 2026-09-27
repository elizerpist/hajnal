'use strict';

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
const heroPath = path.join(root, 'assets', 'hero', 'hero_m.png');
const compactHeroPath = path.join(root, 'assets', 'hero', 'hero_s.png');
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
assert.ok(fs.existsSync(compactHeroPath), 'the supplied compact history hero asset must be copied into the canonical app-shell assets');
assert.equal(
  crypto.createHash('sha256').update(fs.readFileSync(compactHeroPath)).digest('hex'),
  'a47180c7ef158ebcbf26cbee5a9792dc719365ddce4db9241fa8ff881861f5f0',
  'compact history hero must remain byte-identical to the supplied hero_s.png',
);

[
  'class="history-hero"',
  'src="assets/hero/hero_m.png"',
  'data-component="history-hero-image"',
  'data-action="toggle-history-hero-variant"',
  'data-component="history-hero-variant-toggle"',
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
  'Júniusi folytatás',
  'Őszi újrakezdés',
  'Tavaszi újrakezdés',
  'Nyár végi időszak',
  'Téli kitartás',
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

assert.equal((history.match(/class="history-period-card"/g) || []).length, 10, 'History must provide ten tappable sobriety-period cards so its sole scroll region has meaningful test depth');
assert.equal((history.match(/data-history-batch=/g) || []).length, 10, 'each of the ten history period cards must retain a semantic batch identity');
assert.equal((history.match(/data-history-stat=/g) || []).length, 5, 'the source lower section has exactly five history measures');
assert.equal((history.match(/assets\/milestones\/milestone-[^" ]+\.svg/g) || []).length, 10, 'each of the ten period cards must use a local gallery artwork asset');
assert.ok(history.includes('class="history-number-grid"'), 'the five measures must share one compact lower-row component');
assert.equal((history.match(/class="history-number-grid"/g) || []).length, 1, 'the compact/expanded metric presentation must reuse the one existing metric payload');
assert.ok(history.includes('data-action="toggle-history-metrics"'), 'the compact history footer must expose one semantic metric expansion control');
assert.ok(history.includes('data-component="history-metrics-toggle"'), 'the metric control must have a stable controller-owned component contract');
assert.ok(history.includes('class="history-period-scroll"'), 'only the period-card list must own its own scroll area');
assert.ok(history.includes('data-history-batch="2025-06"'), 'the recovered June 2025 period must remain available as the fifth card');
assert.ok(history.indexOf('history-period-intro') < history.indexOf('history-period-scroll') && history.indexOf('history-period-scroll') < history.indexOf('history-number-summary'), 'the fixed quote, scrollable period list, and fixed number summary must stay in visual order');
assert.ok(html.includes('grid-template-columns: repeat(5, minmax(0, 1fr));'), 'the lower history measures must use the source one-row five-column layout');
assert.ok(html.includes('.history-content { position: absolute; z-index: 2; top: 224px; right: 0; bottom: var(--bottom-nav-h); left: 0; display: grid; grid-template-rows: auto minmax(0, 1fr) auto; overflow: hidden; padding: 24px 18px 17px;'), 'the quote and number summary must be fixed by the History three-row layout');
assert.ok(html.includes('.history-period-scroll { min-height: 0; overflow-y: auto;'), 'the period list must be the sole scrolling History region');
assert.ok(html.includes('.history-hero-copy h1 { font-family: Georgia, "Times New Roman", serif; font-size: 30px;'), 'the history hero title must retain source serif typography');
assert.ok(html.includes('.history-screen[data-history-hero-variant="compact"] .history-hero { height: 185px; }'), 'the compact layout must use the hero_s aspect-derived smaller hero');
assert.ok(html.includes('.history-screen[data-history-hero-variant="compact"] .history-content { top: 154px;'), 'the compact layout must raise the body card and grow its sole scroll area');
assert.ok(html.includes('.history-screen[data-history-hero-variant="compact"][data-history-metrics-expanded="false"] .history-number-grid'), 'the compact history layout must collapse the one metric grid without duplicating it');
assert.ok(html.includes('.history-screen[data-history-hero-variant="compact"][data-history-metrics-expanded="true"] .history-number-grid'), 'the compact history metric grid must expand upward into the body/scroll boundary');
assert.ok(html.includes('.history-period-card h2 { font-family: Georgia, "Times New Roman", serif;'), 'period card names must retain the source serif typography');
assert.ok(!history.includes('history-batch-carousel'), 'the old horizontal batch circles must not remain in Történetem');
assert.ok(!history.includes('history-current-card'), 'the old dashboard current-period card must not remain in Történetem');
assert.ok(!history.includes('history-stat-grid'), 'the old two-column statistics dashboard must not remain in Történetem');
assert.ok(!history.includes('Válaszd ki az időszakodat'), 'the old History subtitle must be replaced by source copy');
assert.ok(!history.includes('direction-pill'), 'Történetem must not add a direction selector pill');

console.log('PASS history source-reference contract');
