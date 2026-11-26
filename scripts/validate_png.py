#!/usr/bin/env python3
"""Fail when an adb error or an empty/truncated screenshot replaces a PNG."""
from pathlib import Path
import struct
import sys

header = Path(sys.argv[1]).read_bytes()[:24]
if len(header) != 24 or header[:8] != b'\x89PNG\r\n\x1a\n':
    raise SystemExit(f'{sys.argv[1]} is not a PNG screenshot')
width, height = struct.unpack('>II', header[16:24])
if width < 300 or height < 600:
    raise SystemExit(f'{sys.argv[1]} is too small: {width}x{height}')
