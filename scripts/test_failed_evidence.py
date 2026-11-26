import json
import os
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory
import unittest


class FailedEvidenceTest(unittest.TestCase):
    def test_draft_evidence_is_preserved_once_for_the_correct_commit(self):
        with TemporaryDirectory() as temp:
            root = Path(temp)
            (root / 'evidence').mkdir()
            (root / 'evidence/lock-visual-test.log').write_text('driver disconnected')
            state = root / 'state.json'
            state.write_text(json.dumps({'exists': False, 'target': 'a' * 40, 'assets': []}))
            gh = root / 'gh'
            gh.write_text('''#!/usr/bin/env python3
import json, os, pathlib, sys
p = pathlib.Path(os.environ['MOCK_STATE']); s = json.loads(p.read_text()); a = sys.argv[1:]
if a[:2] == ['release', 'view']:
    if not s['exists']: sys.exit(1)
    field = a[a.index('--json') + 1]
    print({'tagName': 'tag', 'isDraft': 'true', 'targetCommitish': s['target'],
           'assets': '\\n'.join(s['assets'])}[field])
elif a[:2] == ['release', 'create']: s['exists'] = True
elif a[:2] == ['release', 'upload']: s['assets'].append(a[-1].split('#')[-1])
else: sys.exit(2)
p.write_text(json.dumps(s))
''')
            gh.chmod(0o755)
            git = root / 'git'
            git.write_text('#!/bin/sh\nexit 0\n')
            git.chmod(0o755)
            env = dict(os.environ, PATH=f"{root}:{os.environ['PATH']}", MOCK_STATE=str(state),
                       GITHUB_SHA='a' * 40, GITHUB_SERVER_URL='https://github.com',
                       GITHUB_REPOSITORY='owner/repo', GITHUB_RUN_ID='42', GITHUB_RUN_ATTEMPT='1')
            script = str(Path(__file__).with_name('publish_failed_evidence.sh').resolve())
            for _ in range(2):
                subprocess.run(['bash', script], cwd=root, env=env,
                               check=True, capture_output=True)
            result = json.loads(state.read_text())
            self.assertEqual(result['assets'], ['failed-42-1-lock-visual-test.log'])
            result['target'] = 'b' * 40
            state.write_text(json.dumps(result))
            self.assertNotEqual(subprocess.run(['bash', script], cwd=root, env=env,
                                               capture_output=True).returncode, 0)


if __name__ == '__main__':
    unittest.main()
