'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /const keepsPathNavigation = this\.state\.route === 'path';/, 'the controller must retain the one shared BottomNav for every Ösvény view');
assert.match(html, /const isNavigationRoute = NAVIGATION_ROUTES\.has\(this\.state\.route\) && \(!isPathFocus \|\| keepsPathNavigation\);/, 'Path focus must never hide BottomNav in an Ösvény submenu');
assert.match(html, /\.path-screen\.path-focus \.path-content\s*\{[^}]*bottom:\s*var\(--bottom-nav-h\);/, 'every focused Ösvény submenu must reserve BottomNav height');
assert.match(html, /\.path-screen\[data-path-view="step"\]\.path-focus \.path-content\s*\{[^}]*bottom:\s*var\(--bottom-nav-h\);/, 'a step menu must reserve vertical space above BottomNav');
assert.match(html, /\.path-screen\[data-path-view="step"\] \.path-step-four-scroll\s*\{[^}]*height:\s*100%;/, 'the step menu must use the height already bounded by BottomNav and must not reserve it twice');
assert.match(html, /\.path-screen\[data-path-view="topics"\] \.path-content\s*\{[^}]*bottom:\s*var\(--bottom-nav-h\);/, 'the topics menu must reserve vertical space above BottomNav');
assert.match(html, /\.path-screen\[data-path-view="topics"\] \.path-step-four-topics-shell\s*\{[^}]*height:\s*100%;/, 'the topics shell must use its bounded parent height once BottomNav is retained');
assert.match(html, /\.path-screen\[data-path-view="question"\]\[data-path-step="step-4"\]\.path-focus \.path-content\s*\{[^}]*bottom:\s*var\(--bottom-nav-h\);/, 'the focused Step 4 question editor must reserve BottomNav height too');
assert.match(html, /\.path-screen\[data-path-view="step"\] \.path-step-four-menu-grid\s*\{[^}]*margin-bottom:\s*24px;/, 'the four lower chapter actions must keep breathing room above BottomNav');

console.log('PASS Path Step and Topics BottomNav source contract');
