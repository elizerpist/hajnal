'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /const keepsPathNavigation = this\.state\.route === 'path' && \['overview', 'step', 'topics'\]\.includes\(this\.getPathNavigation\(\)\.view\);/, 'the controller must explicitly retain global navigation for Path overview, step and topics');
assert.match(html, /const isNavigationRoute = NAVIGATION_ROUTES\.has\(this\.state\.route\) && \(!isPathFocus \|\| keepsPathNavigation\);/, 'Path focus may only hide BottomNav outside the three specified Path menu views');
assert.match(html, /\.path-screen\[data-path-view="step"\]\.path-focus \.path-content\s*\{[^}]*bottom:\s*var\(--bottom-nav-h\);/, 'a step menu must reserve vertical space above BottomNav');
assert.match(html, /\.path-screen\[data-path-view="step"\] \.path-step-four-scroll\s*\{[^}]*height:\s*100%;/, 'the step menu must use the height already bounded by BottomNav and must not reserve it twice');
assert.match(html, /\.path-screen\[data-path-view="topics"\] \.path-content\s*\{[^}]*bottom:\s*var\(--bottom-nav-h\);/, 'the topics menu must reserve vertical space above BottomNav');
assert.match(html, /\.path-screen\[data-path-view="topics"\] \.path-step-four-topics-shell\s*\{[^}]*height:\s*100%;/, 'the topics shell must use its bounded parent height once BottomNav is retained');

console.log('PASS Path Step and Topics BottomNav source contract');
