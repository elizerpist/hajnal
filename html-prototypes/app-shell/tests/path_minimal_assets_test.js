'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const minimalDirectory = path.join(root, 'assets', 'path-minimal');
const expectedAssets = [
  ['overview-hero.png', 1136, 1385],
  ...Array.from({ length: 12 }, (_, index) => [`step-${String(index + 1).padStart(2, '0')}.png`, 1536, 1024]),
];

for (const [name, width, height] of expectedAssets) {
  const asset = path.join(minimalDirectory, name);
  assert.ok(fs.existsSync(asset), `${name} must exist in the canonical minimal Ösvény asset directory`);
  const bytes = fs.readFileSync(asset);
  assert.deepEqual(bytes.subarray(0, 8), Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]), `${name} must be a PNG`);
  assert.equal(bytes.readUInt32BE(16), width, `${name} must retain its required width`);
  assert.equal(bytes.readUInt32BE(20), height, `${name} must retain its required height`);
}

console.log('PASS Ösvény minimal asset dimensions contract');
