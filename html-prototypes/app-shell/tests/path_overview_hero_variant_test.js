'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const appShellPath = path.join(root, 'index.html');
const html = fs.readFileSync(appShellPath, 'utf8');
const heroAsset = path.join(root, 'assets', 'path-hero', 'overview_richer.png');

assert.ok(fs.existsSync(heroAsset), 'the optional richer Ösvény hero must be a local asset');
const heroBytes = fs.readFileSync(heroAsset);
assert.deepEqual(heroBytes.subarray(0, 8), Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]), 'the optional richer Ösvény hero must be a PNG');
assert.equal(heroBytes.readUInt32BE(16), 2048, 'the richer Ösvény hero must retain its landscape source width');
assert.equal(heroBytes.readUInt32BE(20), 768, 'the richer Ösvény hero must retain its landscape source height');

assert.match(html, /const PATH_OVERVIEW_RICHER_HERO_ASSET\s*=\s*'assets\/path-hero\/overview_richer\.png';/, 'one centralized local richer hero asset constant must exist');
assert.match(html, /overviewHeroVariant:\s*'default'/, 'new Path state must default to the existing overview hero');
assert.match(html, /pathState\.overviewHeroVariant\s*=\s*pathState\.overviewHeroVariant\s*===\s*'richer'\s*\?\s*'richer'\s*:\s*'default';/, 'legacy Path state must normalize the optional hero variant without changing work data');
assert.match(html, /getPathOverviewHeroAsset\(\)\s*\{[\s\S]*?overviewHeroVariant\s*===\s*'richer'[\s\S]*?PATH_OVERVIEW_RICHER_HERO_ASSET[\s\S]*?getPathOverviewArtwork\(\)\.hero[\s\S]*?\}/, 'one resolver must preserve original/minimal art unless the optional richer hero is selected');
assert.match(html, /togglePathOverviewHeroVariant\(\)\s*\{[\s\S]*?overviewHeroVariant\s*=\s*this\.state\.path\.overviewHeroVariant\s*===\s*'richer'\s*\?\s*'default'\s*:\s*'richer';[\s\S]*?persistPathStepWorkState\(\);[\s\S]*?renderPath\(\);[\s\S]*?\}/, 'the controller must own the one persisted hero-variant toggle');
assert.match(html, /case 'toggle-path-overview-hero-variant':\s*this\.togglePathOverviewHeroVariant\(\);\s*break;/, 'the existing delegated action switch must own the hero toggle intent');
assert.match(html, /this\.pathScreen\.dataset\.pathOverviewHeroVariant\s*=\s*this\.state\.path\.overviewHeroVariant\s*===\s*'richer'\s*\?\s*'richer'\s*:\s*'default';/, 'the rendered screen must expose its selected hero variant');
assert.match(html, /setProperty\('--path-overview-hero-art',\s*`url\("\$\{this\.getPathOverviewHeroAsset\(\)\}"\)`\);/, 'the existing hero CSS variable must read the centralized resolver');
assert.match(html, /class="path-overview-hero-variant-toggle"[\s\S]*?data-action="toggle-path-overview-hero-variant"[\s\S]*?aria-pressed="\$\{useRicherHero\}"[\s\S]*?aria-label="\$\{useRicherHero \?/, 'the existing overview action cluster must expose an accessible hero-variant button');
assert.match(html, /\.path-overview-asset-style-toggle,\s*\.path-overview-hero-variant-toggle\s*\{/, 'the optional hero control must reuse the remaining compact overview action geometry');
assert.match(html, /--chapter-hero-fade-extension:\s*80px;/, 'the shared chapter hero fade extension must have one semantic token owner');
assert.match(html, /--chapter-hero-fade-mask:\s*linear-gradient\(180deg,\s*#000 0%,\s*#000 58%,\s*rgba\(0,0,0,\.82\) 67%,\s*rgba\(0,0,0,\.49\) 79%,\s*rgba\(0,0,0,\.18\) 91%,\s*transparent 100%\);/, 'the shared chapter hero fade mask must have one semantic token owner');
assert.match(html, /--history-inline-hero-fade-extension:\s*var\(--chapter-hero-fade-extension\);/, 'History must consume the shared chapter hero fade-extension token');
assert.match(html, /--history-inline-hero-fade-mask:\s*var\(--chapter-hero-fade-mask\);/, 'History must consume the shared chapter hero fade-mask token');
assert.match(html, /\.path-screen\[data-path-view="overview"\]\[data-path-overview-hero-variant="richer"\]::before\s*\{\s*height:\s*calc\(var\(--path-overview-hero-height\) \+ var\(--chapter-hero-fade-extension\)\);\s*background-position:\s*center 27%;\s*opacity:\s*\.58;\s*transform:\s*scaleX\(-1\);\s*transform-origin:\s*center;\s*-webkit-mask-image:\s*var\(--chapter-hero-fade-mask\);\s*mask-image:\s*var\(--chapter-hero-fade-mask\);\s*\}/, 'only the selected richer Ösvény hero must extend and fade beneath the current-work card, with its own crop and mirroring');

console.log('PASS Ösvény optional richer overview hero contract');
