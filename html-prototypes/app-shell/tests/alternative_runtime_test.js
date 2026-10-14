#!/usr/bin/env node
'use strict';

// The former alternative History runtime tested the intentionally removed
// card-carousel mode. The live controller contract now has a single chapter
// pager and is asserted by the source-level redesign contract.
require('./history_chapter_hero_redesign_test');
console.log('PASS alternative runtime contract migrated to permanent chapter pager');
