'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const appShellPath = path.join(__dirname, '..', 'index.html');
const html = fs.readFileSync(appShellPath, 'utf8');

assert.match(html, /--main-menu-hero-copy-top:\s*48px;/, 'one shared token must own the Sponsor-aligned hero title top position');
assert.match(html, /--main-menu-hero-copy-left:\s*26px;/, 'one shared token must own the Sponsor-aligned hero title left position');
assert.match(html, /--main-menu-hero-title-color:\s*#07132C;/, 'one shared token must own the main menu title color');
assert.match(html, /--main-menu-hero-title-size:\s*32px;/, 'one shared token must own the main menu title size');
assert.match(html, /--main-menu-hero-subtitle-margin-top:\s*7px;/, 'one shared token must own the title/subtitle relationship');
assert.match(html, /--main-menu-hero-subtitle-size:\s*14px;/, 'one shared token must own the secondary copy size');

for (const selector of ['.sponsor-hero-copy', '.meetings-hero-copy']) {
  const pattern = new RegExp(`${selector.replace('.', '\\.') }\\s*\\{[^}]*top:\\s*var\\(--main-menu-hero-copy-top\\);[^}]*left:\\s*var\\(--main-menu-hero-copy-left\\);`, 's');
  assert.match(html, pattern, `${selector} must consume the shared Sponsor-aligned hero-copy geometry`);
}

for (const selector of ['.sponsor-hero-copy h1', '.meetings-hero-copy h1']) {
  const pattern = new RegExp(`${selector.replace('.', '\\.') }\\s*\\{[^}]*color:\\s*var\\(--main-menu-hero-title-color\\);[^}]*font-size:\\s*var\\(--main-menu-hero-title-size\\);`, 's');
  assert.match(html, pattern, `${selector} must consume the shared title color and size`);
}

assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-hero-copy\s*\{[^}]*top:\s*var\(--main-menu-hero-copy-top\);[^}]*left:\s*var\(--main-menu-hero-copy-left\);/, 'the active Történetem hero must consume the shared title position');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \.history-hero-copy h1\s*\{[^}]*color:\s*var\(--main-menu-hero-title-color\);[^}]*font-size:\s*var\(--main-menu-hero-title-size\);/, 'the active Történetem hero must consume the shared title visual tokens');
assert.match(html, /\.path-overview-heading\s*\{[^}]*padding-top:\s*var\(--main-menu-hero-path-heading-offset\);/, 'the Ösvény title must adapt to the shared title baseline from its status-row layout');
assert.match(html, /\.path-overview-header h1\s*\{[^}]*color:\s*var\(--main-menu-hero-title-color\);[^}]*font-size:\s*var\(--main-menu-hero-title-size\);/, 'the Ösvény title must consume the shared title color and size');

for (const selector of ['.sponsor-hero-copy p', '.meetings-hero-copy p', '.history-screen[data-history-workspace="inline"] .history-hero-copy p', '.path-overview-heading p']) {
  const escaped = selector.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').replace(/\\ /g, '\\s+');
  const pattern = new RegExp(`${escaped}\\s*\\{[^}]*margin:\\s*var\\(--main-menu-hero-subtitle-margin-top\\) 0 0;[^}]*font-size:\\s*var\\(--main-menu-hero-subtitle-size\\);`, 's');
  assert.match(html, pattern, `${selector} must preserve the shared secondary copy relationship and size`);
}

assert.doesNotMatch(html, /path-overview-quote/, 'the Ösvény overview hero must not render or style a separate quote');
assert.doesNotMatch(html, /const overviewQuote\s*=/, 'the removed Ösvény quote must not remain as an unused render value');
assert.match(html, /<div class="path-overview-heading"><h1>Ösvény<\/h1><p>Lépésről lépésre közelebb önmagadhoz\.<\/p><\/div><div class="path-overview-actions">/, 'the Ösvény hero must keep only title, subtitle, and its existing action cluster');

console.log('PASS main-menu hero title alignment contract');
