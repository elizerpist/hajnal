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
  ["information", "onboarding"],
  ["start-date", "onboarding"],
  ["recovery-goal", "onboarding"],
  ["sponsor-setup", "onboarding"],
  ["notifications", "onboarding"],
  ["home-collapsed", "notifications"],
  ["home", "home-collapsed"],
  ["checkin-clean", "home"],
  ["evening-reflection", "checkin-clean"],
  ["reflection-saved", "evening-reflection"],
  ["panic-root", "home"],
  ["panic-help-sheet", "panic-root"],
  ["checkin-survival-pack", "panic-root"],
  ["panic-sponsor-call", "panic-root"],
  ["panic-help-message", "panic-root"],
  ["panic-backup-contact", "panic-root"],
  ["panic-why-started", "panic-root"],
  ["panic-meeting-finder", "panic-root"],
  ["panic-emergency-help", "panic-root"],
  ["checkin-relapse", "home"],
  ["daily-image", "home"],
];
const screenRows = [
  [
    "entry",
    "splash",
    "welcome-lighting-lab splash onboarding information start-date recovery-goal sponsor-setup notifications",
    ["welcome-lighting-lab", "splash", "onboarding", "information", "start-date", "recovery-goal", "sponsor-setup", "notifications"],
  ],
  [
    "home",
    "home-collapsed",
    "home-collapsed home checkin-clean evening-reflection reflection-saved",
    [
      "home-collapsed",
      "home",
      "checkin-clean",
      "evening-reflection",
      "reflection-saved",
    ],
  ],
  [
    "panic",
    "panic-root",
    "panic-root panic-help-sheet checkin-survival-pack panic-sponsor-call panic-help-message panic-backup-contact panic-why-started panic-meeting-finder panic-emergency-help checkin-relapse",
    [
      "panic-root",
      "panic-help-sheet",
      "checkin-survival-pack",
      "panic-sponsor-call",
      "panic-help-message",
      "panic-backup-contact",
      "panic-why-started",
      "panic-meeting-finder",
      "panic-emergency-help",
      "checkin-relapse",
    ],
  ],
  [
    "daily-image",
    "daily-image",
    "daily-image",
    ["daily-image"],
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
  assert.ok(rowPositions["panic-root"].top > rowPositions["home-collapsed"].top + 900, "panic row must be directly below the home row");
  assert.ok(rowPositions["daily-image"].top > rowPositions["panic-root"].top + 900, "daily image row must render below the panic row");

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
    };
  });
  assert.deepEqual(collapsedHomeLayout, {
    dashboardTop: 614,
    hasOpenedCard: false,
    navBottomGap: 0,
    navLabels: ["Kezdőlap", "Haladás", "Eszközök", "Szponzor", "Profil"],
    currentTarget: "home-collapsed",
  }, "collapsed home must keep the dashboard lower and render a complete bottom nav");

  const panicRootActions = await page.locator("#panic-root .panic-grid button").evaluateAll((buttons) =>
    buttons.map((button) => ({
      text: button.textContent.trim(),
      action: button.dataset.action,
      target: button.dataset.targetScreen,
    })),
  );
  assert.deepEqual(panicRootActions, [
    { text: "Hívd a szponzorod", action: "call-sponsor", target: "panic-sponsor-call" },
    { text: "Hívd a tartalék kapcsolattartót", action: "call-backup-contact", target: "panic-backup-contact" },
    { text: "15 perces túlélőcsomag", action: "start-survival-pack", target: "checkin-survival-pack" },
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
      };
    }),
  );
  assert.deepEqual(panicMainButtonState, [
    { text: "Segítségkell", hasHeartIcon: true, backgroundImage: "none", display: "flex", flexDirection: "column" },
    { text: "Segítségkell", hasHeartIcon: true, backgroundImage: "none", display: "flex", flexDirection: "column" },
  ], "large panic help buttons must have a homogeneous fill and heart icon");

  const flattenedImages = await page.locator(".phone-screen img").evaluateAll((images) =>
    images
      .filter((image) => {
        const screenId = image.closest(".phone-screen")?.id;
        const allowedSplash = screenId === "splash" && image.src.endsWith("/welcome_svg.svg");
        const allowedFullscreen2 = ["home-collapsed", "home", "daily-image"].includes(screenId) && image.src.endsWith("/hero_fullscreen2_svg.svg");
        const allowedHurray = screenId === "checkin-clean" && image.src.endsWith("/hurray_svg.svg");
        const allowedFullscreen = [
          "evening-reflection",
          "reflection-saved",
          "checkin-relapse",
          "checkin-survival-pack",
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

    assert.equal(metrics.width, 412, `${id} width`);
    assert.equal(metrics.height, 892, `${id} height`);
    assert.equal(metrics.borderRadius, "34px", `${id} radius`);
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
        width: 412,
        height: 892,
      },
      animations: "disabled",
    });
    assert.deepEqual(pngSize(evidencePath), { width: 412, height: 892 }, `${id} screenshot size`);
    process.stdout.write(`PASS browser ${id} 412x892 no-overflow\n`);
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
