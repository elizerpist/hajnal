'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /overviewHeroCardVisible:\s*true/, 'Path must initialize one controller-owned current-card visibility state');
assert.match(html, /case 'toggle-path-overview-hero-card': this\.togglePathOverviewHeroCard\(\); break;/, 'the Path overview control must use one controller intent');
assert.match(html, /togglePathOverviewHeroCard\(\)\s*\{\s*this\.state\.path\.overviewHeroCardVisible\s*=\s*!this\.state\.path\.overviewHeroCardVisible;\s*this\.renderPath\(\);\s*\}/, 'the existing Path controller must be the single write path for the visibility state');
assert.match(html, /data-action="toggle-path-overview-hero-card"/, 'Path overview must render the requested custom hero-card toggle');
assert.match(html, /data-component="path-overview-hero-card-toggle"/, 'the toggle needs a stable semantic component name');
assert.match(html, /aria-pressed="\$\{this\.state\.path\.overviewHeroCardVisible\}"/, 'the toggle must expose its actual pressed state');
assert.match(html, /data-path-overview-hero-card-visible/, 'the Path screen must expose the visibility state for scoped layout CSS');
assert.match(html, /data-path-overview-hero-card-visible="false"\] \.path-overview-fast-card\s*\{[^}]*visibility:\s*hidden;[^}]*pointer-events:\s*none;/, 'hiding the hero card must preserve its grid space so the list never jumps upward');
assert.doesNotMatch(html, /data-path-overview-hero-card-visible="false"\] \.path-overview-content\s*\{[^}]*grid-template-rows:/, 'the hero-card toggle must not rewrite the list grid and shift the body');
assert.match(html, /data-component="path-overview-card-quote"/, 'the card track needs a semantic quote surface for the hidden-card state');
assert.match(html, /\.path-overview-fast-card\s*\{[^}]*grid-row:\s*1;[^}]*grid-column:\s*1;/, 'the hidden current-work card must retain the first grid cell without creating an implicit column');
assert.match(html, /\.path-overview-card-quote\s*\{[^}]*grid-row:\s*1;[^}]*grid-column:\s*1;[^}]*justify-items:\s*center;/, 'the replacement quote must overlay the first grid cell rather than create a second implicit column');
assert.match(html, /\.path-overview-card-quote p\s*\{[^}]*white-space:\s*nowrap;[^}]*text-align:\s*center;/, 'the replacement quote must stay centred on one line');
assert.match(html, /\.path-overview-content > \.path-step-list-card\s*\{[^}]*grid-row:\s*2;[^}]*grid-column:\s*1\s*\/\s*-1;[^}]*width:\s*100%;/, 'the 12-step list must span the full explicit overview grid width when the hero card is hidden');
assert.match(html, /data-path-overview-hero-card-visible="false"\] \.path-overview-header \.path-overview-quote\s*\{[^}]*visibility:\s*hidden;/, 'the original hero quote must move rather than being duplicated when the card is hidden');

console.log('PASS Path overview hero-card toggle source contract');
