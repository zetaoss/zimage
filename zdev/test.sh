#!/usr/bin/env bash
set -euo pipefail

image="${1:?usage: zdev/test.sh <image>}"

docker run --rm --entrypoint sh "$image" -ec '
  air -v
  agy --version
  codex --version
  composer --version
  copilot --version
  gh --version
  go version
  gopls version
  nginx -v
  node --version
  php --version
  pnpm --version
'
