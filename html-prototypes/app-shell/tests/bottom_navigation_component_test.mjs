import assert from 'node:assert/strict';
import test from 'node:test';
import { pathToFileURL } from 'node:url';

const componentUrl = pathToFileURL(new URL('../components/bottom-navigation.mjs', import.meta.url).pathname).href;

test('BottomNav mounts exactly one local-link navigation for the active route', async () => {
  const { mountBottomNavigation } = await import(componentUrl);
  const host = { innerHTML: '<nav>stale duplicate</nav>' };

  mountBottomNavigation(host, 'history');
  assert.equal((host.innerHTML.match(/<nav\b/g) || []).length, 1, 'a mount replaces stale navigation instead of appending');
  assert.match(host.innerHTML, /data-component="bottom-navigation"/);
  assert.match(host.innerHTML, /href="history\.html"[^>]*aria-current="page"/);
  assert.match(host.innerHTML, /href="\.\.\/index\.html"/);
  assert.match(host.innerHTML, /href="path\.html"/);
  assert.match(host.innerHTML, /href="meetings\.html"/);

  mountBottomNavigation(host, 'timeline');
  assert.equal((host.innerHTML.match(/<nav\b/g) || []).length, 1, 're-mounting cannot create a second BottomNav');
  assert.match(host.innerHTML, /href="history\.html"[^>]*aria-current="page"/, 'History remains the selected parent for Timeline');
});

test('BottomNav rejects an unknown active route instead of rendering an inert nav', async () => {
  const { mountBottomNavigation } = await import(componentUrl);
  assert.throws(() => mountBottomNavigation({ innerHTML: '' }, 'unknown'), /Unknown BottomNav route/);
});

test('Home document receives links relative to the app-shell root', async () => {
  const { mountBottomNavigation } = await import(componentUrl);
  const host = { innerHTML: '' };
  mountBottomNavigation(host, 'home', { rootDocument: true });
  assert.match(host.innerHTML, /href="index\.html"[^>]*aria-current="page"/);
  assert.match(host.innerHTML, /href="pages\/history\.html"/);
});
