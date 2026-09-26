'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const htmlPath = path.join(__dirname, '..', 'index.html');
const assetDirectory = path.join(__dirname, '..', '..', '..', 'docs', 'prototypes', 'assets');

assert.ok(fs.existsSync(htmlPath), 'canonical offline HTML must exist');

const html = fs.readFileSync(htmlPath, 'utf8');

assert.match(html, /<meta name="prototype-id" content="hajnal\/offline-ui">/);
assert.match(html, /<meta name="prototype-status" content="current">/);
assert.doesNotMatch(html, /assets\//);
assert.doesNotMatch(html, /(?:src|href)\s*=\s*["']https?:\/\//i);
assert.doesNotMatch(html, /url\(\s*["']?https?:\/\//i);
assert.doesNotMatch(html, /fetch\s*\(/);
assert.match(html, /data:image\/svg\+xml;base64,/);
assert.doesNotMatch(html, /welcome-svg-source|hajnalWelcomeLighting/);
[
  'hero_fullscreen2_svg.svg',
  'hero_fullscreen_svg.svg',
  'hero_m_svg.svg',
  'hero_s_svg.svg',
  'hero_xl_svg.svg',
  'hurray_svg.svg',
  'logo_svg.svg',
  'welcome_svg.svg',
].forEach((asset) => {
  const embeddedAsset = `data:image/svg+xml;base64,${fs.readFileSync(path.join(assetDirectory, asset)).toString('base64')}`;
  assert.ok(html.includes(embeddedAsset), `${asset} must be embedded without alteration`);
});

console.log('PASS offline single-file contract');
