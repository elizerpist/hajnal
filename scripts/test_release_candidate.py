import hashlib
import os
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory
import unittest

from verify_release_candidate import check
from record_validation import validation_for


class CandidateTest(unittest.TestCase):
    def test_validation_proof_binds_commit_run_attempt_and_downloaded_apk(self):
        with TemporaryDirectory() as temp:
            apk = Path(temp, 'candidate.apk')
            apk.write_bytes(b'signed candidate')
            sha = 'a' * 40
            candidate = {'commit': sha, 'run': '42',
                         'sha256': hashlib.sha256(apk.read_bytes()).hexdigest()}
            proof = validation_for(candidate, apk, sha, '42', '2')
            self.assertEqual(proof, {'commit': sha, 'run': '42', 'attempt': '2',
                                     'sha256': candidate['sha256']})
            with self.assertRaises(ValueError):
                validation_for(candidate, apk, sha, '42', '0')
            apk.write_bytes(b'other')
            with self.assertRaises(ValueError):
                validation_for(candidate, apk, sha, '42', '2')

    def test_staging_is_idempotent_and_rejects_changed_binary(self):
        with TemporaryDirectory() as temp:
            root = Path(temp)
            apk = root / 'build/app/outputs/flutter-apk/app-profile.apk'
            apk.parent.mkdir(parents=True)
            apk.write_bytes(b'tested')
            (root / 'hajnal-build-time').write_text('2026-11-26T12:00:00Z')
            (root / 'remote').mkdir()
            gh = root / 'gh'
            gh.write_text('''#!/bin/sh
case "$1 $2" in
  "release view")
    case "$*" in *isDraft*) echo true;; *assets*) ls "$MOCK_REMOTE";; esac;;
  "release upload") cp "$4" "$MOCK_REMOTE/";;
  "release download")
    shift 3
    while [ "$#" -gt 0 ]; do
      case "$1" in --pattern) file="$2"; shift 2;; --dir) dir="$2"; shift 2;; *) shift;; esac
    done
    cp "$MOCK_REMOTE/$file" "$dir/";;
  *) exit 1;;
esac
''')
            gh.chmod(0o755)
            env = dict(os.environ, PATH=f"{root}:{os.environ['PATH']}",
                       MOCK_REMOTE=str(root / 'remote'), RUNNER_TEMP=str(root),
                       GITHUB_SHA='a' * 40, GITHUB_RUN_ID='42', GITHUB_RUN_ATTEMPT='1')
            script = str(Path(__file__).with_name('stage_human.sh').resolve())
            for _ in range(2):
                subprocess.run(['bash', script], cwd=root, env=env,
                               check=True, capture_output=True)
            apk.write_bytes(b'changed')
            result = subprocess.run(['bash', script], cwd=root, env=env,
                                    capture_output=True)
            self.assertNotEqual(result.returncode, 0)

    def test_only_tested_commit_and_binary_can_be_published(self):
        with TemporaryDirectory() as temp:
            apk = Path(temp, 'app.apk')
            apk.write_bytes(b'tested')
            sha = 'a' * 40
            candidate = {'commit': sha, 'run': '42',
                         'sha256': hashlib.sha256(b'tested').hexdigest()}
            validation = {'commit': sha, 'run': '42', 'attempt': '2',
                          'sha256': candidate['sha256']}
            run = {'headSha': sha, 'headBranch': 'build/starter', 'event': 'push',
                   'status': 'completed', 'jobs': [
                       {'name': 'verify', 'conclusion': 'success'},
                       {'name': 'build-human', 'conclusion': 'success', 'steps': [
                           {'name': 'Build signed HUMAN APK', 'conclusion': 'success'},
                           {'name': 'Stage signed HUMAN candidate', 'conclusion': 'success'}]},
                       {'name': 'human-apk', 'conclusion': 'success', 'steps': [
                           {'name': 'Run local and schema checks in the release workspace', 'conclusion': 'success'},
                           {'name': 'Verify signed HUMAN candidate', 'conclusion': 'success'},
                           {'name': 'Android smoke and integration tests', 'conclusion': 'success'},
                           {'name': 'Publish evidence to a draft release', 'conclusion': 'success'},
                           {'name': 'Require rendered lock screen evidence', 'conclusion': 'success'},
                           {'name': 'Record successful validation', 'conclusion': 'success'}]}]}
            check(run, candidate, validation, apk, sha, '42')
            for bad in ('other', 'b' * 40):
                with self.assertRaises(ValueError):
                    check(run, candidate, validation, apk, bad, '42')
            with self.assertRaises(ValueError):
                check(run, candidate, validation, apk, sha, '43')
            apk.write_bytes(b'different')
            with self.assertRaises(ValueError):
                check(run, candidate, validation, apk, sha, '42')
            apk.write_bytes(b'tested')
            validation['sha256'] = 'f' * 64
            with self.assertRaises(ValueError):
                check(run, candidate, validation, apk, sha, '42')
            validation['sha256'] = candidate['sha256']
            run['jobs'][2]['steps'][0]['conclusion'] = 'failure'
            with self.assertRaises(ValueError):
                check(run, candidate, validation, apk, sha, '42')
            run['jobs'][2]['steps'][0]['conclusion'] = 'success'
            run['jobs'][1]['conclusion'] = 'failure'
            with self.assertRaises(ValueError):
                check(run, candidate, validation, apk, sha, '42')
            run['jobs'][1]['conclusion'] = 'success'
            run['event'] = 'pull_request'
            with self.assertRaises(ValueError):
                check(run, candidate, validation, apk, sha, '42')


if __name__ == '__main__':
    unittest.main()
