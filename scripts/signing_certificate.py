#!/usr/bin/env python3
"""Read the one verified signer fingerprint from supported apksigner output."""
from pathlib import Path
import re
import sys


def certificate(text: str, expected: str) -> str:
    fingerprints = set(re.findall(
        r'^(?:Signer #\d+|V\d+ Signer):? certificate SHA-256 digest: ([0-9a-fA-F]{64})\s*$',
        text, flags=re.MULTILINE,
    ))
    fingerprints = {value.lower() for value in fingerprints}
    if len(fingerprints) != 1:
        raise ValueError('Expected exactly one APK signing certificate')
    fingerprint = fingerprints.pop()
    if not re.fullmatch(r'[0-9a-f]{64}', expected) or fingerprint != expected:
        raise ValueError('APK is not signed by the configured Hajnal certificate')
    return fingerprint


if __name__ == '__main__':
    print(certificate(Path(sys.argv[1]).read_text(), Path(sys.argv[2]).read_text().strip()))
