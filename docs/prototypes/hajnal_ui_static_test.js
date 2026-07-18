'use strict';

const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');

const htmlPath = path.join(__dirname, 'hajnal_ui.html');
const html = fs.existsSync(htmlPath) ? fs.readFileSync(htmlPath, 'utf8') : '';
const sourceAssetDirectory = '/storage/emulated/0/hajnal';
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

function fileSha256(filename) {
  return crypto.createHash('sha256').update(fs.readFileSync(filename)).digest('hex');
}

function expectCopiedAsset(filename) {
  const sourcePath = path.join(sourceAssetDirectory, filename);
  const referencePath = path.join(__dirname, '..', 'references', 'source-of-truth', filename);
  const prototypePath = path.join(__dirname, 'assets', filename);
  assert.ok(fs.existsSync(referencePath), `${filename} must be copied into source-of-truth references`);
  assert.ok(fs.existsSync(prototypePath), `${filename} must be copied into prototype assets`);
  assert.equal(fileSha256(referencePath), fileSha256(sourcePath), `${filename} source-of-truth hash`);
  assert.equal(fileSha256(prototypePath), fileSha256(sourcePath), `${filename} prototype asset hash`);
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
    expectCount(/class="phone-screen/g, 30, 'phone screen count');
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
    expectContains('assets/hero_fullscreen2_svg.svg');
    expectContains('assets/hero_fullscreen_svg.svg');
    expectContains('assets/hurray_svg.svg');
    expectContains('assets/welcome_svg.svg');
    expectCopiedAsset('welcome_svg.svg');
    expectContains('.glass-card');
    expectAbsent('id="hajnal-liquid-glass-warp"');
    expectAbsent('filter: url(#hajnal-liquid-glass-warp)');
    expectAbsent('rgba(255, 255, 255, 1.5)');
    assert.match(html, /\.glass-card\s*\{[^}]*width:\s*240px;[^}]*height:\s*360px;[^}]*background:\s*rgba\(255,\s*255,\s*255,\s*0\.22\);[^}]*backdrop-filter:\s*blur\(18px\) saturate\(1\.24\);[^}]*-webkit-backdrop-filter:\s*blur\(18px\) saturate\(1\.24\);[^}]*border-radius:\s*20px;[^}]*border:\s*1px solid rgba\(255,\s*255,\s*255,\s*0\.24\);[^}]*box-shadow:[^}]*0 8px 28px rgba\(0,\s*0,\s*0,\s*0\.08\),[^}]*inset 0 1px 0 rgba\(255,\s*255,\s*255,\s*0\.42\),[^}]*inset 0 -1px 0 rgba\(255,\s*255,\s*255,\s*0\.08\),[^}]*inset 0 0 24px 8px rgba\(255,\s*255,\s*255,\s*0\.14\);[^}]*position:\s*relative;[^}]*overflow:\s*hidden/s, 'shared .glass-card must be refined to read as transparent glass, not a white card');
    assert.match(html, /\.glass-card::before\s*\{[^}]*content:\s*'';[^}]*position:\s*absolute;[^}]*top:\s*0;[^}]*left:\s*0;[^}]*right:\s*0;[^}]*height:\s*1px;[^}]*background:\s*linear-gradient\([^}]*90deg,[^}]*transparent,[^}]*rgba\(255,\s*255,\s*255,\s*0\.55\),[^}]*transparent[^}]*\)/s, 'shared .glass-card top highlight must be subtle after the white-card feedback');
    assert.match(html, /\.glass-card::after\s*\{[^}]*content:\s*'';[^}]*position:\s*absolute;[^}]*top:\s*0;[^}]*left:\s*0;[^}]*width:\s*1px;[^}]*height:\s*100%;[^}]*background:\s*linear-gradient\([^}]*180deg,[^}]*rgba\(255,\s*255,\s*255,\s*0\.5\),[^}]*transparent,[^}]*rgba\(255,\s*255,\s*255,\s*0\.18\)[^}]*\)/s, 'shared .glass-card side highlight must be subtle after the white-card feedback');
    expectContains('class="home-hero-image"');
    expectCount(/<img\b/g, 12, 'only the approved SVG splash, hero, daily, hurray, and wizard images may use img tags');
    expectCount(/src="assets\/hero_xl_svg\.svg"/g, 0, 'latest prototype must not keep the old XL SVG image tags');
    expectCount(/src="assets\/welcome_svg\.svg"/g, 1, 'Splash must use the approved welcome SVG asset once');
    expectCount(/src="assets\/hero_fullscreen2_svg\.svg"/g, 2, 'home and daily image screens must use the approved fullscreen2 SVG asset');
    expectCount(/src="assets\/hurray_svg\.svg"/g, 2, 'hurray reward screens must use the approved hurray SVG asset');
    expectCount(/src="assets\/hero_fullscreen_svg\.svg"/g, 7, 'regular check-in wizard image tags must use the approved fullscreen SVG asset');
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
    expectScreenContains('splash', [
      'Csak a mai nap.',
      'data-transition-delay="2000-3000"',
      'class="splash-bg" src="assets/welcome_svg.svg"',
      'data-background-source="welcome_svg.svg"'
    ]);
    assert.ok(!screenSlice('splash').includes('class="splash-landscape"'), 'Splash must not keep the old inline landscape SVG over the welcome background');
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
    const homeBodyIndex = homeScreen.indexOf('class="home-body');
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
    assert.match(html, /\.home-screen\s*\{[^}]*background:\s*#F9F3F7/s, 'home screen must not expose a dark fallback container behind the glass card');
    assert.match(html, /\.home-illustration\s*\{[^}]*height:\s*calc\(var\(--screen-h\) - 70px\);[^}]*background:\s*transparent/s, 'home hero image must extend behind the full glass card area down to the bottom nav');
    assert.match(html, /\.home-body\s*\{[^}]*top:\s*586px/s, 'home sheet must move 38px lower after the latest screenshot feedback');
    assert.ok(homeScreen.includes('class="home-body glass-card"'), 'home sheet must use the user-provided .glass-card class');
    assert.ok(homeScreen.includes('data-glass-card="home-sheet"'), 'home sheet must expose the glass-card marker');
    assert.match(html, /\.home-body\.glass-card\s*\{[^}]*width:\s*auto;[^}]*height:\s*auto;[^}]*border-radius:\s*92px 92px 0 0/s, 'home sheet may override glass-card dimensions/radius for the screen-8 bottom container');
    assert.ok(!/\.home-body::before\s*\{[^}]*url\("assets\/hero_fullscreen2_svg\.svg"\)/s.test(html), 'home sheet must not keep the extra hero-clone backing layer behind the card');
    assert.ok(!/\.home-body::after\s*\{[^}]*url\("assets\/hero_fullscreen2_svg\.svg"\)/s.test(html), 'home sheet must not keep the extra hero-clone overlay layer');
    assert.match(html, /\.home-body\s*\{[^}]*display:\s*flex;[^}]*flex-direction:\s*column/s, 'home sheet must allow the help button to sit at the bottom');
    assert.match(html, /\.home-metrics\s*\{[^}]*z-index:\s*32;[^}]*top:\s*518px/s, 'home dashboard must move 38px lower with the sheet');
    assert.match(html, /\.home-metrics\s*\{[^}]*color:\s*var\(--hajnal-navy\);[^}]*background:\s*#FFFCFB;[^}]*backdrop-filter:\s*none/s, 'home clean-days dashboard must stay solid rather than glass');
    assert.match(html, /\.metric strong\s*\{[^}]*color:\s*var\(--hajnal-navy\)/s, 'clean-days number must not inherit white text');
    assert.match(html, /\.tasks-card\s*\{[^}]*border:\s*0;[^}]*background:\s*transparent;[^}]*box-shadow:\s*none/s, 'home task list must be merged into the lower sheet, not a separate card');
    assert.match(html, /\.task-row\s*\{[^}]*min-height:\s*24px/s, 'home task rows must be compact enough to fit in the sheet');
    assert.match(html, /\.home-actions\s*\{[^}]*margin-top:\s*auto/s, 'home help button must sit at the bottom of the sheet');
    assert.match(html, /\.help-button\s*\{[^}]*border:\s*0;[^}]*background:\s*linear-gradient\(160deg,\s*#FF78A8,\s*#E04D86\);[^}]*box-shadow:\s*0 18px 38px rgba\(239,\s*85,\s*145,\s*\.26\)/s, 'home help button must reuse the panic button fill and glow without the distracting inner container ring');
    assert.ok(homeScreen.includes('class="segmented-progress"'), 'home dashboard needs a segmented progress bar');
    assert.ok(homeScreen.includes('class="dashboard-separator"'), 'home dashboard needs the center separator');
    assert.ok(homeScreen.includes('class="home-hero-image" src="assets/hero_fullscreen2_svg.svg"'), 'home hero must use the fullscreen2 SVG asset');
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
    const eveningReflectionScreen = screenSlice('evening-reflection');
    expectOrdered([
      'data-screen="home"',
      'data-screen="daily-image"',
      'data-screen="daily-checkin"',
      'data-screen="checkin-clean"',
      'data-screen="evening-clean-reward"',
      'data-screen="evening-reflection"',
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
      'Miért vagy hálás?',
      'Van valami, amit nem szeretnél elfelejteni?',
      'Írd le a nap legjobb pillanatát.',
      'Hála lista',
      'Új hozzáadása',
      'Fotó',
      'Hangjegyzet',
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
    expectContains('data-component="reflection-response-panel"');
    expectContains('data-reflection-content');
    expectContains('data-gratitude-list');
    expectContains('add-gratitude-item');
    expectContains('data-action="add-photo-memo-inline"');
    expectContains('data-action="toggle-voice-memo-inline"');
    expectAbsent('data-component="inline-gratitude"');
    expectAbsent('id="inline-photo-caption"');
    expectAbsent('id="inline-voice-note"');
    ['checkin-mood', 'checkin-craving', 'checkin-note', 'support-note', 'gratitude-add', 'photo-memo', 'voice-memo'].forEach((id) => {
      expectAbsent(`data-screen="${id}"`);
      expectAbsent(`data-target-screen="${id}"`);
    });
    assert.ok(dailyImageScreen.includes('class="phone-screen daily-image-screen no-nav"'), 'daily image screen must use the fullscreen screen variant');
    assert.ok(dailyImageScreen.includes('data-slide-mode="fullscreen"'), 'daily image screen must document fullscreen slide behavior');
    assert.ok(dailyImageScreen.includes('class="daily-fullscreen-bg" src="assets/hero_fullscreen2_svg.svg"'), 'daily image screen must use fullscreen2 as the full-screen image');
    assert.ok(dailyImageScreen.includes('class="daily-image-progress" role="progressbar"'), 'daily image screen needs a semantic progress bar');
    assert.ok(dailyImageScreen.includes('aria-valuemin="0" aria-valuemax="90" aria-valuenow="24"'), 'daily image progress must expose the 90-day position');
    assert.ok(dailyImageScreen.includes('24. nap'), 'daily image screen needs the day label under the progress bar');
    assert.ok(dailyImageScreen.includes('a 90 napos úton'), 'daily image screen needs the 90-day subtitle under the progress bar');
    assert.ok(dailyImageScreen.includes('daily-image-quote'), 'daily image screen needs the quote overlay near the image bottom');
    assert.ok(!dailyImageScreen.includes('data-component="daily-image-carousel"'), 'daily image screen must remove the carousel component');
    assert.ok(!dailyImageScreen.includes('daily-carousel-nav'), 'daily image screen must remove carousel navigation buttons');
    assert.ok(!dailyImageScreen.includes('data-carousel-slide="past"'), 'daily image screen must remove neighboring past preview');
    assert.ok(!dailyImageScreen.includes('data-carousel-slide="future"'), 'daily image screen must remove neighboring future preview');
    assert.ok(!dailyImageScreen.includes('daily-art-card'), 'daily image screen must remove the inner image container');
    assert.ok(!dailyImageScreen.includes('daily-art-actions'), 'daily image screen must remove bottom action buttons');
    assert.ok(!dailyImageScreen.includes('<header class="screen-header"'), 'daily image screen must not show the old title/header');
    ['daily-checkin', 'evening-reflection', 'checkin-relapse', 'support-next-step', 'checkin-survival-pack', 'checkin-breathing', 'checkin-motivation']
      .forEach((id) => assert.ok(screenSlice(id).includes('class="checkin-bg" src="assets/hero_fullscreen_svg.svg"'), `${id} must use the fullscreen hero image`));
    ['checkin-clean', 'evening-clean-reward']
      .forEach((id) => assert.ok(screenSlice(id).includes('class="checkin-bg" src="assets/hurray_svg.svg"'), `${id} must use the hurray fullscreen image`));
    assert.match(html, /\.checkin-fullscreen\s*\{[^}]*background:\s*#171848/s, 'check-in wizard screens must define a fullscreen dark base');
    assert.match(html, /\.checkin-bg\s*\{[^}]*position:\s*absolute;[^}]*inset:\s*0;[^}]*object-fit:\s*cover/s, 'fullscreen check-in hero image must cover the whole phone viewport');
    assert.match(html, /\.hurray-screen \.checkin-reward-copy\s*\{[^}]*margin:\s*126px 34px 0/s, 'hurray reward text must move up near the screen 10 title height');
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
      'placeholder="Írd le a nap legjobb pillanatát."',
      'data-action="save-evening-reflection" data-target-screen="home"'
    ]);
    assert.ok(!eveningReflectionScreen.includes('class="checkin-top-actions"'), 'evening reflection screen must remove top x/check controls');
    assert.ok(!eveningReflectionScreen.includes('class="quiet-link"'), 'evening reflection panel must remove the top save link');
    assert.equal((eveningReflectionScreen.match(/class="reflection-prompt/g) || []).length, 4, 'evening reflection selector must have four cards');
    assert.ok(eveningReflectionScreen.includes('data-reflection-prompt="gratitude"'), 'gratitude must be part of the reflection selector cards');
    assert.ok(eveningReflectionScreen.includes('class="evening-scroll" data-component="evening-scroll-area"'), 'evening reflection content must live in a scroll area');
    assert.ok(eveningReflectionScreen.indexOf('class="evening-scroll"') < eveningReflectionScreen.indexOf('class="evening-save-actions"'), 'evening footer actions must stay outside the scroll area');
    assert.ok(eveningReflectionScreen.includes('class="evening-reflection-panel glass-card"'), 'screen 12 outer container must use the user-provided .glass-card class');
    assert.ok(eveningReflectionScreen.includes('data-component="reflection-response-panel"'), 'the dynamic reflection response container must exist');
    assert.ok(eveningReflectionScreen.includes('class="reflection-response-panel glass-card"'), 'the section 3 content container must use the user-provided .glass-card class');
    assert.ok(eveningReflectionScreen.includes('data-reflection-content'), 'the dynamic reflection response container must be script-addressable');
    expectContains("list.setAttribute('data-gratitude-list', '')");
    expectContains('addButton.setAttribute(\'data-action\', \'add-gratitude-item\')');
    assert.ok(eveningReflectionScreen.includes('data-component="inline-media-memos"'), 'photo and voice memo controls must remain in section 4');
    assert.ok(eveningReflectionScreen.includes('data-action="add-photo-memo-inline"'), 'photo memo control must remain inline inside evening reflection');
    assert.ok(eveningReflectionScreen.includes('data-action="toggle-voice-memo-inline"'), 'voice memo control must remain inline inside evening reflection');
    assert.ok(!eveningReflectionScreen.includes('data-component="inline-gratitude"'), 'section 4 must not keep the old gratitude box');
    assert.ok(!eveningReflectionScreen.includes('id="inline-photo-caption"'), 'section 4 photo memo must not keep a note field underneath');
    assert.ok(!eveningReflectionScreen.includes('id="inline-voice-note"'), 'section 4 voice memo must not keep a note field underneath');
    assert.ok(!eveningReflectionScreen.includes('data-target-screen="gratitude-add"'), 'gratitude must not navigate to a helper screen');
    assert.ok(!eveningReflectionScreen.includes('data-target-screen="photo-memo"'), 'photo memo must not navigate to a helper screen');
    assert.ok(!eveningReflectionScreen.includes('data-target-screen="voice-memo"'), 'voice memo must not navigate to a helper screen');
    assert.ok(!/#evening-reflection \.evening-reflection-panel::before/.test(html), 'screen 12 panel must not keep an extra screen-specific backing layer');
    assert.match(html, /#evening-reflection \.evening-reflection-panel\.glass-card\s*\{[^}]*flex:\s*1;[^}]*display:\s*flex;[^}]*flex-direction:\s*column;[^}]*margin:\s*32px 18px 24px;[^}]*width:\s*auto;[^}]*height:\s*auto/s, 'evening reflection panel must use .glass-card with only layout overrides');
    assert.match(html, /\.evening-scroll\s*\{[^}]*flex:\s*1;[^}]*overflow-y:\s*auto;[^}]*padding-bottom:\s*12px/s, 'evening reflection screen content must scroll above the floating footer');
    assert.match(html, /\.reflection-response-panel\.glass-card\s*\{[^}]*width:\s*auto;[^}]*height:\s*auto;[^}]*border-radius:\s*17px/s, 'the section 3 content container must use .glass-card with compact layout overrides');
    assert.match(html, /#evening-reflection \.evening-save-actions\s*\{[^}]*flex:\s*0 0 auto;[^}]*grid-template-columns:\s*104px 104px;[^}]*justify-content:\s*end/s, 'evening reflection bottom actions must be outside the scroll area, smaller, and right aligned');
    assert.match(html, /#evening-reflection \.evening-save-actions \.(?:secondary-button|primary-button),\s*#evening-reflection \.evening-save-actions \.(?:primary-button|secondary-button)\s*\{[^}]*min-height:\s*42px/s, 'evening reflection bottom buttons must be smaller');
    expectContains('const reflectionPromptContent = {');
    expectContains('function setActiveReflectionPrompt');
    expectContains('function addGratitudeItem');
    expectContains('data-active-reflection-prompt');
    expectCount(/data-component="daily-task-detail"/g, 3, 'daily task detail count');
    expectCount(/data-component="checkin-support-option"/g, 5, 'check-in support menu option count');
    expectCount(/<textarea\b/g, 1, 'writable memo textarea count');
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
    expectContains('data-page="home" data-root-screen="home" data-row-screens="home daily-image daily-checkin checkin-clean evening-clean-reward evening-reflection checkin-relapse support-next-step checkin-survival-pack checkin-breathing checkin-motivation daily-tasks panic-mode"');
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
