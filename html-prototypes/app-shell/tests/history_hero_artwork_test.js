'use strict';

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
const periodSource = html.match(/const HISTORY_PERIODS = Object\.freeze\((\[[\s\S]*?\])\);/);

assert.ok(periodSource, 'History periods must keep one immutable asset mapping');
const periods = new Function(`return (${periodSource[1]});`)();
const expectedAssetByPeriod = Object.freeze({
  '2024-05': 'history_period_2024_05_flat.png',
  '2024-06': 'history_period_2024_06_flat.png',
  '2024-08': 'history_period_2024_08_flat.png',
  '2024-10': 'history_period_2024_10_flat.png',
  '2025-01': 'history_period_2025_01_flat.png',
  '2025-05': 'history_period_2025_05_flat.png',
  '2025-06': 'history_period_2025_06_flat.png',
  '2025-08': 'history_period_2025_08_flat.png',
  '2025-11': 'history_period_2025_11_flat.png',
  current: 'history_period_current_flat.png'
});

assert.deepEqual(periods.map((period) => period.id), Object.keys(expectedAssetByPeriod), 'all existing History periods must retain their ordering and IDs');
assert.ok(periods.every((period) => /^assets\/history\/history_period_card_(?:active_1|side_1|side_2)\.png$/.test(period.art)), 'the existing small carousel cards must keep their independent artwork');
assert.equal(new Set(periods.map((period) => period.heroArt)).size, periods.length, 'each chapter must own a unique hero artwork, not a tinted reuse');
const periodArtworkHashes = new Set();
for (const period of periods) {
  const assetName = expectedAssetByPeriod[period.id];
  assert.equal(period.heroArt, `assets/history/${assetName}`, `${period.id} must bind its dedicated flat-vector hero PNG`);
  const asset = path.join(root, 'assets', 'history', assetName);
  assert.ok(fs.existsSync(asset), `${period.id} artwork must be a project-local asset`);
  const bytes = fs.readFileSync(asset);
  assert.deepEqual(bytes.subarray(0, 8), Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]), `${period.id} artwork must be a real PNG`);
  const width = bytes.readUInt32BE(16);
  const height = bytes.readUInt32BE(20);
  assert.ok(width > height && width / height >= 1.7 && width / height <= 2.1, `${period.id} artwork must remain a wide hero asset, not a layout substitute`);
  periodArtworkHashes.add(crypto.createHash('sha256').update(bytes).digest('hex'));
}
assert.equal(periodArtworkHashes.size, periods.length, 'each period artwork must have distinct generated PNG content');

const sharedHero = path.join(root, 'assets', 'history', 'history_hero_soft.png');
assert.ok(fs.existsSync(sharedHero), 'the quiet shared History hero must remain a local PNG');
assert.deepEqual(fs.readFileSync(sharedHero).subarray(0, 8), Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]), 'the shared History hero must be a real PNG');
assert.match(html, /const HISTORY_PRESENTATION_HERO_ASSET = 'assets\/history\/history_hero_soft\.png';/, 'the pre-existing common hero owner must stay unchanged');
assert.match(html, /renderHistoryPagerSlide\(period, role\)[\s\S]*?history-period-pager-art[\s\S]*?src="\$\{escapeHtml\(period\.heroArt\)\}"/, 'only the full-period hero renderer may consume the new period-specific hero assets');

console.log('PASS History flat-vector artwork asset contract');
