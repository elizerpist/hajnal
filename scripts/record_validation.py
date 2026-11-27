#!/usr/bin/env python3
"""Bind a successful emulator validation to the immutable signed candidate."""
import hashlib
import json
from pathlib import Path
import sys


def validation_for(candidate, apk, commit, run, attempt):
    if (candidate.get('commit'), str(candidate.get('run'))) != (commit, str(run)):
        raise ValueError('Candidate commit or run does not match')
    if not str(attempt).isdigit() or int(attempt) < 1:
        raise ValueError('Invalid validation attempt')
    digest = hashlib.sha256(Path(apk).read_bytes()).hexdigest()
    if digest != candidate.get('sha256'):
        raise ValueError('Downloaded APK differs from signed candidate')
    return {'commit': commit, 'run': str(run), 'attempt': str(attempt), 'sha256': digest}


if __name__ == '__main__':
    candidate_path, apk, commit, run, attempt = sys.argv[1:]
    candidate = json.loads(Path(candidate_path).read_text())
    print(json.dumps(validation_for(candidate, apk, commit, run, attempt), indent=2))
