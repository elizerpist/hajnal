#!/usr/bin/env bash
set -euo pipefail
git fetch origin gh-pages:refs/remotes/origin/gh-pages
if ! git cat-file -e refs/remotes/origin/gh-pages:download/index.html 2>/dev/null; then
  echo 'Missing previous published HUMAN APK for required upgrade test.' >&2
  exit 1
fi
git show refs/remotes/origin/gh-pages:download/index.html > "$RUNNER_TEMP/hajnal-previous-page.html"
python3 - "$RUNNER_TEMP/hajnal-previous-page.html" > "$RUNNER_TEMP/hajnal-previous-info" <<'PY'
import json, os, re, sys, urllib.request
from pathlib import Path
text = Path(sys.argv[1]).read_text()
match = re.search(r'<!-- HAJNAL_META (.*?) -->', text)
if not match:
    raise SystemExit('The existing download page has no release metadata')
m = json.loads(match.group(1))
if m['commit'] == os.environ['GITHUB_SHA']:
    request = urllib.request.Request(
        'https://api.github.com/repos/' + os.environ['GITHUB_REPOSITORY'] + '/releases?per_page=100',
        headers={'User-Agent': 'hajnal-ci', 'Accept': 'application/vnd.github+json'})
    releases = json.load(urllib.request.urlopen(request))
    previous = []
    for release in releases:
        if release['draft']:
            continue
        for asset in release['assets']:
            if asset['name'] == 'build-meta.json':
                candidate = json.load(urllib.request.urlopen(asset['browser_download_url']))
                if candidate['versionCode'] < m['versionCode']:
                    previous.append(candidate)
    if not previous:
        raise SystemExit('No earlier published APK is available for repeated upgrade test')
    m = max(previous, key=lambda item: item['versionCode'])
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
mkdir -p evidence
"$tools_dir/aapt" dump badging "$RUNNER_TEMP/hajnal-previous.apk" > evidence/previous-apk-badging.txt
"$tools_dir/aapt" dump badging build/app/outputs/flutter-apk/app-profile.apk > evidence/new-apk-badging.txt
"$tools_dir/aapt" dump xmltree "$RUNNER_TEMP/hajnal-previous.apk" AndroidManifest.xml > evidence/previous-merged-manifest.txt
"$tools_dir/aapt" dump xmltree build/app/outputs/flutter-apk/app-profile.apk AndroidManifest.xml > evidence/new-merged-manifest.txt
"$tools_dir/aapt" dump resources "$RUNNER_TEMP/hajnal-previous.apk" > evidence/previous-resources.txt
"$tools_dir/aapt" dump resources build/app/outputs/flutter-apk/app-profile.apk > evidence/new-resources.txt
python3 - <<'PY'
import re
from pathlib import Path
def inspect(name):
    text = Path(name).read_text()
    match = re.search(r"package: name='([^']+)' versionCode='(\d+)'", text)
    if not match or match.group(1) != 'hu.elizerpist.hajnal':
        raise SystemExit('Unexpected APK application ID')
    return int(match.group(2))
old = inspect('evidence/previous-apk-badging.txt')
new = inspect('evidence/new-apk-badging.txt')
if new <= old:
    raise SystemExit(f'New versionCode {new} must exceed installed versionCode {old}')
print(f'Verified application ID and upgrade versionCode {old} -> {new}')
PY
