import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const moduleName = process.env.HAJNAL_PLAYWRIGHT_MODULE || "playwright";
const { chromium } = await import(moduleName);

const prototypeDirectory = path.dirname(fileURLToPath(import.meta.url));
const htmlPath = path.join(prototypeDirectory, "hajnal_ui.html");
const evidenceDirectory = path.join(prototypeDirectory, "verification");
const updateEvidence = process.env.HAJNAL_UPDATE_EVIDENCE === "1";
const scratchDirectory = fs.mkdtempSync(path.join(os.tmpdir(), "hajnal-browser-test-"));
const screenOrder = [
  ["splash", null],
  ["onboarding", "splash"],
  ["information", "onboarding"],
  ["start-date", "onboarding"],
  ["recovery-goal", "onboarding"],
  ["sponsor-setup", "onboarding"],
  ["notifications", "onboarding"],
  ["home", "notifications"],
  ["daily-image", "home"],
  ["checkin-clean", "home"],
  ["evening-reflection", "checkin-clean"],
  ["reflection-saved", "evening-reflection"],
  ["checkin-relapse", "home"],
  ["panic-root", "home"],
  ["panic-help-sheet", "panic-root"],
  ["checkin-survival-pack", "panic-root"],
  ["checkin-breathing", "panic-root"],
  ["panic-sponsor-call", "panic-root"],
  ["panic-help-message", "panic-root"],
  ["panic-backup-contact", "panic-root"],
  ["panic-why-started", "panic-root"],
  ["panic-meeting-finder", "panic-root"],
  ["panic-emergency-help", "panic-root"],
];
const screenRows = [
  [
    "entry",
    "splash",
    "splash onboarding information start-date recovery-goal sponsor-setup notifications",
    ["splash", "onboarding", "information", "start-date", "recovery-goal", "sponsor-setup", "notifications"],
  ],
  [
    "home",
    "home",
    "home daily-image checkin-clean evening-reflection reflection-saved",
    [
      "home",
      "daily-image",
      "checkin-clean",
      "evening-reflection",
      "reflection-saved",
    ],
  ],
  [
    "relapse",
    "checkin-relapse",
    "checkin-relapse",
    ["checkin-relapse"],
  ],
  [
    "panic",
    "panic-root",
    "panic-root panic-help-sheet checkin-survival-pack checkin-breathing panic-sponsor-call panic-help-message panic-backup-contact panic-why-started panic-meeting-finder panic-emergency-help",
    [
      "panic-root",
      "panic-help-sheet",
      "checkin-survival-pack",
      "checkin-breathing",
      "panic-sponsor-call",
      "panic-help-message",
      "panic-backup-contact",
      "panic-why-started",
      "panic-meeting-finder",
      "panic-emergency-help",
    ],
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

async function alignScreenForIntegerClip(screen) {
  await screen.scrollIntoViewIfNeeded();
  await screen.evaluate((element) => {
    const bounds = element.getBoundingClientRect();
    if (bounds.top < 0) window.scrollBy(0, Math.floor(bounds.top));
    if (bounds.bottom > window.innerHeight) window.scrollBy(0, Math.ceil(bounds.bottom - window.innerHeight));
  });
}

fs.mkdirSync(evidenceDirectory, { recursive: true });

const browser = await chromium.launch({
  headless: true,
  args: ["--no-sandbox", "--disable-dev-shm-usage"],
});

try {
  const page = await browser.newPage({
    viewport: { width: 3900, height: 1900 },
    deviceScaleFactor: 1,
  });

  await page.goto(pathToFileURL(htmlPath).href, { waitUntil: "networkidle" });

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
  assert.ok(rowPositions.home.top > rowPositions.splash.top + 900, "home must render in the next row");
  assert.equal(rowPositions.home.left, rowPositions.splash.left, "home row must start at the same x position as the entry row");

  const flattenedImages = await page.locator(".phone-screen img").evaluateAll((images) =>
    images
      .filter((image) => {
        const screenId = image.closest(".phone-screen")?.id;
        const allowedSplash = screenId === "splash" && image.src.endsWith("/welcome_svg.svg");
        const allowedFullscreen2 = (screenId === "home" || screenId === "daily-image") && image.src.endsWith("/hero_fullscreen2_svg.svg");
        const allowedHurray = screenId === "checkin-clean" && image.src.endsWith("/hurray_svg.svg");
        const allowedFullscreen = [
          "evening-reflection",
          "reflection-saved",
          "checkin-relapse",
          "checkin-survival-pack",
          "checkin-breathing",
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
    secondaryText: "Később folytatom",
    secondaryWidth: 148,
    primaryWidth: 176,
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
  fs.rmSync(scratchDirectory, { recursive: true, force: true });
}
