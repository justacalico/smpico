#!/bin/bash
set -euo pipefail

# Auto-release on pushes to main: when the commits since the latest tag
# warrant a version bump, cocogitto creates the version commit (using the
# lightweight "ci" hook profile) and tag, which are pushed to GitLab. The
# bump commit is pushed with ci.skip so it does not trigger another
# pipeline; the tag push starts the tag pipeline that mirrors the tag to
# GitHub where the release build and release happen.

# Base the bump on the latest remote main in case more merges landed while
# this pipeline was running.
git fetch origin main "+refs/tags/*:refs/tags/*"
git checkout -B main origin/main
git clean -fd

LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)
NEW_COMMITS=$(git rev-list "${LATEST_TAG:+$LATEST_TAG..}HEAD" --count)

if [ "$NEW_COMMITS" = "0" ]; then
  echo "No commits since ${LATEST_TAG:-start}, skipping release"
  exit 0
fi

if version=$(cog bump --dry-run --auto 2>/dev/null) && [ -n "$version" ]; then
  echo "Bumping to $version"
  cog bump --auto --hook-profile ci
else
  # Commits without conventional prefixes still warrant a patch release.
  echo "No conventional bump found, bumping patch ($NEW_COMMITS commit(s) since ${LATEST_TAG:-start})"
  cog bump --patch --hook-profile ci
fi

TAG=$(git tag --points-at HEAD | head -n1)
if [ -z "$TAG" ]; then
  echo "cog bump did not create a tag" >&2
  exit 1
fi

push_bump() {
  git push -o ci.skip origin HEAD:main
}

if ! push_bump; then
  echo "Main moved while bumping, rebasing onto latest origin/main"
  git fetch origin main "+refs/tags/*:refs/tags/*"
  git rebase origin/main
  git tag -f "$TAG"
  push_bump
fi

git push origin "$TAG"
echo "Released $TAG"
