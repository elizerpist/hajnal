#!/usr/bin/env node
const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const shellRoot = path.resolve(__dirname, '..');
const html = fs.readFileSync(path.join(shellRoot, 'index.html'), 'utf8');
const backgroundsRoot = path.join(shellRoot, 'assets', 'backgrounds');

const requiredBackgrounds = [
  ['index1.png', 'ae4e7c9bd6b893b7ea513d2ff619cc3a1012872a3eec0c104005adbdabacac80'],
  ['panik1.png', '1c18b94a7ff841d02eec105b71c1cd04b629e021fe98e4c00cf53b4dee7a2672'],
  ['galery2.png', '0f4cb950b3910c4891211f62e3d6684d12fe72e7e1e225998b16db78ca5ee163'],
];

for (const [fileName, expectedHash] of requiredBackgrounds) {
  const assetPath = path.join(backgroundsRoot, fileName);
  assert.ok(fs.existsSync(assetPath), `missing required local background asset: ${fileName}`);
  const image = fs.readFileSync(assetPath);
  assert.equal(image.toString('ascii', 1, 4), 'PNG', `${fileName} must remain a PNG`);
  assert.equal(image.readUInt32BE(16), 853, `${fileName} must keep its source width`);
  assert.equal(image.readUInt32BE(20), 1843, `${fileName} must keep its source height`);
  assert.equal(crypto.createHash('sha256').update(image).digest('hex'), expectedHash, `${fileName} must remain the supplied source asset`);
}

assert.match(html, /<img class="home-hero-image" src="assets\/backgrounds\/index1\.png" alt="" loading="eager">/, 'Home must use supplied index1.png as its real background image');
assert.match(html, /\.panic-screen\s*\{[^}]*background-image:\s*url\("assets\/backgrounds\/panik1\.png"\)[^}]*background-size:\s*cover[^}]*background-position:\s*center top/s, 'Pánik must use supplied panik1.png as a cover background');
assert.match(html, /\.milestone-screen\s*\{[^}]*background-image:\s*url\("assets\/backgrounds\/galery2\.png"\)[^}]*background-size:\s*cover[^}]*background-position:\s*center top/s, 'Mérföldkövek must use supplied galery2.png as a cover background');

console.log('PASS supplied Home, Pánik, and Mérföldkő background asset contract');
