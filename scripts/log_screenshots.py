"""Preserve synthetic CI screenshots for inspection if artifact upload fails."""

import base64
from pathlib import Path
import sys


for name in sys.argv[1:]:
    path = Path(name)
    if not path.is_file() or path.stat().st_size == 0:
        continue
    encoded = base64.b64encode(path.read_bytes()).decode('ascii')
    for offset in range(0, len(encoded), 4000):
        print(f'HAJNAL_IMAGE {path.name} {encoded[offset:offset + 4000]}')
