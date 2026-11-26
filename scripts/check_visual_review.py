#!/usr/bin/env python3
"""Require a review of the exact screenshots attached to the source commit."""
import hashlib
import json
from pathlib import Path
import struct
import sys


SCREENSHOTS = ('html-closed.png', 'html-open.png', 'onboarding.png',
               'dashboard-closed.png', 'dashboard-open.png')


def check(directory: str, commit: str) -> None:
    directory = Path(directory)
    review = json.loads((directory / 'visual-review.json').read_text())
    if review.get('commit') != commit or review.get('verdict') != 'approved':
        raise ValueError('Visual review must approve this exact commit')
    if not isinstance(review.get('notes'), str) or len(review['notes'].strip()) < 40:
        raise ValueError('Visual review needs actual comparison notes')
    checksums = review.get('screenshots', {})
    if set(checksums) != set(SCREENSHOTS):
        raise ValueError('Visual review must cover all five screenshots')
    for filename in SCREENSHOTS:
        data = (directory / filename).read_bytes()
        if len(data) < 24 or data[:8] != b'\x89PNG\r\n\x1a\n' or struct.unpack('>II', data[16:24]) != (412, 892):
            raise ValueError(f'{filename}: expected a 412x892 PNG')
        if hashlib.sha256(data).hexdigest() != checksums[filename]:
            raise ValueError(f'{filename}: review checksum differs')


if __name__ == '__main__':
    check(*sys.argv[1:])
