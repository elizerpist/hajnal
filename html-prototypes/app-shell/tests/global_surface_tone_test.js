'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /--screen-background-original:\s*#F9F3F7;/, 'the original app surface must have one semantic token');
assert.match(html, /--screen-background-index:\s*#FDF5F8;/, 'the exact prototype-index surface must have one semantic token');
assert.match(html, /--screen-background-blush:\s*#F4E8F1;/, 'the first more-saturated surface must have one semantic token');
assert.match(html, /--screen-background-mauve:\s*#ECD9E9;/, 'the second more-saturated surface must have one semantic token');
assert.match(html, /--screen-background-lavender:\s*#E0C9E2;/, 'the strongest surface must have one semantic token');
assert.match(html, /--screen-background:\s*var\(--screen-background-original\);/, 'the original surface must remain the default');
assert.match(html, /\.app-frame\[data-surface-tone="index"\]\s*\{[^}]*--screen-background:\s*var\(--screen-background-index\);/, 'the app frame must project the selected surface through the one shared token');
assert.match(html, /\.app-frame\[data-surface-tone="blush"\]\s*\{[^}]*--screen-background:\s*var\(--screen-background-blush\);/, 'the app frame must project the first more-saturated surface through the shared token');
assert.match(html, /\.app-frame\[data-surface-tone="mauve"\]\s*\{[^}]*--screen-background:\s*var\(--screen-background-mauve\);/, 'the app frame must project the second more-saturated surface through the shared token');
assert.match(html, /\.app-frame\[data-surface-tone="lavender"\]\s*\{[^}]*--screen-background:\s*var\(--screen-background-lavender\);/, 'the app frame must project the strongest surface through the shared token');

assert.match(html, /data-component="global-surface-tone-palette"/, 'one main-menu surface-tone palette is required');
const paletteMarkupStart = html.indexOf('data-component="global-surface-tone-palette"');
const paletteMarkupEnd = html.indexOf('</div>', paletteMarkupStart);
const paletteMarkup = html.slice(paletteMarkupStart, paletteMarkupEnd);
assert.equal((paletteMarkup.match(/data-surface-tone-option/g) || []).length, 5, 'the palette must expose exactly five selectable swatches');
assert.match(html, /class="home-surface-tone-palette"[^>]*role="radiogroup"/, 'the palette must expose one accessible radio group');
assert.match(html, /\.home-surface-tone-palette \{[^}]*top:\s*54px;[^}]*display:\s*flex;/, 'the palette must sit directly below the main-menu controls in one row');
assert.match(html, /\.home-surface-tone-option\[aria-checked="true"\]\s*\{[^}]*transform:/, 'the active swatch must be visually raised');
assert.match(html, /this\.surfaceToneOptions\s*=\s*\[\.\.\.root\.querySelectorAll\('\[data-surface-tone-option\]'\)\];/, 'the controller must own the one palette option collection');
assert.match(html, /surfaceTone:\s*this\.readSurfaceTone\(\)/, 'surface tone must be controller-owned state');
assert.match(html, /this\.renderSurfaceTone\(\);/, 'the selected mode must be rendered during initialization');
assert.match(html, /case 'select-global-surface-tone': this\.selectGlobalSurfaceTone\(event\.target\.closest\('\[data-surface-tone-option\]'\)\?\.dataset\.surfaceTone\); break;/, 'only the central action dispatch may select a palette tone');
assert.match(html, /const SURFACE_TONE_IDS = Object\.freeze\(\['index', 'original', 'blush', 'mauve', 'lavender'\]\);/, 'the five valid palette modes must have one shared controller catalogue');
assert.match(html, /readSurfaceTone\(\)\s*\{\s*try \{ const storedTone = window\.localStorage\?\.getItem\('hajnal\.surfaceTone'\); return SURFACE_TONE_IDS\.includes\(storedTone\) \? storedTone : 'original'; \} catch \(_\) \{ return 'original'; \}/, 'only a valid persisted palette mode may override the original fallback');
assert.match(html, /persistSurfaceTone\(\)\s*\{\s*try \{ window\.localStorage\?\.setItem\('hajnal\.surfaceTone', this\.state\.surfaceTone\); \}/, 'the chosen mode must persist through the controller');
assert.match(html, /renderSurfaceTone\(\)\s*\{[^}]*this\.root\.dataset\.surfaceTone\s*=\s*surfaceTone;[^}]*this\.surfaceToneOptions\.forEach\(\(option\) => option\.setAttribute\('aria-checked', String\(option\.dataset\.surfaceTone === surfaceTone\)\)\);/s, 'rendering must project the state to the app frame and every accessible swatch');
assert.match(html, /selectGlobalSurfaceTone\(surfaceTone\)\s*\{\s*if \(!SURFACE_TONE_IDS\.includes\(surfaceTone\)\) return;\s*this\.state\.surfaceTone\s*=\s*surfaceTone;\s*this\.persistSurfaceTone\(\);\s*this\.renderSurfaceTone\(\);\s*\}/, 'selection must have one validated state-write, persistence, and render path');

assert.match(html, /\.route-screen \{[^}]*background:\s*var\(--screen-background\);/, 'ordinary route shells must follow the shared selected surface');
assert.match(html, /\.home-body \{[^}]*background:\s*var\(--screen-background\);/, 'the main-menu sheet must follow the shared selected surface');
assert.match(html, /\.history-screen \{ background:\s*var\(--screen-background\); \}/, 'History must follow the shared selected surface');
assert.match(html, /\.history-screen\[data-history-workspace="inline"\] \{[^}]*--history-inline-body-surface:\s*var\(--screen-background\);/, 'inline History must retain its single shared fade destination surface');
assert.match(html, /\.history-detail-screen, \.meetings-screen \{ background:\s*var\(--screen-background\); \}/, 'History submenus and meetings must follow the shared selected surface');
assert.match(html, /\.sponsor-screen, \.sponsor-work-screen, \.sponsor-calendar-screen \{ background:\s*var\(--screen-background\);/, 'Sponsor main, workspace, and calendar routes must follow the shared selected surface');
assert.match(html, /\.meetings-screen, \.meeting-detail-screen, \.meeting-editor-screen \{ background:\s*var\(--screen-background\);/, 'all meeting submenus must follow the shared selected surface');
assert.match(html, /\.path-screen\[data-path-view="overview"\] \{ background:\s*var\(--screen-background\);/, 'Path overview must follow the shared selected surface');
assert.match(html, /\.path-screen\[data-path-view="step"\], \.path-screen\[data-path-view="topics"\], \.path-screen\[data-path-view="topic"\], \.path-screen\[data-path-view="question"\], \.path-screen\[data-path-view="answers"\], \.path-screen\[data-path-view="sponsor-review"\], \.path-screen\[data-path-view="step-summary"\] \{ background:\s*var\(--screen-background\);/, 'every Path submenu must follow the shared selected surface');

assert.match(html, /--hero-art-vertical-fade-mask:\s*linear-gradient\(180deg,[^;]+transparent 100%\)/, 'the shared Path alpha fade mask must remain');
assert.match(html, /--history-inline-hero-fade-mask:\s*linear-gradient\(180deg,[^;]+transparent 100%\)/, 'the inline History alpha fade mask must remain');
assert.match(html, /\.path-step-four-art::after \{[^}]*background:\s*linear-gradient\(transparent, var\(--screen-background\)\);/, 'Path artwork must still fade into the selected shared surface');
assert.match(html, /\.history-period-pager-art \{[^}]*-webkit-mask-image:\s*var\(--history-inline-hero-fade-mask\);[^}]*mask-image:\s*var\(--history-inline-hero-fade-mask\);/, 'History pager artwork must retain its alpha fade mask');

const surfaceToneCatalogueStart = html.indexOf("      const SURFACE_TONE_IDS = Object.freeze(['index', 'original', 'blush', 'mauve', 'lavender']);");
const controllerStart = html.indexOf('      class HomeInteractionController {');
const controllerEnd = html.indexOf('      new HomeInteractionController(document.querySelector(\'.app-frame\'));', controllerStart);
assert.ok(surfaceToneCatalogueStart >= 0 && controllerStart >= 0 && controllerEnd > controllerStart, 'the controller must remain independently evaluable with its one palette catalogue');
const storedValues = new Map();
const controllerSandbox = {
  window: {
    localStorage: {
      getItem: (key) => storedValues.get(key) ?? null,
      setItem: (key, value) => storedValues.set(key, value),
    },
  },
};
controllerSandbox.globalThis = controllerSandbox;
const controllerSource = html
  .slice(surfaceToneCatalogueStart, controllerEnd)
  .replace('class HomeInteractionController {', 'globalThis.SurfaceToneController = class HomeInteractionController {');
vm.runInNewContext(controllerSource, controllerSandbox);
const controller = Object.create(controllerSandbox.SurfaceToneController.prototype);
const attributes = new Map();
controller.root = { dataset: {} };
controller.surfaceToneOptions = ['index', 'original', 'blush', 'mauve', 'lavender'].map((surfaceTone) => ({
  dataset: { surfaceTone },
  setAttribute: (key, value) => attributes.set(`${surfaceTone}:${key}`, value),
}));
controller.state = { surfaceTone: controller.readSurfaceTone() };

assert.equal(controller.state.surfaceTone, 'original', 'missing persistence must start in the original mode');
storedValues.set('hajnal.surfaceTone', 'index');
assert.equal(controller.readSurfaceTone(), 'index', 'the valid stored index mode must restore');
storedValues.set('hajnal.surfaceTone', 'lavender');
assert.equal(controller.readSurfaceTone(), 'lavender', 'the valid strongest palette mode must restore');
storedValues.set('hajnal.surfaceTone', 'unexpected');
assert.equal(controller.readSurfaceTone(), 'original', 'an invalid stored value must fall back to original');
controller.state.surfaceTone = 'original';
controller.renderSurfaceTone();
assert.equal(controller.root.dataset.surfaceTone, 'original', 'original mode must project to the app frame');
assert.equal(attributes.get('original:aria-checked'), 'true', 'original mode must make exactly its swatch active');
assert.equal(attributes.get('index:aria-checked'), 'false', 'original mode must leave the index swatch inactive');
controller.selectGlobalSurfaceTone('mauve');
assert.equal(controller.state.surfaceTone, 'mauve', 'selection must choose the requested palette surface');
assert.equal(storedValues.get('hajnal.surfaceTone'), 'mauve', 'selection must persist the requested palette surface');
assert.equal(controller.root.dataset.surfaceTone, 'mauve', 'selection must project the palette surface to the app frame');
assert.equal(attributes.get('mauve:aria-checked'), 'true', 'selection must make the chosen swatch active');
assert.equal(attributes.get('original:aria-checked'), 'false', 'selection must make the former active swatch inactive');
controller.selectGlobalSurfaceTone('invalid');
assert.equal(controller.state.surfaceTone, 'mauve', 'an unknown palette value must not mutate the selected surface');

console.log('PASS global surface-tone source contract');
