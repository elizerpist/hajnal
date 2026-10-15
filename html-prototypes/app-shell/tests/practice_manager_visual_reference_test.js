'use strict';

/*
 * Source contract for the approved `gyakorlat.png` manager composition.
 * This protects only the visual shell; controller/persistence ownership stays
 * covered by the existing practice manager tests.
 */

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');

assert.match(html, /practice-focus-dialog--manager/, 'The manager needs its own scoped focus-layout class, not a generic scrolling popup');
assert.match(html, /practice-manager-scroll/, 'Only the manager list must own the scroll area');
assert.match(html, /practice-manager-list-heading[\s\S]*?practice-list-filter/, 'The manager heading and compact filter must remain paired');
assert.match(html, /practice-active-card[\s\S]*?practice-active-card-action/, 'The active card needs a dedicated right-side Details action');
assert.match(html, /practice-manager-row[\s\S]*?practice-row-activate[\s\S]*?practice-row-menu/, 'Every row needs separate activate and context actions');
assert.match(html, /\.practice-focus-dialog--manager\s*\{[\s\S]*?grid-template-rows:/, 'The manager must reserve fixed rows around its scrollable list');
assert.match(html, /\.practice-manager-scroll\s*\{[\s\S]*?overflow-y:\s*auto/, 'The list, not the dialog, must be vertically scrollable');
assert.match(html, /\.practice-manager-row\s*\{[\s\S]*?grid-template-columns:\s*[^;]*auto\s+minmax\(0,1fr\)\s+auto\s+auto/, 'List rows must use icon, copy, activate and context columns');
assert.match(html, /\.practice-manager-create\s*\{[\s\S]*?border:\s*1px dashed/, 'The create action needs the approved dashed outline treatment');

console.log('PASS practice manager visual-reference contract');
