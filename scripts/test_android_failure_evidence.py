import os
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory
import unittest


class AndroidFailureEvidenceTest(unittest.TestCase):
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


if __name__ == '__main__':
    unittest.main()
