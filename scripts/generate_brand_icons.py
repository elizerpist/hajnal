#!/usr/bin/env python3
"""Regenerate launcher PNGs from assets/brand/logo.svg using librsvg."""
import json
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parent.parent
logo = root / 'assets/brand/logo.svg'
android = root / 'android/app/src/main/res'
ios = root / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'


def render(path, size, *, background=None, content=None):
    path.parent.mkdir(parents=True, exist_ok=True)
    content = size if content is None else content
    offset = (size - content) / 2
    args = ['rsvg-convert', '--width', str(content), '--height', str(content),
            '--page-width', str(size), '--page-height', str(size),
            f'--left={offset}', f'--top={offset}']
    if background:
        args += ['--background-color', background]
    subprocess.run([*args, '--output', str(path), str(logo)], check=True)


for density, size in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96),
                      ('xxhdpi', 144), ('xxxhdpi', 192)]:
    # Cover the system mask with the source artwork, excluding its transparent rim.
    render(android / f'mipmap-{density}/ic_launcher.png', size,
           background='#1d1e53', content=round(size * 1.6))
    canvas = size * 9 // 4
    render(android / f'mipmap-{density}/ic_launcher_foreground.png', canvas,
           content=round(canvas * 1.25))

catalog = json.loads((ios / 'Contents.json').read_text())
for item in catalog['images']:
    points = float(item['size'].split('x')[0])
    pixels = round(points * int(item['scale'][0]))
    render(ios / item['filename'], pixels, background='#1d1e53', content=round(pixels * 1.6))
