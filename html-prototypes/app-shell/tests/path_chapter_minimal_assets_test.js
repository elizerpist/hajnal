'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
const minimalDirectory = path.join(root, 'assets', 'path-chapter-minimal');
const cardKinds = ['topics', 'answers', 'sponsor-review', 'summary'];
const expectedAssets = [
  ...Array.from({ length: 12 }, (_, index) => [
    `step-${String(index + 1).padStart(2, '0')}-hero.png`,
    index === 3 ? 1136 : 1536,
    index === 3 ? 1385 : 1024,
  ]),
  ...Array.from({ length: 12 }, (_, stepIndex) => cardKinds.map((kind) => [
    `step-${String(stepIndex + 1).padStart(2, '0')}-${kind}.png`,
    1536,
    1024,
  ])).flat(),
];

assert.match(html, /const PATH_ARTWORKS = Object\.freeze\(/, 'one neutral artwork resolver must own both Overview and chapter visual modes');
assert.match(html, /getPathChapterMenuAssets\(step\)/, 'chapter function cards must resolve through the shared style-aware helper');
assert.match(html, /getPathArtworkSet\(\)/, 'chapter heroes and Overview artwork must share the same AssetStyleMode state source');

for (const [name, width, height] of expectedAssets) {
  const asset = path.join(minimalDirectory, name);
  assert.ok(fs.existsSync(asset), `${name} must exist in the canonical minimal chapter asset directory`);
  const bytes = fs.readFileSync(asset);
  assert.deepEqual(bytes.subarray(0, 8), Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]), `${name} must be a PNG`);
  assert.equal(bytes.readUInt32BE(16), width, `${name} must retain its required width`);
  assert.equal(bytes.readUInt32BE(20), height, `${name} must retain its required height`);
}

console.log('PASS Ösvény minimal chapter asset dimensions and shared-resolver contract');
