#!/usr/bin/env bash
set -euo pipefail
for file in html-closed.png html-open.png onboarding.png dashboard-closed.png dashboard-open.png flutter-test.log android-test.log artwork-test.log signed-upgrade-test.log; do
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
for file in evidence/html-closed.png evidence/html-open.png evidence/onboarding.png evidence/dashboard-closed.png evidence/dashboard-open.png evidence/flutter-test.log evidence/android-test.log evidence/artwork-test.log evidence/signed-upgrade-test.log; do
  if ! printf '%s\n' "$existing" | grep -Fxq "$(basename "$file")"; then
    test "$draft" = true
    gh release upload "$tag" "$file"
  fi
done
