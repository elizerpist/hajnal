import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import test from 'node:test';

const app = path.resolve(import.meta.dirname, '..');
const navPages = ['index.html', 'pages/history.html', 'pages/timeline.html', 'pages/calendar.html', 'pages/milestones.html', 'pages/meetings.html', 'pages/path.html', 'pages/panic.html', 'pages/sponsor.html'];
const detailPages = ['pages/timeline-event.html', 'pages/initialization.html'];

test('every route document has a unique prototype identity and declared navigation ownership', () => {
  const ids = new Set();
  for (const relativePath of [...navPages, ...detailPages]) {
    const html = fs.readFileSync(path.join(app, relativePath), 'utf8');
    const id = html.match(/<meta name="prototype-id" content="([^"]+)">/)?.[1];
    assert.ok(id, `${relativePath} has a prototype ID`);
    assert.ok(!ids.has(id), `${relativePath} does not duplicate ${id}`);
    ids.add(id);
    assert.match(html, /<link rel="stylesheet" href="(?:styles|\.\.\/styles)\//, `${relativePath} uses shared styles`);
    if (navPages.includes(relativePath)) {
      assert.equal((html.match(/data-component="bottom-navigation-host"/g) || []).length, 1, `${relativePath} contains one nav host`);
      assert.match(html, /mountPageChrome\(/, `${relativePath} mounts shared navigation`);
      assert.doesNotMatch(html, /route-bottom-nav|class="bottom-nav"/, `${relativePath} contains no copied BottomNav`);
    } else {
      assert.match(html, /data-navigation="none"/, `${relativePath} intentionally declares navigation absence`);
    }
  }
});
