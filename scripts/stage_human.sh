#!/usr/bin/env bash
set -euo pipefail
tag="hajnal-s0-${GITHUB_SHA:0:12}"
apk="hajnal_S0_HUMAN_${GITHUB_SHA:0:12}.apk"
mkdir -p candidate
cp build/app/outputs/flutter-apk/app-profile.apk "candidate/$apk"
python3 - "$GITHUB_SHA" "$GITHUB_RUN_ID" "candidate/$apk" > candidate/candidate.json <<'PY'
import hashlib, json, os, sys
from pathlib import Path
sha, run, apk = sys.argv[1:]
print(json.dumps({'commit': sha, 'run': run,
                  'attempt': os.environ['GITHUB_RUN_ATTEMPT'],
                  'sha256': hashlib.sha256(Path(apk).read_bytes()).hexdigest(),
                  'buildTime': Path(os.environ['RUNNER_TEMP'], 'hajnal-build-time').read_text().strip()}))
PY
test "$(gh release view "$tag" --json isDraft --jq '.isDraft')" = true
existing="$(gh release view "$tag" --json assets --jq '.assets[].name')"
for file in "$apk" candidate.json; do
  if printf '%s\n' "$existing" | grep -Fxq "$file"; then
    mkdir -p candidate/existing
    gh release download "$tag" --pattern "$file" --dir candidate/existing
    if [ "$file" = candidate.json ]; then
      python3 - "$GITHUB_SHA" "candidate/$apk" <<'PY'
import hashlib, json, sys
from pathlib import Path
sha, apk = sys.argv[1:]
existing = json.loads(Path('candidate/existing/candidate.json').read_text())
assert existing['commit'] == sha
assert existing['sha256'] == hashlib.sha256(Path(apk).read_bytes()).hexdigest()
PY
    else
      cmp "candidate/$file" "candidate/existing/$file"
    fi
  else
    gh release upload "$tag" "candidate/$file"
  fi
done
