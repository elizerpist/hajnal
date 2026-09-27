#!/usr/bin/env node
'use strict';

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

const shellRoot = path.resolve(__dirname, '..');
const html = fs.readFileSync(path.join(shellRoot, 'index.html'), 'utf8');
const framePath = path.join(shellRoot, 'assets', 'frames', 'frame1.png');

assert.ok(fs.existsSync(framePath), 'the supplied transparent frame1.png must be a local app-shell asset');
const frame = fs.readFileSync(framePath);
assert.equal(frame.toString('ascii', 1, 4), 'PNG', 'frame1.png must remain a PNG');
assert.equal(frame.readUInt32BE(16), 1122, 'frame1.png must retain its source width');
assert.equal(frame.readUInt32BE(20), 1402, 'frame1.png must retain its source height');
assert.equal(crypto.createHash('sha256').update(frame).digest('hex'), '0252b64186c04c09e97754153b13baaf55825a469bcf3fb50b483ccc0bf13516', 'frame1.png must remain the supplied frame asset');

assert.match(html, /<h1 id="milestone-screen-title">Mérföldkövek<\/h1><p>9 kapu a 90 napos úton\.<\/p>/, 'gallery title and subtitle must match the source reference');
assert.match(html, /<p class="milestone-intro">Minden tiszta nap egy újabb lépés<br>önmagad felé\.<\/p>/, 'gallery introductory copy must match the source reference');
assert.match(html, /<p class="milestone-gallery-closing">Ugyanaz a bátorság,<br>ragyogóbb holnapok\.<\/p>/, 'gallery closing copy must match the source reference');

const galleryStart = html.indexOf('<section class="milestone-grid"');
const gallery = galleryStart >= 0 ? html.slice(galleryStart, html.indexOf('</main>', galleryStart)) : '';
assert.equal((gallery.match(/class="milestone-frame"/g) || []).length, 9, 'every 3×3 gallery card must carry the supplied decorative frame');
assert.equal((gallery.match(/class="milestone-art-window"/g) || []).length, 9, 'every gallery image must sit beneath the frame in an inner crop window');
assert.equal((gallery.match(/data-milestone-badge="unlocked"/g) || []).length, 5, 'all five active milestones must render an unlocked badge');
assert.equal((gallery.match(/data-milestone-badge="locked"/g) || []).length, 4, 'all four inactive milestones must render a locked badge');
assert.match(gallery, /class="milestone-art-window"[\s\S]*?class="milestone-art"[\s\S]*?class="milestone-frame"[\s\S]*?data-milestone-badge=/, 'art must be layered below the transparent frame and its upper-right badge');
assert.match(html, /\.milestone-grid\s*\{[^}]*grid-auto-rows:\s*148px[^}]*gap:\s*10px/s, 'gallery must use the source-proportioned 3×3 grid geometry');
assert.match(html, /\.milestone-card\s*\{(?=[^}]*aspect-ratio:\s*1122\s*\/\s*1402)(?=[^}]*background:\s*transparent)(?=[^}]*border:\s*0)/s, 'each card must use the supplied frame proportions without a substitute card shell');
assert.match(html, /\.milestone-art-window\s*\{[^}]*overflow:\s*hidden[^}]*border-radius:/s, 'milestone art must be clipped to the frame hole\'s rounded-square shape');
assert.match(html, /\.milestone-frame\s*\{[^}]*z-index:\s*2/s, 'the transparent decorative frame must overlay the milestone art');
assert.match(html, /\.milestone-status-badge\[data-milestone-badge="unlocked"\][^}]*background:\s*#68B88B/s, 'active cards must use the requested green check badge');
assert.match(html, /\.milestone-status-badge\[data-milestone-badge="locked"\][^}]*color:\s*#8E8A9F/s, 'inactive cards must use the requested gray lock badge');
assert.match(html, /\.milestone-screen \.screen-header-copy h1[^}]*font-family:\s*Georgia/s, 'source gallery title must use its serif type treatment');
assert.match(html, /\.milestone-card h3[^}]*font-family:\s*Georgia/s, 'source gallery milestone labels must use their serif type treatment');

console.log('PASS source-faithful framed milestone gallery contract');
