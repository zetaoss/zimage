#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel)"
cd "$repo_root"

extensions_source_url='https://raw.githubusercontent.com/zetaoss/zengine/main/mwz/extensions/extensions.yaml'
extensions_source_file="$(mktemp)"
trap 'rm -f "$extensions_source_file"' EXIT
curl --fail --silent --show-error --location "$extensions_source_url" --output "$extensions_source_file"
node hack/check-extensions.mjs "$extensions_source_file" zbase/extensions.yaml zbase/Dockerfile
