#!/usr/bin/env bash
set -euo pipefail
for file in html-closed.png html-open.png onboarding.png dashboard-closed.png dashboard-open.png picker-open.png picker-night.png picker-before-upgrade.png picker-after-upgrade.png picker-before-upgrade-theme.txt picker-after-upgrade-theme.txt previous-apk-badging.txt new-apk-badging.txt previous-merged-manifest.txt new-merged-manifest.txt previous-resources.txt new-resources.txt flutter-test.log android-test.log android-night-test.log artwork-test.log signed-upgrade-test.log lock-visual-test.log lock-native-test.log lock-launcher-test.log lock-real-setup.png lock-launcher.png lock-settings.png lock-pin-setup.png lock-biometric-step.png lock-settings-comparison.png lock-pin-setup-comparison.png lock-biometric-step-comparison.png; do
  test -s "evidence/$file"
done
tag="hajnal-s0-${GITHUB_SHA:0:12}"
if ! gh release view "$tag" --json tagName >/dev/null 2>&1; then
  gh release create "$tag" --target "$GITHUB_SHA" --draft --title "Hajnal S0 ${GITHUB_SHA:0:12}" --notes "Evidence draft for commit $GITHUB_SHA. Run: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
fi
draft="$(gh release view "$tag" --json isDraft --jq '.isDraft')"
target="$(gh release view "$tag" --json targetCommitish --jq '.targetCommitish')"
tag_sha="$(git ls-remote origin "refs/tags/$tag" "refs/tags/$tag^{}" | awk '/\^\{\}$/{peeled=$1} !/\^\{\}$/{tag=$1} END {print peeled ? peeled : tag}')"
if [ -n "$tag_sha" ]; then
  test "$tag_sha" = "$GITHUB_SHA"
else
  test "$draft" = true
  test "$target" = "$GITHUB_SHA"
fi
existing="$(gh release view "$tag" --json assets --jq '.assets[].name')"
for file in evidence/html-closed.png evidence/html-open.png evidence/onboarding.png evidence/dashboard-closed.png evidence/dashboard-open.png evidence/picker-open.png evidence/picker-night.png evidence/picker-before-upgrade.png evidence/picker-after-upgrade.png evidence/picker-before-upgrade-theme.txt evidence/picker-after-upgrade-theme.txt evidence/previous-apk-badging.txt evidence/new-apk-badging.txt evidence/previous-merged-manifest.txt evidence/new-merged-manifest.txt evidence/previous-resources.txt evidence/new-resources.txt evidence/flutter-test.log evidence/android-test.log evidence/android-night-test.log evidence/artwork-test.log evidence/signed-upgrade-test.log evidence/lock-visual-test.log evidence/lock-native-test.log evidence/lock-launcher-test.log evidence/lock-real-setup.png evidence/lock-launcher.png evidence/lock-settings.png evidence/lock-pin-setup.png evidence/lock-biometric-step.png evidence/lock-settings-comparison.png evidence/lock-pin-setup-comparison.png evidence/lock-biometric-step-comparison.png; do
  if ! printf '%s\n' "$existing" | grep -Fxq "$(basename "$file")"; then
    test "$draft" = true
    gh release upload "$tag" "$file"
  fi
done
