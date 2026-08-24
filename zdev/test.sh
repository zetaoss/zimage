#!/usr/bin/env bash
set -euo pipefail

image="${1:?usage: zdev/test.sh <image>}"

docker run --rm --entrypoint sh "$image" -ec '
  php --version
  nginx -v
  go version
  gopls version
  air -v
  node --version
  pnpm --version
  composer --version
  gh --version
  codex --version
  copilot --version
  agy --version
'
