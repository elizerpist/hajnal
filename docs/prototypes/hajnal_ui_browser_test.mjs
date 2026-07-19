import assert from "node:assert/strict";
import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const moduleName = process.env.HAJNAL_PLAYWRIGHT_MODULE || "playwright";
const { chromium } = await import(moduleName);

const prototypeDirectory = path.dirname(fileURLToPath(import.meta.url));
const htmlPath = path.join(prototypeDirectory, "hajnal_ui.html");
const evidenceDirectory = path.join(prototypeDirectory, "verification");
const updateEvidence = process.env.HAJNAL_UPDATE_EVIDENCE === "1";
const scratchDirectory = fs.mkdtempSync(path.join(os.tmpdir(), "hajnal-browser-test-"));
const screenOrder = [
  ["welcome-lighting-lab", null],
  ["splash", null],
  ["onboarding", "splash"],
  ["start-date", "onboarding"],
  ["recovery-goal", "onboarding"],
  ["sponsor-setup", "onboarding"],
  ["notifications", "onboarding"],
  ["home-collapsed", "notifications"],
  ["home", "home-collapsed"],
  ["progress-milestones", "home"],
  ["daily-image", "progress-milestones"],
  ["checkin-clean", "home"],
  ["evening-reflection", "checkin-clean"],
  ["reflection-saved", "evening-reflection"],
  ["panic-root", "home"],
  ["survival-stop", "panic-root"],
  ["survival-breathe", "survival-stop"],
  ["survival-water", "survival-breathe"],
  ["survival-outside", "survival-water"],
  ["survival-note", "survival-outside"],
  ["panic-help-message", "panic-root"],
  ["panic-why-started", "panic-root"],
  ["panic-meeting-finder", "panic-root"],
  ["checkin-relapse", "home"],
  ["progress-overview", "home"],
  ["progress-calendar", "progress-overview"],
  ["progress-day-detail", "progress-calendar"],
  ["recovery-overview", "home"],
  ["recovery-steps-overview", "recovery-overview"],
  ["recovery-step-detail", "recovery-steps-overview"],
  ["recovery-evening", "recovery-overview"],
  ["tools-journal-list", "recovery-overview"],
  ["tools-journal-entry", "tools-journal-list"],
  ["tools-journal-detail", "tools-journal-list"],
  ["alt-progress-overview", "progress-overview"],
  ["alt-progress-daily-view", "alt-progress-overview"],
  ["alt-progress-journal-entry", "alt-progress-daily-view"],
  ["alt-progress-calendar", "alt-progress-overview"],
  ["alt-progress-calendar-day", "alt-progress-calendar"],
  ["alt-progress-statistics", "alt-progress-overview"],
  ["alt-progress-milestones", "alt-progress-overview"],
  ["alt-progress-milestone-detail", "alt-progress-milestones"],
  ["alt-progress-activity", "alt-progress-overview"],
  ["alt-progress-activity-detail", "alt-progress-activity"],
];
const altProgressScreens = [
  ["alt-progress-overview", "Haladás - Áttekintés (#6)", "progress-overview"],
  ["alt-progress-daily-view", "Napi nézet", "alt-progress-overview"],
  ["alt-progress-journal-entry", "Naplóbejegyzés", "alt-progress-daily-view"],
  ["alt-progress-calendar", "Naptár (havi nézet)", "alt-progress-overview"],
  ["alt-progress-calendar-day", "Nap részlete (naptárból)", "alt-progress-calendar"],
  ["alt-progress-statistics", "Statisztikák", "alt-progress-overview"],
  ["alt-progress-milestones", "Mérföldkövek", "alt-progress-overview"],
  ["alt-progress-milestone-detail", "Mérföldkő részlete", "alt-progress-milestones"],
  ["alt-progress-activity", "Aktivitás (napló)", "alt-progress-overview"],
  ["alt-progress-activity-detail", "Aktivitás részlete", "alt-progress-activity"],
];
const screenRows = [
  [
    "entry",
    "splash",
    "welcome-lighting-lab splash onboarding start-date recovery-goal sponsor-setup notifications",
    ["welcome-lighting-lab", "splash", "onboarding", "start-date", "recovery-goal", "sponsor-setup", "notifications"],
  ],
  [
    "home",
    "home-collapsed",
    "home-collapsed home progress-milestones daily-image checkin-clean evening-reflection reflection-saved",
    [
      "home-collapsed",
      "home",
      "progress-milestones",
      "daily-image",
      "checkin-clean",
      "evening-reflection",
      "reflection-saved",
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
    "progress-overview",
    "progress-overview progress-calendar progress-day-detail",
    ["progress-overview", "progress-calendar", "progress-day-detail"],
  ],
  [
    "recovery",
    "recovery-overview",
    "recovery-overview recovery-steps-overview recovery-step-detail recovery-evening tools-journal-list tools-journal-entry tools-journal-detail",
    ["recovery-overview", "recovery-steps-overview", "recovery-step-detail", "recovery-evening", "tools-journal-list", "tools-journal-entry", "tools-journal-detail"],
  ],
  [
    "alt-progress",
    "alt-progress-overview",
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
const staticServer = await createStaticServer(prototypeDirectory);

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

  const lightingLab = await page.locator("#welcome-lighting-lab").evaluate(async (screen) => {
    await window.hajnalWelcomeLighting?.ready;
    const slider = screen.querySelector("[data-lighting-slider]");
    const profileLabel = screen.querySelector("[data-lighting-profile-name]");
    const svg = screen.querySelector("[data-component='welcome-svg-stage'] svg");
    const primarySkyStops = Array.from(svg?.querySelectorAll("#gradient_0 stop") || [])
      .map((stop) => `${stop.getAttribute("offset")}:${stop.getAttribute("stop-color")}`);
    const firstDirectFill = Array.from(svg?.querySelectorAll("[fill]") || [])
      .find((element) => /^#[0-9a-f]{6}$/i.test(element.getAttribute("fill") || ""));
    return {
      source: screen.dataset.svgSource,
      engine: screen.dataset.lightingEngine,
      primarySkyGradient: screen.dataset.primarySkyGradient,
      hasSvg: Boolean(svg),
      sliderMin: slider?.getAttribute("min"),
      sliderMax: slider?.getAttribute("max"),
      sliderStep: slider?.getAttribute("step"),
      profileLabel: profileLabel?.textContent?.trim(),
      primarySkyStops,
      firstDirectFill: firstDirectFill?.getAttribute("fill"),
    };
  });
  assert.deepEqual(lightingLab, {
    source: "assets/welcome_svg.svg",
    engine: "bucketed-path-profiles",
    primarySkyGradient: "gradient_0",
    hasSvg: true,
    sliderMin: "0",
    sliderMax: "1",
    sliderStep: "0.001",
    profileLabel: "Lila hajnal",
    primarySkyStops: ["0:#D99AC9", ".52:#6A55A8", "1:#343477"],
    firstDirectFill: "#5A4091",
  }, "lighting lab must load the real welcome SVG and apply an art-directed starting profile");

  const goldenHour = await page.locator("#welcome-lighting-lab").evaluate((screen) => {
    const slider = screen.querySelector("[data-lighting-slider]");
    slider.value = "0.84";
    slider.dispatchEvent(new Event("input", { bubbles: true }));
    const svg = screen.querySelector("[data-component='welcome-svg-stage'] svg");
    return {
      label: screen.querySelector("[data-lighting-profile-name]")?.textContent?.trim(),
      primarySkyStops: Array.from(svg?.querySelectorAll("#gradient_0 stop") || [])
        .map((stop) => `${stop.getAttribute("offset")}:${stop.getAttribute("stop-color")}`),
      progress: screen.querySelector("[data-lighting-progress]")?.textContent?.trim(),
    };
  });
  assert.deepEqual(goldenHour, {
    label: "Aranyóra",
    primarySkyStops: ["0:#FFD77B", ".52:#E9A46E", "1:#8065A8"],
    progress: "76. nap",
  }, "lighting slider must move through the explicit golden-hour keyframe, not a direct night-day mix");

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
  assert.equal(rowPositions["progress-milestones"].top, rowPositions["home-collapsed"].top, "milestones must render in the home row");
  assert.ok(rowPositions["progress-milestones"].left > rowPositions.home.left, "milestones must sit to the right of the main home screen");
  assert.equal(rowPositions["daily-image"].top, rowPositions["home-collapsed"].top, "daily image must sit next to milestones in the home row");
  assert.ok(rowPositions["daily-image"].left > rowPositions["progress-milestones"].left, "daily image must sit to the right of milestones");
  assert.ok(rowPositions["panic-root"].top > rowPositions["home-collapsed"].top + 900, "panic row must be directly below the home row");
  assert.ok(rowPositions["progress-overview"].top > rowPositions["panic-root"].top + 900, "progress row must render below the panic row");
  assert.ok(rowPositions["recovery-overview"].top > rowPositions["progress-overview"].top + 900, "recovery row must render below the progress row");

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
    progressTarget: Array.from(nav.querySelectorAll("button")).find((button) => button.textContent.trim() === "Haladás")?.dataset.targetScreen,
  };
  });
  assert.deepEqual(collapsedHomeLayout, {
    dashboardTop: 614,
    hasOpenedCard: false,
    navBottomGap: 0,
    navLabels: ["Kezdőlap", "Haladás", "Felépülés", "Szponzor", "Profil"],
    currentTarget: "home-collapsed",
    progressTarget: "progress-overview",
  }, "collapsed home must keep the dashboard lower and render a complete bottom nav");

  const dailyAssetGallery = await page.locator("[data-component='daily-project-assets'] [data-asset-src]").evaluateAll((cards) =>
    cards.map((card) => ({
      label: card.dataset.assetLabel,
      source: card.dataset.assetSrc,
    })),
  );
  assert.deepEqual(dailyAssetGallery, [
    { label: "Logó", source: "assets/logo_svg.svg" },
    { label: "Welcome", source: "assets/welcome_svg.svg" },
    { label: "Hero S", source: "assets/hero_s_svg.svg" },
    { label: "Hero M", source: "assets/hero_m_svg.svg" },
    { label: "Hero XL", source: "assets/hero_xl_svg.svg" },
    { label: "Hero fullscreen", source: "assets/hero_fullscreen_svg.svg" },
    { label: "Hero fullscreen 2", source: "assets/hero_fullscreen2_svg.svg" },
    { label: "Hurray", source: "assets/hurray_svg.svg" },
  ], "daily image row must expose every project SVG asset");

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
    { screen: "progress-overview", parent: "home", title: "Haladás", shortcuts: ["progress-calendar"] },
    { screen: "progress-calendar", parent: "progress-overview", title: "Naptár", shortcuts: [] },
    { screen: "progress-day-detail", parent: "progress-calendar", title: "Péntek, május 24.", shortcuts: [] },
  ], "progress menu must remove screen 17 and keep day detail under calendar");

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
    { screen: "recovery-overview", parent: "home", title: "Felépülés", navActive: "Felépülés", shortcuts: ["recovery-steps-overview", "progress-overview", "tools-journal-list", "recovery-evening", "panic-why-started", "survival-stop"] },
    { screen: "recovery-steps-overview", parent: "recovery-overview", title: "12 lépés", navActive: "Felépülés", shortcuts: [] },
    { screen: "recovery-step-detail", parent: "recovery-steps-overview", title: "4. lépés", navActive: "Felépülés", shortcuts: [] },
    { screen: "recovery-evening", parent: "recovery-overview", title: "Esti reflexió", navActive: "Felépülés", shortcuts: [] },
    { screen: "tools-journal-list", parent: "recovery-overview", title: "Napló", navActive: "Felépülés", shortcuts: [] },
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
    currentNav: "Felépülés",
    hasWhyStarted: true,
  }, "screen 30 recovery overview must scroll while keeping the bottom nav and why-started menu available");

  const altProgressRow = await page.locator('[data-page="alt-progress"]').evaluate((row) => ({
    root: row.dataset.rootScreen,
    rowScreens: row.dataset.rowScreens,
    sourceReference: row.dataset.sourceReference || "",
    sourceAsset: row.dataset.sourceAsset || "",
    cropComponents: row.querySelectorAll('[data-component="haladas-source-crop"]').length,
    sourceCropMarkers: row.querySelectorAll("[data-source-crop]").length,
    deletedA3References: row.querySelectorAll('[data-screen="alt-progress-day-detail"], #alt-progress-day-detail, #column-alt-progress-day-detail, [data-target-screen="alt-progress-day-detail"], [data-action="open-alt-day-detail"]').length,
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
  assert.deepEqual(altProgressRow.root, "alt-progress-overview", "alternative progress row root");
  assert.deepEqual(altProgressRow.rowScreens, altProgressScreens.map(([id]) => id).join(" "), "alternative progress row screen order");
  assert.deepEqual(altProgressRow.sourceReference, "/storage/emulated/0/hajnal/haladas.png", "alternative progress source reference");
  assert.deepEqual(altProgressRow.sourceAsset, "", "alternative progress row must not embed a copied PNG asset");
  assert.deepEqual(altProgressRow.cropComponents, 0, "alternative progress row must not use source crop components");
  assert.deepEqual(altProgressRow.sourceCropMarkers, 0, "alternative progress row must not expose source crop coordinates");
  assert.deepEqual(altProgressRow.deletedA3References, 0, "A3 alt-progress day detail and all row references must be removed");
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
    altProgressRow.screens.find((screen) => screen.screen === "alt-progress-overview")?.components.includes("alt-progress-menu-grid"),
    "alternative overview must contain a functional menu grid",
  );
  assert.ok(
    altProgressRow.screens.find((screen) => screen.screen === "alt-progress-daily-view")?.textareas === 1,
    "alternative daily view must contain an editable note textarea",
  );
  assert.ok(
    altProgressRow.screens.find((screen) => screen.screen === "alt-progress-statistics")?.components.includes("alt-progress-line-chart"),
    "alternative statistics must contain DOM chart elements",
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
