#!/usr/bin/env python3
"""Keep the Welcome artwork intact while removing only the unwanted sky band."""
import hashlib
import json
from pathlib import Path
import unittest
import xml.etree.ElementTree as ET

SVG = '{http://www.w3.org/2000/svg}'
PATH = Path('assets/artwork/onboarding/welcome.svg')
REMOVED = (
    'M0 0L853 0L853 262.262C848.841 262.809',
    'M125.929 255.023',
    'M833.504 283.349',
    'M828.444 277.412',
)


class WelcomeArtworkTest(unittest.TestCase):
    def test_sky_gradient_and_viewbox(self):
        root = ET.parse(PATH).getroot()
        self.assertEqual(root.get('viewBox'), '0 0 853 1844')
        gradient = root.find(f'.//{SVG}linearGradient[@id="gradient_0"]')
        self.assertEqual(gradient.attrib, {
            'id': 'gradient_0', 'gradientUnits': 'userSpaceOnUse',
            'x1': '418.67084', 'y1': '1225.2273',
            'x2': '435.95963425', 'y2': '0',
        })
        self.assertEqual([item.attrib for item in gradient], [
            {'offset': '0', 'stop-color': '#FFBAB1'},
            {'offset': '0.80351179', 'stop-color': '#B084EE'},
            {'offset': '1', 'stop-color': '#A67CDE'},
        ])
        backgrounds = [p for p in root.findall(f'.//{SVG}path')
                       if p.get('fill') == 'url(#gradient_0)']
        self.assertEqual(len(backgrounds), 1)
        self.assertEqual(backgrounds[0].get('d'), 'M0 0L853 0L853 1844L0 1844Z')

    def test_only_the_four_named_paths_were_removed(self):
        paths = ET.parse(PATH).getroot().findall(f'.//{SVG}path')
        self.assertFalse(any(p.get('fill') == '#A67CDE' and
                             p.get('d', '').startswith(REMOVED) for p in paths))
        payload = json.dumps([p.attrib for p in paths if p.get('fill') != 'url(#gradient_0)'], sort_keys=True,
                             separators=(',', ':')).encode()
        self.assertEqual(hashlib.sha256(payload).hexdigest(),
                         '2bcf09a6e4ac79aa559ec166fa72be0f5813e2305212c121f7421f3dfe9f4687')


if __name__ == '__main__':
    unittest.main()
