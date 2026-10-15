'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /--screen-background-original:\s*#F9F3F7;/, 'the default light-pink surface token must remain explicit');
assert.match(html, /--screen-background:\s*var\(--screen-background-original\);/, 'all screens must use the fixed default light-pink surface');
assert.doesNotMatch(html, /data-surface-tone-option|global-surface-tone-palette|select-global-surface-tone|SURFACE_TONE_IDS|readSurfaceTone|persistSurfaceTone|renderSurfaceTone/, 'the retired global colour selector must have no UI, action, or persistence path');
assert.doesNotMatch(html, /data-surface-tone=/, 'the app shell must no longer expose a mutable surface-tone state');
assert.match(html, /\.route-screen \{[^}]*background:\s*var\(--screen-background\);/, 'route shells must inherit the one fixed surface token');
assert.match(html, /\.home-body \{[^}]*background:\s*var\(--screen-background\);/, 'the Home sheet must inherit the same fixed surface token');

console.log('PASS fixed global surface source contract');
