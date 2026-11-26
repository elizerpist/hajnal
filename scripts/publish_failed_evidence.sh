#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob
files=(evidence/*)
(( ${#files[@]} )) || exit 0
tag="hajnal-s0-${GITHUB_SHA:0:12}"
if ! gh release view "$tag" --json tagName >/dev/null 2>&1; then
  gh release create "$tag" --target "$GITHUB_SHA" --draft --title "Hajnal S0 ${GITHUB_SHA:0:12}" --notes "Evidence draft for commit $GITHUB_SHA. Run: $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
fi
test "$(gh release view "$tag" --json isDraft --jq '.isDraft')" = true
target="$(gh release view "$tag" --json targetCommitish --jq '.targetCommitish')"
tag_sha="$(git ls-remote origin "refs/tags/$tag" "refs/tags/$tag^{}" | awk '/\^\{\}$/{peeled=$1} !/\^\{\}$/{tag=$1} END {print peeled ? peeled : tag}')"
test "${tag_sha:-$target}" = "$GITHUB_SHA"
existing="$(gh release view "$tag" --json assets --jq '.assets[].name')"
for file in "${files[@]}"; do
  [ -f "$file" ] && [ -s "$file" ] || continue
  name="failed-${GITHUB_RUN_ID}-${GITHUB_RUN_ATTEMPT}-$(basename "$file")"
  if ! printf '%s\n' "$existing" | grep -Fxq "$name"; then
    gh release upload "$tag" "$file#$name"
  fi
done
