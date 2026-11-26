#!/usr/bin/env bash
set -euo pipefail
tag="hajnal-s0-${GITHUB_SHA:0:12}"
apk="hajnal_S0_HUMAN_${GITHUB_SHA:0:12}.apk"
if ! gh release view "$tag" --json tagName >/dev/null 2>&1; then
  exit 0
fi
if gh release view "$tag" --json assets --jq '.assets[].name' | grep -Fxq "$apk"; then
  mkdir -p "$RUNNER_TEMP/hajnal-existing"
  gh release download "$tag" --pattern "$apk" --dir "$RUNNER_TEMP/hajnal-existing"
  tools_dir="$ANDROID_HOME/build-tools/$(ls "$ANDROID_HOME/build-tools" | sort -V | tail -1)"
  "$tools_dir/apksigner" verify --verbose --print-certs "$RUNNER_TEMP/hajnal-existing/$apk" > "$RUNNER_TEMP/hajnal-existing/signature.txt"
  python3 scripts/signing_certificate.py "$RUNNER_TEMP/hajnal-existing/signature.txt" scripts/hajnal_signer.sha256
  "$tools_dir/aapt" dump xmltree "$RUNNER_TEMP/hajnal-existing/$apk" AndroidManifest.xml > "$RUNNER_TEMP/hajnal-existing/manifest.txt"
  grep -Fq "$GITHUB_SHA" "$RUNNER_TEMP/hajnal-existing/manifest.txt"
  cp "$RUNNER_TEMP/hajnal-existing/$apk" build/app/outputs/flutter-apk/app-profile.apk
fi
