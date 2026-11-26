#!/usr/bin/env python3
"""Align reference content with emulator screenshots for manual review."""
from pathlib import Path
from PIL import Image, ImageChops

reference = Image.open('docs/references/source-of-truth/pin.png').convert('RGB')
for name, left in [('lock-settings', 88), ('lock-pin-setup', 558), ('lock-biometric-step', 1030)]:
    actual = Image.open(f'evidence/{name}.png').convert('RGB')
    # Status and navigation areas belong to Android, not to the mockup.
    actual = actual.crop((0, 24, actual.width, actual.height - 24))
    expected = reference.crop((left, 130, left + 418, 965)).resize(actual.size, Image.Resampling.LANCZOS)
    overlay = Image.blend(expected, actual, 0.5)
    difference = ImageChops.difference(expected, actual)
    panel = Image.new('RGB', (actual.width * 4, actual.height))
    for index, image in enumerate((expected, actual, overlay, difference)):
        panel.paste(image, (index * actual.width, 0))
    panel.save(Path('evidence') / f'{name}-comparison.png')
