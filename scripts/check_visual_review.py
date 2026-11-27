#!/usr/bin/env python3
"""Require a review of the exact screenshots attached to the source commit."""
import hashlib
import json
from pathlib import Path
import struct
import sys


SCREENSHOTS = ('calendar-density160.png', 'calendar-density240.png', 'calendar-years.png', 'calendar-months.png', 'calendar-today-outline.png', 'style-editor.png', 'style-preview-card.png', 'style-onboarding.png', 'style-lock.png', 'launcher-mask-circle.png', 'launcher-mask-rounded.png', 'boarding-welcome-1.png', 'boarding-welcome-2.png', 'boarding-welcome-3.png', 'boarding-date.png', 'boarding-motivation.png', 'boarding-modules.png', 'boarding-sponsor.png', 'boarding-sponsor-expanded.png', 'html-closed.png', 'html-open.png', 'onboarding.png',
               'dashboard-closed.png', 'dashboard-open.png', 'picker-open.png',
               'picker-night.png', 'picker-before-upgrade.png', 'picker-after-upgrade.png',
               'lock-settings.png', 'lock-pin-setup.png', 'lock-biometric-step.png',
               'lock-real-setup.png', 'lock-launcher.png',
               'lock-settings-comparison.png', 'lock-pin-setup-comparison.png',
               'lock-biometric-step-comparison.png')


def check(directory: str, commit: str) -> None:
    directory = Path(directory)
    review = json.loads((directory / 'visual-review.json').read_text())
    if review.get('commit') != commit or review.get('verdict') != 'approved':
        raise ValueError('Visual review must approve this exact commit')
    if not isinstance(review.get('notes'), str) or len(review['notes'].strip()) < 40:
        raise ValueError('Visual review needs actual comparison notes')
    checksums = review.get('screenshots', {})
    if set(checksums) != set(SCREENSHOTS):
        raise ValueError('Visual review must cover all screenshots and comparisons')
    for filename in SCREENSHOTS:
        data = (directory / filename).read_bytes()
        if len(data) < 24 or data[:8] != b'\x89PNG\r\n\x1a\n':
            raise ValueError(f'{filename}: expected a PNG')
        width, height = struct.unpack('>II', data[16:24])
        if filename.startswith('lock-'):
            if width < 300 or height < 600:
                raise ValueError(f'{filename}: image too small')
        elif filename.startswith('launcher-mask-'):
            if (width, height) != (288, 288):
                raise ValueError(f'{filename}: expected a 288x288 icon mask')
        elif filename == 'calendar-density240.png':
            if (width, height) != (618, 1338):
                raise ValueError(f'{filename}: expected a 618x1338 PNG')
        elif (width, height) != (412, 892):
            raise ValueError(f'{filename}: expected a 412x892 PNG')
        if hashlib.sha256(data).hexdigest() != checksums[filename]:
            raise ValueError(f'{filename}: review checksum differs')


if __name__ == '__main__':
    check(*sys.argv[1:])
