# syntax=docker/dockerfile:1

# Keep expensive, versioned tooling independent from ZBASE_VERSION so that a
# zbase update does not rebuild it.
ARG GO_VERSION=1.26
ARG ZBASE_VERSION=version-required

FROM golang:${GO_VERSION}-trixie AS go-devtools

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    set -eux; \
    GOBIN=/out/bin go install golang.org/x/tools/gopls@latest; \
    GOBIN=/out/bin go install github.com/air-verse/air@latest

FROM node:24-bookworm-slim AS cli-tools

ENV PATH=/root/.local/bin:${PATH}

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    npm install --global pnpm@latest; \
    curl -fsSL https://antigravity.google/cli/install.sh | bash; \
    curl -fsSL https://chatgpt.com/codex/install.sh | sh; \
    curl -fsSL https://gh.io/copilot-install | bash

# Supplied from the repository's versions.env by Make and GitHub Actions.
FROM ghcr.io/zetaoss/zbase:${ZBASE_VERSION}

ENV GOPATH=/go \
    PATH=/usr/local/go/bin:/go/bin:/root/.local/bin:/root/.local/share/pnpm/bin:${PATH}

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        bash \
        coreutils \
        gcc \
        gh \
        inotify-tools \
        jq \
        mariadb-client \
        libc6-dev \
        openssh-server \
        procps \
        psmisc \
        ripgrep \
        supervisor; \
    rm -rf /var/lib/apt/lists/*; \
    printf '%s\n' \
        'export GOPATH=/go' \
        'export PATH="/usr/local/go/bin:/go/bin:/root/.local/bin:/root/.local/share/pnpm/bin:$PATH"' \
        > /etc/profile.d/zdev.sh

COPY --link --from=go-devtools /usr/local/go/ /usr/local/go/
COPY --link --from=go-devtools /out/bin/ /go/bin/
COPY --link --from=cli-tools /root/.codex/packages/ /root/.codex/packages/
COPY --link --from=cli-tools /root/.local/bin/ /root/.local/bin/
COPY --link --from=cli-tools /usr/local/bin/ /usr/local/bin/
COPY --link --from=cli-tools /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
COPY --from=composer:2.10 /usr/bin/composer /usr/bin/composer
