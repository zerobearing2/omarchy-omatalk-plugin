#!/usr/bin/env bash
# Plugin publish: test, validate, commit the version, push, gh release
# create. Same shape as omatalk's make release. Does not clobber a tag.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ "$(git rev-parse --abbrev-ref HEAD)" != master ]; then
  echo "need master; git switch master" >&2
  exit 1
fi

unexpected=""
while IFS= read -r status; do
  if [ -z "$status" ]; then
    continue
  fi
  path="${status:3}"
  case "$path" in
    manifest.json)
      ;;
    *)
      if [ -z "$unexpected" ]; then
        unexpected="$path"
      else
        unexpected="$unexpected $path"
      fi
      ;;
  esac
done <<STATUS
$(git status --porcelain)
STATUS

if [ -n "$unexpected" ]; then
  echo "unexpected dirty paths: $unexpected" >&2
  exit 1
fi

git fetch origin master --tags

version="$(sed -n 's/^  "version": "\(.*\)",$/\1/p' manifest.json)"
if [ -z "$version" ]; then
  echo "could not read version from manifest.json" >&2
  exit 1
fi
tag="v$version"

remote_tag="$(git ls-remote --tags origin "refs/tags/$tag")"
if [ -n "$remote_tag" ]; then
  echo "$tag already exists — make bump first" >&2
  exit 1
fi

if [ "$(git merge-base HEAD origin/master)" != "$(git rev-parse origin/master)" ]; then
  echo "master is behind origin; pull first" >&2
  exit 1
fi

tests/run.sh
omarchy plugin validate "$ROOT"

git add manifest.json
if git diff --cached --quiet; then
  echo "version already committed"
else
  git commit -m "Release $tag"
fi

git push origin master

gh release create "$tag" --title "$tag" --generate-notes \
  --target "$(git rev-parse HEAD)"

echo "Released $tag"
