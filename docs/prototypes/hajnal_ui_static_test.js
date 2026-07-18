'use strict';

const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');

const htmlPath = path.join(__dirname, 'hajnal_ui.html');
const html = fs.existsSync(htmlPath) ? fs.readFileSync(htmlPath, 'utf8') : '';
const group = process.argv[2] || 'all';
const screenOrder = [
  'splash',
  'onboarding',
  'information',
  'start-date',
  'recovery-goal',
  'sponsor-setup',
  'notifications',
  'home'
];

function expectContains(value) {
  assert.ok(html.includes(value), `Missing ${value}`);
}

function expectCount(pattern, expected, message) {
  const actual = (html.match(pattern) || []).length;
  assert.equal(actual, expected, message || `${pattern} count`);
}

function expectOrdered(values) {
  let cursor = -1;
  for (const value of values) {
    const next = html.indexOf(value, cursor + 1);
    assert.ok(next > cursor, `${value} is missing or out of order`);
    cursor = next;
  }
}

function screenSlice(id) {
  const screenIndex = screenOrder.indexOf(id);
  assert.notEqual(screenIndex, -1, `Unknown screen: ${id}`);
  const marker = `data-screen="${id}"`;
  const markerIndex = html.indexOf(marker);
  assert.notEqual(markerIndex, -1, `Missing screen marker: ${id}`);
  const start = html.lastIndexOf('<article', markerIndex);
  const nextId = screenOrder[screenIndex + 1];
  if (!nextId) return html.slice(start);
  const nextMarkerIndex = html.indexOf(`data-screen="${nextId}"`, markerIndex + marker.length);
  const end = html.lastIndexOf('<article', nextMarkerIndex);
  return html.slice(start, end);
}

function expectScreenContains(id, values) {
  const screen = screenSlice(id);
  values.forEach((value) => assert.ok(screen.includes(value), `${id} is missing ${value}`));
}

function pngSize(filename) {
  const buffer = fs.readFileSync(path.join(__dirname, 'verification', filename));
  assert.equal(buffer.toString('ascii', 1, 4), 'PNG', `${filename} must be PNG`);
  return {
    width: buffer.readUInt32BE(16),
    height: buffer.readUInt32BE(20)
  };
}

function expectForbiddenPillAbsent(selector) {
  const escaped = selector.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const rule = new RegExp(`${escaped}\\s*\\{[^}]*border-radius:\\s*(?:999px|9999px|50%)`, 's');
  assert.ok(!rule.test(html), `${selector} must remain a rounded box, not a pill`);
}

const tests = {
  shell() {
    expectContains('--screen-w: 412px');
    expectContains('--screen-h: 892px');
    expectContains('--phone-radius: 34px');
    ['#2C2E77', '#6A56B4', '#B89AD7', '#F18EAF', '#FEC884', '#FCF0F0']
      .forEach(expectContains);
    expectCount(/class="phone-screen/g, 8, 'phone screen count');
    expectContains('data-source-reference="docs/references/source-of-truth/logo.png"');
    expectContains('src="../references/source-of-truth/logo.png"');
    expectContains('class="prototype-brand"');
    assert.match(
      html,
      /\.prototype-brand\s*\{[^}]*display:\s*flex;[^}]*flex-direction:\s*column/s,
      'The page icon must sit above the short description'
    );
    ['.soft-card', '.choice-row', '.primary-button', '.secondary-button', '.toggle-row']
      .forEach(expectForbiddenPillAbsent);
    expectCount(/<img\b/g, 2, 'only the page logo and Splash logo may be raster images');
    expectCount(/<img[^>]+source-of-truth\/logo\.png/g, 2, 'both raster images must be the Hajnal logo');
  },

  entry() {
    expectOrdered([
      'data-screen="splash"',
      'data-screen="onboarding"',
      'data-screen="information"',
      'data-screen="start-date"'
    ]);
    [
      'Hajnal',
      'Csak a mai nap.',
      'Nem kell 90 napot egyszerre végigcsinálnod.',
      'Csak a mait.',
      'Kezdjük el',
      'Már van fiókom',
      'Elolvastam és elfogadom.',
      'Ma',
      'Tegnap',
      'Dátum kiválasztása'
    ].forEach(expectContains);
    expectContains('data-transition-delay="2000-3000"');
    expectContains('data-first-use-target="onboarding"');
    expectContains('data-returning-target="home"');
    expectContains('type="checkbox"');
    expectCount(/name="start-date"/g, 3, 'start-date choice count');
    expectScreenContains('splash', ['Csak a mai nap.', 'data-transition-delay="2000-3000"']);
    assert.ok(!/<button\b/.test(screenSlice('splash')), 'Splash must not contain a CTA');
    expectScreenContains('onboarding', ['Kezdjük el', 'Már van fiókom']);
    expectScreenContains('information', ['Elolvastam és elfogadom.', 'continue-information']);
    expectScreenContains('start-date', ['Ma', 'Tegnap', 'Dátum kiválasztása']);
    expectCount(/class="calendar-day[^\"]*"[^>]*type="button"/g, 35, 'semantic calendar date button count');
  },

  setup() {
    expectOrdered([
      'data-screen="recovery-goal"',
      'data-screen="sponsor-setup"',
      'data-screen="notifications"'
    ]);
    expectCount(/name="recovery-goal"/g, 7, 'recovery goal count');
    expectCount(/name="sponsor-choice"/g, 3, 'sponsor choice count');
    [
      'Alkohol',
      'Kábítószer',
      'Gyógyszer',
      'Szerencsejáték',
      'Viselkedési függőség',
      'Nem szeretném megadni',
      'Egyéb',
      'Igen, hozzáadom',
      'Később',
      'Nincs még',
      'Reggeli emlékeztető',
      'Esti check-in',
      '21:00',
      'Szponzorhívás emlékeztetője',
      'Napi írás emlékeztetője',
      'Meeting emlékeztetője',
      'Belépek a Hajnalba'
    ].forEach(expectContains);
    expectCount(/data-component="toggle-row"/g, 5, 'notification toggle row count');
    expectCount(/class="switch"/g, 5, 'notification switch visual count');
  },

  home() {
    expectContains('data-screen="home"');
    [
      '24. nap',
      'Ma még nincs lezárva',
      'Napi check-in',
      'Segítség kell'
    ].forEach(expectContains);
    expectCount(/data-component="daily-task"/g, 5, 'daily task count');
    expectContains('<nav class="bottom-nav"');
    const navStart = html.indexOf('<nav class="bottom-nav"');
    const navEnd = html.indexOf('</nav>', navStart);
    const nav = html.slice(navStart, navEnd);
    let cursor = -1;
    for (const label of ['Kezdőlap', 'Haladás', 'Eszközök', 'Szponzor', 'Profil']) {
      const next = nav.indexOf(label, cursor + 1);
      assert.ok(next > cursor, `${label} is missing or out of order in bottom navigation`);
      cursor = next;
    }
  },

  accessibility() {
    expectContains('aria-label="Vissza"');
    expectContains('aria-label="Értesítések"');
    expectContains('aria-hidden="true"');
    expectContains('<label');
    expectContains('.native-control:focus-visible');
    expectContains('.compact-field:focus-within');
    expectContains('button:focus-visible');
    assert.ok(!/class="calendar-grid"[^>]*aria-hidden="true"/.test(html), 'Calendar controls must be exposed to assistive technology');
    assert.ok(!/<div[^>]+role="button"/i.test(html), 'Use native button elements');
  },

  hierarchy() {
    expectOrdered(screenOrder.map((id) => `data-screen="${id}"`));
    const parents = {
      onboarding: 'splash',
      information: 'onboarding',
      'start-date': 'onboarding',
      'recovery-goal': 'onboarding',
      'sponsor-setup': 'onboarding',
      notifications: 'onboarding',
      home: 'notifications'
    };
    Object.entries(parents).forEach(([id, parent]) => {
      assert.ok(
        screenSlice(id).includes(`data-parent-screen="${parent}"`),
        `${id} must declare ${parent} as its parent`
      );
    });
  },

  visualEvidence() {
    screenOrder.forEach((id) => {
      assert.deepEqual(pngSize(`${id}.png`), { width: 412, height: 892 }, `${id} screenshot size`);
    });
  }
};

const selected = group === 'all' ? Object.keys(tests) : [group];

selected.forEach((name) => {
  assert.ok(tests[name], `Unknown test group: ${name}`);
  tests[name]();
  process.stdout.write(`PASS ${name}\n`);
});
