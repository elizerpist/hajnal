'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(
  html,
  /\.bottom-nav\[hidden\],\s*\.route-bottom-nav\[hidden\]\s*\{[^}]*display:\s*none\s*!important/s,
  'the inactive navigation copy must be removed from the layout, not only visually covered',
);
assert.match(
  html,
  /this\.mainNavigation\s*=\s*root\.querySelector\('\[data-component="bottom-navigation"\]'\)/,
  'the controller must own the one home navigation surface',
);
assert.match(
  html,
  /this\.routeNavigations\s*=\s*Array\.from\(root\.querySelectorAll\('\.route-bottom-nav'\)\)/,
  'route navigation surfaces must be registered by the same controller',
);
assert.match(
  html,
  /this\.mainNavigation\.hidden\s*=\s*!isHome/,
  'the home navigation must be hidden while a route navigation is active',
);
assert.match(
  html,
  /nav\.hidden\s*=\s*!\(\s*!isHome\s*&&\s*ownerRoute\s*===\s*this\.state\.route/s,
  'the controller must expose only the active route navigation',
);

console.log('PASS app-shell single visible bottom navigation contract');
