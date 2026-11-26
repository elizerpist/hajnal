#!/usr/bin/env bash
set -euo pipefail
gh auth setup-git
tag="hajnal-s0-${GITHUB_SHA:0:12}"
apk="hajnal_S0_HUMAN_${GITHUB_SHA:0:12}.apk"
tools_dir="$ANDROID_HOME/build-tools/$(ls "$ANDROID_HOME/build-tools" | sort -V | tail -1)"
mkdir -p release
existing="$(gh release view "$tag" --json assets --jq '.assets[].name')"
if printf '%s\n' "$existing" | grep -Fxq "$apk"; then
  gh release download "$tag" --pattern "$apk" --dir release
else
  cp build/app/outputs/flutter-apk/app-profile.apk "release/$apk"
fi
"$tools_dir/apksigner" verify --verbose --print-certs "release/$apk" | tee release/signature.txt
grep -q 'Verified using v2 scheme (APK Signature Scheme v2): true' release/signature.txt
"$tools_dir/aapt" dump badging "release/$apk" > release/badging.txt
grep -q "package: name='hu.elizerpist.hajnal'" release/badging.txt
"$tools_dir/aapt" dump xmltree "release/$apk" AndroidManifest.xml > release/manifest.txt
grep -Fq "$GITHUB_SHA" release/manifest.txt
version_code="$(sed -n "s/.*versionCode='\([0-9]*\)'.*/\1/p" release/badging.txt | head -1)"
version_name="$(sed -n "s/.*versionName='\([^']*\)'.*/\1/p" release/badging.txt | head -1)"
test -n "$version_code" && test -n "$version_name"
(cd release && sha256sum "$apk" > "$apk.sha256")
checksum="$(cut -d' ' -f1 "release/$apk.sha256")"
cert="$(python3 scripts/signing_certificate.py release/signature.txt scripts/hajnal_signer.sha256)"
test -n "$cert"
printf 'Commit: %s\nCI: %s/%s/actions/runs/%s\nVersion: %s (%s)\nSHA-256: %s\nSigning certificate SHA-256: %s\nSigning: Android APK Signature Scheme v2 verified\n' "$GITHUB_SHA" "$GITHUB_SERVER_URL" "$GITHUB_REPOSITORY" "$GITHUB_RUN_ID" "$version_name" "$version_code" "$checksum" "$cert" > release/notes.txt
python3 - "$GITHUB_SHA" "$version_code" "$version_name" "$checksum" "$cert" "$GITHUB_RUN_ID" > release/build-meta.json <<'PY'
import json, os, sys
from pathlib import Path
sha, code, name, checksum, cert, run = sys.argv[1:]
print(json.dumps({'commit': sha, 'versionCode': int(code), 'versionName': name,
                  'sha256': checksum, 'signingCertificateSha256': cert,
                  'buildTime': Path(os.environ['RUNNER_TEMP'], 'hajnal-build-time').read_text().strip(),
                  'run': f"{os.environ['GITHUB_SERVER_URL']}/{os.environ['GITHUB_REPOSITORY']}/actions/runs/{run}"}, indent=2))
PY
# Refuse a lower version or different signing key before publishing anything.
git fetch origin gh-pages:refs/remotes/origin/gh-pages
if git cat-file -e refs/remotes/origin/gh-pages:download/index.html 2>/dev/null; then
  git show refs/remotes/origin/gh-pages:download/index.html > "$RUNNER_TEMP/hajnal-previous-page.html"
  python3 scripts/render_download.py "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/releases/download/$tag/$apk" release/build-meta.json "$RUNNER_TEMP/hajnal-previous-page.html"
fi
# Existing assets are immutable; reuse them and verify instead of clobbering.
draft="$(gh release view "$tag" --json isDraft --jq '.isDraft')"
for file in "$apk" "$apk.sha256" signature.txt build-meta.json; do
  if printf '%s\n' "$existing" | grep -Fxq "$file"; then
    mkdir -p release/previous
    gh release download "$tag" --pattern "$file" --dir release/previous
    if [ "$file" = "$apk.sha256" ]; then
      (cd release/previous && cp "../$apk" . && sha256sum -c "$apk.sha256")
    fi
    if [ "$file" = build-meta.json ]; then
      python3 - "$GITHUB_SHA" "$checksum" "$cert" "$version_code" <<'PY'
import json, sys
m = json.load(open('release/previous/build-meta.json'))
assert (m['commit'], m['sha256'], m['signingCertificateSha256'], str(m['versionCode'])) == tuple(sys.argv[1:])
PY
      cp release/previous/build-meta.json release/build-meta.json
    fi
  else
    test "$draft" = true
    gh release upload "$tag" "release/$file"
  fi
done
if [ "$draft" = true ]; then
  gh release edit "$tag" --notes-file release/notes.txt --draft=false --prerelease
fi
# Deliberately unauthenticated: verify the actual public bytes, not the upload response.
url="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/releases/download/$tag/$apk"
for attempt in $(seq 1 12); do
  if curl -fLsS --retry 2 --output "release/public-$apk" "$url"; then break; fi
  sleep 5
done
test "$(sha256sum "release/public-$apk" | cut -d' ' -f1)" = "$checksum"
curl -fLsS --retry 3 --output "release/public-$apk.sha256" "$url.sha256"
cmp "release/$apk.sha256" "release/public-$apk.sha256"
"$tools_dir/apksigner" verify "release/public-$apk"
bash scripts/publish_pages.sh "$url" release/build-meta.json
