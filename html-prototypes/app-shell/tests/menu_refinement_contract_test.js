'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
const historyCardAsset = path.join(root, 'assets', 'history-chapter-hero', 'history_period_card.png');

assert.match(html, /\.sponsor-work-profile\s*\{[^}]*height:\s*var\(--path-overview-current-card-height\);[^}]*grid-template-columns:\s*66px minmax\(0,1fr\) 58px 58px 22px;/s, 'the work-screen profile geometry must scale its complete content set to its 102px card');
assert.match(html, /\.sponsor-work-profile \.sponsor-avatar\s*\{[^}]*width:\s*62px;[^}]*height:\s*62px;/s, 'the work-screen avatar must scale with the enlarged card');
assert.match(html, /\.sponsor-work-contact-link, \.sponsor-work-profile button\s*\{[^}]*width:\s*58px;[^}]*height:\s*58px;/s, 'the work-screen contact controls must scale with the enlarged card');

assert.match(html, /<p>Közösség\. Támogatás\.<\/p>/, 'Meetings must retain only its requested short subtitle');
assert.doesNotMatch(html, /Mindig van hely, ahol meghallgatnak\./, 'the removed Meetings slogan must not remain in the UI');

assert.doesNotMatch(html, /path-overview-height-toggle/, 'the obsolete Path overview height switch must not render or style');
assert.doesNotMatch(html, /togglePathOverviewLayout\(\)/, 'the obsolete Path overview height control must not retain a state-changing controller method');
assert.match(html, /this\.pathScreen\.dataset\.pathOverviewLayout\s*=\s*'compact';/, 'the Path overview must expose only the fixed lower/compact layout');
assert.match(html, /const displayedPathMarkup = view === 'overview'/, 'the rendered overview must own a separate displayed-markup path');
assert.ok(html.includes('pathMarkup.replace(/<button class="path-overview-history"[\\s\\S]*?<\\/button>/, \'\')'), 'the obsolete Path overview history action must be removed before the overview is displayed');
assert.match(html, /data-action="open-path-step-work-history"/, 'the retained per-step work history route must remain available from each step menu');

assert.ok(fs.existsSync(historyCardAsset), 'the expanded History period card must use a local generated decorative PNG');
const asset = fs.readFileSync(historyCardAsset);
assert.deepEqual(asset.subarray(0, 8), Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]), 'the History card artwork must be PNG');
assert.ok(asset.readUInt32BE(16) >= 1600, 'the History card artwork needs a wide, high-resolution source');
assert.ok(asset.readUInt32BE(20) >= 900, 'the History card artwork needs enough vertical detail for expansion');
assert.match(html, /history_period_card\.png/, 'the History card must consume its local decorative artwork');
assert.match(html, /\.history-chapter-info-card::before\s*\{[^}]*background-position:\s*right bottom;[^}]*background-size:\s*100% auto;/s, 'the History card artwork must crop bottom-up so expanding reveals further detail');

assert.match(html, /--main-menu-hero-view-switch-top:\s*42px;/, 'one shared token must own the History/Meetings floating selector vertical coordinate');
assert.match(html, /\.history-inline-view-switch\s*\{[^}]*top:\s*var\(--main-menu-hero-view-switch-top\);/s, 'History must consume the shared selector coordinate');
assert.match(html, /\.meetings-inline-view-switch\s*\{[^}]*top:\s*var\(--main-menu-hero-view-switch-top\);/s, 'Meetings must consume the shared selector coordinate');

assert.doesNotMatch(html, /global-surface-tone-palette/, 'the Home global surface selector must not remain in markup or code');
assert.doesNotMatch(html, /select-global-surface-tone/, 'the removed Home surface selector action must not remain delegated');
assert.match(html, /--screen-background:\s*var\(--screen-background-original\);/, 'the Home surface must remain fixed to the default light-pink background token');

assert.match(html, /\.sponsor-detail-content\s*\{[^}]*bottom:\s*var\(--bottom-nav-h\);/s, 'Sponsor detail content must reserve the single shared BottomNav');
assert.doesNotMatch(html, /sponsor-save-button/, 'Sponsor details must not retain a manual save CTA');
assert.match(html, /autoSaveSponsorDetails\([^)]*\)\s*\{[\s\S]*?this\.state\.sponsor\s*=/, 'the controller must own automatic Sponsor detail persistence');

console.log('PASS menu refinement contract');
