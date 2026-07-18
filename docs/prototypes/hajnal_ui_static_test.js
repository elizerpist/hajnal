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
  'home',
  'daily-image',
  'daily-checkin',
  'checkin-clean',
  'evening-clean-reward',
  'evening-reflection',
  'gratitude-add',
  'photo-memo',
  'voice-memo',
  'checkin-relapse',
  'support-next-step',
  'checkin-survival-pack',
  'checkin-breathing',
  'checkin-motivation',
  'daily-tasks',
  'panic-mode',
  'panic-root',
  'panic-help-sheet',
  'panic-sponsor-call',
  'panic-help-message',
  'panic-backup-contact',
  'panic-survival-pack',
  'panic-breathing',
  'panic-why-started',
  'panic-meeting-finder',
  'panic-emergency-help'
];

function expectContains(value) {
  assert.ok(html.includes(value), `Missing ${value}`);
}

function expectAbsent(value) {
  assert.ok(!html.includes(value), `Unexpected ${value}`);
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
    expectCount(/class="phone-screen/g, 33, 'phone screen count');
    expectContains('data-source-reference="docs/references/source-of-truth/logo_svg.svg"');
    expectContains('id="hajnal-logo-symbol"');
    expectContains('id="sun_bg_gradient"');
    expectContains('fill="url(#sun_bg_gradient)"');
    expectContains('style="display:inline"');
    expectContains('class="prototype-logo-svg"');
    expectContains('class="splash-logo-svg"');
    expectContains('class="prototype-brand"');
    assert.match(
      html,
      /\.prototype-brand\s*\{[^}]*display:\s*flex;[^}]*flex-direction:\s*column/s,
      'The page icon must sit above the short description'
    );
    ['.soft-card', '.choice-row', '.primary-button', '.secondary-button', '.toggle-row']
      .forEach(expectForbiddenPillAbsent);
    expectContains('assets/hero_xl_svg.svg');
    expectContains('assets/hero_fullscreen_svg.svg');
    expectContains('class="home-hero-image"');
    expectCount(/<img\b/g, 16, 'only the approved SVG hero, carousel, and wizard images may use img tags');
    expectCount(/src="assets\/hero_xl_svg\.svg"/g, 4, 'home and daily carousel image tags must use the approved XL SVG asset');
    expectCount(/src="assets\/hero_fullscreen_svg\.svg"/g, 12, 'check-in wizard image tags must use the approved fullscreen SVG asset');
    expectCount(/src="assets\/hero_m_svg\.svg"/g, 0, 'check-in wizard must not use the old card-sized M SVG asset');
    expectCount(/href="#hajnal-logo-symbol"/g, 2, 'top and Splash icons must use the inline SVG logo symbol');
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
    const homeScreen = screenSlice('home');
    const homeBodyIndex = homeScreen.indexOf('<section class="home-body"');
    const dashboardIndex = homeScreen.indexOf('data-component="home-dashboard"');
    const tasksIndex = homeScreen.indexOf('<section class="tasks-card"');
    const helpIndex = homeScreen.indexOf('<div class="home-actions"');
    [
      '24. nap',
      'a 90 napos úton',
      'Minden nap<br>egy lépés.',
      'Tiszta napok',
      'a 90 napból',
      'Ma tiszta<br>maradtam',
      'Esti check-in',
      'Segítség kell'
    ].forEach((value) => assert.ok(homeScreen.includes(value), `home is missing ${value}`));
    assert.ok(!homeScreen.includes('Napi check-in'), 'home screen must not keep the old standalone Napi check-in CTA');
    assert.ok(!homeScreen.includes('Írj 10 percet'), 'home checklist must remove the old 10-minute writing task');
    assert.ok(!homeScreen.includes('Írj 3 dolgot, amiért hálás vagy'), 'home checklist must remove the old gratitude-writing task');
    assert.ok(!homeScreen.includes('home-divider'), 'home hero subtitle must not keep the underline marker');
    assert.ok(!homeScreen.includes('home-sheet-handle'), 'home lower sheet must not include a separate handle');
    assert.ok(dashboardIndex !== -1 && homeBodyIndex !== -1 && dashboardIndex < homeBodyIndex, 'home dashboard must float outside and above the lower sheet');
    assert.ok(tasksIndex !== -1 && helpIndex !== -1 && tasksIndex < helpIndex, 'home checklist must render above the help button');
    assert.match(html, /\.home-illustration\s*\{[^}]*height:\s*607px/s, 'home hero must be 68% of the 892px screen height');
    assert.match(html, /\.home-body\s*\{[^}]*top:\s*548px/s, 'home sheet must overlap the lower edge of the hero');
    assert.match(html, /\.home-body\s*\{[^}]*display:\s*flex;[^}]*flex-direction:\s*column/s, 'home sheet must allow the help button to sit at the bottom');
    assert.match(html, /\.home-metrics\s*\{[^}]*z-index:\s*32;[^}]*top:\s*480px/s, 'home dashboard must be a top floating layer');
    assert.match(html, /\.tasks-card\s*\{[^}]*border:\s*0;[^}]*background:\s*transparent;[^}]*box-shadow:\s*none/s, 'home task list must be merged into the lower sheet, not a separate card');
    assert.match(html, /\.task-row\s*\{[^}]*min-height:\s*24px/s, 'home task rows must be compact enough to fit in the sheet');
    assert.match(html, /\.home-actions\s*\{[^}]*margin-top:\s*auto/s, 'home help button must sit at the bottom of the sheet');
    assert.match(html, /\.help-button\s*\{[^}]*border:\s*0;[^}]*background:\s*linear-gradient\(160deg,\s*#FF78A8,\s*#E04D86\);[^}]*box-shadow:\s*0 18px 38px rgba\(239,\s*85,\s*145,\s*\.26\)/s, 'home help button must reuse the panic button fill and glow without the distracting inner container ring');
    assert.ok(homeScreen.includes('class="segmented-progress"'), 'home dashboard needs a segmented progress bar');
    assert.ok(homeScreen.includes('class="dashboard-separator"'), 'home dashboard needs the center separator');
    assert.ok(homeScreen.includes('data-action="mark-clean-today" data-target-screen="checkin-clean"'), 'home dashboard needs the clean-day action');
    assert.ok(homeScreen.includes('data-action="open-evening-checkin" data-target-screen="evening-reflection" data-fallback-screen="daily-checkin"'), 'home checklist needs an evening check-in wizard entry with both clean-state routes');
    expectCount(/data-component="daily-task"/g, 3, 'home daily task count');
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

  homeBranch() {
    const dailyImageScreen = screenSlice('daily-image');
    expectOrdered([
      'data-screen="home"',
      'data-screen="daily-image"',
      'data-screen="daily-checkin"',
      'data-screen="checkin-clean"',
      'data-screen="evening-clean-reward"',
      'data-screen="evening-reflection"',
      'data-screen="gratitude-add"',
      'data-screen="photo-memo"',
      'data-screen="voice-memo"',
      'data-screen="checkin-relapse"',
      'data-screen="support-next-step"',
      'data-screen="checkin-survival-pack"',
      'data-screen="checkin-breathing"',
      'data-screen="checkin-motivation"',
      'data-screen="daily-tasks"',
      'data-screen="panic-mode"'
    ]);
    [
      'Napi kép',
      'Mai feladataim',
      'CHECK-IN - ELSŐ LÉPÉS',
      'Hogy sikerült',
      'a mai napod?',
      'Ma tiszta maradtam',
      'Megcsináltad!',
      '25. nap',
      'Tovább az esti reflexióhoz',
      'Esti reflexió',
      'Hangulatom most',
      'Mi volt ma a legjobb?',
      'Mi volt ma a legnehezebb?',
      'Van valami, amit nem szeretnél elfelejteni?',
      'Írd ide bármit...',
      'Hála hozzáadása',
      'Fotó',
      'Hangjegyzet',
      'Miért vagy hálás?',
      'Kép memo',
      'Hang memo',
      'Ma visszaestem',
      'Köszönjük,',
      'hogy őszinte voltál.',
      'Itt vagyunk',
      'neked.',
      '15 perces túlélő csomag',
      'Légzőgyakorlat',
      'Motivációs üzenetek',
      'Nem kell tökéletesnek lenned',
      'Pánik mód',
      'Nem vagy egyedül.'
    ].forEach(expectContains);
    expectContains('data-action="open-daily-image" data-target-screen="daily-image"');
    expectContains('data-action="open-daily-image" data-target-screen="daily-image" data-trigger="home-image-tap"');
    expectContains('Napi kép (a főmenü képére tap indítja)');
    expectContains('data-action="mark-clean-today" data-target-screen="checkin-clean"');
    expectContains('data-action="mark-clean" data-target-screen="evening-clean-reward"');
    expectContains('data-action="continue-evening-reflection" data-target-screen="evening-reflection"');
    expectContains('data-action="open-panic" data-target-screen="panic-mode"');
    expectContains('data-action="save-evening-reflection" data-target-screen="home"');
    expectContains('data-action="open-gratitude-add" data-target-screen="gratitude-add"');
    expectContains('data-action="open-photo-memo" data-target-screen="photo-memo"');
    expectContains('data-action="open-voice-memo" data-target-screen="voice-memo"');
    ['checkin-mood', 'checkin-craving', 'checkin-note', 'support-note'].forEach((id) => {
      expectAbsent(`data-screen="${id}"`);
      expectAbsent(`data-target-screen="${id}"`);
    });
    assert.ok(dailyImageScreen.includes('data-component="daily-image-carousel"'), 'daily image screen needs carousel structure');
    assert.ok(dailyImageScreen.includes('data-action="previous-daily-image"'), 'daily image carousel needs previous navigation');
    assert.ok(dailyImageScreen.includes('data-action="next-daily-image"'), 'daily image carousel needs next navigation');
    assert.ok(dailyImageScreen.includes('data-carousel-slide="past"'), 'daily image carousel needs a visible past slide');
    assert.ok(dailyImageScreen.includes('data-carousel-slide="current"'), 'daily image carousel needs the current slide');
    assert.ok(dailyImageScreen.includes('data-carousel-slide="future"'), 'daily image carousel needs a future slide');
    assert.match(html, /\.daily-carousel\s*\{[^}]*padding:\s*0;[^}]*border-radius:\s*inherit/s, 'daily image carousel must let the active image fill the rounded container');
    assert.match(html, /\.daily-slide\.current\s*\{[^}]*top:\s*0;[^}]*right:\s*0;[^}]*bottom:\s*0;[^}]*left:\s*0;[^}]*border-radius:\s*inherit/s, 'current daily image slide must be full-bleed');
    assert.match(html, /\.daily-slide img\s*\{[^}]*object-fit:\s*cover/s, 'daily carousel images must cover the rounded container');
    assert.match(html, /\.daily-slide\.future\s*\{[^}]*filter:\s*grayscale\(1\)/s, 'future daily image slide must be gray');
    ['daily-checkin', 'checkin-clean', 'evening-clean-reward', 'evening-reflection', 'gratitude-add', 'photo-memo', 'voice-memo', 'checkin-relapse', 'support-next-step', 'checkin-survival-pack', 'checkin-breathing', 'checkin-motivation']
      .forEach((id) => assert.ok(screenSlice(id).includes('class="checkin-bg" src="assets/hero_fullscreen_svg.svg"'), `${id} must use the fullscreen hero image`));
    assert.match(html, /\.checkin-fullscreen\s*\{[^}]*background:\s*#171848/s, 'check-in wizard screens must define a fullscreen dark base');
    assert.match(html, /\.checkin-bg\s*\{[^}]*position:\s*absolute;[^}]*inset:\s*0;[^}]*object-fit:\s*cover/s, 'fullscreen check-in hero image must cover the whole phone viewport');
    assert.match(html, /\.checkin-bottom-actions\s*\{[^}]*margin-top:\s*auto/s, 'check-in CTAs must stay anchored near the bottom like the source PNG');
    const cleanRewardScreen = screenSlice('checkin-clean');
    assert.ok(cleanRewardScreen.includes('data-auto-return-target="home"'), 'screen 11 must auto-return to the main menu');
    assert.ok(!cleanRewardScreen.includes('data-action="continue-clean-reward"'), 'screen 11 must not expose a continue reward action');
    assert.ok(!cleanRewardScreen.includes('>Tovább</button>'), 'screen 11 must not show a Tovább button');
    expectScreenContains('evening-clean-reward', [
      'data-parent-screen="daily-checkin"',
      'Tovább az esti reflexióhoz',
      'data-action="continue-evening-reflection" data-target-screen="evening-reflection"'
    ]);
    expectScreenContains('evening-reflection', [
      'data-parent-screen="home"',
      'data-component="evening-reflection-panel"',
      'data-component="mood-score"',
      'data-mood-value="1"',
      'data-mood-value="5"',
      'data-component="reflection-selector"',
      'aria-pressed="true"',
      'id="evening-reflection-text"',
      'placeholder="Írd ide bármit..."',
      'data-action="save-evening-reflection" data-target-screen="home"'
    ]);
    expectScreenContains('gratitude-add', [
      'data-parent-screen="evening-reflection"',
      'id="gratitude-line-1"',
      'id="gratitude-line-2"',
      'id="gratitude-line-3"',
      'data-action="save-gratitude" data-target-screen="evening-reflection"'
    ]);
    expectScreenContains('photo-memo', [
      'data-parent-screen="evening-reflection"',
      'data-component="photo-memo-dropzone"',
      'id="photo-memo-caption"',
      'data-action="save-photo-memo" data-target-screen="evening-reflection"'
    ]);
    expectScreenContains('voice-memo', [
      'data-parent-screen="evening-reflection"',
      'data-component="voice-recorder"',
      'id="voice-memo-note"',
      'data-action="save-voice-memo" data-target-screen="evening-reflection"'
    ]);
    expectCount(/data-component="daily-task-detail"/g, 3, 'daily task detail count');
    expectCount(/data-component="checkin-support-option"/g, 5, 'check-in support menu option count');
    expectCount(/<textarea\b/g, 3, 'writable memo textarea count');
  },

  panicBranch() {
    expectOrdered([
      'data-screen="panic-root"',
      'data-screen="panic-help-sheet"',
      'data-screen="panic-sponsor-call"',
      'data-screen="panic-help-message"',
      'data-screen="panic-backup-contact"',
      'data-screen="panic-survival-pack"',
      'data-screen="panic-breathing"',
      'data-screen="panic-why-started"',
      'data-screen="panic-meeting-finder"',
      'data-screen="panic-emergency-help"'
    ]);
    [
      'Pánik mód elemei',
      'Segítség kell panel',
      'Semmi nem indul automatikusan.',
      'Szponzor hívása',
      'Segítő személy hívása',
      'Előre megírt üzenet',
      'Sürgősségi segítség',
      'Hívd a szponzorod',
      'Küldj segítségkérő üzenetet',
      'Hívd a tartalék kapcsolattartót',
      '15 perces túlélőcsomag',
      'Légzőgyakorlat',
      'Olvasd el, miért kezdted el',
      'Keresd meg a következő meetinget',
      'Szakmai vagy sürgősségi segítség',
      'Állj meg. Nézz körül.',
      'Vegyél öt lassú levegőt.',
      'Igyál vizet.',
      'Várj 10 percet.',
      'Belégzés',
      'Meeting keresése'
    ].forEach(expectContains);
    expectContains('data-action="open-help-sheet" data-target-screen="panic-help-sheet"');
    expectContains('data-action="start-survival-pack" data-target-screen="panic-survival-pack"');
    expectContains('data-action="meeting-finder" data-target-screen="panic-meeting-finder"');
    expectCount(/class="screen-row/g, 3, 'screen row count');
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
    expectCount(/class="screen-row/g, 3, 'screen row count');
    expectContains('data-page="entry" data-root-screen="splash" data-row-screens="splash onboarding information start-date recovery-goal sponsor-setup notifications"');
    expectContains('data-page="home" data-root-screen="home" data-row-screens="home daily-image daily-checkin checkin-clean evening-clean-reward evening-reflection gratitude-add photo-memo voice-memo checkin-relapse support-next-step checkin-survival-pack checkin-breathing checkin-motivation daily-tasks panic-mode"');
    expectContains('data-page="panic" data-root-screen="panic-root" data-row-screens="panic-root panic-help-sheet panic-sponsor-call panic-help-message panic-backup-contact panic-survival-pack panic-breathing panic-why-started panic-meeting-finder panic-emergency-help"');
    const parents = {
      onboarding: 'splash',
      information: 'onboarding',
      'start-date': 'onboarding',
      'recovery-goal': 'onboarding',
      'sponsor-setup': 'onboarding',
      notifications: 'onboarding',
      home: 'notifications',
      'daily-image': 'home',
      'daily-tasks': 'home',
      'daily-checkin': 'home',
      'checkin-clean': 'daily-checkin',
      'evening-clean-reward': 'daily-checkin',
      'evening-reflection': 'home',
      'gratitude-add': 'evening-reflection',
      'photo-memo': 'evening-reflection',
      'voice-memo': 'evening-reflection',
      'checkin-relapse': 'daily-checkin',
      'support-next-step': 'checkin-relapse',
      'checkin-survival-pack': 'support-next-step',
      'checkin-breathing': 'support-next-step',
      'checkin-motivation': 'support-next-step',
      'panic-mode': 'home',
      'panic-root': 'panic-mode',
      'panic-help-sheet': 'panic-root',
      'panic-sponsor-call': 'panic-root',
      'panic-help-message': 'panic-root',
      'panic-backup-contact': 'panic-root',
      'panic-survival-pack': 'panic-root',
      'panic-breathing': 'panic-root',
      'panic-why-started': 'panic-root',
      'panic-meeting-finder': 'panic-root',
      'panic-emergency-help': 'panic-root'
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

const selected = group === 'all'
  ? Object.keys(tests).filter((name) => name !== 'visualEvidence' || process.env.HAJNAL_CHECK_VISUAL_EVIDENCE === '1')
  : [group];

selected.forEach((name) => {
  assert.ok(tests[name], `Unknown test group: ${name}`);
  tests[name]();
  process.stdout.write(`PASS ${name}\n`);
});
