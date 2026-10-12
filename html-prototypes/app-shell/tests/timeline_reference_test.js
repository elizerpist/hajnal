'use strict';

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
const timelineHero = path.join(root, 'assets', 'hero', 'timelinehero.png');
const historyDetailStart = html.indexOf('<section class="route-screen history-detail-screen"');
const eventDetailStart = html.indexOf('<section class="route-screen timeline-event-detail-screen"');
const eventDetailEnd = html.indexOf('<section class="route-screen', eventDetailStart + 1);
const historyDetail = html.slice(historyDetailStart, eventDetailStart);
const eventDetail = html.slice(eventDetailStart, eventDetailEnd === -1 ? html.length : eventDetailEnd);
const timelinePanelStart = historyDetail.indexOf('data-history-detail-panel="timeline"');
const calendarPanelStart = historyDetail.indexOf('data-history-detail-panel="calendar"');
const timelinePanel = historyDetail.slice(timelinePanelStart, calendarPanelStart);
const historyPeriodTimelinesStart = html.indexOf('const HISTORY_PERIOD_TIMELINES =');
const historyPeriodTimelinesEnd = html.indexOf('const HISTORY_CALENDAR_WEEKDAYS =');
const historyPeriodTimelines = html.slice(historyPeriodTimelinesStart, historyPeriodTimelinesEnd);

assert.ok(fs.existsSync(timelineHero), 'the supplied timeline detail hero must be copied into the canonical app-shell assets');
assert.equal(
  crypto.createHash('sha256').update(fs.readFileSync(timelineHero)).digest('hex'),
  '796531a3c99b48936199e3355a3ba136b4a2483dab8dd5e27a506818b44268b0',
  'timelinehero.png must remain byte-identical to the supplied source asset',
);
assert.ok(html.includes('padding: 24px 18px 17px;'), 'the fixed History quote must move another 10 px upward to enlarge its card scroll region');

assert.ok(historyDetailStart >= 0 && eventDetailStart > historyDetailStart, 'the current-period timeline and its event detail must be separate semantic routes');
[
  'data-history-detail-tab="timeline"',
  'data-history-detail-tab="calendar"',
  'Idővonal',
  'Naptár',
  'class="timeline-period-hero"',
  'data-component="timeline-hero-image"',
  'data-history-presentation-surface="timeline"',
  '24 nap tiszta',
  'Február 2025',
  'Idővonalam számokban',
  'class="history-number-summary"',
  'data-component="history-metrics-surface"',
].forEach((expected) => assert.ok(historyDetail.includes(expected), `source-right timeline is missing ${expected}`));
assert.equal((historyDetail.match(/data-history-detail-tab=/g) || []).length, 2, 'the current period has exactly Idővonal and Naptár tabs');
assert.ok(!historyDetail.includes('Statisztikák'), 'the current-period source-right view must not expose a Statisztikák tab or heading');
assert.ok(!historyDetail.includes('history-timeline-filters'), 'the Timeline must not retain the removed filter-pill row');
assert.ok(!historyDetail.includes('data-history-timeline-filter'), 'the Timeline must not retain filter-pill interactions');
assert.ok(historyDetail.includes('src="assets/hero/timelinehero.png"'), 'the Timeline must initially bind the shared Rail hero image');
assert.ok(historyDetail.includes('data-action="toggle-history-hero-variant"'), 'the Timeline hero needs the shared semantic push-push layout trigger');
assert.ok(!timelinePanel.includes('history-clean-card'), '24 nap tiszta must not remain in a Timeline body clean-day card');
assert.ok(!historyDetail.includes('history-metrics-toggle'), 'all Timeline insight cards must remove their dedicated arrow trigger');
assert.ok(timelinePanel.includes('data-component="history-period-timeline-events"'), 'the one stable Timeline event mount must remain inside its direct scroll region');
assert.ok(historyPeriodTimelinesStart >= 0 && historyPeriodTimelinesEnd > historyPeriodTimelinesStart, 'period-specific Timeline event content must have one immutable data source');
['Újrakezdtem', 'Irodalom', 'Jobban vagyok', '60 nap'].forEach((title) => assert.ok(historyPeriodTimelines.includes(title), `the current period data must retain ${title}`));
const currentTimelineMatch = /['"]?current['"]?: Object\.freeze\(\{[^]*?events: freezeHistoryPeriodTimelineEvents\(\[([^]*?)\]\) \}\)/.exec(historyPeriodTimelines);
assert.ok(currentTimelineMatch, 'the current period must keep an explicit immutable Timeline event collection');
assert.equal((currentTimelineMatch[1].match(/id: 'current-/g) || []).length, 12, 'the current period data must retain twelve Timeline events for the one internal scroll region');
assert.equal((timelinePanel.match(/class="history-detail-events-scroll"/g) || []).length, 1, 'the longer Timeline must retain exactly one internal scroll owner');
assert.match(html, /renderSelectedHistoryTimeline\(selected\)[^]*?data-action="open-timeline-event-detail"/, 'every data-driven Timeline event must remain a semantic event-detail trigger');
assert.ok(html.includes('.history-detail-screen[data-history-detail-view="timeline"] .history-detail-content { z-index: 2; top: 224px; grid-template-rows: 44px minmax(0, 1fr) auto;'), 'the overlapping Timeline body card must retain only its tabs above the scroll panel, above the hero');
assert.ok(html.includes('.history-detail-screen[data-history-detail-view="timeline"][data-history-hero-variant="compact"] .history-detail-content { top: 154px;'), 'the compact Timeline hero must raise the body card and grow its sole event-list scroll area');
assert.ok(html.includes(':is(.history-screen, .history-detail-screen[data-history-detail-view="timeline"], .history-detail-screen[data-history-detail-view="calendar"][data-history-calendar-view="grid"])[data-history-metrics-expanded="false"] .history-number-grid'), 'the Timeline insight payload must start from the shared collapsed metric primitive');
assert.ok(html.includes('.history-detail-events-scroll { min-height: 0; height: 100%; overflow-y: auto;'), 'only the event list may scroll inside the source-right timeline view');
assert.ok(html.includes(':is(.history-screen, .history-detail-screen[data-history-detail-view="timeline"])[data-history-metrics-expanded="false"] .history-number-summary { margin-top: var(--insight-rail-gap); }'), 'collapsed Timeline metrics must leave persistent breathing room above the insight rail without adding a second scroll owner');
assert.ok(!html.includes('historyTimelineFilter'), 'the controller must not retain state for removed Timeline filter pills');
assert.ok(!html.includes('selectHistoryTimelineFilter'), 'the controller must not retain the removed Timeline filter action');

[
  'id="timeline-event-detail"',
  'src="assets/hero/timelinehero.png"',
  'Esemény részletei',
  'Elindultam',
  '2024. december 28. • 10:24',
  'Ma döntöttem úgy, hogy új életet kezdek.',
  'Részletek',
  'Dátum',
  'Időpont',
  'Típus',
  'Mérföldkő',
  '#kezdet',
  '#döntés',
  '#remény',
  'Jegyzet',
  'Képek',
  'Szerkesztés',
  'Törlés',
  'data-action="return-to-history-detail"',
].forEach((expected) => assert.ok(eventDetail.includes(expected), `source-center event detail is missing ${expected}`));
assert.ok(!eventDetail.includes('route-bottom-nav'), 'the source-center event detail must not carry a BottomNav');
assert.ok(html.includes('.app-frame[data-route="timeline-event-detail"] .timeline-event-detail-screen'), 'the existing route switch must own event detail visibility');
[
  "case 'open-history-detail': this.openHistoryDetail('timeline', event.target.closest('[data-history-batch]')?.querySelector('h2')?.textContent); break;",
  "case 'open-history-detail-calendar': this.openHistoryDetail('calendar'); break;",
  "case 'toggle-history-hero-variant': this.toggleHistoryHeroVariant(event.target.closest('[data-history-presentation-surface]')?.dataset.historyPresentationSurface); break;",
  "case 'toggle-history-metrics': this.toggleHistoryMetrics(event.target.closest('[data-history-presentation-surface]')?.dataset.historyPresentationSurface); break;",
  "case 'open-timeline-event-detail': this.navigate('timeline-event-detail'); break;",
  "case 'return-to-history-detail': this.navigate('history'); break;",
  "historyPresentation: { history: { heroVariant: 'large', bodyPresentation: 'card', metricsExpanded: false }, timeline: { heroVariant: 'large', bodyPresentation: 'card', metricsExpanded: false }, calendar: { heroVariant: 'large', bodyPresentation: 'card', metricsExpanded: false } }",
  'toggleHistoryHeroVariant(surface = \'history\') {',
  'toggleHistoryMetrics(surface = \'history\') {',
  'renderHistoryPresentation(surface) {',
  "['history', 'history-detail', 'timeline-event-detail'].includes(this.state.route)",
].forEach((expected) => assert.ok(html.includes(expected), `the sole controller must own ${expected}`));
assert.ok(!/\bfetch\s*\(/.test(html), 'the timeline source implementation must remain fully local/offline');

console.log('PASS timeline source-reference contract');
