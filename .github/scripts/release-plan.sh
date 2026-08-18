#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
source versions.env
zbase_version="${ZBASE_VERSION:-}"
zdev_version="${ZDEV_VERSION:-}"
semver='^[0-9]+\.[0-9]+\.[0-9]+$'
[[ "$zbase_version" =~ $semver ]] || { echo "Invalid ZBASE_VERSION: $zbase_version" >&2; exit 1; }
[[ "$zdev_version" =~ $semver ]] || { echo "Invalid ZDEV_VERSION: $zdev_version" >&2; exit 1; }

zbase_tag="zbase/v${zbase_version}"
zdev_tag="zdev/v${zdev_version}"
release_zbase=true
release_zdev=true

if git rev-parse -q --verify "refs/tags/$zbase_tag" >/dev/null; then
  release_zbase=false
  if ! git diff --quiet "$zbase_tag"..HEAD -- zbase; then
    echo "zbase changed after $zbase_tag; bump ZBASE_VERSION in versions.env" >&2
    exit 1
  fi
fi
if git rev-parse -q --verify "refs/tags/$zdev_tag" >/dev/null; then
  release_zdev=false
  if ! git diff --quiet "$zdev_tag"..HEAD -- zdev; then
    echo "zdev changed after $zdev_tag; bump ZDEV_VERSION in versions.env" >&2
    exit 1
  fi
fi
if [[ "$release_zbase" == true && "$release_zdev" != true ]]; then
  echo "A new zbase changes zdev's base; bump ZDEV_VERSION in versions.env too" >&2
  exit 1
fi

revision="${GITHUB_SHA:-$(git rev-parse HEAD)}"
output_file="${GITHUB_OUTPUT:-/dev/null}"
{
  echo "zbase_version=$zbase_version"
  echo "zbase_minor=${zbase_version%.*}"
  echo "zbase_tag=$zbase_tag"
  echo "zdev_version=$zdev_version"
  echo "zdev_minor=${zdev_version%.*}"
  echo "zdev_tag=$zdev_tag"
  echo "release_zbase=$release_zbase"
  echo "release_zdev=$release_zdev"
  echo "short_sha=${revision:0:12}"
  echo "created=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} >> "$output_file"
