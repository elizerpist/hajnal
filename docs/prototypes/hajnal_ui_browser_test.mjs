import assert from "node:assert/strict";
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const moduleName = process.env.HAJNAL_PLAYWRIGHT_MODULE || "playwright";
const { chromium } = await import(moduleName);

const prototypeDirectory = path.dirname(fileURLToPath(import.meta.url));
const htmlPath = path.join(prototypeDirectory, "..", "..", "html-prototypes", "offline-ui", "index.html");
const evidenceDirectory = path.join(prototypeDirectory, "verification");
const updateEvidence = process.env.HAJNAL_UPDATE_EVIDENCE === "1";
const scratchDirectory = fs.mkdtempSync(path.join(os.tmpdir(), "hajnal-browser-test-"));
const screenOrder = [
  ["splash", null],
  ["onboarding", "splash"],
  ["start-date", "onboarding"],
  ["sponsor-setup", "onboarding"],
  ["onboarding-why-started", "sponsor-setup"],
  ["notifications", "onboarding-why-started"],
  ["home-collapsed", "notifications"],
  ["home", "home-collapsed"],
  ["home-statistics", "home"],
  ["home-statistics-detail", "home-statistics"],
  ["home-statistics-detail-timeline", "home-statistics-detail"],
  ["home-statistics-timeline", "home"],
  ["progress-milestones", "home"],
  ["daily-image", "progress-milestones"],
  ["checkin-clean", "home"],
  ["evening-reflection", "checkin-clean"],
  ["reflection-saved", "evening-reflection"],
  ["evening-inventory-state", "home"],
  ["evening-inventory-recovery", "evening-inventory-state"],
  ["evening-inventory-connection", "evening-inventory-recovery"],
  ["evening-inventory-program", "evening-inventory-connection"],
  ["evening-inventory-honest-review", "evening-inventory-program"],
  ["evening-inventory-gratitude", "evening-inventory-honest-review"],
  ["evening-inventory-spirituality", "evening-inventory-gratitude"],
  ["evening-inventory-free-reflection", "evening-inventory-spirituality"],
  ["panic-root", "home"],
  ["survival-stop", "panic-root"],
  ["survival-breathe", "survival-stop"],
  ["survival-water", "survival-breathe"],
  ["survival-outside", "survival-water"],
  ["survival-note", "survival-outside"],
  ["panic-help-message", "panic-root"],
  ["panic-why-started", "panic-root"],
  ["panic-meeting-finder", "panic-root"],
  ["checkin-relapse", "panic-root"],
  ["progress-calendar", "home"],
  ["progress-day-detail", "progress-calendar"],
  ["recovery-overview", "home"],
  ["recovery-steps-overview", "recovery-overview"],
  ["recovery-step-detail", "recovery-steps-overview"],
  ["recovery-evening", "recovery-overview"],
  ["tools-journal-list", "recovery-overview"],
  ["tools-journal-entry", "tools-journal-list"],
  ["tools-journal-detail", "tools-journal-list"],
  ["alt-progress-daily-view", "progress-calendar"],
  ["alt-progress-journal-entry", "alt-progress-daily-view"],
  ["alt-progress-calendar-day", "alt-progress-daily-view"],
];
const altProgressScreens = [
  ["alt-progress-daily-view", "Napi nézet", "progress-calendar"],
  ["alt-progress-journal-entry", "Naplóbejegyzés", "alt-progress-daily-view"],
  ["alt-progress-calendar-day", "Nap részlete", "alt-progress-daily-view"],
];
const screenRows = [
  [
    "entry",
    "splash",
    "splash onboarding start-date sponsor-setup onboarding-why-started notifications",
    ["splash", "onboarding", "start-date", "sponsor-setup", "onboarding-why-started", "notifications"],
  ],
  [
    "home",
    "home-collapsed",
    "home-collapsed home",
    [
      "home-collapsed",
      "home",
    ],
  ],
  [
    "home-statistics-views",
    "home-statistics",
    "home-statistics home-statistics-detail home-statistics-detail-timeline",
    [
      "home-statistics",
      "home-statistics-detail",
      "home-statistics-detail-timeline",
    ],
  ],
  [
    "home-period-history",
    "home-statistics-timeline",
    "home-statistics-timeline progress-milestones",
    [
      "home-statistics-timeline",
      "progress-milestones",
    ],
  ],
  [
    "home-daily-close",
    "daily-image",
    "daily-image checkin-clean evening-reflection reflection-saved",
    [
      "daily-image",
      "checkin-clean",
      "evening-reflection",
      "reflection-saved",
    ],
  ],
  [
    "evening-inventory-wizard",
    "evening-inventory-state",
    "evening-inventory-state evening-inventory-recovery evening-inventory-connection evening-inventory-program evening-inventory-honest-review evening-inventory-gratitude evening-inventory-spirituality evening-inventory-free-reflection",
    [
      "evening-inventory-state",
      "evening-inventory-recovery",
      "evening-inventory-connection",
      "evening-inventory-program",
      "evening-inventory-honest-review",
      "evening-inventory-gratitude",
      "evening-inventory-spirituality",
      "evening-inventory-free-reflection",
    ],
  ],
  [
    "panic",
    "panic-root",
    "panic-root survival-stop survival-breathe survival-water survival-outside survival-note panic-help-message panic-why-started panic-meeting-finder checkin-relapse",
    [
      "panic-root",
      "survival-stop",
      "survival-breathe",
      "survival-water",
      "survival-outside",
      "survival-note",
      "panic-help-message",
      "panic-why-started",
      "panic-meeting-finder",
      "checkin-relapse",
    ],
  ],
  [
    "progress",
    "progress-calendar",
    "progress-calendar progress-day-detail",
    ["progress-calendar", "progress-day-detail"],
  ],
  [
    "recovery",
    "recovery-overview",
    "recovery-overview recovery-steps-overview recovery-step-detail recovery-evening tools-journal-list tools-journal-entry tools-journal-detail",
    ["recovery-overview", "recovery-steps-overview", "recovery-step-detail", "recovery-evening", "tools-journal-list", "tools-journal-entry", "tools-journal-detail"],
  ],
  [
    "alt-progress",
    "alt-progress-daily-view",
    altProgressScreens.map(([id]) => id).join(" "),
    altProgressScreens.map(([id]) => id),
  ],
];

function pngSize(filename) {
  const buffer = fs.readFileSync(filename);
  assert.equal(buffer.toString("ascii", 1, 4), "PNG", `${filename} must be a PNG`);
  return {
    width: buffer.readUInt32BE(16),
    height: buffer.readUInt32BE(20),
  };
}

function contentTypeFor(filename) {
  if (filename.endsWith(".html")) return "text/html; charset=utf-8";
  if (filename.endsWith(".svg")) return "image/svg+xml; charset=utf-8";
  if (filename.endsWith(".js")) return "text/javascript; charset=utf-8";
  if (filename.endsWith(".css")) return "text/css; charset=utf-8";
  return "application/octet-stream";
}

async function createStaticServer(rootDirectory) {
  const server = http.createServer((request, response) => {
    const requestPath = decodeURIComponent(new URL(request.url || "/", "http://127.0.0.1").pathname);
    const resolved = path.resolve(rootDirectory, `.${requestPath}`);
    if (!resolved.startsWith(rootDirectory)) {
      response.writeHead(403);
      response.end("Forbidden");
      return;
    }

    const target = fs.existsSync(resolved) && fs.statSync(resolved).isDirectory()
      ? path.join(resolved, "index.html")
      : resolved;

    fs.readFile(target, (error, data) => {
      if (error) {
        response.writeHead(404);
        response.end("Not found");
        return;
      }
      response.writeHead(200, { "Content-Type": contentTypeFor(target) });
      response.end(data);
    });
  });

  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  const { port } = server.address();
  return { server, baseUrl: `http://127.0.0.1:${port}` };
}

async function alignScreenForIntegerClip(screen) {
  await screen.scrollIntoViewIfNeeded();
  await screen.evaluate((element) => {
    const bounds = element.getBoundingClientRect();
    if (bounds.top < 0) window.scrollBy(0, Math.floor(bounds.top));
    if (bounds.bottom > window.innerHeight) window.scrollBy(0, Math.ceil(bounds.bottom - window.innerHeight));
  });
}

fs.mkdirSync(evidenceDirectory, { recursive: true });
const staticServer = await createStaticServer(path.dirname(htmlPath));

const browser = await chromium.launch({
  headless: true,
  args: ["--no-sandbox", "--disable-dev-shm-usage"],
});

try {
  const page = await browser.newPage({
    viewport: { width: 3900, height: 1900 },
    deviceScaleFactor: 1,
  });

  await page.goto(`${staticServer.baseUrl}/${path.basename(htmlPath)}`, { waitUntil: "networkidle" });

  const renderedOrder = await page.locator(".phone-screen").evaluateAll((screens) =>
    screens.map((screen) => screen.dataset.screen),
  );
  assert.deepEqual(renderedOrder, screenOrder.map(([id]) => id), "screen order");

  const renderedRows = await page.locator(".screen-row").evaluateAll((rows) =>
    rows.map((row) => [
      row.dataset.page,
      row.dataset.rootScreen,
      row.dataset.rowScreens,
      Array.from(row.querySelectorAll(".phone-screen")).map((screen) => screen.dataset.screen),
    ]),
  );
  assert.deepEqual(renderedRows, screenRows, "screen row layout");

  const rowPositions = await page.locator(".phone-screen").evaluateAll((screens) =>
    Object.fromEntries(
      screens.map((screen) => {
        const bounds = screen.getBoundingClientRect();
        return [screen.dataset.screen, { left: bounds.left + window.scrollX, top: bounds.top + window.scrollY }];
      }),
    ),
  );
  assert.ok(rowPositions["home-collapsed"].top > rowPositions.splash.top + 900, "home must render in the next row");
  assert.equal(rowPositions["home-collapsed"].left, rowPositions.splash.left, "home row must start at the same x position as the entry row");
  assert.ok(rowPositions["daily-image"].top > rowPositions["home-collapsed"].top + 900, "daily close row must render below the two home states");
  assert.equal(rowPositions["daily-image"].left, rowPositions["home-collapsed"].left, "daily close row must start at the same x position as the first home row");
  assert.equal(rowPositions["checkin-clean"].top, rowPositions["daily-image"].top, "screen 11 must render next to screen 9 in the daily close row");
  assert.ok(rowPositions["checkin-clean"].left > rowPositions["daily-image"].left, "screen 11 must sit directly to the right of screen 9");
  assert.equal(rowPositions["evening-reflection"].top, rowPositions["daily-image"].top, "screen 12 must render in the daily close row");
  assert.ok(rowPositions["evening-reflection"].left > rowPositions["checkin-clean"].left, "screen 12 must sit directly to the right of screen 11");
  assert.equal(rowPositions["reflection-saved"].top, rowPositions["daily-image"].top, "screen 10 must render in the daily close row");
  assert.ok(rowPositions["reflection-saved"].left > rowPositions["evening-reflection"].left, "screen 10 must sit directly to the right of screen 12");
  assert.ok(rowPositions["evening-inventory-state"].top > rowPositions["daily-image"].top + 900, "inventory row must render below the daily close row");
  assert.equal(rowPositions["evening-inventory-state"].left, rowPositions["daily-image"].left, "inventory row must start at the same x position as the daily close row");
  [
    "evening-inventory-recovery",
    "evening-inventory-connection",
    "evening-inventory-program",
    "evening-inventory-honest-review",
    "evening-inventory-gratitude",
    "evening-inventory-spirituality",
    "evening-inventory-free-reflection",
  ].forEach((id, index, ids) => {
    const predecessor = index === 0 ? "evening-inventory-state" : ids[index - 1];
    assert.equal(rowPositions[id].top, rowPositions["evening-inventory-state"].top, `${id} must remain in the inventory row`);
    assert.ok(rowPositions[id].left > rowPositions[predecessor].left, `${id} must follow its predecessor in the inventory row`);
  });
  assert.ok(rowPositions["home-statistics-timeline"].top > rowPositions["evening-inventory-state"].top + 900, "period history row must render below the inventory row");
  assert.equal(rowPositions["home-statistics-timeline"].left, rowPositions["evening-inventory-state"].left, "period history row must start at the same x position as the inventory row");
  assert.equal(rowPositions["progress-milestones"].top, rowPositions["home-statistics-timeline"].top, "milestones must render next to timeline screen 8E");
  assert.ok(rowPositions["progress-milestones"].left > rowPositions["home-statistics-timeline"].left, "milestones must sit directly to the right of screen 8E");
  assert.ok(rowPositions["panic-root"].top > rowPositions["home-statistics-timeline"].top + 900, "panic row must render directly below the period history row");
  assert.equal(rowPositions["panic-root"].left, rowPositions["home-statistics-timeline"].left, "panic row must start at the same x position as the timeline row");
  const statisticsMenuHeadingPosition = await page.locator("[data-statistics-menu-heading]").evaluate((heading) => {
    const bounds = heading.getBoundingClientRect();
    return { left: bounds.left + window.scrollX, top: bounds.top + window.scrollY, text: heading.textContent.replace(/\s+/g, " ").trim() };
  });
  assert.ok(statisticsMenuHeadingPosition.top > rowPositions["panic-root"].top + 900, "statistics menu heading must render below the panic row");
  assert.ok(statisticsMenuHeadingPosition.text.includes("Történetem") && statisticsMenuHeadingPosition.text.includes("Saját alsó navigáció"), "story heading must identify its bottom-navigation branch");
  assert.ok(rowPositions["home-statistics"].top > rowPositions["panic-root"].top + 900, "statistics views must render below the panic row");
  assert.ok(rowPositions["home-statistics"].top > statisticsMenuHeadingPosition.top, "statistics row must render below its menu heading");
  assert.equal(rowPositions["home-statistics"].left, rowPositions["panic-root"].left, "statistics views row must start at the same x position as the panic row");
  assert.equal(rowPositions["home-statistics-detail"].top, rowPositions["home-statistics"].top, "current period detail must render next to 8C in the statistics row");
  assert.ok(rowPositions["home-statistics-detail"].left > rowPositions["home-statistics"].left, "current period detail must sit directly to the right of the statistics screen");
  assert.equal(rowPositions["home-statistics-detail-timeline"].top, rowPositions["home-statistics"].top, "selected-batch Timeline must render beside 8D in the Statistics row");
  assert.ok(rowPositions["home-statistics-detail-timeline"].left > rowPositions["home-statistics-detail"].left, "selected-batch Timeline must sit directly to the right of 8D");
  const statisticsRowExplanation = await page.locator('[data-page="home-statistics-views"] .home-row-explanation').textContent();
  assert.ok(statisticsRowExplanation.includes("Józan időszakok, egy helyen"), "Statistics row must own the batch-model explanation");
  assert.ok(statisticsRowExplanation.includes("vízszintesen görgethető idővonal"), "Statistics explanation must describe horizontal batch scrolling");
  assert.ok(statisticsRowExplanation.includes("ez a három nézet készült el") && statisticsRowExplanation.includes("tervezés alatt van"), "Statistics explanation must state its current implementation scope");
  assert.equal(/statisztik/iu.test(statisticsRowExplanation), false, "8C/8D/8F explanation must not retain Statistics wording");
  assert.equal(
    /statisztik/iu.test(await page.locator('[data-page="home-statistics-views"]').textContent()),
    false,
    "8C/8D/8F rendered content must not retain Statistics wording",
  );
  assert.ok(rowPositions["recovery-overview"].top > rowPositions["home-statistics"].top + 900, "recovery row must render directly below the Statistics row");
  assert.ok(rowPositions["progress-calendar"].top > rowPositions["recovery-overview"].top + 900, "progress row must render after the recovery row");

  const approvedBottomNavLabels = ["Főmenü", "Történetem", "Ösvény", "Gyűlések", "Szponzor"];
  assert.equal(
    await page.locator(".bottom-nav").evaluateAll((navs, expectedLabels) => (
      navs.length === 17
      && navs.every((nav) => JSON.stringify(Array.from(nav.querySelectorAll("button > span"), (label) => label.textContent.trim())) === JSON.stringify(expectedLabels))
    ), approvedBottomNavLabels),
    true,
    "every rendered bottom navigation must use the approved five-item label order",
  );

  const collapsedHomeLayout = await page.locator("#home-collapsed").evaluate((screen) => {
    const dashboard = screen.querySelector(".home-metrics");
    const nav = screen.querySelector(".bottom-nav");
    const homeBody = screen.querySelector(".home-body");
    if (!dashboard || !nav) return null;
    const screenBox = screen.getBoundingClientRect();
    const dashboardBox = dashboard.getBoundingClientRect();
    const navBox = nav.getBoundingClientRect();
    return {
      dashboardTop: Math.round(dashboardBox.top - screenBox.top),
      hasOpenedCard: Boolean(homeBody),
    navBottomGap: Math.round(screenBox.bottom - navBox.bottom),
    navLabels: Array.from(nav.querySelectorAll("button")).map((button) => button.textContent.trim()),
    currentTarget: nav.querySelector("[aria-current='page']")?.dataset.targetScreen,
    progressTarget: Array.from(nav.querySelectorAll("button")).find((button) => button.textContent.trim() === "Történetem")?.dataset.targetScreen,
  };
  });
  assert.deepEqual(collapsedHomeLayout, {
    dashboardTop: 614,
    hasOpenedCard: false,
    navBottomGap: 0,
    navLabels: ["Főmenü", "Történetem", "Ösvény", "Gyűlések", "Szponzor"],
    currentTarget: "home-collapsed",
    progressTarget: "progress-calendar",
  }, "collapsed home must keep the dashboard lower and render a complete bottom nav");

  const cleanDayTargets = await page.locator("#home-collapsed .clean-days-metric, #home .clean-days-metric").evaluateAll((buttons) =>
    buttons.map((button) => ({
      screen: button.closest(".phone-screen")?.dataset.screen,
      action: button.dataset.action,
      target: button.dataset.targetScreen,
    })),
  );
  assert.deepEqual(cleanDayTargets, [
    { screen: "home-collapsed", action: "open-current-period-timeline", target: "home-statistics-timeline" },
    { screen: "home", action: "open-current-period-timeline", target: "home-statistics-timeline" },
  ], "tapping clean days in either home state must open the current-period timeline directly");

  const homeStatistics = await page.locator("#home-statistics").evaluate((screen) => ({
    parent: screen.dataset.parentScreen,
    reference: screen.dataset.referenceScreenshot,
    title: screen.querySelector("h3")?.textContent.trim(),
    subtitle: screen.querySelector(".screen-subtitle")?.textContent.trim(),
    navCurrent: screen.querySelector(".bottom-nav [aria-current='page'] span")?.textContent.trim(),
    navLabels: Array.from(screen.querySelectorAll(".bottom-nav button span")).map((span) => span.textContent.trim()),
    batches: Array.from(screen.querySelectorAll("[data-component='sobriety-batch-card']")).map((batch) => ({
      id: batch.dataset.batchId,
      days: batch.dataset.batchDays,
      state: batch.dataset.batchState || "past",
      current: batch.getAttribute("aria-current") || null,
      action: batch.dataset.action || null,
      target: batch.dataset.targetScreen || null,
      text: batch.textContent.replace(/\s+/g, " ").trim(),
    })),
    selectedBatch: {
      title: screen.querySelector("[data-component='selected-sobriety-batch'] h4")?.textContent.trim(),
      range: screen.querySelector("[data-component='selected-sobriety-batch'] .selected-batch-range")?.textContent.trim(),
      pill: screen.querySelector("[data-component='selected-sobriety-batch'] .selected-batch-pill")?.textContent.trim(),
      ring: screen.querySelector("[data-component='selected-sobriety-batch'] .selected-batch-ring strong")?.textContent.trim(),
      action: screen.querySelector("[data-component='selected-sobriety-batch']")?.dataset.action,
      target: screen.querySelector("[data-component='selected-sobriety-batch']")?.dataset.targetScreen,
    },
    globalHeader: {
      title: screen.querySelector("[data-component='global-stat-summary'] h4")?.textContent.trim(),
      subtitle: screen.querySelector("[data-component='global-stat-summary'] p")?.textContent.trim(),
      gridAria: screen.querySelector("[data-component='global-stat-grid']")?.getAttribute("aria-label"),
      legacyBatchGridCount: screen.querySelectorAll("[data-component='active-batch-stat-grid']").length,
    },
    coreStats: Array.from(screen.querySelectorAll("[data-stat-card]")).map((card) => ({
      stat: card.dataset.statCard,
      label: card.querySelector("span")?.textContent.trim(),
      value: card.querySelector("strong")?.textContent.trim(),
    })),
    forbiddenBlocks: [
      "[data-component='statistics-period-selector']",
      "[data-component='statistics-trend-chart']",
      "[data-component='statistics-task-bars']",
      ".statistics-task-row",
      "[data-component='statistics-calendar-preview']",
      "[data-action='open-statistics-calendar']",
      "[data-component='statistics-next-milestone']",
      "[data-action='open-statistics-milestones']",
      "[data-component='statistics-insights']",
    ].map((selector) => screen.querySelectorAll(selector).length),
    forbiddenText: ["Szokások teljesülése", "Esti check-in", "Hála lista", "Szponzor hívás", "Naptár preview", "30 nap · Egy hónap", "Legstabilabb nap", "Nehéz idősáv", "Támogatás használata", "Szponzorral beszélgetések", "Sóvárgásmentes napok"]
      .filter((text) => screen.textContent.includes(text)),
  }));
  assert.deepEqual(homeStatistics, {
    parent: "home",
    reference: "Screenshot_20260720-013331.png",
    title: "Történetem",
    subtitle: "Válaszd ki az időszakodat",
    navCurrent: "Ösvény",
    navLabels: ["Főmenü", "Történetem", "Ösvény", "Gyűlések", "Szponzor"],
    batches: [
      { id: "2024-05", days: "8", state: "past", current: null, action: "open-sobriety-batch-detail", target: "home-statistics-detail", text: "2024 8 nap 2024.05." },
      { id: "2024-08", days: "37", state: "past", current: null, action: "open-sobriety-batch-detail", target: "home-statistics-detail", text: "37 nap 2024.08." },
      { id: "2025-01", days: "89", state: "past", current: null, action: "open-sobriety-batch-detail", target: "home-statistics-detail", text: "2025 89 nap 2025.01." },
      { id: "2025-06", days: "4", state: "past", current: null, action: "open-sobriety-batch-detail", target: "home-statistics-detail", text: "4 nap 2025.06. Aktuális időszak" },
      { id: "current", days: "24", state: "current", current: "true", action: "open-sobriety-batch-detail", target: "home-statistics-detail", text: "2026 24 nap Jelenleg" },
    ],
    selectedBatch: {
      title: "Jelenlegi időszak",
      range: "2026. május 1. - jelenleg",
      pill: "24 nap tiszta",
      ring: "24 nap",
      action: "open-current-period-detail",
      target: "home-statistics-detail",
    },
    globalHeader: {
      title: "Történetem összesen",
      subtitle: "Az összes eddigi időszak alapján",
      gridAria: "Történetem összesen",
      legacyBatchGridCount: 0,
    },
    coreStats: [
      { stat: "longest-period", label: "Leghosszabb időszak", value: "89 nap" },
      { stat: "total-clean-days", label: "Összes tiszta nap", value: "162 nap" },
      { stat: "average-mood", label: "Átlagos hangulat", value: "😀 3.8 / 5" },
      { stat: "checkin-rate", label: "Check-in arány", value: "82%" },
      { stat: "na-participation", label: "NA részvétel", value: "12" },
      { stat: "evening-reflections", label: "Esti reflexiók", value: "19" },
    ],
    forbiddenBlocks: [0, 0, 0, 0, 0, 0, 0, 0, 0],
    forbiddenText: [],
  }, "home statistics must collect all stats-related dashboard content");

  const homeStatisticsDetail = await page.locator("#home-statistics-detail").evaluate((screen) => ({
    parent: screen.dataset.parentScreen,
    reference: screen.dataset.referenceScreenshot,
    title: screen.querySelector("h3")?.textContent.trim(),
    period: {
      badge: screen.querySelector(".period-detail-badge")?.textContent.trim(),
      range: screen.querySelector(".period-detail-range")?.textContent.trim(),
    },
    tabs: Array.from(screen.querySelectorAll("[data-period-detail-tab]")).map((tab) => ({
      tab: tab.dataset.periodDetailTab,
      pressed: tab.getAttribute("aria-pressed"),
      text: tab.textContent.trim(),
    })),
    charts: Array.from(screen.querySelectorAll("[data-component^='overview-'][data-chart-value]")).map((chart) => ({
      component: chart.dataset.component,
      value: chart.dataset.chartValue,
      heading: chart.querySelector("h4")?.textContent.trim(),
    })),
    navCurrent: screen.querySelector(".bottom-nav [aria-current='page'] span")?.textContent.trim(),
  }));
  assert.deepEqual(homeStatisticsDetail, {
    parent: "home-statistics",
    reference: "Screenshot_20260720-063624.png",
    title: "Történetem",
    period: {
      badge: "24 nap",
      range: "2026. május 1. - jelenleg",
    },
    tabs: [
      { tab: "overview", pressed: "true", text: "Áttekintés" },
      { tab: "timeline", pressed: "false", text: "Timeline" },
    ],
    charts: [
      { component: "overview-mood-line-chart", value: "3.8", heading: "Mood line" },
      { component: "overview-checkin-rate-chart", value: "82", heading: "Check-in arány" },
    ],
    navCurrent: "Ösvény",
  }, "current period detail must expose the overview tab with chart summaries");
  assert.equal(await page.locator("#home-statistics-detail [data-period-detail-tab='timeline'][data-target-screen='home-statistics-detail-timeline']").count(), 1, "8D timeline tab must open the selected-batch Timeline submenu");
  assert.equal(await page.locator("#home-statistics-detail [data-period-detail-tab='craving']").count(), 0, "8D must not keep a craving tab");
  assert.equal(await page.locator("#home-statistics-detail [data-period-detail-tab='periods'], #home-statistics-detail [data-period-detail-tab='trends']").count(), 0, "8D must remove unfinished Periods and Trends submenu buttons");
  assert.equal(await page.locator("#home-statistics-detail [data-component='overview-clean-days-chart'], #home-statistics-detail .bar-chart").count(), 0, "current period detail must replace the clean-days bar chart with a mood line");

  const statisticsDetailTimeline = await page.locator("#home-statistics-detail-timeline").evaluate((screen) => ({
    parent: screen.dataset.parentScreen,
    reference: screen.dataset.referenceImage,
    title: screen.querySelector("h3")?.textContent.trim(),
    period: {
      badge: screen.querySelector(".period-detail-badge")?.textContent.trim(),
      range: screen.querySelector(".period-detail-range")?.textContent.trim(),
    },
    tabs: Array.from(screen.querySelectorAll("[data-period-detail-tab]")).map((tab) => ({
      tab: tab.dataset.periodDetailTab,
      pressed: tab.getAttribute("aria-pressed"),
      text: tab.textContent.trim(),
      target: tab.dataset.targetScreen || null,
    })),
    batch: screen.querySelector("[data-component='batch-timeline']")?.getAttribute("data-timeline-batch"),
    batchId: screen.querySelector("[data-component='batch-timeline']")?.getAttribute("data-batch-id"),
    eventCount: screen.querySelectorAll("[data-component='timeline-event']").length,
    navCurrent: screen.querySelector(".bottom-nav [aria-current='page'] span")?.textContent.trim(),
  }));
  assert.deepEqual(statisticsDetailTimeline, {
    parent: "home-statistics-detail",
    reference: "/storage/emulated/0/hajnal/timeline.png",
    title: "Történetem",
    period: { badge: "24 nap", range: "2026. május 1. - jelenleg" },
    tabs: [
      { tab: "overview", pressed: "false", text: "Áttekintés", target: "home-statistics-detail" },
      { tab: "timeline", pressed: "true", text: "Timeline", target: null },
    ],
    batch: "current",
    batchId: "current",
    eventCount: 12,
    navCurrent: "Ösvény",
  }, "8F must be the 8D-context Timeline submenu with the interactive batch timeline body");

  const timelineScreen = await page.locator("#home-statistics-timeline").evaluate((screen) => ({
    parent: screen.dataset.parentScreen,
    reference: screen.dataset.referenceImage,
    title: screen.querySelector("h3")?.textContent.trim(),
    tabCount: screen.querySelectorAll("[data-period-detail-tab]").length,
    contentFirstChild: screen.querySelector(".timeline-content")?.firstElementChild?.className,
    batch: screen.querySelector("[data-component='batch-timeline']")?.getAttribute("data-timeline-batch"),
    batchId: screen.querySelector("[data-component='batch-timeline']")?.getAttribute("data-batch-id"),
    filterAction: screen.querySelector("[data-action='filter-timeline']")?.getAttribute("aria-label"),
    eventCount: screen.querySelectorAll("[data-component='timeline-event']").length,
    events: Array.from(screen.querySelectorAll("[data-component='timeline-event']")).map((event) => ({
      event: event.dataset.timelineEvent,
      type: event.dataset.timelineType,
      title: event.querySelector(".timeline-event-title")?.textContent.trim(),
      date: event.querySelector(".timeline-date")?.textContent.replace(/\s+/g, " ").trim(),
      badge: event.querySelector(".timeline-badge")?.textContent.trim() || null,
      hasThumbnail: Boolean(event.querySelector(".timeline-thumb")),
    })),
    imageCount: screen.querySelectorAll("img").length,
  }));
  assert.deepEqual(timelineScreen, {
    parent: "home",
    reference: "/storage/emulated/0/hajnal/timeline.png",
    title: "Timeline",
    tabCount: 0,
    contentFirstChild: "timeline-header-row",
    batch: "current",
    batchId: "current",
    filterAction: "Timeline szűrése",
    eventCount: 12,
    events: [
      { event: "started", type: "start", title: "Elindultam", date: "2024 dec. 28.", badge: null, hasThumbnail: true },
      { event: "seven-days", type: "milestone", title: "7 nap", date: "2025 jan. 4.", badge: "7 nap", hasThumbnail: false },
      { event: "first-meeting", type: "meeting", title: "Első meeting", date: "2025 jan. 7.", badge: null, hasThumbnail: false },
      { event: "first-sponsor", type: "sponsor", title: "Első szponzorom", date: "2025 jan. 12.", badge: null, hasThumbnail: false },
      { event: "step-one", type: "step", title: "1. lépés kész", date: "2025 jan. 20.", badge: null, hasThumbnail: false },
      { event: "thirty-days", type: "milestone", title: "30 nap", date: "2025 jan. 28.", badge: "30 nap", hasThumbnail: true },
      { event: "relapse", type: "relapse", title: "Visszaesés", date: "2025 febr. 2.", badge: null, hasThumbnail: false },
      { event: "restarted", type: "start", title: "Újrakezdtem", date: "2025 febr. 3.", badge: null, hasThumbnail: false },
      { event: "fourteen-days", type: "milestone", title: "14 nap", date: "2025 febr. 17.", badge: "14 nap", hasThumbnail: false },
      { event: "step-two", type: "step", title: "2. lépés kész", date: "2025 márc. 1.", badge: null, hasThumbnail: false },
      { event: "first-sponsor-meeting", type: "meeting", title: "Első szponzori találkozó", date: "2025 márc. 15.", badge: null, hasThumbnail: false },
      { event: "today", type: "current", title: "Ma", date: "2025 máj. 24.", badge: "Jelenleg", hasThumbnail: false },
    ],
    imageCount: 0,
  }, "8E must render the reference timeline as interactive DOM for the selected batch");

  assert.equal(await page.locator("[data-component='daily-project-assets'] [data-asset-src]").count(), 0, "daily image asset catalog must remain deleted");

  const panicRootActions = await page.locator("#panic-root .panic-grid button").evaluateAll((buttons) =>
    buttons.map((button) => ({
      text: button.textContent.trim(),
      action: button.dataset.action,
      target: button.dataset.targetScreen,
    })),
  );
  assert.deepEqual(panicRootActions, [
    { text: "Hívd a szponzorod", action: "call-sponsor", target: "panic-help-message" },
    { text: "Hívd a tartalék kapcsolattartót", action: "call-backup-contact", target: "panic-help-message" },
    { text: "15 perces túlélőcsomag", action: "start-survival-pack", target: "survival-stop" },
    { text: "Olvasd el, miért kezdted el", action: "why-started", target: "panic-why-started" },
    { text: "Keresd meg a következő meetinget", action: "meeting-finder", target: "panic-meeting-finder" },
    { text: "Visszaestem", action: "report-relapse", target: "checkin-relapse" },
  ], "screen 16 panic quick options must remove message/professional help and add relapse");

  const motivationViews = await page.locator("#onboarding-why-started, #panic-why-started").evaluateAll((screens) =>
    screens.map((screen) => ({
      id: screen.id,
      parent: screen.dataset.parentScreen,
      record: screen.dataset.motivationRecord || null,
      source: screen.dataset.motivationSource || null,
      textareas: screen.querySelectorAll("textarea").length,
      editControls: screen.querySelectorAll('[aria-label="Szerkesztés"]').length,
    })),
  );
  assert.deepEqual(motivationViews, [
    { id: "onboarding-why-started", parent: "sponsor-setup", record: "initial-personal-motivation", source: null, textareas: 1, editControls: 0 },
    { id: "panic-why-started", parent: "panic-root", record: null, source: "initial-personal-motivation", textareas: 0, editControls: 0 },
  ], "onboarding must be the only motivation authoring screen while screen 30 stays a read-only panic reminder");

  const panicMainButtonState = await page.locator(".panic-main-button").evaluateAll((buttons) =>
    buttons.map((button) => {
      const style = getComputedStyle(button);
      return {
        text: button.textContent.trim(),
        hasHeartIcon: !!button.querySelector('use[href="#icon-heart"]'),
        backgroundImage: style.backgroundImage,
        display: style.display,
        flexDirection: style.flexDirection,
        action: button.dataset.action,
        target: button.dataset.targetScreen || null,
      };
    }),
  );
  assert.deepEqual(panicMainButtonState, [
    { text: "Segítségkell", hasHeartIcon: true, backgroundImage: "none", display: "flex", flexDirection: "column", action: "focus-panic-options", target: null },
  ], "large panic help button must have a homogeneous fill, heart icon, and no deleted screen target");

  const survivalFlowScreens = await page.locator(".survival-flow-card").evaluateAll((cards) =>
    cards.map((card) => {
      const screen = card.closest(".phone-screen");
      const cta = screen?.querySelector(".checkin-bottom-actions button");
      return {
        screen: screen?.dataset.screen,
        parent: screen?.dataset.parentScreen,
        step: card.dataset.survivalStep,
        title: card.querySelector("h3")?.textContent.trim(),
        body: card.querySelector("p")?.textContent.trim(),
        cta: cta?.textContent.trim(),
        target: cta?.dataset.targetScreen,
      };
    }),
  );
  assert.deepEqual(survivalFlowScreens, [
    { screen: "survival-stop", parent: "panic-root", step: "1 / 5", title: "Állj meg.", body: "Ne csinálj semmit 10 másodpercig.", cta: "Kész", target: "survival-breathe" },
    { screen: "survival-breathe", parent: "survival-stop", step: "2 / 5", title: "Lélegezz.", body: "Vegyél 5 lassú, mély levegőt.", cta: "Kész", target: "survival-water" },
    { screen: "survival-water", parent: "survival-breathe", step: "3 / 5", title: "Igyál vizet.", body: "Egy korty is számít.", cta: "Kész", target: "survival-outside" },
    { screen: "survival-outside", parent: "survival-water", step: "4 / 5", title: "Menj ki.", body: "Friss levegő. Változtass környezetet.", cta: "Kész", target: "survival-note" },
    { screen: "survival-note", parent: "survival-outside", step: "5 / 5", title: "Írj egy mondatot.", body: "Írd ki, ami benned van. Csak őszintén.", cta: "Hívni fogok", target: "panic-help-message" },
  ], "15-minute survival package must include every source screen in order");

  const contactScreens = await page.locator('[data-contact-layout="combined-contact-accordions"]').evaluateAll((screens) =>
    screens.map((screen) => ({
      screen: screen.dataset.screen,
      title: screen.querySelector("h3")?.textContent.trim(),
      contacts: Array.from(screen.querySelectorAll('[data-component="panic-contact-accordion"]')).map((accordion) => ({
        contact: accordion.dataset.contact,
        state: accordion.dataset.contactState,
        open: accordion.hasAttribute("open"),
        name: accordion.querySelector('[data-component="panic-contact-card"] strong')?.textContent.trim(),
        callAction: accordion.querySelector('[data-component="panic-call-card"]')?.dataset.action,
        messageActions: Array.from(accordion.querySelectorAll('[data-component="panic-quick-messages"] [data-action]')).map((button) => button.dataset.action),
      })),
    })),
  );
  assert.deepEqual(contactScreens, [
    {
      screen: "panic-help-message",
      title: "Hívj fel valakit",
      contacts: [
        { contact: "sponsor", state: "expanded", open: true, name: "Kata", callAction: "start-sponsor-call", messageActions: ["send-sponsor-template", "send-sponsor-template", "send-sponsor-template"] },
        { contact: "backup", state: "collapsed", open: false, name: "Anya", callAction: "start-backup-call", messageActions: ["send-backup-template", "send-backup-template", "send-backup-template"] },
      ],
    },
  ], "combined call screen must show sponsor and backup contacts as expandable accordions");

  const progressScreens = await page.locator(".progress-screen").evaluateAll((screens) =>
    screens.map((screen) => ({
      screen: screen.dataset.screen,
      parent: screen.dataset.parentScreen,
      title: screen.querySelector("h3")?.textContent.trim(),
      shortcuts: Array.from(screen.querySelectorAll("[data-progress-shortcut]")).map((button) => button.dataset.targetScreen),
    })),
  );
  assert.deepEqual(progressScreens, [
    { screen: "progress-calendar", parent: "home", title: "Napló", shortcuts: [] },
    { screen: "progress-day-detail", parent: "progress-calendar", title: "Péntek, május 24.", shortcuts: [] },
  ], "progress row must use screen 18 journal menu as the direct Haladás root");
  assert.equal(
    await page.locator('[data-screen="progress-overview"], #progress-overview, #column-progress-overview, [data-target-screen="progress-overview"], [data-parent-screen="progress-overview"], [data-action="open-progress-calendar"], [data-progress-shortcut="journal"]').count(),
    0,
    "deleted screen 16 progress overview and all direct references must be removed",
  );

  const progressJournalMenu = await page.locator("#progress-calendar").evaluate((screen) => ({
    subtitle: screen.querySelector(".screen-subtitle")?.textContent.trim(),
    dayBeltLabel: screen.querySelector("[data-component='journal-day-belt']")?.getAttribute("aria-label"),
    dayButtons: Array.from(screen.querySelectorAll("[data-component='journal-day-button']")).map((button) => ({
      date: button.dataset.date,
      selected: button.getAttribute("aria-current") || null,
      text: button.textContent.replace(/\s+/g, " ").trim(),
    })),
    selectedDateCount: screen.querySelectorAll("[aria-current='date']").length,
    notes: Array.from(screen.querySelectorAll("[data-component='journal-day-notes'] [data-journal-note]")).map((note) => ({
      note: note.dataset.journalNote,
      target: note.dataset.targetScreen,
      title: note.querySelector("strong")?.textContent.trim(),
    })),
    forbiddenText: ["Szponzorral beszéltem", "Sóvárgás", "Részletek megnyitása"].filter((text) => screen.textContent.includes(text)),
    legacyCalendarGridCount: screen.querySelectorAll(".calendar-mini-grid").length,
    expandedCalendarComponentCount: screen.querySelectorAll("[data-component='journal-calendar-expand'], [data-component='journal-month-grid']").length,
    expandedCalendarStateCount: screen.querySelectorAll("[data-state='expanded'], [data-gesture='swipe-down'], [aria-expanded='true']").length,
  }));
  assert.deepEqual(progressJournalMenu, {
    subtitle: "Napok és jegyzetek",
    dayBeltLabel: "Napló napjai",
    dayButtons: [
      { date: "2024-05-20", selected: null, text: "H 20" },
      { date: "2024-05-21", selected: null, text: "K 21" },
      { date: "2024-05-22", selected: null, text: "Sz 22" },
      { date: "2024-05-23", selected: null, text: "Cs 23" },
      { date: "2024-05-24", selected: "date", text: "P 24" },
      { date: "2024-05-25", selected: null, text: "Sz 25" },
      { date: "2024-05-26", selected: null, text: "V 26" },
    ],
    selectedDateCount: 1,
    notes: [
      { note: "evening-reflection", target: "progress-day-detail", title: "Esti reflexió" },
      { note: "gratitude", target: "progress-day-detail", title: "Hála lista" },
      { note: "journal-entry", target: "progress-day-detail", title: "Naplóbejegyzés" },
      { note: "meeting-note", target: "progress-day-detail", title: "Meeting jegyzet" },
    ],
    forbiddenText: [],
    legacyCalendarGridCount: 0,
    expandedCalendarComponentCount: 0,
    expandedCalendarStateCount: 0,
  }, "screen 18 must render as a journal menu with only the day belt above selected-day notes");

  const deletedProgressJourney = await page.locator('[data-screen="progress-journey"], #progress-journey, #column-progress-journey, [data-target-screen="progress-journey"], [data-action="open-progress-journey"], [data-progress-shortcut="journey"], [data-component="general-statistics-summary"]').count();
  assert.equal(deletedProgressJourney, 0, "screen 17 progress-journey and all references must be removed");
  const removedProgressStats = await page.locator('[data-target-screen="progress-stats"], [data-action="open-progress-stats"], [data-progress-shortcut="stats"]').count();
  assert.equal(removedProgressStats, 0, "no target or shortcut may point at removed screen 20");

  const milestoneGallery = await page.locator("#progress-milestones").evaluate((screen) => ({
    parent: screen.dataset.parentScreen,
    title: screen.querySelector("h3")?.textContent.trim(),
    cards: Array.from(screen.querySelectorAll('[data-component="milestone-card"]')).map((card) => ({
      day: card.dataset.milestoneDay,
      state: card.dataset.milestoneState,
      disabled: card.hasAttribute("disabled"),
      target: card.dataset.targetScreen || null,
      background: getComputedStyle(card).backgroundColor,
    })),
  }));
  assert.deepEqual(milestoneGallery.cards.map((card) => card.day), ["1", "3", "7", "14", "21", "30", "45", "60", "90"], "milestone gallery must always show 9 cards within 90 days");
  assert.deepEqual(milestoneGallery.cards.map((card) => card.state), ["active", "active", "active", "active", "active", "inactive", "inactive", "inactive", "inactive"], "milestone card state must match 24 days of progress");
  assert.deepEqual(milestoneGallery.cards.map((card) => card.disabled), [false, false, false, false, false, true, true, true, true], "inactive milestone cards must be disabled");
  assert.deepEqual(milestoneGallery.cards.map((card) => card.target), ["daily-image", "daily-image", "daily-image", "daily-image", "daily-image", null, null, null, null], "only active milestones may open the daily image gallery");

  const dailyGallery = await page.locator("#daily-image").evaluate((screen) => ({
    parent: screen.dataset.parentScreen,
    slideMode: screen.dataset.slideMode,
    backTarget: screen.querySelector(".daily-image-back")?.dataset.targetScreen,
    progressNow: screen.querySelector(".daily-image-progress")?.getAttribute("aria-valuenow"),
    slides: Array.from(screen.querySelectorAll("[data-carousel-slide]")).map((slide) => ({
      slide: slide.dataset.carouselSlide,
      quote: slide.querySelector(".daily-image-quote")?.textContent.replace(/\s+/g, " ").trim(),
    })),
  }));
  assert.deepEqual(dailyGallery, {
    parent: "progress-milestones",
    slideMode: "milestone-carousel",
    backTarget: "progress-milestones",
    progressNow: "24",
    slides: [
      { slide: "30-1", quote: "A következő kapu már látszik. Ma csak addig menj, ameddig a mai nap engedi." },
      { slide: "30-2", quote: "A türelem is haladás. A kép változhat, a 24. napod stabilan itt marad." },
      { slide: "30-3", quote: "Nem siettetjük a fényt. Minden tiszta nap hozzáad egy árnyalattal többet." },
    ],
  }, "daily image must be a milestone carousel with fixed progress and per-image quotes");

  assert.equal(await page.locator('[data-page="tools"]').count(), 0, "standalone tools row must be removed");
  assert.equal(await page.locator(".tools-screen").count(), 0, "standalone tools screens must be folded into recovery");

  const recoveryScreens = await page.locator(".recovery-screen").evaluateAll((screens) =>
    screens.map((screen) => ({
      screen: screen.dataset.screen,
      parent: screen.dataset.parentScreen,
      title: screen.querySelector("h3")?.textContent.trim(),
      navActive: screen.querySelector(".bottom-nav [aria-current='page'] span")?.textContent.trim() || null,
      shortcuts: Array.from(screen.querySelectorAll("[data-recovery-shortcut]")).map((button) => button.dataset.targetScreen),
    })),
  );
  assert.deepEqual(recoveryScreens, [
    { screen: "recovery-overview", parent: "home", title: "Felépülés", navActive: "Ösvény", shortcuts: ["recovery-steps-overview", "progress-calendar", "tools-journal-list", "recovery-evening", "panic-why-started", "survival-stop"] },
    { screen: "recovery-steps-overview", parent: "recovery-overview", title: "12 lépés", navActive: "Ösvény", shortcuts: [] },
    { screen: "recovery-step-detail", parent: "recovery-steps-overview", title: "4. lépés", navActive: "Ösvény", shortcuts: [] },
    { screen: "recovery-evening", parent: "recovery-overview", title: "Esti reflexió", navActive: "Ösvény", shortcuts: [] },
    { screen: "tools-journal-list", parent: "recovery-overview", title: "Napló", navActive: "Ösvény", shortcuts: [] },
    { screen: "tools-journal-entry", parent: "tools-journal-list", title: "Új naplóbejegyzés", navActive: null, shortcuts: [] },
    { screen: "tools-journal-detail", parent: "tools-journal-list", title: "Naplóbejegyzés", navActive: null, shortcuts: [] },
  ], "recovery row must keep only the requested recovery menu shortcuts");

  const recoveryOverviewLayout = await page.locator("#recovery-overview").evaluate((screen) => {
    const content = screen.querySelector(".recovery-content");
    const nav = screen.querySelector(".bottom-nav");
    return {
      overflowY: getComputedStyle(content).overflowY,
      contentScrolls: content.scrollHeight > content.clientHeight,
      hasBottomNav: Boolean(nav),
      currentNav: nav?.querySelector("[aria-current='page'] span")?.textContent.trim(),
      hasWhyStarted: Boolean(screen.querySelector('[data-action="open-recovery-why-started"][data-target-screen="panic-why-started"]')),
    };
  });
  assert.deepEqual(recoveryOverviewLayout, {
    overflowY: "auto",
    contentScrolls: true,
    hasBottomNav: true,
    currentNav: "Ösvény",
    hasWhyStarted: true,
  }, "screen 30 recovery overview must scroll while keeping the bottom nav and why-started menu available");

  const altProgressRow = await page.locator('[data-page="alt-progress"]').evaluate((row) => ({
    root: row.dataset.rootScreen,
    rowScreens: row.dataset.rowScreens,
    sourceReference: row.dataset.sourceReference || "",
    sourceAsset: row.dataset.sourceAsset || "",
    cropComponents: row.querySelectorAll('[data-component="haladas-source-crop"]').length,
    sourceCropMarkers: row.querySelectorAll("[data-source-crop]").length,
    deletedA1References: row.querySelectorAll('[data-screen="alt-progress-overview"], #alt-progress-overview, #column-alt-progress-overview, [data-target-screen="alt-progress-overview"], [data-action="open-alt-overview"], [data-component="alt-progress-dashboard"], [data-component="alt-progress-menu-grid"]').length,
    deletedA3References: row.querySelectorAll('[data-screen="alt-progress-day-detail"], #alt-progress-day-detail, #column-alt-progress-day-detail, [data-target-screen="alt-progress-day-detail"], [data-action="open-alt-day-detail"]').length,
    deletedA5References: row.querySelectorAll('[data-screen="alt-progress-calendar"], #alt-progress-calendar, #column-alt-progress-calendar, [data-target-screen="alt-progress-calendar"], [data-action="open-alt-calendar"], [data-component="alt-progress-calendar-grid"], [data-component="alt-calendar-view-switch"]').length,
    deletedA7A8A9References: row.querySelectorAll('[data-screen="alt-progress-statistics"], #alt-progress-statistics, #column-alt-progress-statistics, [data-target-screen="alt-progress-statistics"], [data-action="open-alt-statistics"], [data-screen="alt-progress-milestones"], #alt-progress-milestones, #column-alt-progress-milestones, [data-target-screen="alt-progress-milestones"], [data-action="open-alt-milestones"], [data-action="open-alt-next-milestone"], [data-component="alt-progress-next-milestone"], [data-screen="alt-progress-milestone-detail"], #alt-progress-milestone-detail, #column-alt-progress-milestone-detail, [data-target-screen="alt-progress-milestone-detail"], [data-action="open-alt-milestone-detail"], [data-action="alt-progress-share-milestone"]').length,
    deletedA10A11References: row.querySelectorAll('[data-screen="alt-progress-activity"], #alt-progress-activity, #column-alt-progress-activity, [data-target-screen="alt-progress-activity"], [data-action="open-alt-activity-detail"], [data-component="alt-progress-activity-tabs"], [data-component="alt-progress-activity-list"], [data-screen="alt-progress-activity-detail"], #alt-progress-activity-detail, #column-alt-progress-activity-detail, [data-target-screen="alt-progress-activity-detail"], [data-action="return-alt-activity"], [data-component="alt-progress-activity-result"], [data-component="alt-progress-activity-detail-list"]').length,
    imageCount: row.querySelectorAll("img").length,
    screens: Array.from(row.querySelectorAll(".alt-progress-screen")).map((screen) => ({
      screen: screen.dataset.screen,
      parent: screen.dataset.parentScreen,
      title: screen.getAttribute("aria-label"),
      buttons: screen.querySelectorAll("button").length,
      textareas: screen.querySelectorAll("textarea").length,
      components: Array.from(screen.querySelectorAll("[data-component]")).map((element) => element.dataset.component),
      width: Math.round(screen.getBoundingClientRect().width),
      height: Math.round(screen.getBoundingClientRect().height),
      backgroundImage: getComputedStyle(screen).backgroundImage,
    })),
  }));
  assert.deepEqual(altProgressRow.root, "alt-progress-daily-view", "alternative progress row root");
  assert.deepEqual(altProgressRow.rowScreens, altProgressScreens.map(([id]) => id).join(" "), "alternative progress row screen order");
  assert.deepEqual(altProgressRow.sourceReference, "/storage/emulated/0/hajnal/haladas.png", "alternative progress source reference");
  assert.deepEqual(altProgressRow.sourceAsset, "", "alternative progress row must not embed a copied PNG asset");
  assert.deepEqual(altProgressRow.cropComponents, 0, "alternative progress row must not use source crop components");
  assert.deepEqual(altProgressRow.sourceCropMarkers, 0, "alternative progress row must not expose source crop coordinates");
  assert.deepEqual(altProgressRow.deletedA1References, 0, "A1 alt-progress overview and all row references must be removed");
  assert.deepEqual(altProgressRow.deletedA3References, 0, "A3 alt-progress day detail and all row references must be removed");
  assert.deepEqual(altProgressRow.deletedA5References, 0, "A5 alt-progress monthly calendar and all row references must be removed");
  assert.deepEqual(altProgressRow.deletedA7A8A9References, 0, "A7/A8/A9 alternative statistics and milestone screens and all row references must be removed");
  assert.deepEqual(altProgressRow.deletedA10A11References, 0, "A10/A11 alternative activity screens and all row references must be removed");
  assert.deepEqual(altProgressRow.imageCount, 0, "alternative progress row must be built from DOM/CSS, not img tags");
  assert.deepEqual(
    altProgressRow.screens.map(({ screen, title, parent }) => ({ screen, title, parent })),
    altProgressScreens.map(([screen, title, parent]) => ({ screen, title, parent })),
    "alternative progress row must expose all functional screens in order",
  );
  assert.equal(altProgressRow.screens.every((screen) => screen.width === 412 && screen.height === 892), true, "every alternative progress screen must keep normal phone dimensions");
  assert.equal(altProgressRow.screens.every((screen) => screen.buttons > 0), true, "every alternative progress screen must expose real button controls");
  assert.equal(altProgressRow.screens.every((screen) => !screen.backgroundImage.includes("/assets/haladas.png")), true, "alternative progress screens must not use the source PNG as a background");
  assert.ok(
    altProgressRow.screens.find((screen) => screen.screen === "alt-progress-daily-view")?.textareas === 1,
    "alternative daily view must contain an editable note textarea",
  );
  const flattenedImages = await page.locator(".phone-screen img").evaluateAll((images) =>
    images
      .filter((image) => {
        const screenId = image.closest(".phone-screen")?.id;
        const allowedSplash = screenId === "splash" && image.src.endsWith("/welcome_svg.svg");
        const allowedFullscreen2 = ["home-collapsed", "home"].includes(screenId) && image.src.endsWith("/hero_fullscreen2_svg.svg");
        const allowedHurray = screenId === "checkin-clean" && image.src.endsWith("/hurray_svg.svg");
        const allowedFullscreen = [
          "evening-reflection",
          "reflection-saved",
          "checkin-relapse",
        ].includes(screenId) && image.src.endsWith("/hero_fullscreen_svg.svg");
        return !(allowedSplash || allowedFullscreen2 || allowedHurray || allowedFullscreen);
      })
      .map((image) => ({ screen: image.closest(".phone-screen")?.id, src: image.src })),
  );
  assert.deepEqual(flattenedImages, [], "phone screens must only use the approved SVG hero image, not flattened raster images");

  const cleanSheet = await page.locator("#checkin-clean .reflection-choice-sheet").evaluate((sheet) => {
    const bounds = sheet.getBoundingClientRect();
    const screen = sheet.closest(".phone-screen").getBoundingClientRect();
    return {
      rounded: getComputedStyle(sheet).borderRadius,
      bottomGap: Math.round(screen.bottom - bounds.bottom),
      primaryText: sheet.querySelector(".sheet-primary")?.textContent?.trim(),
      secondaryText: sheet.querySelector(".sheet-secondary")?.textContent?.trim(),
    };
  });
  assert.deepEqual(cleanSheet, {
    rounded: "32px",
    bottomGap: 28,
    primaryText: "Most, 2 percet rászánok",
    secondaryText: "Később",
  }, "screen 11 must show the source-of-truth slide-up choice sheet");

  const inventoryWizard = page.locator('[data-page="evening-inventory-wizard"]');
  const inventoryScreens = inventoryWizard.locator('.evening-inventory-screen');
  assert.equal(await inventoryScreens.count(), 8, "the expanded Evening Inventory must expose exactly eight review screens");
  assert.equal(
    await inventoryScreens.evaluateAll((screens) => screens.every((screen) => {
      const bounds = screen.getBoundingClientRect();
      const panel = screen.querySelector('[data-component="evening-inventory-panel"]');
      return Math.round(bounds.width) === 412
        && Math.round(bounds.height) === 892
        && Boolean(panel)
        && getComputedStyle(panel).backgroundColor === "rgba(255, 255, 255, 0.92)";
    })),
    true,
    "every inventory screen must retain phone geometry and the Screen-12-derived reflection panel",
  );
  assert.equal(await inventoryWizard.locator('[data-wizard-step]').count(), 8, "every inventory screen must expose a progress step");
  assert.equal(await inventoryWizard.locator('[data-action="inventory-next"][disabled]').count(), 0, "optional inventory fields must never disable forward navigation");
  assert.equal(await inventoryWizard.locator('[required]').count(), 0, "inventory fields must remain optional");
  assert.equal(await inventoryWizard.locator('[data-inventory-session="daily-inventory"]').count(), 8, "the eight screens must share one Daily Inventory session semantic");
  assert.equal(
    await inventoryWizard.locator('[data-component="inventory-evening-background"]').evaluateAll((backgrounds) => backgrounds.length === 8 && backgrounds.every((background) => (
      background.dataset.sourceScreen === 'evening-reflection'
      && background.dataset.sourceAsset === 'hero_fullscreen_svg.svg'
      && getComputedStyle(background).backgroundImage.includes('data:image/svg+xml;base64')
    ))),
    true,
    "every inventory screen must render the existing Screen 12 evening background asset",
  );

  const moodGood = page.locator('#evening-inventory-state [data-inventory-value="good"]');
  await moodGood.click();
  assert.equal(await moodGood.getAttribute('aria-pressed'), 'true', "mood selection must expose pressed state");
  assert.equal(await page.locator('#evening-inventory-state [data-inventory-value="neutral"]').getAttribute('aria-pressed'), 'false', "single-select mood must clear the prior state");
  const craving = page.locator('#evening-inventory-state [data-component="inventory-craving-range"]');
  await craving.evaluate((input) => {
    input.value = '7';
    input.dispatchEvent(new Event('input', { bubbles: true }));
  });
  assert.equal(await page.locator('#evening-inventory-state [data-component="inventory-craving-output"]').innerText(), '7 / 10', "craving range must provide a calm numeric readout");

  await page.locator('#evening-inventory-recovery [data-inventory-choice="old-pattern"][data-inventory-value="yes"]').click();
  assert.equal(await page.locator('#evening-inventory-recovery [data-reveal-when="old-pattern:yes"]').evaluate((node) => node.hidden), false, "old-pattern note must appear only after an affirmative answer");
  const gratitudeRows = page.locator('#evening-inventory-gratitude [data-gratitude-item]');
  assert.equal(await gratitudeRows.count(), 1, "daily gratitude begins with one quiet editable row, not a fixed count");
  await page.locator('#evening-inventory-gratitude [data-action="remove-inventory-gratitude"]').click();
  assert.equal(await gratitudeRows.count(), 0, "gratitude may be left empty");
  await page.locator('#evening-inventory-gratitude [data-action="add-gratitude-item"]').click();
  await page.locator('#evening-inventory-gratitude [data-action="add-gratitude-item"]').click();
  assert.equal(await gratitudeRows.count(), 2, "gratitude supports multiple daily items without a limit or reward");
  const freeText = page.locator('#evening-inventory-free-reflection [data-component="inventory-free-reflection-text"]');
  await freeText.fill('Csendben lezárom a mai napot.');
  assert.equal(await page.locator('#evening-inventory-free-reflection [data-component="inventory-character-count"]').innerText(), '29 karakter', "free reflection retains its visible character count");
  assert.equal(await page.locator('#evening-inventory-free-reflection [data-action="add-photo-memo"]').count(), 1, "free reflection retains photo memo capability");
  assert.equal(await page.locator('#evening-inventory-free-reflection [data-action="add-voice-memo"]').count(), 1, "free reflection retains voice memo capability");

  await page.locator('#evening-reflection [data-reflection-prompt="hardest"]').click();
  assert.equal(
    await page.locator("#evening-reflection [data-active-reflection-prompt]").getAttribute("data-active-reflection-prompt"),
    "hardest",
    "hardest prompt must become active",
  );
  assert.equal(
    await page.locator("#evening-reflection [data-reflection-content]").getAttribute("data-active-reflection-prompt"),
    "hardest",
    "section 3 content must switch to the selected prompt",
  );
  assert.equal(
    await page.locator("#evening-reflection [data-reflection-text]").getAttribute("placeholder"),
    "Kezdj el írni...",
    "the screenshot-style writing panel keeps the simple placeholder",
  );
  await page.locator('#evening-reflection [data-reflection-prompt="gratitude"]').click();
  assert.equal(
    await page.locator("#evening-reflection [data-reflection-section-title]").innerText(),
    "3. Miért vagy hálás ma?",
    "gratitude mode must use the source-of-truth gratitude heading",
  );
  assert.match(
    await page.locator("#evening-reflection [data-reflection-content]").innerText(),
    /Írj le legalább 3 dolgot, amiért ma hálás vagy\./,
    "gratitude mode must show the source-of-truth helper copy",
  );
  assert.equal(await page.locator("#evening-reflection [data-gratitude-item]").count(), 3, "gratitude mode starts with three list items");
  assert.equal(await page.locator("#evening-reflection .gratitude-index").count(), 3, "gratitude rows use numbered badges");
  assert.equal(await page.locator("#evening-reflection .gratitude-drag-handle").count(), 3, "gratitude rows expose visual reorder handles");
  await page.locator('#evening-reflection [data-action="add-gratitude-item"]').click();
  assert.equal(await page.locator("#evening-reflection [data-gratitude-item]").count(), 4, "gratitude add button grows the list inline");
  await page.locator('#evening-reflection [data-action="remove-gratitude-item"]').first().click();
  assert.equal(await page.locator("#evening-reflection [data-gratitude-item]").count(), 3, "gratitude delete button removes a list item inline");
  assert.equal(await page.locator("#evening-reflection [data-action='remove-gratitude-item']").count(), 3, "remaining gratitude rows keep delete controls");

  const eveningLayout = await page.locator("#evening-reflection").evaluate((screen) => {
    const scroll = screen.querySelector(".evening-scroll");
    const footer = screen.querySelector(".evening-save-actions");
    const secondary = screen.querySelector(".evening-save-actions .secondary-button");
    const primary = screen.querySelector(".evening-save-actions .primary-button");
    if (!scroll || !footer || !secondary || !primary) return null;
    const scrollBox = scroll.getBoundingClientRect();
    const footerBox = footer.getBoundingClientRect();
    const secondaryBox = secondary.getBoundingClientRect();
    const primaryBox = primary.getBoundingClientRect();
    const screenBox = screen.getBoundingClientRect();
    const scrollStyle = getComputedStyle(scroll);
    return {
      scrollOverflowEnabled: scrollStyle.overflowY === "auto",
      footerAfterScroll: footerBox.top >= scrollBox.bottom,
      footerVisible: footerBox.bottom <= screenBox.bottom,
      footerRightAligned: Math.round(screenBox.right - footerBox.right) === 28,
      secondaryText: secondary.textContent.trim(),
      secondaryWidth: Math.round(secondaryBox.width),
    primaryWidth: Math.round(primaryBox.width),
    };
  });
  assert.deepEqual(eveningLayout, {
    scrollOverflowEnabled: true,
    footerAfterScroll: true,
    footerVisible: true,
    footerRightAligned: true,
    secondaryText: "Később",
    secondaryWidth: 96,
    primaryWidth: 104,
  }, "screen 12 must scroll internally while the compact footer stays fixed and right-aligned");

  const panelHeightInGratitudeMode = await page.locator("#evening-reflection [data-component='evening-reflection-panel']").evaluate((panel) =>
    Math.round(panel.getBoundingClientRect().height),
  );
  await page.locator('#evening-reflection [data-reflection-prompt="remember"]').click();
  const panelHeightInRememberMode = await page.locator("#evening-reflection [data-component='evening-reflection-panel']").evaluate((panel) =>
    Math.round(panel.getBoundingClientRect().height),
  );
  await page.locator('#evening-reflection [data-reflection-prompt="best"]').click();
  const panelHeightInBestMode = await page.locator("#evening-reflection [data-component='evening-reflection-panel']").evaluate((panel) =>
    Math.round(panel.getBoundingClientRect().height),
  );
  assert.deepEqual(
    [panelHeightInGratitudeMode, panelHeightInRememberMode, panelHeightInBestMode],
    [860, 860, 860],
    "screen 12 mother container height must stay fixed across prompt modes",
  );

  assert.equal(await page.locator("#reflection-saved .saved-title").innerText(), "Elmentve!", "final saved title");
  assert.match(
    await page.locator("#reflection-saved .saved-message").innerText(),
    /Köszönöm,\s+hogy ma is időt szántál\s+magadra\./,
    "final saved gratitude copy",
  );

  const calendarButtons = page.locator("#start-date button.calendar-day");
  assert.equal(await calendarButtons.count(), 35, "semantic calendar date button count");
  assert.equal(await page.locator('#start-date button.calendar-day[aria-current="date"][aria-pressed="true"]').count(), 1);

  const unlabeledControls = await page.locator(".phone-screen button, .phone-screen input").evaluateAll((controls) =>
    controls
      .filter((control) => {
        const ariaLabel = control.getAttribute("aria-label")?.trim();
        const text = control.textContent?.trim();
        const labelText = Array.from(control.labels || []).map((label) => label.textContent?.trim()).join(" ").trim();
        return !ariaLabel && !text && !labelText;
      })
      .map((control) => `${control.closest(".phone-screen")?.id}:${control.tagName.toLowerCase()}`),
  );
  assert.deepEqual(unlabeledControls, [], "all controls need accessible names");

  const controls = page.locator(".phone-screen button, .phone-screen input");
  const focusFailures = [];
  for (let index = 0; index < await controls.count(); index += 1) {
    const control = controls.nth(index);
    await control.focus();
    const result = await control.evaluate((element) => {
      const candidates = [
        element,
        element.closest("label"),
        element.closest(".compact-field"),
        element.parentElement,
      ].filter(Boolean);
      const hasVisibleIndicator = candidates.some((candidate) => {
        const style = getComputedStyle(candidate);
        return style.outlineStyle !== "none" && parseFloat(style.outlineWidth) >= 2;
      });
      return {
        hasVisibleIndicator,
        screen: element.closest(".phone-screen")?.id,
        name: element.getAttribute("aria-label") || element.textContent?.trim() || element.getAttribute("value"),
      };
    });
    if (!result.hasVisibleIndicator) focusFailures.push(result);
  }
  assert.deepEqual(focusFailures, [], "all focusable controls need visible focus indicators");
  process.stdout.write("PASS browser hierarchy, semantics, labels, and focus\n");
  await page.evaluate(() => {
    if (document.activeElement instanceof HTMLElement) document.activeElement.blur();
  });

  for (const [id, parent] of screenOrder) {
    const screen = page.locator(`#${id}`);
    await alignScreenForIntegerClip(screen);
    assert.equal(await screen.getAttribute("data-parent-screen"), parent, `${id} parent`);
    const box = await screen.boundingBox();
    assert.ok(box, `${id} bounding box`);
    const expectedSize = { width: 412, height: 892, radius: "34px" };

    const metrics = await screen.evaluate((element) => {
      const bounds = element.getBoundingClientRect();
      const style = getComputedStyle(element);
      return {
        width: bounds.width,
        height: bounds.height,
        borderRadius: style.borderRadius,
        scrollHeight: element.scrollHeight,
        clientHeight: element.clientHeight,
        scrollWidth: element.scrollWidth,
        clientWidth: element.clientWidth,
      };
    });

    assert.equal(metrics.width, expectedSize.width, `${id} width`);
    assert.equal(metrics.height, expectedSize.height, `${id} height`);
    assert.equal(metrics.borderRadius, expectedSize.radius, `${id} radius`);
    assert.equal(metrics.scrollHeight, metrics.clientHeight, `${id} vertical overflow`);
    assert.equal(metrics.scrollWidth, metrics.clientWidth, `${id} horizontal overflow`);

    const evidencePath = path.join(
      updateEvidence ? evidenceDirectory : scratchDirectory,
      `${id}.png`,
    );
    await page.screenshot({
      path: evidencePath,
      clip: {
        x: Math.round(box.x),
        y: Math.round(box.y),
        width: expectedSize.width,
        height: expectedSize.height,
      },
      animations: "disabled",
    });
    assert.deepEqual(pngSize(evidencePath), { width: expectedSize.width, height: expectedSize.height }, `${id} screenshot size`);
    process.stdout.write(`PASS browser ${id} ${expectedSize.width}x${expectedSize.height} no-overflow\n`);
  }

  if (updateEvidence) {
    await page.setViewportSize({ width: 3900, height: 900 });
    await page.screenshot({
      path: path.join(evidenceDirectory, "first-page-overview.png"),
      fullPage: true,
      animations: "disabled",
    });
  }
} finally {
  await browser.close();
  staticServer.server.close();
  fs.rmSync(scratchDirectory, { recursive: true, force: true });
}
