#!/usr/bin/env python3
"""Render the Android adaptive icon's visible area under common system masks."""
from pathlib import Path
import os
from PIL import Image, ImageDraw

source = Path('android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png')
image = Image.open(source).convert('RGBA')
assert image.width == image.height
visible = round(image.width * 2 / 3)
offset = (image.width - visible) // 2
image = image.crop((offset, offset, offset + visible, offset + visible))
assert image.getchannel('A').getextrema() == (255, 255), 'Visible artwork has a transparent rim'
output = Path(os.environ.get('HAJNAL_EVIDENCE_DIR', 'evidence'))
output.mkdir(exist_ok=True)
for name, shape in [('circle', 'circle'), ('rounded', 'rounded')]:
    mask = Image.new('L', image.size, 0)
    draw = ImageDraw.Draw(mask)
    bounds = (0, 0, visible - 1, visible - 1)
    if shape == 'circle':
        draw.ellipse(bounds, fill=255)
    else:
        draw.rounded_rectangle(bounds, radius=round(visible * .22), fill=255)
    result = image.copy()
    result.putalpha(mask)
    result.save(output / f'launcher-mask-{name}.png')
