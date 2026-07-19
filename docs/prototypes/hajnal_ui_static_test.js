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
  'start-date',
  'recovery-goal',
  'sponsor-setup',
  'notifications',
  'home-collapsed',
  'home',
  'progress-milestones',
  'daily-image',
  'checkin-clean',
  'evening-reflection',
  'reflection-saved',
  'panic-root',
  'survival-stop',
  'survival-breathe',
  'survival-water',
  'survival-outside',
  'survival-note',
  'panic-help-message',
  'panic-why-started',
  'panic-meeting-finder',
  'checkin-relapse',
  'progress-overview',
  'progress-calendar',
  'progress-day-detail',
  'recovery-overview',
  'recovery-steps-overview',
  'recovery-step-detail',
  'recovery-evening',
  'tools-journal-list',
  'tools-journal-entry',
  'tools-journal-detail',
  'alt-progress-overview',
  'alt-progress-daily-view',
  'alt-progress-journal-entry',
  'alt-progress-calendar',
  'alt-progress-calendar-day',
  'alt-progress-statistics',
  'alt-progress-milestones',
  'alt-progress-milestone-detail',
  'alt-progress-activity',
  'alt-progress-activity-detail'
];

const altProgressScreens = [
  ['alt-progress-overview', 'Haladás - Áttekintés (#6)', 'progress-overview'],
  ['alt-progress-daily-view', 'Napi nézet', 'alt-progress-overview'],
  ['alt-progress-journal-entry', 'Naplóbejegyzés', 'alt-progress-daily-view'],
  ['alt-progress-calendar', 'Naptár (havi nézet)', 'alt-progress-overview'],
  ['alt-progress-calendar-day', 'Nap részlete (naptárból)', 'alt-progress-calendar'],
  ['alt-progress-statistics', 'Statisztikák', 'alt-progress-overview'],
  ['alt-progress-milestones', 'Mérföldkövek', 'alt-progress-overview'],
  ['alt-progress-milestone-detail', 'Mérföldkő részlete', 'alt-progress-milestones'],
  ['alt-progress-activity', 'Aktivitás (napló)', 'alt-progress-overview'],
  ['alt-progress-activity-detail', 'Aktivitás részlete', 'alt-progress-activity']
];

const altProgressFunctionalRequirements = {
  'alt-progress-overview': [
    'data-component="alt-progress-dashboard"',
    'data-component="alt-progress-menu-grid"',
    'data-target-screen="alt-progress-daily-view"',
    'data-target-screen="alt-progress-calendar"',
    'data-target-screen="alt-progress-statistics"',
    'data-target-screen="alt-progress-milestones"',
    'data-target-screen="alt-progress-activity"'
  ],
  'alt-progress-daily-view': [
    'data-component="alt-progress-day-switcher"',
    'data-component="alt-mood-selector"',
    'data-component="alt-mood-option"',
    'data-component="alt-progress-result-list"',
    'data-component="alt-progress-daily-note"',
    'data-target-screen="alt-progress-journal-entry"',
    '<textarea'
  ],
  'alt-progress-journal-entry': [
    'data-component="alt-progress-journal-card"',
    'data-action="alt-progress-edit-entry"',
    'data-action="alt-progress-share-entry"',
    'data-action="alt-progress-delete-entry"'
  ],
  'alt-progress-calendar': [
    'data-component="alt-progress-calendar-grid"',
    'data-component="alt-calendar-day"',
    'data-target-screen="alt-progress-calendar-day"',
    'data-component="alt-calendar-view-switch"'
  ],
  'alt-progress-calendar-day': [
    'data-component="alt-progress-calendar-day-summary"',
    'data-component="alt-progress-calendar-checklist"',
    'data-target-screen="alt-progress-journal-entry"'
  ],
  'alt-progress-statistics': [
    'data-component="alt-progress-period-tabs"',
    'data-component="alt-progress-line-chart"',
    'data-component="alt-progress-completion-ring"',
    'data-component="alt-progress-task-bars"'
  ],
  'alt-progress-milestones': [
    'data-component="alt-progress-milestone-tabs"',
    'data-component="alt-progress-milestone-list"',
    'data-component="alt-progress-next-milestone"',
    'data-target-screen="alt-progress-milestone-detail"'
  ],
  'alt-progress-milestone-detail': [
    'data-component="alt-progress-milestone-badge"',
    'data-component="alt-progress-milestone-meaning"',
    'data-action="alt-progress-share-milestone"'
  ],
  'alt-progress-activity': [
    'data-component="alt-progress-activity-tabs"',
    'data-component="alt-progress-activity-list"',
    'data-target-screen="alt-progress-activity-detail"'
  ],
  'alt-progress-activity-detail': [
    'data-component="alt-progress-activity-result"',
    'data-component="alt-progress-activity-detail-list"',
    'data-target-screen="alt-progress-activity"'
  ]
};

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
  assert.equal(fileSha256(prototypePath), fileSha256(referencePath), `${filename} prototype asset hash`);
  if (fs.existsSync(sourcePath)) {
    assert.equal(fileSha256(referencePath), fileSha256(sourcePath), `${filename} local source hash`);
  }
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
    expectCount(/class="phone-screen/g, 44, 'phone screen count');
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
    expectCount(/<img\b/g, 7, 'only the approved SVG splash, hero, hurray, and wizard images may use img tags');
    expectCount(/<img\b[^>]*src="assets\/hero_xl_svg\.svg"/g, 0, 'latest prototype must not keep the old XL SVG image tags');
    expectCount(/<img\b[^>]*src="assets\/welcome_svg\.svg"/g, 1, 'Splash must use the approved welcome SVG asset once');
    expectCount(/<img\b[^>]*src="assets\/hero_fullscreen2_svg\.svg"/g, 2, 'home states must use the approved fullscreen2 SVG asset as img tags');
    expectCount(/<img\b[^>]*src="assets\/hurray_svg\.svg"/g, 1, 'hurray reward screen must use the approved hurray SVG asset');
    expectCount(/<img\b[^>]*src="assets\/hero_fullscreen_svg\.svg"/g, 3, 'regular fullscreen flow image tags must use the approved fullscreen SVG asset');
    expectCount(/<img\b[^>]*src="assets\/hero_m_svg\.svg"/g, 0, 'check-in wizard must not use the old card-sized M SVG asset');
    expectCount(/href="#hajnal-logo-symbol"/g, 2, 'top and Splash icons must use the inline SVG logo symbol');
  },

  entry() {
    expectOrdered([
      'data-screen="welcome-lighting-lab"',
      'data-screen="splash"',
      'data-screen="onboarding"',
      'data-screen="start-date"'
    ]);
    [
      'Hajnal',
      'Csak a mai nap.',
      'Nem kell 90 napot egyszerre végigcsinálnod.',
      'Csak a mait.',
      'Kezdjük el',
      'Ma',
      'Tegnap',
      'Dátum kiválasztása'
    ].forEach(expectContains);
    expectContains('data-transition-delay="2000-3000"');
    expectContains('data-first-use-target="onboarding"');
    expectContains('data-returning-target="home"');
    expectContains('type="checkbox"');
    expectCount(/name="start-date"/g, 3, 'start-date choice count');
    expectAbsent('data-screen="information"');
    expectAbsent('data-target-screen="information"');
    expectAbsent('id="column-information"');
    expectAbsent('Már van fiókom');
    expectAbsent('Elolvastam és elfogadom.');
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
    expectScreenContains('onboarding', ['Kezdjük el', 'data-action="start-onboarding" data-target-screen="start-date"']);
    expectScreenContains('start-date', ['data-parent-screen="onboarding"', 'data-target-screen="onboarding"', 'Ma', 'Tegnap', 'Dátum kiválasztása']);
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
    for (const label of ['Kezdőlap', 'Haladás', 'Felépülés', 'Szponzor', 'Profil']) {
      assert.ok(collapsedNav.includes(label), `collapsed home bottom nav is missing ${label}`);
    }
    assert.ok(collapsedNav.includes('data-target-screen="progress-overview"'), 'collapsed home Haladás nav item must target the progress overview');
    assert.ok(collapsedNav.includes('data-target-screen="recovery-overview"'), 'collapsed home Felépülés nav item must target the recovery overview');
    expectCount(/data-component="daily-task"/g, 3, 'home daily task count');
    expectContains('<nav class="bottom-nav"');
    const navStart = html.indexOf('<nav class="bottom-nav"');
    const navEnd = html.indexOf('</nav>', navStart);
    const nav = html.slice(navStart, navEnd);
    let cursor = -1;
    for (const label of ['Kezdőlap', 'Haladás', 'Felépülés', 'Szponzor', 'Profil']) {
      const next = nav.indexOf(label, cursor + 1);
      assert.ok(next > cursor, `${label} is missing or out of order in bottom navigation`);
      cursor = next;
    }
    assert.ok(nav.includes('data-target-screen="progress-overview"'), 'expanded home Haladás nav item must target the progress overview');
    assert.ok(nav.includes('data-target-screen="recovery-overview"'), 'expanded home Felépülés nav item must target the recovery overview');
  },

  homeBranch() {
    const collapsedHomeScreen = screenSlice('home-collapsed');
    const homeScreen = screenSlice('home');
    const milestoneScreen = screenSlice('progress-milestones');
    const dailyImageScreen = screenSlice('daily-image');
    const cleanRewardScreen = screenSlice('checkin-clean');
    const eveningReflectionScreen = screenSlice('evening-reflection');
    const savedScreen = screenSlice('reflection-saved');
    const relapseScreen = screenSlice('checkin-relapse');
    expectOrdered([
      'data-screen="home-collapsed"',
      'data-screen="home"',
      'data-screen="progress-milestones"',
      'data-screen="daily-image"',
      'data-screen="checkin-clean"',
      'data-screen="evening-reflection"',
      'data-screen="reflection-saved"',
      'data-screen="panic-root"',
      'data-screen="survival-stop"',
      'data-screen="survival-breathe"',
      'data-screen="survival-water"',
      'data-screen="survival-outside"',
      'data-screen="survival-note"',
      'data-screen="checkin-relapse"',
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
      '15 perces túlélőcsomag',
      'Nem kell tökéletesnek lenned',
      'Pánik mód',
      'Nem vagy egyedül.'
    ].forEach(expectContains);
    expectContains('data-action="open-milestones" data-target-screen="progress-milestones"');
    expectContains('data-action="open-milestones" data-target-screen="progress-milestones" data-trigger="home-image-tap"');
    expectContains('data-action="expand-home-card" data-target-screen="home"');
    expectContains('data-action="mark-clean-today" data-target-screen="checkin-clean"');
    expectContains('data-action="start-evening-reflection-now" data-target-screen="evening-reflection"');
    expectContains('data-action="skip-evening-reflection" data-target-screen="home"');
    expectContains('data-action="save-evening-reflection" data-target-screen="reflection-saved"');
    expectContains('data-action="open-panic" data-target-screen="panic-root"');
    expectContains('data-action="return-home-after-save" data-target-screen="home"');
    ['daily-checkin', 'evening-clean-reward', 'checkin-mood', 'checkin-craving', 'checkin-note', 'support-note', 'gratitude-add', 'photo-memo', 'voice-memo', 'support-next-step', 'checkin-motivation', 'daily-tasks', 'panic-mode', 'panic-survival-pack', 'panic-breathing', 'checkin-survival-pack'].forEach((id) => {
      expectAbsent(`data-screen="${id}"`);
      expectAbsent(`data-target-screen="${id}"`);
    });
    assert.ok(collapsedHomeScreen.indexOf('data-component="home-dashboard"') !== -1, 'collapsed home must keep the clean-days dashboard');
    assert.ok(collapsedHomeScreen.indexOf('data-component="home-dashboard"') < collapsedHomeScreen.indexOf('data-action="expand-home-card"'), 'collapsed home dashboard must render before the invisible expand hotspot');
    assert.ok(homeScreen.includes('class="home-body"'), 'expanded home state must remain the opened-card version');
    assert.ok(milestoneScreen.includes('class="phone-screen milestone-gallery-screen"'), 'milestones must move into the home-row gallery screen');
    assert.ok(milestoneScreen.includes('data-parent-screen="home"'), 'milestones must be a main menu child screen');
    assert.ok(milestoneScreen.includes('data-component="milestone-gallery-grid"'), 'milestones must render as a gallery grid');
    assert.equal((milestoneScreen.match(/data-component="milestone-card"/g) || []).length, 9, 'milestone gallery must always expose exactly 9 cards');
    ['1', '3', '7', '14', '21', '30', '45', '60', '90'].forEach((day) => {
      assert.ok(milestoneScreen.includes(`data-milestone-day="${day}"`), `milestone day ${day} must be present`);
    });
    assert.ok(!milestoneScreen.includes('180 nap'), 'milestones must stop at the 90-day journey');
    assert.equal((milestoneScreen.match(/data-milestone-state="active"/g) || []).length, 5, '24 days must unlock five milestone cards');
    assert.equal((milestoneScreen.match(/data-milestone-state="inactive"/g) || []).length, 4, 'future milestone cards must stay inactive');
    assert.equal((milestoneScreen.match(/data-target-screen="daily-image"/g) || []).length, 5, 'only active milestone cards may target the daily image gallery');
    assert.equal((milestoneScreen.match(/disabled aria-disabled="true"/g) || []).length, 4, 'inactive milestone cards must be disabled and non-tappable');
    assert.match(html, /\.milestone-card:disabled\s*\{[^}]*background:\s*rgba\(232,\s*231,\s*238,\s*\.92\);[^}]*color:\s*rgba\(44,\s*46,\s*119,\s*\.40\);[^}]*cursor:\s*default/s, 'inactive milestone cards must be grey and non-interactive');
    assert.ok(dailyImageScreen.includes('class="phone-screen daily-image-screen no-nav"'), 'daily image screen must use the fullscreen screen variant');
    assert.ok(dailyImageScreen.includes('data-slide-mode="milestone-carousel"'), 'daily image screen must document milestone carousel behavior');
    assert.ok(dailyImageScreen.includes('data-parent-screen="progress-milestones"'), 'daily image screen must sit next to the milestone gallery');
    assert.ok(dailyImageScreen.includes('class="daily-image-back icon-button"'), 'daily image screen needs a top-left back button');
    assert.ok(dailyImageScreen.includes('data-action="return-to-milestones" data-target-screen="progress-milestones"'), 'daily image back button must return to milestones');
    assert.ok(dailyImageScreen.includes('data-component="daily-image-carousel"'), 'daily image screen must expose a horizontal swipe carousel');
    assert.equal((dailyImageScreen.match(/data-carousel-slide=/g) || []).length, 3, 'daily image carousel must expose multiple images for the selected milestone');
    assert.equal((dailyImageScreen.match(/class="daily-image-quote"/g) || []).length, 3, 'each carousel image must have its own quote');
    ['assets/hero_fullscreen2_svg.svg', 'assets/hero_fullscreen_svg.svg', 'assets/hurray_svg.svg'].forEach((asset) => {
      assert.ok(dailyImageScreen.includes(`--asset-url: url('${asset}')`), `${asset} must be available as a carousel slide`);
    });
    assert.ok(dailyImageScreen.includes('class="daily-image-progress" role="progressbar"'), 'daily image screen needs a semantic progress bar');
    assert.ok(dailyImageScreen.includes('aria-valuemin="0" aria-valuemax="90" aria-valuenow="24"'), 'daily image progress must expose the 90-day position');
    assert.ok(dailyImageScreen.includes('24. nap'), 'daily image screen needs the day label under the progress bar');
    assert.ok(dailyImageScreen.includes('a 90 napos úton'), 'daily image screen needs the 90-day subtitle under the progress bar');
    assert.ok(!dailyImageScreen.includes('daily-carousel-nav'), 'daily image screen must remove carousel navigation buttons');
    assert.ok(!dailyImageScreen.includes('data-carousel-slide="past"'), 'daily image screen must remove neighboring past preview');
    assert.ok(!dailyImageScreen.includes('data-carousel-slide="future"'), 'daily image screen must remove neighboring future preview');
    assert.ok(!dailyImageScreen.includes('daily-art-card'), 'daily image screen must remove the inner image container');
    assert.ok(!dailyImageScreen.includes('daily-art-actions'), 'daily image screen must remove bottom action buttons');
    assert.ok(!dailyImageScreen.includes('<header class="screen-header"'), 'daily image screen must not show the old title/header');
    expectAbsent('data-component="daily-project-assets"');
    expectAbsent('Napi kép asset készlet');
    expectAbsent('asset-preview-card');
    expectAbsent('data-asset-src="assets/logo_svg.svg"');
    ['evening-reflection', 'reflection-saved', 'checkin-relapse']
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
    expectCount(/<textarea\b/g, 3, 'reflection, journal entry, and functional alternative daily note editors must expose textareas');
  },

  progressBranch() {
    const progressOverviewScreen = screenSlice('progress-overview');
    expectOrdered([
      'data-screen="progress-overview"',
      'data-screen="progress-calendar"',
      'data-screen="progress-day-detail"',
      'data-screen="recovery-overview"'
    ]);
    expectContains('data-page="progress" data-root-screen="progress-overview" data-row-screens="progress-overview progress-calendar progress-day-detail"');
    [
      'Haladás',
      '24. nap',
      'a jelenlegi sorozatod',
      'Leghosszabb sorozat',
      'Naptár',
      'Következő mérföldkő',
      '30 nap · Egy hónap',
      'Péntek, május 24.',
      'Esti check-in',
      'Hangulat',
      'Sóvárgás',
      'Szponzorral beszéltem',
      'Május 2024',
      'Részletek megnyitása'
    ].forEach(expectContains);
    [
      ['data-action="open-progress-calendar" data-target-screen="progress-calendar"', 'Naptár shortcut'],
      ['data-action="open-progress-day-detail" data-target-screen="progress-day-detail"', 'day detail target']
    ].forEach(([needle, label]) => assert.ok(html.includes(needle), `Missing ${label}`));
    [
      'data-screen="progress-stats"',
      'id="progress-stats"',
      'id="column-progress-stats"',
      'data-target-screen="progress-stats"',
      'data-action="open-progress-stats"',
      'data-progress-shortcut="stats"',
      'Átlagos sóvárgás szint',
      'Legtöbbször használt eszközök',
      'Hangulat átlag',
      'Segítségkérés gyakorisága'
    ].forEach(expectAbsent);
    [
      'data-screen="progress-journey"',
      'id="progress-journey"',
      'id="column-progress-journey"',
      'data-target-screen="progress-journey"',
      'data-action="open-progress-journey"',
      'data-progress-shortcut="journey"',
      'data-component="general-statistics-summary"',
      '<span class="screen-index">17</span>',
      'Általános statisztika',
      '1–30. nap',
      '31–60. nap',
      '61–90. nap',
      'Check-in arány'
    ].forEach(expectAbsent);
    expectContains('<div class="screen-label"><span class="screen-index">18</span><strong>Naptár</strong> · Haladás child</div>');
    expectContains('<div class="screen-label"><span class="screen-index">19</span><strong>Napi részlet</strong> · Haladás child</div>');
    assert.ok(screenSlice('progress-day-detail').includes('data-parent-screen="progress-calendar"'), 'screen 19 must become a calendar child after deleting screen 17');
    assert.ok(!progressOverviewScreen.includes('data-progress-shortcut="milestones"'), 'progress overview must no longer contain the milestone shortcut');
    assert.ok(!progressOverviewScreen.includes('data-action="open-progress-milestones"'), 'progress overview must not open milestones directly');
    assert.ok(!progressOverviewScreen.includes('data-target-screen="progress-milestones"'), 'progress overview must not target the moved milestone screen');
    assert.match(html, /\.progress-screen\s*\{[^}]*background:\s*linear-gradient\(180deg,\s*#FFF8FC/s, 'progress screens must use the warm blush utility surface');
    assert.match(html, /\.progress-menu-card\s*\{[^}]*border-radius:\s*12px;[^}]*background:\s*rgba\(255,\s*255,\s*255,\s*\.88\)/s, 'progress menu elements must use warm rounded boxes');
  },

  toolsBranch() {
    expectOrdered([
      'data-screen="progress-milestones"',
      'data-screen="recovery-overview"',
      'data-screen="recovery-steps-overview"',
      'data-screen="recovery-step-detail"',
      'data-screen="recovery-evening"',
      'data-screen="tools-journal-list"',
      'data-screen="tools-journal-entry"',
      'data-screen="tools-journal-detail"'
    ]);
    expectAbsent('data-page="tools"');
    expectAbsent('data-target-screen="tools"');
    [
      'data-screen="tools-overview"',
      'data-screen="tools-steps"',
      'data-screen="tools-step-question"',
      'data-screen="tools-step-summary"',
      'data-screen="tools-craving-log"',
      'data-target-screen="tools-overview"',
      'data-target-screen="tools-steps"',
      'data-target-screen="tools-step-question"',
      'data-target-screen="tools-step-summary"',
      'data-target-screen="tools-craving-log"',
      'id="column-tools-overview"',
      'id="column-tools-steps"',
      'id="column-tools-step-question"',
      'id="column-tools-step-summary"',
      'id="column-tools-craving-log"',
      'data-component="recovery-services-overview"',
      'screen-index">S</span>',
      'Szolgáltatások áttekintése'
    ].forEach(expectAbsent);
    [
      'Felépülés',
      'Haladás',
      'Napló',
      'Hála lista',
      'Miért kezdtem el?',
      'Túlélőcsomag',
      'Új bejegyzés',
      'Keresés a bejegyzések között...',
      'Nehéz nap volt, de nem adtam fel',
      'Új naplóbejegyzés',
      'Milyen címkét választasz?',
      'Hogyan érzed magad?',
      'Mennyire volt erős a sóvárgásod?',
      'Kép hozzáadása',
      'Hangfelvétel',
      'Bejegyzések erről a hétvégi találkozón.',
      'Szerkesztés',
      'Törlés'
    ].forEach(expectContains);
    [
      ['data-action="open-recovery-progress" data-target-screen="progress-overview"', 'progress shortcut in recovery'],
      ['data-action="open-recovery-journal" data-target-screen="tools-journal-list"', 'journal card moved into recovery'],
      ['data-action="open-recovery-gratitude" data-target-screen="recovery-evening"', 'gratitude shortcut in recovery'],
      ['data-action="new-journal-entry" data-target-screen="tools-journal-entry"', 'new journal target'],
      ['data-action="open-journal-detail" data-target-screen="tools-journal-detail"', 'journal detail target']
    ].forEach(([needle, label]) => assert.ok(html.includes(needle), `Missing ${label}`));
    assert.ok(screenSlice('tools-journal-list').includes('data-parent-screen="recovery-overview"'), 'journal list must move under the recovery menu');
    expectAbsent('eszkozok_12lepes_naplo.png');
  },

  recoveryBranch() {
    const recoveryOverviewScreen = screenSlice('recovery-overview');
    expectOrdered([
      'data-screen="recovery-overview"',
      'data-screen="recovery-steps-overview"',
      'data-screen="recovery-step-detail"',
      'data-screen="recovery-evening"',
      'data-screen="tools-journal-list"',
      'data-screen="tools-journal-entry"',
      'data-screen="tools-journal-detail"'
    ]);
    expectContains('data-page="recovery" data-root-screen="recovery-overview" data-row-screens="recovery-overview recovery-steps-overview recovery-step-detail recovery-evening tools-journal-list tools-journal-entry tools-journal-detail"');
    [
      'Felépülés menü',
      '12 lépés és eszközök',
      'A felépülésed központja',
      'Felépülés',
      'Aktuális lépésed',
      '4. lépés',
      'Alapos és bátor erkölcsi leltárt készítettünk magunkról.',
      'Folytatás',
      'Esti reflexió',
      'Írd le a mai napod és gondolataid',
      'Bejegyzéseid',
      'Korábbi naplóbejegyzések',
      'Haladás',
      '90 napos út, naptár és mérföldkövek',
      'Napló',
      'Hála lista',
      'Támogatók és eszközök',
      'Miért kezdtem el?',
      'Emlékeztet arra, amiért itt vagy',
      'Túlélőcsomag',
      'Eszközök a nehéz pillanatokra',
      'Az út, amely egy nap egyszerre történik.',
      '4 / 12 lépés teljesítve',
      'Beismertük, hogy tehetetlenek vagyunk az alkohollal szemben',
      'Elhittük, hogy egy nálunk nagyobb erő visszaadhatja józan eszünket.',
      'Döntést hoztunk, hogy akaratunkat és életünket rábízzuk Istenre',
      'Ma erre fókuszál',
      'Írj őszintén az erősségeidről és a hibáidról.',
      'Kérdések a mai napra',
      'Milyen hibáim ismétlődnek?',
      'Kiknek ártottam a viselkedésemmel?',
      'Miben szeretnék változni?',
      'Napló írása a 4. lépésről',
      'Hogyan érzed magad most?',
      'Napi bejegyzéseid',
      'Május 20.',
      'Május 19.',
      'Május 18.',
      'Május 17.',
      'Felépülés'
    ].forEach(expectContains);
    [
      ['data-action="continue-recovery-step" data-target-screen="recovery-step-detail"', 'continue current step'],
      ['data-action="open-recovery-steps" data-target-screen="recovery-steps-overview"', 'open 12-step overview'],
      ['data-action="open-recovery-progress" data-target-screen="progress-overview"', 'progress menu target'],
      ['data-action="open-recovery-evening" data-target-screen="recovery-evening"', 'open recovery evening reflection'],
      ['data-action="open-recovery-journal" data-target-screen="tools-journal-list"', 'open entries shortcut'],
      ['data-action="open-recovery-gratitude" data-target-screen="recovery-evening"', 'open gratitude shortcut'],
      ['data-action="open-recovery-why-started" data-target-screen="panic-why-started"', 'why started shortcut'],
      ['data-action="open-recovery-survival-pack" data-target-screen="survival-stop"', 'survival package shortcut'],
      ['data-action="open-recovery-step-detail" data-target-screen="recovery-step-detail"', 'step detail target'],
      ['data-action="write-recovery-step-journal" data-target-screen="recovery-evening"', 'step journal CTA']
    ].forEach(([needle, label]) => assert.ok(html.includes(needle), `Missing ${label}`));
    [
      'data-action="open-recovery-daily-image"',
      'data-recovery-shortcut="daily-image"',
      '<strong>Napi kép</strong>',
      'Aznapi vizuális kép',
      'data-action="open-recovery-daily-question"',
      'data-recovery-shortcut="daily-question"',
      '<strong>Napi józansági kérdés</strong>',
      'data-action="open-recovery-breathing"',
      'data-recovery-shortcut="breathing"',
      '<strong>Légzőgyakorlat</strong>',
      'Nyugtató légzés, amikor kell',
      'data-action="open-recovery-panic"',
      'data-recovery-shortcut="panic"',
      '<strong>Pánik mód</strong>',
      'Azonnali segítség, ha szükséged van rá'
    ].forEach((needle) => assert.ok(!recoveryOverviewScreen.includes(needle), `Screen 30 must not include ${needle}`));
    let shortcutCursor = -1;
    [
      'data-recovery-shortcut="steps"',
      'data-recovery-shortcut="progress"',
      'data-recovery-shortcut="evening"',
      'data-recovery-shortcut="journal"',
      'data-recovery-shortcut="gratitude"',
      'data-recovery-shortcut="why-started"',
      'data-recovery-shortcut="survival"'
    ].forEach((needle) => {
      const next = recoveryOverviewScreen.indexOf(needle, shortcutCursor + 1);
      assert.ok(next > shortcutCursor, `Screen 30 remaining shortcut ${needle} is missing or out of order`);
      shortcutCursor = next;
    });
    assert.ok(recoveryOverviewScreen.includes('<nav class="bottom-nav"'), 'screen 30 must keep its bottom nav inside the phone');
    assert.ok(recoveryOverviewScreen.includes('aria-current="page" data-target-screen="recovery-overview"'), 'screen 30 bottom nav must keep Felépülés active');
    assert.ok(recoveryOverviewScreen.includes('data-action="open-recovery-why-started" data-target-screen="panic-why-started"'), 'screen 30 must include a Miért kezdtem el menu action');
    assert.match(html, /#recovery-overview \.recovery-content\s*\{[^}]*max-height:\s*calc\(var\(--screen-h\) - 68px - 70px\);[^}]*overflow-y:\s*auto;[^}]*padding-bottom:\s*18px/s, 'screen 30 recovery menu content must scroll above the bottom nav');
    assert.match(html, /#recovery-overview \.bottom-nav\s*\{[^}]*position:\s*relative;[^}]*z-index:\s*6/s, 'screen 30 bottom nav must stay visible below the scroll area');
    assert.match(html, /\.recovery-screen\s*\{[^}]*background:\s*linear-gradient\(180deg,\s*#FFF9F5/s, 'recovery screens must use the warm source-of-truth background');
    assert.match(html, /\.recovery-hero-card\s*\{[^}]*background:\s*url\("assets\/hero_s_svg\.svg"\)/s, 'recovery main hero must use an existing project SVG asset');
    assert.match(html, /\.recovery-step-art\s*\{[^}]*background:\s*url\("assets\/hero_fullscreen2_svg\.svg"\)/s, 'recovery detail art must use an existing project SVG asset');
    expectAbsent('12lepes.png');
  },

  altProgressBranch() {
    const rowScreens = altProgressScreens.map(([id]) => id).join(' ');
    expectOrdered([
      'data-screen="tools-journal-detail"',
      'data-page="alt-progress"',
      ...altProgressScreens.map(([id]) => `data-screen="${id}"`)
    ]);
    expectContains(`data-page="alt-progress" data-root-screen="alt-progress-overview" data-row-screens="${rowScreens}"`);
    expectContains('data-source-reference="/storage/emulated/0/hajnal/haladas.png"');
    expectContains('HALADÁS MENÜ - TELJES STRUKTÚRA ÉS NAVIGÁCIÓ');
    expectContains('Funkcionáló HTML menük - valódi containerek, gombok és állapotok');
    expectContains('data-component="alt-progress-menu-row"');
    expectAbsent('data-component="haladas-source-crop"');
    expectAbsent('data-component="alt-progress-source-row"');
    expectAbsent('data-source-crop=');
    expectAbsent('data-source-asset="assets/haladas.png"');
    expectAbsent('background-image: url("assets/haladas.png")');
    expectAbsent('alt-progress-source-screen');
    expectAbsent('alt-progress-source-column');
    expectAbsent('<img src="assets/haladas.png"');
    [
      'data-screen="alt-progress-day-detail"',
      'id="alt-progress-day-detail"',
      'id="column-alt-progress-day-detail"',
      'data-target-screen="alt-progress-day-detail"',
      'data-action="open-alt-day-detail"',
      '<span class="screen-index">A3</span>'
    ].forEach(expectAbsent);
    altProgressScreens.forEach(([id, title, parent]) => {
      const screen = screenSlice(id);
      assert.ok(screen.includes('class="phone-screen alt-progress-screen"'), `${id} must be a full functional phone screen`);
      assert.ok(screen.includes(`data-parent-screen="${parent}"`), `${id} parent must follow the alternative flow map`);
      assert.ok(screen.includes(`aria-label="${title}"`), `${id} must expose the source title`);
      assert.ok(!screen.includes('<img'), `${id} must not flatten the source design into an image`);
      assert.ok(screen.includes('<button'), `${id} must include native buttons for menu/actions`);
      (altProgressFunctionalRequirements[id] || []).forEach((needle) => {
        assert.ok(screen.includes(needle), `${id} is missing functional DOM marker ${needle}`);
      });
    });
    assert.equal((html.match(/class="screen-column alt-progress-column"/g) || []).length, altProgressScreens.length, 'every alternative progress screen must live in a normal labelled column');
    assert.match(html, /\.alt-progress-row\s*\{[^}]*display:\s*flex;[^}]*gap:\s*28px;[^}]*align-items:\s*flex-start/s, 'alternative progress row must be a bottom horizontal screen row');
    assert.match(html, /\.alt-progress-screen\s*\{[^}]*background:\s*linear-gradient\(180deg,\s*#FFF9F5/s, 'alternative progress screens must be CSS-rendered phone screens');
    assert.match(html, /\.alt-progress-menu-grid\s*\{[^}]*display:\s*grid;[^}]*grid-template-columns:\s*repeat\(2,\s*1fr\)/s, 'overview menu must be a real grid of controls');
    assert.match(html, /\.alt-progress-bottom-nav\s*\{[^}]*position:\s*absolute;[^}]*bottom:\s*0/s, 'alternative progress screens must use an anchored bottom nav');
  },

  panicBranch() {
    const panicRootScreen = screenSlice('panic-root');
    expectOrdered([
      'data-screen="panic-root"',
      'data-screen="survival-stop"',
      'data-screen="survival-breathe"',
      'data-screen="survival-water"',
      'data-screen="survival-outside"',
      'data-screen="survival-note"',
      'data-screen="panic-help-message"',
      'data-screen="panic-why-started"',
      'data-screen="panic-meeting-finder"',
      'data-screen="checkin-relapse"'
    ]);
    [
      'Pánik mód elemei',
      'Hívd a szponzorod',
      'Hívd a tartalék kapcsolattartót',
      '15 perces túlélőcsomag',
      'Olvasd el, miért kezdted el',
      'Keresd meg a következő meetinget',
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
      'Hívj fel valakit',
      'Kapcsolattartók',
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
    expectAbsent('data-screen="checkin-survival-pack"');
    expectAbsent('id="column-checkin-survival-pack"');
    expectAbsent('data-target-screen="checkin-survival-pack"');
    expectAbsent('data-action="start-checkin-survival"');
    expectAbsent('data-screen="survival-call-sponsor"');
    expectAbsent('id="column-survival-call-sponsor"');
    expectAbsent('data-target-screen="survival-call-sponsor"');
    expectAbsent('data-screen="panic-backup-contact"');
    expectAbsent('id="column-panic-backup-contact"');
    expectAbsent('data-target-screen="panic-backup-contact"');
    expectAbsent('data-screen="panic-emergency-help"');
    expectAbsent('id="panic-emergency-help"');
    expectAbsent('id="column-panic-emergency-help"');
    expectAbsent('data-target-screen="panic-emergency-help"');
    expectAbsent('<span class="screen-index">32</span><strong>Szakmai segítség</strong>');
    expectAbsent('Sürgősségi segítség');
    expectAbsent('Szakmai vagy sürgősségi segítség');
    expectAbsent('open-emergency-sheet');
    expectContains('data-action="start-survival-pack" data-target-screen="survival-stop"');
    [
      ['survival-stop', '1 / 5', 'Kész', 'survival-breathe'],
      ['survival-breathe', '2 / 5', 'Kész', 'survival-water'],
      ['survival-water', '3 / 5', 'Kész', 'survival-outside'],
      ['survival-outside', '4 / 5', 'Kész', 'survival-note'],
      ['survival-note', '5 / 5', 'Hívni fogok', 'panic-help-message']
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
    assert.ok(panicRootScreen.includes('data-action="call-backup-contact" data-target-screen="panic-help-message"'), 'screen 16 backup quick option must target the combined call screen');
    assert.ok(panicRootScreen.includes('data-action="report-relapse" data-target-screen="checkin-relapse"'), 'screen 16 must include a relapse button targeting checkin-relapse');
    assert.ok(panicRootScreen.includes('>Visszaestem</button>'), 'screen 16 relapse button must be labeled Visszaestem');
    const callSomeoneScreen = screenSlice('panic-help-message');
    assert.ok(callSomeoneScreen.includes('data-contact-layout="combined-contact-accordions"'), 'combined call screen must expose the accordion contact layout');
    assert.ok(callSomeoneScreen.includes('<h3>Hívj fel valakit</h3>'), 'combined call screen title must be Hívj fel valakit');
    assert.equal((callSomeoneScreen.match(/data-component="panic-contact-accordion"/g) || []).length, 2, 'combined call screen must contain sponsor and backup accordions');
    [
      ['data-contact="sponsor"', 'data-contact-state="expanded"', 'Kata', '+36 30 123 4567', 'data-action="start-sponsor-call"', 'data-action="send-sponsor-template"', 'Szponzor'],
      ['data-contact="backup"', 'data-contact-state="collapsed"', 'Anya', '+36 30 987 6543', 'data-action="start-backup-call"', 'data-action="send-backup-template"', 'Tartalék kapcsolattartó']
    ].forEach(([contact, state, contactName, phone, callAction, messageAction, title]) => {
      assert.ok(callSomeoneScreen.includes(contact), `combined call screen must include ${contact}`);
      assert.ok(callSomeoneScreen.includes(state), `combined call screen must expose ${state}`);
      assert.ok(callSomeoneScreen.includes(contactName), `combined call screen must include ${contactName}`);
      assert.ok(callSomeoneScreen.includes(phone), `combined call screen must include ${phone}`);
      assert.ok(callSomeoneScreen.includes(callAction), `combined call screen must expose ${callAction}`);
      assert.ok(callSomeoneScreen.includes(messageAction), `combined call screen must expose ${messageAction}`);
      assert.ok(callSomeoneScreen.includes(title), `combined call screen must include ${title}`);
    });
    assert.equal((callSomeoneScreen.match(/data-component="panic-call-card"/g) || []).length, 2, 'each contact accordion must include a call card');
    assert.equal((callSomeoneScreen.match(/data-component="panic-quick-messages"/g) || []).length, 2, 'each contact accordion must include quick messages');
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
    expectContains('data-page="entry" data-root-screen="splash" data-row-screens="welcome-lighting-lab splash onboarding start-date recovery-goal sponsor-setup notifications"');
    expectContains('data-page="home" data-root-screen="home-collapsed" data-row-screens="home-collapsed home progress-milestones daily-image checkin-clean evening-reflection reflection-saved"');
    expectContains('data-page="panic" data-root-screen="panic-root" data-row-screens="panic-root survival-stop survival-breathe survival-water survival-outside survival-note panic-help-message panic-why-started panic-meeting-finder checkin-relapse"');
    expectAbsent('data-page="daily-image"');
    expectContains('data-page="progress" data-root-screen="progress-overview" data-row-screens="progress-overview progress-calendar progress-day-detail"');
    expectAbsent('data-page="tools"');
    expectContains('data-page="recovery" data-root-screen="recovery-overview" data-row-screens="recovery-overview recovery-steps-overview recovery-step-detail recovery-evening tools-journal-list tools-journal-entry tools-journal-detail"');
    expectContains(`data-page="alt-progress" data-root-screen="alt-progress-overview" data-row-screens="${altProgressScreens.map(([id]) => id).join(' ')}"`);
    const parents = {
      onboarding: 'splash',
      'start-date': 'onboarding',
      'recovery-goal': 'onboarding',
      'sponsor-setup': 'onboarding',
      notifications: 'onboarding',
      'home-collapsed': 'notifications',
      home: 'home-collapsed',
      'progress-milestones': 'home',
      'daily-image': 'progress-milestones',
      'checkin-clean': 'home',
      'evening-reflection': 'checkin-clean',
      'reflection-saved': 'evening-reflection',
      'checkin-relapse': 'home',
      'panic-root': 'home',
      'survival-stop': 'panic-root',
      'survival-breathe': 'survival-stop',
      'survival-water': 'survival-breathe',
      'survival-outside': 'survival-water',
      'survival-note': 'survival-outside',
      'panic-help-message': 'panic-root',
      'panic-why-started': 'panic-root',
      'panic-meeting-finder': 'panic-root',
      'progress-overview': 'home',
      'progress-day-detail': 'progress-calendar',
      'progress-calendar': 'progress-overview',
      'tools-journal-list': 'recovery-overview',
      'tools-journal-entry': 'tools-journal-list',
      'tools-journal-detail': 'tools-journal-list',
      'recovery-overview': 'home',
      'recovery-steps-overview': 'recovery-overview',
      'recovery-step-detail': 'recovery-steps-overview',
      'recovery-evening': 'recovery-overview',
      'alt-progress-overview': 'progress-overview',
      'alt-progress-daily-view': 'alt-progress-overview',
      'alt-progress-journal-entry': 'alt-progress-daily-view',
      'alt-progress-calendar': 'alt-progress-overview',
      'alt-progress-calendar-day': 'alt-progress-calendar',
      'alt-progress-statistics': 'alt-progress-overview',
      'alt-progress-milestones': 'alt-progress-overview',
      'alt-progress-milestone-detail': 'alt-progress-milestones',
      'alt-progress-activity': 'alt-progress-overview',
      'alt-progress-activity-detail': 'alt-progress-activity'
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
