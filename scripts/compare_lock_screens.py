#!/usr/bin/env python3
"""Align reference content with emulator screenshots for manual review."""
from pathlib import Path
from PIL import Image, ImageChops

reference = Image.open('docs/references/source-of-truth/pin.png').convert('RGB')
for name, left in [('lock-settings', 88), ('lock-pin-setup', 558), ('lock-biometric-step', 1030)]:
    actual = Image.open(f'evidence/{name}.png').convert('RGB')
    if name == 'lock-settings':
        left_pixel = actual.getpixel((10, 80))
        right_pixel = actual.getpixel((actual.width - 10, 80))
        difference = sum(abs(a - b) for a, b in zip(left_pixel, right_pixel))
        Path('evidence/lock-settings-status.txt').write_text('PASS\n' if difference < 60 else 'FAIL\n')
    if name == 'lock-biometric-step':
        # The reference's brand mark occupies the upper centre, above the title.
        region = actual.crop((80, 30, actual.width - 80, 210))
        background = actual.getpixel((20, 20))
        visible = sum(1 for pixel in region.getdata() if sum(abs(a - b) for a, b in zip(pixel, background)) > 40)
        Path('evidence/lock-logo-status.txt').write_text('PASS\n' if visible >= 4000 else 'FAIL\n')
    # Status and navigation areas belong to Android, not to the mockup.
    actual = actual.crop((0, 24, actual.width, actual.height - 48))
    expected = reference.crop((left, 130, left + 418, 945)).resize(actual.size, Image.Resampling.LANCZOS)
    overlay = Image.blend(expected, actual, 0.5)
    difference = ImageChops.difference(expected, actual)
    panel = Image.new('RGB', (actual.width * 4, actual.height))
    for index, image in enumerate((expected, actual, overlay, difference)):
        panel.paste(image, (index * actual.width, 0))
    panel.save(Path('evidence') / f'{name}-comparison.png')
