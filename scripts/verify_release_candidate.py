#!/usr/bin/env python3
"""Accept only the tested APK from a trusted run awaiting visual review."""
import hashlib
import json
from pathlib import Path
import sys


def check(run, candidate, apk, commit, run_id):
    if (run['headSha'], run['headBranch'], run['event']) != (
        commit, 'build/starter', 'push'
    ):
        raise ValueError('Candidate did not come from the trusted branch push')
    if run['status'] not in ('completed', 'in_progress'):
        raise ValueError('Source run has not reached the review gate')
    jobs = {job['name']: job for job in run['jobs']}
    if jobs['verify']['conclusion'] != 'success':
        raise ValueError('Verification job did not pass')
    if jobs['human-apk']['conclusion'] != 'success':
        raise ValueError('HUMAN build and Android tests did not pass')
    steps = jobs['human-apk']['steps']
    results = {step['name']: step['conclusion'] for step in steps}
    required = ('Run local and schema checks in the release workspace',
                'Build signed HUMAN APK', 'Android smoke and integration tests',
                'Publish evidence to a draft release',
                'Require rendered lock screen evidence', 'Stage the tested HUMAN APK')
    if any(results.get(name) != 'success' for name in required):
        raise ValueError('A required build or test step failed')
    if any(step['conclusion'] == 'failure' for step in steps):
        raise ValueError('The source run has another failed step')
    if candidate['commit'] != commit or str(candidate['run']) != str(run_id):
        raise ValueError('Candidate provenance does not match the test run')
    if hashlib.sha256(Path(apk).read_bytes()).hexdigest() != candidate['sha256']:
        raise ValueError('Candidate APK differs from the tested APK')


if __name__ == '__main__':
    run_path, candidate_path, apk_path, sha, run_id = sys.argv[1:]
    check(json.loads(Path(run_path).read_text()),
          json.loads(Path(candidate_path).read_text()), apk_path, sha, run_id)
