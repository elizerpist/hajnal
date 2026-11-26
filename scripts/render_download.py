#!/usr/bin/env python3
"""Render a verified release as a rollback-protected static download page."""
import html
import json
from pathlib import Path
import re
import sys
from urllib.parse import urlparse


def render(url: str, metadata_path: str, page_path: str) -> None:
    metadata = json.loads(Path(metadata_path).read_text())
    page = Path(page_path)
    if (
        urlparse(url).scheme != 'https'
        or not re.fullmatch(r'[0-9a-f]{40}', metadata['commit'])
        or not re.fullmatch(r'[0-9a-f]{64}', metadata['sha256'])
        or not re.fullmatch(r'[0-9a-f]{64}', metadata['signingCertificateSha256'])
        or not isinstance(metadata['versionCode'], int)
        or metadata['versionCode'] < 1
    ):
        raise ValueError('Invalid release metadata')
    if page.exists():
        match = re.search(r'<!-- HAJNAL_META (.*?) -->', page.read_text())
        if not match:
            raise ValueError('Existing page has no verifiable metadata')
        old = json.loads(match.group(1))
        if old['signingCertificateSha256'] != metadata['signingCertificateSha256']:
            raise ValueError('Signing certificate changed')
        if old['commit'] == metadata['commit'] and (old['sha256'], old['versionCode']) != (metadata['sha256'], metadata['versionCode']):
            raise ValueError('Published commit binary metadata differs')
        if old['versionCode'] >= metadata['versionCode'] and old['commit'] != metadata['commit']:
            raise ValueError('Same or newer version already published')
    marker = json.dumps(metadata, separators=(',', ':'), sort_keys=True)
    escape = html.escape
    page.write_text(f'''<!doctype html>
<html lang="hu"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta http-equiv="refresh" content="0; url={escape(url, quote=True)}"><title>Hajnal letöltése</title></head>
<body><main><h1>Hajnal S0</h1><p><a href="{escape(url, quote=True)}">HUMAN APK letöltése</a></p>
<p>Forráscommit: <code>{escape(metadata['commit'])}</code></p><p>Buildidő: {escape(metadata['buildTime'])}</p>
<p>SHA-256: <code>{escape(metadata['sha256'])}</code></p></main><!-- HAJNAL_META {marker} --></body></html>\n''')


if __name__ == '__main__':
    render(*sys.argv[1:])
