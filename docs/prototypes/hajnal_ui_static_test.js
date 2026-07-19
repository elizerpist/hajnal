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
  'welcome-lighting-lab',
  'splash',
  'onboarding',
  'information',
  'start-date',
  'recovery-goal',
  'sponsor-setup',
  'notifications',
  'home-collapsed',
  'home',
  'checkin-clean',
  'evening-reflection',
  'reflection-saved',
  'panic-root',
  'checkin-survival-pack',
  'survival-stop',
  'survival-breathe',
  'survival-water',
  'survival-outside',
  'survival-note',
  'survival-call-sponsor',
  'panic-help-message',
  'panic-backup-contact',
  'panic-why-started',
  'panic-meeting-finder',
  'panic-emergency-help',
  'checkin-relapse',
  'daily-image',
  'progress-overview',
  'progress-journey',
  'progress-day-detail',
  'progress-calendar',
  'progress-stats',
  'progress-milestones',
  'tools-overview',
  'tools-steps',
  'tools-step-question',
  'tools-step-summary',
  'tools-journal-list',
  'tools-journal-entry',
  'tools-craving-log',
  'tools-journal-detail'
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
    expectCount(/class="phone-screen/g, 42, 'phone screen count');
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
    [
      'logo_svg.svg',
      'welcome_svg.svg',
      'hero_s_svg.svg',
      'hero_m_svg.svg',
      'hero_xl_svg.svg',
      'hero_fullscreen_svg.svg',
      'hero_fullscreen2_svg.svg',
      'hurray_svg.svg'
    ].forEach(expectCopiedAsset);
    expectAbsent('.glass-card');
    expectAbsent('id="hajnal-liquid-glass-warp"');
    expectAbsent('filter: url(#hajnal-liquid-glass-warp)');
    expectAbsent('rgba(255, 255, 255, 1.5)');
    expectContains('class="home-hero-image"');
    expectCount(/<img\b/g, 9, 'only the approved SVG splash, hero, daily, hurray, and wizard images may use img tags');
    expectCount(/<img\b[^>]*src="assets\/hero_xl_svg\.svg"/g, 0, 'latest prototype must not keep the old XL SVG image tags');
    expectCount(/<img\b[^>]*src="assets\/welcome_svg\.svg"/g, 1, 'Splash must use the approved welcome SVG asset once');
    expectCount(/<img\b[^>]*src="assets\/hero_fullscreen2_svg\.svg"/g, 3, 'home states and daily image screen must use the approved fullscreen2 SVG asset');
    expectCount(/<img\b[^>]*src="assets\/hurray_svg\.svg"/g, 1, 'hurray reward screen must use the approved hurray SVG asset');
    expectCount(/<img\b[^>]*src="assets\/hero_fullscreen_svg\.svg"/g, 4, 'regular fullscreen flow image tags must use the approved fullscreen SVG asset');
    expectCount(/<img\b[^>]*src="assets\/hero_m_svg\.svg"/g, 0, 'check-in wizard must not use the old card-sized M SVG asset');
    expectCount(/href="#hajnal-logo-symbol"/g, 2, 'top and Splash icons must use the inline SVG logo symbol');
  },

  entry() {
    expectOrdered([
      'data-screen="welcome-lighting-lab"',
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
    expectScreenContains('welcome-lighting-lab', [
      'class="phone-screen svg-lighting-lab-screen"',
      'data-screen="welcome-lighting-lab"',
      'data-source-screen="splash"',
      'data-svg-source="assets/welcome_svg.svg"',
      'data-lighting-engine="bucketed-path-profiles"',
      'data-primary-sky-gradient="gradient_0"',
      'data-path-count="116"',
      'data-gradient-count="14"',
      'data-stop-count="28"',
      'data-component="welcome-svg-stage"',
      'type="range"',
      'data-lighting-slider',
      'aria-label="Éjszaka-nappal fényprofil"',
      'data-lighting-profile-name'
    ]);
    assert.ok(!screenSlice('welcome-lighting-lab').includes('<img'), 'lighting lab must not add another img tag for the welcome SVG');
    [
      'deep-night',
      'moonlit-night',
      'blue-hour',
      'violet-dawn',
      'rose-dawn',
      'orange-sunrise',
      'golden-hour',
      'bright-morning'
    ].forEach(expectContains);
    [
      'skyTop',
      'skyMiddle',
      'distantMountainFill',
      'nearMountainFill',
      'groundFill',
      'waterFill',
      'shadowColor',
      'highlightColor',
      'atmosphericGlow',
      'sunColor',
      'moonOpacity',
      'starsOpacity'
    ].forEach(expectContains);
    expectContains('fetch(svgSource)');
    expectContains('chooseLightingSegment(progress)');
    expectContains('interpolateLightingProfile(start.profile, end.profile, segmentProgress)');
    expectContains('normalizePrimarySkyGradient(svg, profile)');
    expectContains('setPrimarySkyStops(primarySkyGradient, profile)');
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
    expectContains('data-screen="home-collapsed"');
    expectContains('data-screen="home"');
    const collapsedHomeScreen = screenSlice('home-collapsed');
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
    assert.match(html, /\.home-screen\s*\{[^}]*background:\s*#F9F3F7/s, 'home screen must not expose a dark fallback container behind the lower card');
    assert.match(html, /\.home-illustration\s*\{[^}]*height:\s*calc\(var\(--screen-h\) - 70px\);[^}]*background:\s*transparent/s, 'home hero image must extend behind the lower card area down to the bottom nav');
    assert.match(html, /\.home-body\s*\{[^}]*top:\s*586px/s, 'home sheet must move 38px lower after the latest screenshot feedback');
    assert.ok(homeScreen.includes('class="home-body"'), 'home sheet must use the original non-glass class');
    assert.ok(!homeScreen.includes('data-glass-card="home-sheet"'), 'home sheet must drop the glass marker');
    assert.match(html, /\.home-body\s*\{[^}]*border-radius:\s*92px 92px 0 0;[^}]*background:\s*linear-gradient\(180deg,\s*#FFFBFD 0%,\s*#F9F2F6 100%\);[^}]*color:\s*var\(--hajnal-navy\)/s, 'home sheet must restore the pre-glass colorful lower card');
    assert.match(html, /\.home-body::before\s*\{[^}]*background:\s*inherit/s, 'home sheet curve must use the same pre-glass background as the body');
    assert.ok(!/\.home-body::before\s*\{[^}]*url\("assets\/hero_fullscreen2_svg\.svg"\)/s.test(html), 'home sheet must not keep the extra hero-clone backing layer behind the card');
    assert.ok(!/\.home-body::after\s*\{[^}]*url\("assets\/hero_fullscreen2_svg\.svg"\)/s.test(html), 'home sheet must not keep the extra hero-clone overlay layer');
    assert.match(html, /\.home-body\s*\{[^}]*display:\s*flex;[^}]*flex-direction:\s*column/s, 'home sheet must allow the help button to sit at the bottom');
    assert.match(html, /\.home-metrics\s*\{[^}]*z-index:\s*32;[^}]*top:\s*518px/s, 'home dashboard must move 38px lower with the sheet');
    assert.match(html, /\.home-metrics\s*\{[^}]*color:\s*var\(--hajnal-navy\);[^}]*background:\s*#FFFCFB;[^}]*backdrop-filter:\s*none/s, 'home clean-days dashboard must stay solid rather than glass');
    assert.ok(!/\.home-metrics\s*\{[^}]*box-shadow:\s*0 18px 38px rgba\(44,\s*46,\s*119,\s*\.16\)/s.test(html), 'home dashboard must not cast the old strong downward shadow over the lower card');
    assert.match(html, /\.home-metrics\s*\{[^}]*box-shadow:\s*0 2px 8px rgba\(44,\s*46,\s*119,\s*\.04\),\s*inset 0 1px 0 rgba\(255,\s*255,\s*255,\s*\.68\)/s, 'home dashboard shadow must be subtle enough not to darken the top of the lower card');
    assert.match(html, /\.metric strong\s*\{[^}]*color:\s*var\(--hajnal-navy\)/s, 'clean-days number must not inherit white text');
    assert.match(html, /\.tasks-card\s*\{[^}]*border:\s*0;[^}]*background:\s*transparent;[^}]*box-shadow:\s*none/s, 'home task list must be merged into the lower sheet, not a separate card');
    assert.match(html, /\.task-row\s*\{[^}]*min-height:\s*24px/s, 'home task rows must be compact enough to fit in the sheet');
    assert.match(html, /\.home-actions\s*\{[^}]*margin-top:\s*auto/s, 'home help button must sit at the bottom of the sheet');
    assert.match(html, /\.help-button\s*\{[^}]*border:\s*0;[^}]*background:\s*linear-gradient\(160deg,\s*#FF78A8,\s*#E04D86\);[^}]*box-shadow:\s*0 18px 38px rgba\(239,\s*85,\s*145,\s*\.26\)/s, 'home help button must reuse the panic button fill and glow without the distracting inner container ring');
    assert.ok(homeScreen.includes('<svg class="icon" aria-hidden="true"><use href="#icon-heart"></use></svg>Segítség kell'), 'home help button must show a heart icon instead of the bullet marker');
    assert.ok(!homeScreen.includes('>◉</span>Segítség kell'), 'home help button must not keep the old dot marker');
    assert.ok(homeScreen.includes('class="segmented-progress"'), 'home dashboard needs a segmented progress bar');
    assert.ok(homeScreen.includes('class="dashboard-separator"'), 'home dashboard needs the center separator');
    assert.ok(homeScreen.includes('class="home-hero-image" src="assets/hero_fullscreen2_svg.svg"'), 'home hero must use the fullscreen2 SVG asset');
    assert.ok(homeScreen.includes('data-action="mark-clean-today" data-target-screen="checkin-clean"'), 'home dashboard needs the clean-day action');
    assert.ok(homeScreen.includes('data-action="open-evening-checkin" data-target-screen="checkin-clean"'), 'home checklist evening check-in must start the new clean-day sheet flow');
    expectScreenContains('home-collapsed', [
      'class="phone-screen home-screen home-collapsed-screen"',
      'data-screen="home-collapsed"',
      'data-parent-screen="notifications"',
      'data-state="collapsed"',
      'data-action="expand-home-card" data-target-screen="home"',
      'data-action="mark-clean-today" data-target-screen="checkin-clean"',
      'class="home-hero-image" src="assets/hero_fullscreen2_svg.svg"',
      'Tiszta napok',
      'Ma tiszta<br>maradtam'
    ]);
    assert.ok(!collapsedHomeScreen.includes('class="home-body"'), 'collapsed home must not show the large opened lower card');
    assert.ok(!collapsedHomeScreen.includes('class="tasks-card"'), 'collapsed home must not show the checklist');
    assert.ok(!collapsedHomeScreen.includes('Mai feladataim'), 'collapsed home must not include checklist heading');
    assert.match(html, /\.home-collapsed-screen \.home-metrics\s*\{[^}]*top:\s*614px/s, 'collapsed home dashboard must sit lower than the previous 590px position');
    const collapsedNavStart = collapsedHomeScreen.indexOf('<nav class="bottom-nav"');
    assert.ok(collapsedNavStart !== -1, 'collapsed home must render its own bottom navigation');
    const collapsedNavEnd = collapsedHomeScreen.indexOf('</nav>', collapsedNavStart);
    const collapsedNav = collapsedHomeScreen.slice(collapsedNavStart, collapsedNavEnd);
    assert.ok(collapsedNav.includes('data-target-screen="home-collapsed"'), 'collapsed home current nav item must target the collapsed home screen');
    for (const label of ['Kezdőlap', 'Haladás', 'Eszközök', 'Szponzor', 'Profil']) {
      assert.ok(collapsedNav.includes(label), `collapsed home bottom nav is missing ${label}`);
    }
    assert.ok(collapsedNav.includes('data-target-screen="progress-overview"'), 'collapsed home Haladás nav item must target the progress overview');
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
    assert.ok(nav.includes('data-target-screen="progress-overview"'), 'expanded home Haladás nav item must target the progress overview');
  },

  homeBranch() {
    const collapsedHomeScreen = screenSlice('home-collapsed');
    const homeScreen = screenSlice('home');
    const dailyImageScreen = screenSlice('daily-image');
    const cleanRewardScreen = screenSlice('checkin-clean');
    const eveningReflectionScreen = screenSlice('evening-reflection');
    const savedScreen = screenSlice('reflection-saved');
    const relapseScreen = screenSlice('checkin-relapse');
    expectOrdered([
      'data-screen="home-collapsed"',
      'data-screen="home"',
      'data-screen="checkin-clean"',
      'data-screen="evening-reflection"',
      'data-screen="reflection-saved"',
      'data-screen="panic-root"',
      'data-screen="checkin-survival-pack"',
      'data-screen="survival-stop"',
      'data-screen="survival-breathe"',
      'data-screen="survival-water"',
      'data-screen="survival-outside"',
      'data-screen="survival-note"',
      'data-screen="survival-call-sponsor"',
      'data-screen="panic-emergency-help"',
      'data-screen="checkin-relapse"',
      'data-screen="daily-image"',
      'data-screen="progress-overview"'
    ]);
    [
      'Napi kép',
      'Mai feladataim',
      'Ma tiszta maradtam',
      'Megcsináltad!',
      '25. nap',
      'Szeretnél pár percet szánni az esti reflexióra?',
      'Segít lezárni a napot',
      'és tisztábban látni holnap.',
      'Most, 2 percet rászánok',
      'Később',
      'Esti reflexió',
      'Pár perc csak magadnak.',
      '1. Hogy érzed magad?',
      '2. Ma miről szeretnél írni?',
      '3. Írd le a gondolataidat',
      'Mi volt ma a legjobb?',
      'Mi volt ma a nehéz?',
      'Miért vagy hálás?',
      'Nem szeretném elfelejteni...',
      'Kezdj el írni...',
      '0 karakter',
      'Hála lista',
      '3. Miért vagy hálás ma?',
      'Írj le legalább 3 dolgot, amiért ma hálás vagy.',
      'Új hozzáadása',
      'Fotó hozzáadása',
      'Hangjegyzet',
      'Később',
      'Mentés',
      'Elmentve!',
      'Köszönöm,',
      'hogy ma is időt szántál',
      'magadra.',
      'Vissza a kezdőlapra',
      '2 mp múlva visszairányítunk.',
      'Ma visszaestem',
      'Köszönjük,',
      'hogy őszinte voltál.',
      '15 perces túlélő csomag',
      'Nem kell tökéletesnek lenned',
      'Pánik mód',
      'Nem vagy egyedül.'
    ].forEach(expectContains);
    expectContains('data-action="open-daily-image" data-target-screen="daily-image"');
    expectContains('data-action="open-daily-image" data-target-screen="daily-image" data-trigger="home-image-tap"');
    expectContains('Napi kép (a főmenü képére tap indítja)');
    expectContains('data-action="expand-home-card" data-target-screen="home"');
    expectContains('data-action="mark-clean-today" data-target-screen="checkin-clean"');
    expectContains('data-action="start-evening-reflection-now" data-target-screen="evening-reflection"');
    expectContains('data-action="skip-evening-reflection" data-target-screen="home"');
    expectContains('data-action="save-evening-reflection" data-target-screen="reflection-saved"');
    expectContains('data-action="open-panic" data-target-screen="panic-root"');
    expectContains('data-action="return-home-after-save" data-target-screen="home"');
    ['daily-checkin', 'evening-clean-reward', 'checkin-mood', 'checkin-craving', 'checkin-note', 'support-note', 'gratitude-add', 'photo-memo', 'voice-memo', 'support-next-step', 'checkin-motivation', 'daily-tasks', 'panic-mode', 'panic-survival-pack', 'panic-breathing'].forEach((id) => {
      expectAbsent(`data-screen="${id}"`);
      expectAbsent(`data-target-screen="${id}"`);
    });
    assert.ok(collapsedHomeScreen.indexOf('data-component="home-dashboard"') !== -1, 'collapsed home must keep the clean-days dashboard');
    assert.ok(collapsedHomeScreen.indexOf('data-component="home-dashboard"') < collapsedHomeScreen.indexOf('data-action="expand-home-card"'), 'collapsed home dashboard must render before the invisible expand hotspot');
    assert.ok(homeScreen.includes('class="home-body"'), 'expanded home state must remain the opened-card version');
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
    expectContains('data-component="daily-project-assets"');
    expectContains('Napi kép asset készlet');
    [
      ['logo_svg.svg', 'Logó'],
      ['welcome_svg.svg', 'Welcome'],
      ['hero_s_svg.svg', 'Hero S'],
      ['hero_m_svg.svg', 'Hero M'],
      ['hero_xl_svg.svg', 'Hero XL'],
      ['hero_fullscreen_svg.svg', 'Hero fullscreen'],
      ['hero_fullscreen2_svg.svg', 'Hero fullscreen 2'],
      ['hurray_svg.svg', 'Hurray']
    ].forEach(([asset, label]) => {
      expectContains(`data-asset-src="assets/${asset}"`);
      expectContains(`data-asset-label="${label}"`);
    });
    ['evening-reflection', 'reflection-saved', 'checkin-relapse', 'checkin-survival-pack']
      .forEach((id) => assert.ok(screenSlice(id).includes('class="checkin-bg" src="assets/hero_fullscreen_svg.svg"'), `${id} must use the fullscreen hero image`));
    assert.ok(cleanRewardScreen.includes('class="checkin-bg" src="assets/hurray_svg.svg"'), 'checkin-clean must use the hurray fullscreen image');
    assert.match(html, /\.checkin-fullscreen\s*\{[^}]*background:\s*#171848/s, 'check-in wizard screens must define a fullscreen dark base');
    assert.match(html, /\.checkin-bg\s*\{[^}]*position:\s*absolute;[^}]*inset:\s*0;[^}]*object-fit:\s*cover/s, 'fullscreen check-in hero image must cover the whole phone viewport');
    assert.match(html, /\.hurray-screen \.checkin-reward-copy\s*\{[^}]*margin:\s*126px 34px 0/s, 'hurray reward text must move up near the screen 10 title height');
    assert.ok(cleanRewardScreen.includes('data-auto-sheet-delay="2000"'), 'screen 11 must document the delayed slide-up reflection choice sheet');
    assert.ok(cleanRewardScreen.includes('data-reference-screenshot="Screenshot_20260718-232534.png"'), 'screen 11 must reference the source bottom-sheet screenshot');
    assert.ok(cleanRewardScreen.includes('class="reflection-choice-sheet"'), 'screen 11 must include the slide-up reflection choice card');
    assert.ok(cleanRewardScreen.includes('class="sheet-handle"'), 'the choice sheet must include the top handle');
    assert.ok(cleanRewardScreen.includes('class="sheet-moon-badge"'), 'the choice sheet must include the moon icon badge');
    assert.ok(!cleanRewardScreen.includes('data-auto-return-target="home"'), 'screen 11 must not auto-return before the user chooses from the sheet');
    assert.ok(!cleanRewardScreen.includes('data-action="continue-clean-reward"'), 'screen 11 must not expose a continue reward action');
    assert.ok(!cleanRewardScreen.includes('>Tovább</button>'), 'screen 11 must not show a Tovább button');
    expectScreenContains('evening-reflection', [
      'data-parent-screen="checkin-clean"',
      'data-reference-screenshots="Screenshot_20260718-223635.png Screenshot_20260718-225614.png"',
      'data-component="evening-reflection-panel"',
      'data-component="evening-scroll-area"',
      'data-reflection-prompt="gratitude"',
      'data-component="inline-memo-tools"',
      'Később',
      'data-action="save-evening-reflection" data-target-screen="reflection-saved"'
    ]);
    expectScreenContains('reflection-saved', [
      'data-parent-screen="evening-reflection"',
      'data-reference-screenshot="Screenshot_20260718-232635.png"',
      'data-auto-return-target="home"',
      'data-auto-return-delay="2000"',
      'class="reflection-saved-content"',
      'class="saved-check-ring"',
      'Elmentve!',
      'Köszönöm,',
      'hogy ma is időt szántál',
      'magadra.',
      'data-action="return-home-after-save" data-target-screen="home"'
    ]);
    assert.ok(relapseScreen.includes('data-parent-screen="home"'), 'screen 15 must remain a home-triggered branch even when placed at the end of the panic row');
    assert.match(html, /\.reflection-choice-sheet\s*\{[^}]*position:\s*absolute;[^}]*left:\s*24px;[^}]*right:\s*24px;[^}]*bottom:\s*28px;[^}]*border-radius:\s*32px;[^}]*background:\s*rgba\(255,\s*255,\s*255,\s*\.96\);[^}]*color:\s*var\(--hajnal-navy\)/s, 'screen 11 bottom sheet must match the source card placement and white design');
    assert.match(html, /\.sheet-primary\s*\{[^}]*min-height:\s*48px;[^}]*background:\s*linear-gradient\(135deg,\s*#7750D7,\s*#5F35B9\);[^}]*color:\s*#FFFFFF/s, 'bottom sheet primary action must match the screenshot purple button');
    assert.match(html, /\.sheet-secondary\s*\{[^}]*min-height:\s*48px;[^}]*background:\s*#FFFFFF;[^}]*color:\s*var\(--hajnal-purple\)/s, 'bottom sheet secondary action must match the screenshot white outline button');
    assert.match(html, /#evening-reflection \.checkin-content\s*\{[^}]*height:\s*calc\(var\(--screen-h\) - 32px\);[^}]*overflow:\s*hidden/s, 'screen 12 must keep a fixed mother container');
    assert.match(html, /\.evening-section-title\s*\{[^}]*color:\s*rgba\(226,\s*220,\s*242,\s*\.86\)/s, 'screen 12 section titles must use the darker screenshot text color');
    assert.match(html, /#evening-reflection \.evening-save-actions\s*\{[^}]*grid-template-columns:\s*96px 104px;[^}]*justify-content:\s*end/s, 'screen 12 footer buttons must be smaller and right-aligned');
    assert.ok(!eveningReflectionScreen.includes('Később folytatom'), 'screen 12 secondary footer button must use the shorter label');
    assert.match(html, /#evening-reflection \.evening-save-actions \.secondary-button,\s*#evening-reflection \.evening-save-actions \.primary-button\s*\{[^}]*white-space:\s*nowrap/s, 'screen 12 footer labels must stay on one line');
    assert.match(html, /\.reflection-saved-screen::after\s*\{[^}]*background:\s*linear-gradient\(180deg,\s*rgba\(20,\s*18,\s*64,\s*\.10\) 0%,\s*rgba\(97,\s*49,\s*118,\s*\.22\) 48%,\s*rgba\(10,\s*20,\s*37,\s*\.80\) 100%\)/s, 'final saved screen must use the screenshot dusk overlay');
    assert.match(html, /\.reflection-saved-content\s*\{[^}]*min-height:\s*calc\(var\(--screen-h\) - 32px\);[^}]*padding:\s*166px 32px 42px;[^}]*text-align:\s*center/s, 'final saved content must match the source vertical placement');
    assert.match(html, /\.saved-check-ring\s*\{[^}]*width:\s*106px;[^}]*height:\s*106px;[^}]*border:\s*5px solid rgba\(184,\s*126,\s*245,\s*\.82\)/s, 'final saved screen must include the large purple check ring');
    assert.match(html, /\.saved-return-button\s*\{[^}]*min-height:\s*50px;[^}]*background:\s*linear-gradient\(135deg,\s*#8054DD,\s*#6938C1\)/s, 'final saved CTA must match the screenshot button');
    expectCount(/data-component="daily-task-detail"/g, 0, 'daily task detail screens must be removed');
    expectCount(/data-component="checkin-support-option"/g, 0, 'deleted check-in support menu must not leave option rows behind');
    assert.equal((eveningReflectionScreen.match(/<textarea\b/g) || []).length, 1, 'screen 12 reflection editor textarea must be restored');
    expectCount(/<textarea\b/g, 3, 'reflection, workbook question, and journal entry editors must expose textareas');
  },

  progressBranch() {
    expectOrdered([
      'data-screen="daily-image"',
      'data-screen="progress-overview"',
      'data-screen="progress-journey"',
      'data-screen="progress-day-detail"',
      'data-screen="progress-calendar"',
      'data-screen="progress-stats"',
      'data-screen="progress-milestones"'
    ]);
    expectContains('data-page="progress" data-root-screen="progress-overview" data-row-screens="progress-overview progress-journey progress-day-detail progress-calendar progress-stats progress-milestones"');
    [
      'Haladás',
      '24. nap',
      'a jelenlegi sorozatod',
      'Leghosszabb sorozat',
      '90 napos út',
      'Naptár',
      'Statisztikák',
      'Mérföldkövek',
      'Következő mérföldkő',
      '30 nap · Egy hónap',
      '1–30. nap',
      '31–60. nap',
      '61–90. nap',
      'Péntek, május 24.',
      'Esti check-in',
      'Hangulat',
      'Sóvárgás',
      'Szponzorral beszéltem',
      'Május 2024',
      'Részletek megnyitása',
      'Átlagos sóvárgás szint',
      'Check-in arány',
      'Legtöbbször használt eszközök',
      '1 nap',
      '3 nap',
      '7 nap',
      '14 nap',
      '30 nap',
      '45 nap',
      '60 nap',
      '90 nap',
      '180 nap'
    ].forEach(expectContains);
    [
      ['data-action="open-progress-journey" data-target-screen="progress-journey"', '90 napos út shortcut'],
      ['data-action="open-progress-calendar" data-target-screen="progress-calendar"', 'Naptár shortcut'],
      ['data-action="open-progress-stats" data-target-screen="progress-stats"', 'Statisztikák shortcut'],
      ['data-action="open-progress-milestones" data-target-screen="progress-milestones"', 'Mérföldkövek shortcut'],
      ['data-action="open-progress-day-detail" data-target-screen="progress-day-detail"', 'day detail target']
    ].forEach(([needle, label]) => assert.ok(html.includes(needle), `Missing ${label}`));
    assert.match(html, /\.progress-screen\s*\{[^}]*background:\s*linear-gradient\(180deg,\s*#FFF8FC/s, 'progress screens must use the warm blush utility surface');
    assert.match(html, /\.progress-menu-card\s*\{[^}]*border-radius:\s*12px;[^}]*background:\s*rgba\(255,\s*255,\s*255,\s*\.88\)/s, 'progress menu elements must use warm rounded boxes');
  },

  toolsBranch() {
    expectOrdered([
      'data-screen="progress-milestones"',
      'data-screen="tools-overview"',
      'data-screen="tools-steps"',
      'data-screen="tools-step-question"',
      'data-screen="tools-step-summary"',
      'data-screen="tools-journal-list"',
      'data-screen="tools-journal-entry"',
      'data-screen="tools-craving-log"',
      'data-screen="tools-journal-detail"'
    ]);
    expectContains('data-page="tools" data-root-screen="tools-overview" data-row-screens="tools-overview tools-steps tools-step-question tools-step-summary tools-journal-list tools-journal-entry tools-craving-log tools-journal-detail"');
    expectAbsent('data-target-screen="tools"');
    [
      'Eszközök',
      'Eszközök a felépülésedhez, minden nap.',
      '12 lépés munkafüzet',
      'Napló',
      'Sóvárgásnapló',
      'Hála lista',
      'Napi józansági kérdés',
      'Légzőgyakorlat',
      'Miért kezdtem el?',
      'Túlélőcsomag',
      'Pánik mód',
      '12 lépés munkafüzet',
      '3 / 12 lépés',
      '1 Beismertük tehetetlenségünket',
      '2 Elhittük, hogy létezik nálunk nagyobb erő',
      '2. lépés',
      '2 / 6 kérdés',
      'Mit jelent számodra az, hogy létezik nálad nagyobb erő?',
      '2. lépés összegzése',
      'Fontos gondolataid',
      'Szeretném megbeszélni a szponzorommal',
      'PDF export',
      'Megosztás',
      'Új bejegyzés',
      'Keresés a bejegyzések között...',
      'Nehéz nap volt, de nem adtam fel',
      'Új naplóbejegyzés',
      'Milyen címkét választasz?',
      'Hogyan érzed magad?',
      'Mennyire volt erős a sóvárgásod?',
      'Kép hozzáadása',
      'Hangfelvétel',
      'Mai nap',
      '3 bejegyzés',
      'Stressz a munka miatt',
      'Egyedüllét, unalom',
      'Reggel még nyugodt voltam',
      'Bejegyzések erről a hétvégi találkozón.',
      'Szerkesztés',
      'Törlés'
    ].forEach(expectContains);
    [
      ['data-action="open-tools-steps" data-target-screen="tools-steps"', '12-step workbook card'],
      ['data-action="open-tools-journal" data-target-screen="tools-journal-list"', 'journal card'],
      ['data-action="open-tools-craving" data-target-screen="tools-craving-log"', 'craving card'],
      ['data-action="open-tools-survival-pack" data-target-screen="checkin-survival-pack"', 'survival pack shortcut'],
      ['data-action="open-tools-panic" data-target-screen="panic-root"', 'panic mode shortcut'],
      ['data-action="open-tools-step-question" data-target-screen="tools-step-question"', 'step question target'],
      ['data-action="open-tools-step-summary" data-target-screen="tools-step-summary"', 'step summary target'],
      ['data-action="new-journal-entry" data-target-screen="tools-journal-entry"', 'new journal target'],
      ['data-action="open-journal-detail" data-target-screen="tools-journal-detail"', 'journal detail target']
    ].forEach(([needle, label]) => assert.ok(html.includes(needle), `Missing ${label}`));
    assert.match(html, /\.tools-screen\s*\{[^}]*background:\s*linear-gradient\(180deg,\s*#FFF8FC/s, 'tools screens must use the same warm utility surface as the source row');
    assert.match(html, /\.tools-menu-grid\s*\{[^}]*grid-template-columns:\s*repeat\(2,\s*1fr\)/s, 'tools overview must use a compact two-column menu grid');
    assert.match(html, /\.tools-hero-art\s*\{[^}]*background-image:\s*url\('assets\/hero_s_svg\.svg'\)/s, 'tools overview must use a project SVG hero asset, not a new PNG');
    expectAbsent('eszkozok_12lepes_naplo.png');
  },

  panicBranch() {
    const panicRootScreen = screenSlice('panic-root');
    expectOrdered([
      'data-screen="panic-root"',
      'data-screen="checkin-survival-pack"',
      'data-screen="survival-stop"',
      'data-screen="survival-breathe"',
      'data-screen="survival-water"',
      'data-screen="survival-outside"',
      'data-screen="survival-note"',
      'data-screen="survival-call-sponsor"',
      'data-screen="panic-help-message"',
      'data-screen="panic-backup-contact"',
      'data-screen="panic-why-started"',
      'data-screen="panic-meeting-finder"',
      'data-screen="panic-emergency-help"',
      'data-screen="checkin-relapse"'
    ]);
    [
      'Pánik mód elemei',
      'Sürgősségi segítség',
      'Hívd a szponzorod',
      'Hívd a tartalék kapcsolattartót',
      '15 perces túlélőcsomag',
      'Olvasd el, miért kezdted el',
      'Keresd meg a következő meetinget',
      'Szakmai vagy sürgősségi segítség',
      'Szponzor',
      'Kapcsolattartó',
      'Gyors üzenetek',
      'Hívás indítása',
      'Állj meg.',
      'Ne csinálj semmit 10 másodpercig.',
      'Lélegezz.',
      'Vegyél 5 lassú, mély levegőt.',
      'Igyál vizet.',
      'Egy korty is számít.',
      'Menj ki.',
      'Friss levegő. Változtass környezetet.',
      'Írj egy mondatot.',
      'Írd ki, ami benned van. Csak őszintén.',
      'Most hívd fel a szponzorodat.',
      'Nem kell egyedül megcsinálnod.',
      'Meeting keresése',
      'Ma visszaestem'
    ].forEach(expectContains);
    expectAbsent('data-screen="panic-help-sheet"');
    expectAbsent('id="column-panic-help-sheet"');
    expectAbsent('data-target-screen="panic-help-sheet"');
    expectAbsent('Segítség kell panel');
    expectAbsent('data-screen="panic-sponsor-call"');
    expectAbsent('id="column-panic-sponsor-call"');
    expectAbsent('data-target-screen="panic-sponsor-call"');
    expectContains('data-action="start-survival-pack" data-target-screen="checkin-survival-pack"');
    expectContains('data-action="start-checkin-survival" data-target-screen="survival-stop"');
    [
      ['survival-stop', '1 / 6', 'Kész', 'survival-breathe'],
      ['survival-breathe', '2 / 6', 'Kész', 'survival-water'],
      ['survival-water', '3 / 6', 'Kész', 'survival-outside'],
      ['survival-outside', '4 / 6', 'Kész', 'survival-note'],
      ['survival-note', '5 / 6', 'Írni fogok', 'survival-call-sponsor'],
      ['survival-call-sponsor', '6 / 6', 'Hívás', 'panic-help-message']
    ].forEach(([id, step, cta, target]) => {
      const screen = screenSlice(id);
      assert.ok(screen.includes(`data-survival-step="${step}"`), `${id} must expose its source step counter`);
      assert.ok(screen.includes(`>${cta}</button>`), `${id} must use the source CTA label`);
      assert.ok(screen.includes(`data-target-screen="${target}"`), `${id} CTA must target ${target}`);
      assert.ok(screen.includes('class="survival-flow-card"'), `${id} must use the guided survival flow card layout`);
    });
    expectAbsent('15perc.png');
    expectContains('data-action="meeting-finder" data-target-screen="panic-meeting-finder"');
    const panicMainButtons = html.match(/<button class="panic-main-button"[\s\S]*?<\/button>/g) || [];
    assert.equal(panicMainButtons.length, 1, 'panic flow must keep only the screen 16 large help button after deleting screen 24');
    panicMainButtons.forEach((button) => {
      assert.ok(button.includes('<svg class="icon" aria-hidden="true"><use href="#icon-heart"></use></svg>'), 'large help button must show a heart icon');
      assert.ok(button.includes('<span>Segítség<br>kell</span>'), 'large help button label must stay two lines under the heart icon');
      assert.ok(button.includes('data-action="focus-panic-options"'), 'large help button must remain a local CTA after deleting the panel target');
      assert.ok(!button.includes('data-target-screen='), 'large help button must not target a deleted screen');
    });
    assert.match(html, /\.panic-main-button\s*\{[^}]*display:\s*flex;[^}]*flex-direction:\s*column;[^}]*border:\s*0;[^}]*background:\s*#F15D9A;[^}]*box-shadow:\s*0 18px 38px rgba\(239,\s*85,\s*145,\s*\.26\),\s*0 0 0 9px rgba\(241,\s*142,\s*175,\s*\.23\)/s, 'panic main help button must use a homogeneous solid fill with the existing outer glow as an outside ring');
    assert.ok(!/\.panic-main-button\s*\{[^}]*background:\s*linear-gradient/s.test(html), 'panic main help button must not keep the darker gradient interior');
    assert.match(html, /\.panic-main-button \.icon\s*\{[^}]*width:\s*28px;[^}]*height:\s*28px/s, 'panic main help button heart icon must have a stable size');
    expectAbsent('data-screen="checkin-breathing"');
    expectAbsent('data-action="breathing" data-target-screen="checkin-breathing"');
    expectAbsent('id="column-checkin-breathing"');
    expectAbsent('LÉGZŐGYAKORLAT');
    assert.ok(!panicRootScreen.includes('Küldj segítségkérő üzenetet'), 'screen 16 must remove the direct help-message quick button');
    assert.ok(!panicRootScreen.includes('data-action="send-help-message"'), 'screen 16 must remove the direct help-message action');
    assert.ok(!panicRootScreen.includes('Szakmai vagy sürgősségi segítség'), 'screen 16 must remove the direct professional-help quick button');
    assert.ok(!panicRootScreen.includes('data-action="emergency-help"'), 'screen 16 must remove the direct professional-help action');
    assert.ok(panicRootScreen.includes('data-action="call-sponsor" data-target-screen="panic-help-message"'), 'screen 16 sponsor quick option must target the integrated screen 26');
    assert.ok(panicRootScreen.includes('data-action="report-relapse" data-target-screen="checkin-relapse"'), 'screen 16 must include a relapse button targeting checkin-relapse');
    assert.ok(panicRootScreen.includes('>Visszaestem</button>'), 'screen 16 relapse button must be labeled Visszaestem');
    const sponsorMessageScreen = screenSlice('panic-help-message');
    const backupContactScreen = screenSlice('panic-backup-contact');
    [
      [sponsorMessageScreen, 'panic-help-message', 'Kata', '+36 30 123 4567', 'data-action="start-sponsor-call"', 'data-action="send-sponsor-template"', 'Szponzor'],
      [backupContactScreen, 'panic-backup-contact', 'Anya', '+36 30 987 6543', 'data-action="start-backup-call"', 'data-action="send-backup-template"', 'Tartalék kapcsolattartó']
    ].forEach(([screen, id, contactName, phone, callAction, messageAction, title]) => {
      assert.ok(screen.includes(`data-contact-layout="contact-call-messages"`), `${id} must expose the shared contact/call/messages layout`);
      assert.ok(screen.includes(`data-component="panic-contact-card"`), `${id} must have a contact card`);
      assert.ok(screen.includes(contactName), `${id} must include contact name`);
      assert.ok(screen.includes(phone), `${id} must include contact phone`);
      assert.ok(screen.includes(`data-component="panic-call-card"`), `${id} must have a call-start card`);
      assert.ok(screen.includes(callAction), `${id} must expose its call action`);
      assert.ok(screen.includes('Hívás indítása'), `${id} must label the call-start card`);
      assert.ok(screen.includes(`data-component="panic-quick-messages"`), `${id} must have a quick messages section`);
      assert.ok(screen.includes(messageAction), `${id} must expose template message actions`);
      assert.ok(screen.includes(title), `${id} must keep the correct contact title`);
      assert.ok(screen.indexOf('data-component="panic-contact-card"') < screen.indexOf('data-component="panic-call-card"'), `${id} contact card must be above call card`);
      assert.ok(screen.indexOf('data-component="panic-call-card"') < screen.indexOf('data-component="panic-quick-messages"'), `${id} call card must be above quick messages`);
    });
    expectCount(/class="screen-row/g, 6, 'screen row count');
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
    expectCount(/class="screen-row/g, 6, 'screen row count');
    expectContains('data-page="entry" data-root-screen="splash" data-row-screens="welcome-lighting-lab splash onboarding information start-date recovery-goal sponsor-setup notifications"');
    expectContains('data-page="home" data-root-screen="home-collapsed" data-row-screens="home-collapsed home checkin-clean evening-reflection reflection-saved"');
    expectContains('data-page="panic" data-root-screen="panic-root" data-row-screens="panic-root checkin-survival-pack survival-stop survival-breathe survival-water survival-outside survival-note survival-call-sponsor panic-help-message panic-backup-contact panic-why-started panic-meeting-finder panic-emergency-help checkin-relapse"');
    expectContains('data-page="daily-image" data-root-screen="daily-image" data-row-screens="daily-image"');
    expectContains('data-page="progress" data-root-screen="progress-overview" data-row-screens="progress-overview progress-journey progress-day-detail progress-calendar progress-stats progress-milestones"');
    expectContains('data-page="tools" data-root-screen="tools-overview" data-row-screens="tools-overview tools-steps tools-step-question tools-step-summary tools-journal-list tools-journal-entry tools-craving-log tools-journal-detail"');
    const parents = {
      onboarding: 'splash',
      information: 'onboarding',
      'start-date': 'onboarding',
      'recovery-goal': 'onboarding',
      'sponsor-setup': 'onboarding',
      notifications: 'onboarding',
      'home-collapsed': 'notifications',
      home: 'home-collapsed',
      'daily-image': 'home',
      'checkin-clean': 'home',
      'evening-reflection': 'checkin-clean',
      'reflection-saved': 'evening-reflection',
      'checkin-relapse': 'home',
      'panic-root': 'home',
      'checkin-survival-pack': 'panic-root',
      'survival-stop': 'checkin-survival-pack',
      'survival-breathe': 'survival-stop',
      'survival-water': 'survival-breathe',
      'survival-outside': 'survival-water',
      'survival-note': 'survival-outside',
      'survival-call-sponsor': 'survival-note',
      'panic-help-message': 'panic-root',
      'panic-backup-contact': 'panic-root',
      'panic-why-started': 'panic-root',
      'panic-meeting-finder': 'panic-root',
      'panic-emergency-help': 'panic-root',
      'progress-overview': 'home',
      'progress-journey': 'progress-overview',
      'progress-day-detail': 'progress-journey',
      'progress-calendar': 'progress-overview',
      'progress-stats': 'progress-overview',
      'progress-milestones': 'progress-overview',
      'tools-overview': 'home',
      'tools-steps': 'tools-overview',
      'tools-step-question': 'tools-steps',
      'tools-step-summary': 'tools-step-question',
      'tools-journal-list': 'tools-overview',
      'tools-journal-entry': 'tools-journal-list',
      'tools-craving-log': 'tools-overview',
      'tools-journal-detail': 'tools-journal-list'
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
