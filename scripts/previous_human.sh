#!/usr/bin/env bash
set -euo pipefail
git fetch origin gh-pages:refs/remotes/origin/gh-pages
if ! git cat-file -e refs/remotes/origin/gh-pages:download/index.html 2>/dev/null; then
  echo 'No previous HUMAN APK exists; reinstall the first signed build.'
  exit 0
fi
git show refs/remotes/origin/gh-pages:download/index.html > "$RUNNER_TEMP/hajnal-previous-page.html"
python3 - "$RUNNER_TEMP/hajnal-previous-page.html" > "$RUNNER_TEMP/hajnal-previous-info" <<'PY'
import json, re, sys
from pathlib import Path
text = Path(sys.argv[1]).read_text()
match = re.search(r'<!-- HAJNAL_META (.*?) -->', text)
if not match:
    raise SystemExit('The existing download page has no release metadata')
m = json.loads(match.group(1))
assert re.fullmatch('[0-9a-f]{40}', m['commit'])
assert re.fullmatch('[0-9a-f]{64}', m['sha256'])
print(m['commit'])
print(m['sha256'])
PY
sha="$(sed -n '1p' "$RUNNER_TEMP/hajnal-previous-info")"
hash="$(sed -n '2p' "$RUNNER_TEMP/hajnal-previous-info")"
apk="hajnal_S0_HUMAN_${sha:0:12}.apk"
url="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/releases/download/hajnal-s0-${sha:0:12}/$apk"
curl -fLsS --retry 3 --output "$RUNNER_TEMP/hajnal-previous.apk" "$url"
test "$(sha256sum "$RUNNER_TEMP/hajnal-previous.apk" | cut -d' ' -f1)" = "$hash"
tools_dir="$ANDROID_HOME/build-tools/$(ls "$ANDROID_HOME/build-tools" | sort -V | tail -1)"
"$tools_dir/apksigner" verify --verbose --print-certs "$RUNNER_TEMP/hajnal-previous.apk" > "$RUNNER_TEMP/hajnal-previous-signature.txt"
python3 scripts/signing_certificate.py "$RUNNER_TEMP/hajnal-previous-signature.txt" scripts/hajnal_signer.sha256
