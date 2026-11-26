#!/usr/bin/env bash
set -euo pipefail
url="$1"
metadata="$2"
pages_config="$(gh api "repos/$GITHUB_REPOSITORY/pages" --jq '[.build_type, .source.branch] | @tsv')"
test "$pages_config" = $'legacy\tgh-pages'
git fetch origin gh-pages:refs/remotes/origin/gh-pages
pages_dir="$RUNNER_TEMP/hajnal-pages"
git worktree add --detach "$pages_dir" refs/remotes/origin/gh-pages
mkdir -p "$pages_dir/download"
python3 scripts/render_download.py "$url" "$metadata" "$pages_dir/download/index.html"
git -C "$pages_dir" add download/index.html
if ! git -C "$pages_dir" diff --cached --quiet; then
  git -C "$pages_dir" config user.name 'github-actions[bot]'
  git -C "$pages_dir" config user.email '41898282+github-actions[bot]@users.noreply.github.com'
  git -C "$pages_dir" commit -m "Publish verified Hajnal ${GITHUB_SHA:0:12}"
  git -C "$pages_dir" push origin HEAD:refs/heads/gh-pages
fi
# GITHUB_TOKEN pushes do not start branch-based Pages builds by themselves.
build_api="$(gh api -X POST "repos/$GITHUB_REPOSITORY/pages/builds" --jq '.url')"
test -n "$build_api"
for attempt in $(seq 1 90); do
  status="$(gh api "$build_api" --jq '.status')"
  if [ "$status" = built ]; then break; fi
  if [ "$status" = errored ]; then echo 'GitHub Pages build failed' >&2; exit 1; fi
  sleep 5
done
test "$status" = built
pages_url="$(gh api "repos/$GITHUB_REPOSITORY/pages" --jq '.html_url')"
test -n "$pages_url"
for attempt in $(seq 1 30); do
  if curl -fLsS "${pages_url%/}/download/" > "$RUNNER_TEMP/hajnal-public-page.html" && grep -Fq "$GITHUB_SHA" "$RUNNER_TEMP/hajnal-public-page.html"; then break; fi
  sleep 5
done
curl -fLsS "${pages_url%/}/download/" > "$RUNNER_TEMP/hajnal-public-page.html"
grep -Fq "$GITHUB_SHA" "$RUNNER_TEMP/hajnal-public-page.html"
printf 'Pages download URL: %sdownload/\n' "${pages_url%/}/"
