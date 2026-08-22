#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel)"
cd "$repo_root"

extensions_source_url='https://raw.githubusercontent.com/zetaoss/zengine/main/mwz/extensions/extensions.yaml'
extensions_source_file="$(mktemp)"
trap 'rm -f "$extensions_source_file"' EXIT
curl --fail --silent --show-error --location "$extensions_source_url" --output "$extensions_source_file"
node hack/extensions-preflight.mjs "$extensions_source_file" zbase/extensions.yaml zbase/Dockerfile

# shellcheck disable=SC1091
source versions.env
zbase_version="${ZBASE_VERSION:-}"
zdev_version="${ZDEV_VERSION:-}"
semver='^[0-9]+\.[0-9]+\.[0-9]+$'

[[ "$zbase_version" =~ $semver ]] || { echo "Invalid ZBASE_VERSION: $zbase_version" >&2; exit 1; }
[[ "$zdev_version" =~ $semver ]] || { echo "Invalid ZDEV_VERSION: $zdev_version" >&2; exit 1; }

zbase_tag="zbase/v${zbase_version}"
zdev_tag="zdev/v${zdev_version}"
zbase_exists=false
zdev_exists=false

if git rev-parse -q --verify "refs/tags/$zbase_tag" >/dev/null; then
  zbase_exists=true
  if ! git diff --quiet "$zbase_tag"..HEAD -- zbase; then
    echo "zbase changed after $zbase_tag; bump ZBASE_VERSION in versions.env" >&2
    exit 1
  fi
fi

if git rev-parse -q --verify "refs/tags/$zdev_tag" >/dev/null; then
  zdev_exists=true
  if ! git diff --quiet "$zdev_tag"..HEAD -- zdev; then
    echo "zdev changed after $zdev_tag; bump ZDEV_VERSION in versions.env" >&2
    exit 1
  fi
fi

if [[ "$zbase_exists" == false && "$zdev_exists" == true ]]; then
  echo "A new zbase changes zdev's base; bump ZDEV_VERSION in versions.env too" >&2
  exit 1
fi
