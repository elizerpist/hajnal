import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import test from 'node:test';

const app = path.resolve(import.meta.dirname, '..');
const read = (file) => fs.readFileSync(path.join(app, file), 'utf8');

test('main local assets remain attached to their owning route documents', () => {
  assert.match(read('index.html'), /assets\/backgrounds\/index1\.png/);
  assert.match(read('pages/history.html'), /assets\/hero\/hero_m\.png/);
  assert.match(read('pages/timeline-event.html'), /assets\/hero\/timelinehero\.png/);
  assert.match(read('pages/milestones.html'), /assets\/milestones\/milestone-30\.svg/);
  assert.match(read('pages/initialization.html'), /assets\/initialization\/welcome_svg\.svg/);
});

test('core user flows remain reachable through local documents', () => {
  assert.match(read('index.html'), /pages\/panic\.html/);
  assert.match(read('pages/history.html'), /href="timeline\.html"/);
  assert.match(read('pages/timeline.html'), /href="calendar\.html"/);
  assert.match(read('pages/timeline.html'), /href="timeline-event\.html"/);
  assert.match(read('pages/panic.html'), /15 perces túlélőcsomag/);
  assert.match(read('pages/path.html'), /12 lépés/);
  assert.match(read('pages/meetings.html'), /Online gyűlés/);
});

test('History retains its ten independently tappable sobriety periods after route extraction', () => {
  const history = read('pages/history.html');
  assert.equal((history.match(/class="history-period"/g) || []).length, 10);
  assert.equal((history.match(/href="timeline\.html"/g) || []).length, 10);
});
