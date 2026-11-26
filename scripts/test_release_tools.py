#!/usr/bin/env python3
import json
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from render_download import render
from check_visual_review import check, SCREENSHOTS
from signing_certificate import certificate
import hashlib
import struct
import os
import subprocess


class DownloadPageTest(unittest.TestCase):
    def setUp(self):
        self.directory = TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.metadata = Path(self.directory.name, 'metadata.json')
        self.page = Path(self.directory.name, 'index.html')
        self.data = {
            'commit': 'a' * 40, 'versionCode': 7,
            'sha256': 'b' * 64, 'signingCertificateSha256': 'c' * 64,
            'buildTime': '2026-11-26T15:00:00Z',
        }
        self.url = 'https://github.com/elizerpist/hajnal/releases/download/test/app.apk'

    def write(self):
        self.metadata.write_text(json.dumps(self.data))
        render(self.url, str(self.metadata), str(self.page))

    def test_idempotent_and_newer_release(self):
        self.write()
        original = self.page.read_text()
        self.write()
        self.assertEqual(original, self.page.read_text())
        self.data.update(commit='d' * 40, versionCode=8)
        self.write()
        self.assertIn('d' * 40, self.page.read_text())
        self.assertIn(self.url, self.page.read_text())

    def test_reject_rollback_and_signing_change(self):
        self.write()
        original = self.page.read_text()
        self.data.update(commit='d' * 40, versionCode=6)
        with self.assertRaises(ValueError):
            self.write()
        self.data.update(versionCode=8, signingCertificateSha256='e' * 64)
        with self.assertRaises(ValueError):
            self.write()
        self.assertEqual(original, self.page.read_text())

    def test_existing_commit_cannot_change_binary(self):
        self.write()
        original = self.page.read_text()
        self.data['sha256'] = 'f' * 64
        with self.assertRaises(ValueError):
            self.write()
        self.assertEqual(original, self.page.read_text())

    def test_invalid_or_untracked_page_fails_closed(self):
        self.data['sha256'] = 'invalid'
        with self.assertRaises(ValueError):
            self.write()
        self.data['sha256'] = 'b' * 64
        self.page.write_text('untracked existing page')
        with self.assertRaises(ValueError):
            self.write()


class SigningCertificateTest(unittest.TestCase):
    def test_legacy_and_recent_apksigner_output(self):
        fingerprint = 'ab' * 32
        self.assertEqual(certificate('Signer #1 certificate SHA-256 digest: ' + fingerprint, fingerprint), fingerprint)
        self.assertEqual(certificate('V2 Signer: certificate SHA-256 digest: ' + fingerprint.upper(), fingerprint), fingerprint)
        with self.assertRaises(ValueError):
            certificate('V2 Signer: certificate SHA-256 digest: ' + fingerprint +
                        '\nV3 Signer: certificate SHA-256 digest: ' + 'cd' * 32, fingerprint)

    def test_first_release_must_use_configured_hajnal_certificate(self):
        trusted = (Path(__file__).with_name('hajnal_signer.sha256')).read_text().strip()
        output = 'V2 Signer: certificate SHA-256 digest: ' + trusted
        self.assertEqual(certificate(output, trusted), trusted)
        with self.assertRaises(ValueError):
            certificate('V2 Signer: certificate SHA-256 digest: ' + 'cd' * 32, trusted)


class VisualReviewTest(unittest.TestCase):
    def test_checks_exact_commit_images_and_dimensions(self):
        with TemporaryDirectory() as temporary:
            directory = Path(temporary)
            png = b'\x89PNG\r\n\x1a\n' + b'\0' * 8 + struct.pack('>II', 412, 892)
            for filename in SCREENSHOTS:
                (directory / filename).write_bytes(png)
            review = {'commit': 'a' * 40, 'verdict': 'approved',
                      'notes': 'Compared the reference and app geometry, colors, and open state.',
                      'screenshots': {name: hashlib.sha256(png).hexdigest() for name in SCREENSHOTS}}
            (directory / 'visual-review.json').write_text(json.dumps(review))
            check(temporary, 'a' * 40)
            with self.assertRaises(ValueError):
                check(temporary, 'b' * 40)
            (directory / SCREENSHOTS[0]).write_bytes(png + b'changed')
            with self.assertRaises(ValueError):
                check(temporary, 'a' * 40)


class EvidenceReleaseTest(unittest.TestCase):
    def test_draft_without_tag_is_idempotent_and_rejects_wrong_target(self):
        script = Path(__file__).with_name('publish_evidence.sh').resolve()
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / 'evidence').mkdir()
            for name in (*SCREENSHOTS, 'flutter-test.log', 'android-test.log',
                         'artwork-test.log', 'signed-upgrade-test.log'):
                (root / 'evidence' / name).write_text('evidence')
            state = root / 'state.json'
            state.write_text(json.dumps({'exists': False, 'draft': True,
                                         'target': 'a' * 40, 'assets': [], 'creates': 0}))
            gh = root / 'gh'
            gh.write_text("""#!/usr/bin/env python3
import json, os, pathlib, sys
path = pathlib.Path(os.environ['MOCK_STATE'])
s = json.loads(path.read_text())
a = sys.argv[1:]
if a[:2] == ['release', 'view']:
    if not s['exists']: sys.exit(1)
    field = a[a.index('--json') + 1]
    if field == 'tagName': print('tag')
    elif field == 'targetCommitish': print(s['target'])
    elif field == 'isDraft': print(str(s['draft']).lower())
    elif field == 'assets': print('\\n'.join(s['assets']))
elif a[:2] == ['release', 'create']:
    s['exists'] = True
    s['creates'] += 1
elif a[:2] == ['release', 'upload']:
    s['assets'].append(pathlib.Path(a[-1]).name)
else: sys.exit(2)
path.write_text(json.dumps(s))
""")
            gh.chmod(0o755)
            git = root / 'git'
            git.write_text('#!/bin/sh\nif [ -n "$MOCK_TAG" ]; then printf "%s\\trefs/tags/test\\n" "$MOCK_TAG"; fi\nif [ -n "$MOCK_PEELED" ]; then printf "%s\\trefs/tags/test^{}\\n" "$MOCK_PEELED"; fi\n')
            git.chmod(0o755)
            env = dict(os.environ, PATH=f"{root}:{os.environ['PATH']}", MOCK_STATE=str(state),
                       GITHUB_SHA='a' * 40, GITHUB_SERVER_URL='https://github.com',
                       GITHUB_REPOSITORY='owner/repo', GITHUB_RUN_ID='1')
            for _ in range(2):
                subprocess.run(['bash', str(script)], cwd=root, env=env, check=True, capture_output=True)
            result = json.loads(state.read_text())
            self.assertEqual(result['creates'], 1)
            self.assertEqual(len(result['assets']), 9)
            result['target'] = 'b' * 40
            state.write_text(json.dumps(result))
            self.assertNotEqual(subprocess.run(['bash', str(script)], cwd=root, env=env,
                                               capture_output=True).returncode, 0)
            # An existing tag is authoritative, including the peeled annotated tag.
            tagged = dict(env, MOCK_TAG='c' * 40, MOCK_PEELED='a' * 40)
            self.assertEqual(subprocess.run(['bash', str(script)], cwd=root, env=tagged,
                                            capture_output=True).returncode, 0)
            tagged['MOCK_PEELED'] = 'b' * 40
            self.assertNotEqual(subprocess.run(['bash', str(script)], cwd=root, env=tagged,
                                               capture_output=True).returncode, 0)
            result.update(target='a' * 40, draft=False)
            state.write_text(json.dumps(result))
            self.assertNotEqual(subprocess.run(['bash', str(script)], cwd=root, env=env,
                                               capture_output=True).returncode, 0)


class AndroidSmokeScriptTest(unittest.TestCase):
    def test_debug_test_package_is_removed_before_signed_upgrade_test(self):
        script = Path(__file__).with_name('android_smoke.sh').resolve()
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            test_apk = root / 'build/app/outputs/apk/androidTest/debug/test.apk'
            test_apk.parent.mkdir(parents=True)
            test_apk.write_bytes(b'test')
            profile = root / 'build/app/outputs/flutter-apk/app-profile.apk'
            profile.parent.mkdir(parents=True)
            profile.write_bytes(b'profile')
            (root / 'hajnal-signed-test.apk').write_bytes(b'signed')
            adb = root / 'adb'
            adb.write_text('''#!/bin/sh
case "$1:$2:$3" in
  shell:pm:path) [ -f "$MOCK_ROOT/$4.installed" ] && echo package:present; exit 0;;
  shell:am:instrument) echo 'OK (1 test)'; exit 0;;
  exec-out:*) printf screenshot; exit 0;;
esac
case "$1" in
  uninstall) rm -f "$MOCK_ROOT/$2.installed";;
  install)
    case "$*" in
      *hajnal-signed-test.apk) [ ! -f "$MOCK_ROOT/hu.elizerpist.hajnal.test.installed" ] || exit 1; touch "$MOCK_ROOT/hu.elizerpist.hajnal.test.installed";;
      *androidTest*) touch "$MOCK_ROOT/hu.elizerpist.hajnal.test.installed";;
      *) touch "$MOCK_ROOT/hu.elizerpist.hajnal.installed";;
    esac;;
esac
exit 0
''')
            adb.chmod(0o755)
            flutter = root / 'flutter'
            flutter.write_text('#!/bin/sh\necho artwork-passed\n')
            flutter.chmod(0o755)
            env = dict(os.environ, PATH=f"{root}:{os.environ['PATH']}",
                       MOCK_ROOT=str(root), RUNNER_TEMP=str(root))
            subprocess.run(['bash', str(script)], cwd=root, env=env,
                           check=True, capture_output=True)
            self.assertTrue((root / 'evidence/signed-upgrade-test.log').is_file())


if __name__ == '__main__':
    unittest.main()
