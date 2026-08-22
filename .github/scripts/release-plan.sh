#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel)"
cd "$repo_root"

node "$repo_root/hack/preflight.mjs"

# shellcheck disable=SC1091
source versions.env
zbase_version="$ZBASE_VERSION"
zdev_version="$ZDEV_VERSION"

zbase_tag="zbase/v${zbase_version}"
zdev_tag="zdev/v${zdev_version}"
release_zbase=true
release_zdev=true

if git rev-parse -q --verify "refs/tags/$zbase_tag" >/dev/null; then
  release_zbase=false
fi
if git rev-parse -q --verify "refs/tags/$zdev_tag" >/dev/null; then
  release_zdev=false
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
