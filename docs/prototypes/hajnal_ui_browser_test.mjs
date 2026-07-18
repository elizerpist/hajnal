import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const moduleName = process.env.HAJNAL_PLAYWRIGHT_MODULE || "playwright";
const { chromium } = await import(moduleName);

const prototypeDirectory = path.dirname(fileURLToPath(import.meta.url));
const htmlPath = path.join(prototypeDirectory, "hajnal_ui.html");
const evidenceDirectory = path.join(prototypeDirectory, "verification");
const screenOrder = [
  ["splash", null],
  ["onboarding", "splash"],
  ["information", "onboarding"],
  ["start-date", "onboarding"],
  ["recovery-goal", "onboarding"],
  ["sponsor-setup", "onboarding"],
  ["notifications", "onboarding"],
  ["home", "notifications"],
];

function pngSize(filename) {
  const buffer = fs.readFileSync(filename);
  assert.equal(buffer.toString("ascii", 1, 4), "PNG", `${filename} must be a PNG`);
  return {
    width: buffer.readUInt32BE(16),
    height: buffer.readUInt32BE(20),
  };
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

  const flattenedImages = await page.locator(".phone-screen img").evaluateAll((images) =>
    images
      .filter((image) => image.closest(".phone-screen")?.id !== "splash" || !image.src.endsWith("/logo.png"))
      .map((image) => ({ screen: image.closest(".phone-screen")?.id, src: image.src })),
  );
  assert.deepEqual(flattenedImages, [], "phone screens must not be flattened raster images");

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

    const evidencePath = path.join(evidenceDirectory, `${id}.png`);
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

  await page.setViewportSize({ width: 3900, height: 900 });
  await page.screenshot({
    path: path.join(evidenceDirectory, "first-page-overview.png"),
    fullPage: true,
    animations: "disabled",
  });
} finally {
  await browser.close();
}
