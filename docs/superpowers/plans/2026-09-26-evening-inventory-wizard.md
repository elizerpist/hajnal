# Evening Inventory Wizard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add one reviewable, eight-screen Evening Reflection / Daily Inventory wizard row below the existing daily-close row without replacing the approved Screen 12 baseline.

**Architecture:** The canonical standalone HTML remains the only implementation owner. New `evening-inventory-*` screens share one Screen-12-derived `checkin-fullscreen` presentation layer and a small local DOM controller for optional selections, conditional fields, gratitude rows, and wizard navigation. The existing `#evening-reflection` DOM/CSS/JS remains isolated and unchanged as the visual baseline.

**Tech Stack:** One offline HTML document, embedded CSS, embedded JavaScript, Node static contract tests.

## Global Constraints

- Keep `html-prototypes/offline-ui/index.html` standalone, offline, and free of network or asset dependencies.
- Retain all existing Home, daily-close, panic, statistics, recovery, and Screen 12 behavior.
- Place `data-page="evening-inventory-wizard"` immediately after `home-daily-close`; preserve later rows' relative order.
- Render exactly eight semantic `412 × 892` screens: state, recovery, connection, program, honest-review, gratitude, spirituality, free-reflection.
- All inventory inputs are optional; no score, required-field warning, or recovery-quality percentage is introduced.
- Keep future data fields separate with meaningful `data-inventory-*` markers; a Timeline session remains conceptual only.

---

### Task 1: Add the acceptance and red structural contract

**Files:**
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`
- Modify: `docs/prototypes/hajnal_ui_static_test.js`

- [x] **Step 1: Add `HJN-20260926-13`**

Record the authoritative prompt, all seven source-of-truth PNGs, Screen 12 as visual master, the row-order override for former HJN-20260926-06, and the required static/browser evidence.

- [x] **Step 2: Add a failing static test**

Require the `evening-inventory-wizard` row, exact eight-item order, parent/target relationships, Screen 12 preservation, optional navigation, structured data components, gratitude behavior, and no score/mandatory controls.

- [x] **Step 3: Run the focused static test**

Run: `node docs/prototypes/hajnal_ui_static_test.js eveningInventory`

Expected: failure because the new row and its screen IDs do not exist yet.

### Task 2: Build the shared evening-inventory screen family

**Files:**
- Modify: `html-prototypes/offline-ui/index.html`

- [x] **Step 1: Add CSS derived from Screen 12**

Create one `evening-inventory` family using the existing full-screen background, moon header, translucent panel, subdued lavender/pink/cream controls, native control focus styles, and scroll/fixed footer pattern. Do not alter `#evening-reflection` rules.

- [x] **Step 2: Add the new Home-content row**

Insert a new semantic row after `home-daily-close`, add its visual order rule, and render the eight labelled screen columns in the exact inventory order.

- [x] **Step 3: Add minimal local interaction**

Implement only local UI state: choice `aria-pressed` changes, optional conditional text regions, non-blocking back/next navigation metadata, gratitude add/remove/edit rows, and the free-reflection selector with text/photo/voice controls. Do not add storage or a Timeline event renderer.

- [x] **Step 4: Run the focused static test**

Run: `node docs/prototypes/hajnal_ui_static_test.js eveningInventory`

Expected: pass.

### Task 3: Verify the complete prototype contract

**Files:**
- Modify: `docs/prototypes/ACCEPTANCE_CHECKLIST.md`

- [x] **Step 1: Run all static and offline tests**

Run:

```sh
node docs/prototypes/hajnal_ui_static_test.js all
node html-prototypes/offline-ui/tests/offline_single_file_test.js
node --check docs/prototypes/hajnal_ui_static_test.js
node --check docs/prototypes/hajnal_ui_browser_test.mjs
git diff --check
```

- [x] **Step 2: Attempt browser evidence at 412 × 892**

Run the project browser test if Playwright is installed; otherwise record `PARTIAL` with the exact missing dependency and do not claim screenshot verification.

- [x] **Step 3: Update acceptance status honestly and commit/push**

Stage only the wizard implementation, acceptance checklist, tests, and this plan. Commit on `feat/first-prototype-page` and push without force.
