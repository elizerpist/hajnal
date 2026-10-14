'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
const topicDirectory = path.join(root, 'assets', 'path-topic-minimal');
const seedMatch = html.match(/const PATH_STEP_SEEDS = Object\.freeze\(([\s\S]*?)\n      \);\n      const PATH_STEPS/);
assert.ok(seedMatch, 'topic minimal assets must use the canonical structured PATH_STEP_SEEDS source');
const stepSeeds = new Function(`return (${seedMatch[1]});`)();
const expectedAssets = stepSeeds.flatMap((step) => step.themes.map((_, index) => [
  `step-${String(step.number).padStart(2, '0')}-topic-${String(index + 1).padStart(2, '0')}.png`,
  1536,
  1024,
]));

assert.equal(expectedAssets.length, 121, 'every canonical Ösvény theme must receive a dedicated minimal illustration');
assert.match(html, /chapters:\s*Object\.freeze\(\{[\s\S]*?topics:\s*Object\.freeze\(Object\.fromEntries\(PATH_STEPS\.map/, 'PATH_ARTWORKS must centrally own minimal topic artwork beside chapter heroes and function cards');
assert.match(html, /getPathTopicCardVisual\(step, topic, index\)[\s\S]*?getPathArtworkSet\(\)\.chapters\.topics/, 'topic rendering must read the shared original/minimal artwork state rather than introduce local state');

for (const [name, width, height] of expectedAssets) {
  const asset = path.join(topicDirectory, name);
  assert.ok(fs.existsSync(asset), `${name} must exist in the canonical minimal topic asset directory`);
  const bytes = fs.readFileSync(asset);
  assert.deepEqual(bytes.subarray(0, 8), Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]), `${name} must be a PNG`);
  assert.equal(bytes.readUInt32BE(16), width, `${name} must preserve the topic-card width`);
  assert.equal(bytes.readUInt32BE(20), height, `${name} must preserve the topic-card height`);
}

console.log('PASS Ösvény minimal topic asset family and shared-style contract');
