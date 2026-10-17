'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /panicNextMeetingOpen:\s*false/, 'Pánik must own the next-meeting popup state');
assert.match(html, /renderPanicVariant\(\)/, 'Pánik must render the fixed alternative layout');
assert.match(html, /data-action="toggle-panic-next-meeting"/, 'The fixed Panic layout must open the next-meeting popup');
assert.match(html, /class="panic-focus-popup-host panic-next-meeting-popup-host" data-component="panic-next-meeting-popup"/, 'The next meeting must use the common centered focus-popup host');
assert.match(html, /openAppOverlaySheet\(this\.panicNextMeetingPopupHost, trigger\)/, 'The next meeting must open through the shared overlay lifecycle');
assert.match(html, /renderPanicNextMeetingPopup\(\)/, 'The next meeting must render into its dedicated popup content host');
assert.doesNotMatch(html, /data-component="panic-next-meeting-slot"/, 'The inline next-meeting slot must be removed');
assert.match(html, /closeAppOverlaySheet\(this\.panicNextMeetingPopupHost\)/, 'Closing next meeting must use the common overlay lifecycle');
assert.match(html, /else if \(this\.state\.panicNextMeetingOpen\) this\.closePanicNextMeeting\(\)/, 'Escape must close the next-meeting popup before leaving Panic');
assert.match(html, /if \(this\.state\.panicNextMeetingOpen\) \{ this\.closePanicNextMeeting\(\); return; \}/, 'Android Back must close the next-meeting popup before routing');
assert.match(html, /startPanicNextMeetingTicker\(\)[\s\S]*?renderPanicNextMeetingPopup\(\)/, 'The open popup must retain the existing minute-based meeting refresh');
assert.doesNotMatch(html, /data-action="toggle-panic-variant"/, 'The removed panic layout toggle must not survive');
assert.doesNotMatch(html, /renderPanicClassic\(/, 'The static six-tile panic layout must be removed');
assert.match(html, /panic-alternative/, 'Alternative Pánik needs its own scoped view boundary');
assert.match(html, /panic-main-button--pulse/, 'Alternative help button must receive a scoped pulse class');
assert.match(html, /@keyframes\s+panic-help-pulse/, 'Alternative help pulse needs a CSS keyframe');
assert.match(html, /@media\s*\(prefers-reduced-motion:\s*reduce\)/, 'continuous Pánik animation must respect reduced-motion');
assert.match(html, /@media \(max-width: 411px\) \{ \.app-frame \{ width: 100vw; height: 100vh;/, 'the shared shell must fit 320–411px mobile viewports without horizontal frame overflow');
assert.match(html, /openPanicHelpSheet\(/, 'the large help button must open the shared contact sheet');
assert.match(html, /closePanicHelpSheet\(/, 'the help sheet needs a controller close path');
assert.match(html, /Hívj fel valakit/, 'the sheet must explain its safe purpose');
assert.match(html, /Nem indul automatikus hívás vagy üzenet\./, 'the sheet must state that no call or message is automatic');
assert.match(html, /tel:112/, 'emergency dialing must be explicit and scoped to 112');
assert.match(html, /panicHelpContact/, 'help contact selection must remain central controller state');
assert.match(html, /survivalSession/, 'the survival flow must have a resumable timestamped session');
assert.match(html, /startedAt/, 'the survival timer must be based on a real start timestamp');
assert.match(html, /completeSurvivalPack\(/, 'survival must be finishable without compulsory calling');
assert.doesNotMatch(html, /if \(this\.state\.survivalStep >= SURVIVAL_STEPS\.length - 1\) \{ this\.navigate\('panic-contacts'\)/, 'finishing survival may not force the legacy contact route');

// The two Panic support surfaces deliberately share the existing controller and
// overlay lifecycle, but are no longer bottom sheets: they must be centered
// focus popups above the unchanged Panic/survival route.
assert.match(html, /class="panic-focus-popup-host" data-component="panic-help-sheet"/, 'Calling someone must use the common centered focus-popup host');
assert.match(html, /class="panic-focus-popup-host panic-motivation-popup-host" data-component="panic-motivation-sheet"/, 'Why I started must use the same centered focus-popup host');
assert.match(html, /class="panic-focus-popup panic-next-meeting-popup" role="dialog"[^>]+aria-labelledby="panic-next-meeting-popup-title"/, 'Next meeting must be an accessible focus dialog');
assert.match(html, /class="panic-focus-popup" role="dialog"[^>]+aria-labelledby="panic-help-sheet-title"/, 'The help content must be a focus dialog rather than a slide-up panel');
assert.match(html, /class="panic-focus-popup panic-motivation-popup" role="dialog"[^>]+aria-labelledby="panic-motivation-sheet-title"/, 'The motivation content must be a focus dialog rather than a slide-up panel');
assert.match(html, /\.panic-focus-popup-host \{[^}]*display: grid;[^}]*place-items: center;[^}]*\}/, 'The common popup host must center the dialog in the available app viewport');
assert.match(html, /\.panic-focus-popup \{[^}]*max-height: min\(78dvh, 690px\);[^}]*transform: scale\(\.96\);[^}]*\}/, 'The popup must use a constrained focus-window geometry and scale entrance state');
assert.match(html, /\.panic-focus-popup-host\[data-sheet-state="open"\] \.panic-focus-popup \{ transform: scale\(1\); opacity: 1; \}/, 'The popup must open with a focus transition rather than translate from the bottom');
assert.doesNotMatch(html, /data-panic-sheet-handle=/, 'Focus popups must not retain bottom-sheet drag handles');

console.log('PASS panic alternative source contract');
