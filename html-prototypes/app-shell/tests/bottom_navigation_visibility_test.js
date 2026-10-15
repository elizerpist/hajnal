'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

function staticBodyMarkup(htmlSource) {
  const bodyStart = htmlSource.indexOf('<body>');
  const scriptStart = htmlSource.indexOf('<script>', bodyStart);
  assert.notEqual(bodyStart, -1, 'the prototype must have a body');
  assert.notEqual(scriptStart, -1, 'the interactive script must follow the static app markup');
  return htmlSource.slice(bodyStart + '<body>'.length, scriptStart);
}

function assertWellNestedStaticMarkup(markup) {
  const voidElements = new Set(['area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'param', 'source', 'track', 'use', 'path', 'rect', 'circle', 'ellipse', 'line', 'polyline', 'polygon', 'stop', 'wbr']);
  const stack = [];
  const tags = /<\/?([A-Za-z][\w:-]*)(?:\s[^<>]*?)?\s*\/?\s*>/g;
  let match;

  while ((match = tags.exec(markup))) {
    const rawTag = match[0];
    const tagName = match[1].toLowerCase();
    const isClosingTag = rawTag.startsWith('</');
    const isSelfClosing = rawTag.endsWith('/>') || voidElements.has(tagName);
    const line = markup.slice(0, match.index).split('\n').length;

    if (isClosingTag) {
      assert.equal(
        stack.at(-1)?.tagName,
        tagName,
        `static app markup must be well nested at body line ${line}; an unmatched close re-parents routes outside the app frame`,
      );
      stack.pop();
    } else if (!isSelfClosing) {
      stack.push({ tagName, line });
    }
  }

  assert.equal(stack.length, 0, 'the static app markup must close every app-frame child before the script');
}

assertWellNestedStaticMarkup(staticBodyMarkup(html));

assert.match(
  html,
  /<div class="app-frame home-collapsed-screen"[^>]*role="application"/,
  'the outer phone frame must not be a main element: nested route mains otherwise close it in mobile HTML parsing',
);
assert.doesNotMatch(
  html,
  /<main class="app-frame/,
  'the outer frame must stay a neutral structural container while route content owns main semantics',
);

assert.match(
  html,
  /\.bottom-nav\[hidden\]\s*\{[^}]*display:\s*none\s*!important/s,
  'the one navigation surface must be removed from layout when a child route intentionally has no navigation',
);
assert.match(
  html,
  /\.bottom-nav\s*\{[^}]*z-index:\s*90/s,
  'the shared BottomNav must render above route screens instead of being covered by them',
);
assert.match(
  html,
  /\.route-screen\s*\{[^}]*z-index:\s*80/s,
  'route content must stay below the shared BottomNav layer',
);
assert.doesNotMatch(
  html,
  /route-bottom-nav/,
  'route screens must not duplicate the physical BottomNav; the app frame owns exactly one navigation surface',
);
assert.equal(
  (html.match(/<nav class="bottom-nav"/g) || []).length,
  1,
  'there must be exactly one physical BottomNav in the complete document',
);
assert.match(
  html,
  /const NAVIGATION_ROUTES = new Set\(\['home', 'milestones', 'history', 'history-detail', 'meetings', 'meeting-detail', 'path', 'panic', 'sponsor', 'sponsor-work', 'sponsor-next', 'sponsor-details'\]\);/,
  'one route policy must keep the shared BottomNav visible on the requested meeting detail route',
);
assert.match(
  html,
  /this\.mainNavigation\.hidden\s*=\s*!isNavigationRoute/,
  'the controller must toggle the single navigation surface from the route policy',
);
assert.doesNotMatch(
  html,
  /this\.routeNavigations/,
  'the controller must not retain a second navigation ownership collection',
);

console.log('PASS app-shell structural boundary and single BottomNav ownership contract');
