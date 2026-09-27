import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';
import { pathToFileURL } from 'node:url';

const root = new URL('..', import.meta.url);
const insightUrl = pathToFileURL(new URL('../scripts/history-insights.mjs', import.meta.url).pathname).href;

function fakeInsightRoot() {
  const listeners = {};
  const trigger = {
    attributes: new Map([['aria-expanded', 'false']]),
    addEventListener(name, callback) { listeners[name] = callback; },
    setAttribute(name, value) { this.attributes.set(name, String(value)); },
    getAttribute(name) { return this.attributes.get(name); },
    click() { listeners.click(); },
  };
  return { dataset: { expanded: 'false' }, trigger, querySelector(selector) { return selector === '[data-action="toggle-insight"]' ? trigger : null; } };
}

test('History insight starts visible as a collapsed card and toggles the existing payload', async () => {
  const { mountExpandableInsight } = await import(insightUrl);
  const insight = fakeInsightRoot();
  mountExpandableInsight(insight);
  assert.equal(insight.dataset.expanded, 'false');
  assert.equal(insight.trigger.getAttribute('aria-expanded'), 'false');
  insight.trigger.click();
  assert.equal(insight.dataset.expanded, 'true');
  assert.equal(insight.trigger.getAttribute('aria-expanded'), 'true');
  insight.trigger.click();
  assert.equal(insight.dataset.expanded, 'false');
});

test('History and Timeline declare one visible expandable insight and one BottomNav host each', () => {
  for (const page of ['history.html', 'timeline.html']) {
    const html = fs.readFileSync(new URL(`../pages/${page}`, import.meta.url), 'utf8');
    assert.match(html, /data-component="expandable-insight" data-expanded="false"/);
    assert.match(html, /data-action="toggle-insight"/);
    assert.match(html, /Kibontás/);
    assert.equal((html.match(/data-component="bottom-navigation-host"/g) || []).length, 1);
    assert.match(html, /mountPageChrome\(/);
  }
});
