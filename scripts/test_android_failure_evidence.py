import os
from pathlib import Path
import subprocess
import shutil
from tempfile import TemporaryDirectory
import unittest


class AndroidFailureEvidenceTest(unittest.TestCase):
    def test_offline_screenshot_timeout_does_not_hide_the_test_failure(self):
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            test_apk = root / 'build/app/outputs/apk/androidTest/test.apk'
            test_apk.parent.mkdir(parents=True)
            test_apk.write_bytes(b'test')
            adb = root / 'adb'
            adb.write_text('''#!/bin/sh
case "$1:$2:$3" in
  shell:am:instrument) echo 'FAILURES!!!'; exit 0;;
  logcat:*) printf 'diagnostic log';;
esac
exit 0
''')
            adb.chmod(0o755)
            timeout = root / 'timeout'
            real_timeout = shutil.which('timeout')
            self.assertIsNotNone(real_timeout)
            timeout.write_text(f'''#!/bin/sh
case "$*" in
  *"30s"*"exec-out screencap"*) touch "$MOCK_ROOT/adb-timeout"; exit 124;;
esac
exec "{real_timeout}" "$@"
''')
            timeout.chmod(0o755)
            script = Path(__file__).with_name('android_smoke.sh').resolve()
            result = subprocess.run(
                ['bash', str(script)], cwd=root, capture_output=True, timeout=15,
                env=dict(os.environ, MOCK_ROOT=str(root), PATH=f'{root}:{os.environ["PATH"]}'),
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertTrue((root / 'adb-timeout').exists())
            self.assertIn('diagnostic log', (root / 'evidence/android-failure-logcat.txt').read_text())

    def test_failed_instrumentation_stays_failed_and_preserves_diagnostics(self):
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            test_apk = root / 'build/app/outputs/apk/androidTest/test.apk'
            test_apk.parent.mkdir(parents=True)
            test_apk.write_bytes(b'test')
            adb = root / 'adb'
            adb.write_text('''#!/bin/sh
case "$1:$2:$3" in
  shell:am:instrument) echo 'FAILURES!!!'; exit 0;;
  exec-out:screencap:-p) printf 'diagnostic-screen';;
  exec-out:cat:*) printf '<hierarchy/>';;
  logcat:*) printf 'flutter startup error';;
  *) exit 0;;
esac
''')
            adb.chmod(0o755)
            script = Path(__file__).with_name('android_smoke.sh').resolve()
            result = subprocess.run(
                ['bash', str(script)], cwd=root, capture_output=True,
                env=dict(os.environ, PATH=f'{root}:{os.environ["PATH"]}'),
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('FAILURES!!!', (root / 'evidence/android-first-test.log').read_text())
            self.assertTrue((root / 'evidence/android-failure.png').read_bytes())
            self.assertIn('startup error', (root / 'evidence/android-failure-logcat.txt').read_text())
            self.assertIn('hierarchy', (root / 'evidence/android-failure-ui.xml').read_text())

    def test_visual_failure_preserves_completed_images_and_still_fails(self):
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            test_apk = root / 'build/app/outputs/apk/androidTest/test.apk'
            test_apk.parent.mkdir(parents=True)
            test_apk.write_bytes(b'test')
            (root / 'scripts').mkdir()
            shutil.copyfile(Path(__file__).with_name('validate_png.py'), root / 'scripts/validate_png.py')
            adb = root / 'adb'
            adb.write_text('''#!/bin/sh
case "$*" in
  *"test -s files/boarding-welcome-1.png"*) exit 0;;
  *"test -s files/"*) exit 1;;
  *"touch files/lock-visual-copied"*) touch "$MOCK_ROOT/copied"; exit 0;;
esac
case "$1:$2:$3" in
  shell:am:instrument) echo 'OK (1 test)';;
  exec-out:*) python3 -c 'import sys,struct; sys.stdout.buffer.write(bytes.fromhex("89504e470d0a1a0a") + bytes(8) + struct.pack(">II", 412, 892))';;
esac
exit 0
''')
            adb.chmod(0o755)
            flutter = root / 'flutter'
            flutter.write_text('#!/bin/sh\nexit 1\n')
            flutter.chmod(0o755)
            script = Path(__file__).with_name('android_smoke.sh').resolve()
            result = subprocess.run(
                ['bash', str(script)], cwd=root, capture_output=True,
                env=dict(os.environ, MOCK_ROOT=str(root), PATH=f'{root}:{os.environ["PATH"]}'),
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertTrue((root / 'evidence/boarding-welcome-1.png').read_bytes())
            self.assertTrue((root / 'copied').exists())
            self.assertIn(b'Missing or invalid screenshot', result.stderr)


if __name__ == '__main__':
    unittest.main()
