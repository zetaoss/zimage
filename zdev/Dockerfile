# syntax=docker/dockerfile:1

# Supplied from the repository's versions.env by Make and GitHub Actions.
ARG ZBASE_VERSION=version-required
FROM ghcr.io/zetaoss/zbase:${ZBASE_VERSION}

ENV GOPATH=/root/go
ENV PATH=/usr/local/go/bin:/root/go/bin:/root/.local/share/pnpm/bin:${PATH}

RUN set -eux \
    && apk add --no-cache \
        bash \
        coreutils \
        go~1.26 \
        inotify-tools \
        jq \
        mariadb-client \
        openssh-server \
        pnpm \
        procps \
        psmisc \
        ripgrep \
        supervisor \
    && go install golang.org/x/tools/gopls@latest \
    && go install github.com/go-delve/delve/cmd/dlv@latest \
    && go install github.com/air-verse/air@latest \
    && echo ok

RUN set -eux \
    && curl -fsSL https://antigravity.google/cli/install.sh | bash \
    && curl -fsSL https://chatgpt.com/codex/install.sh | sh \
    && curl -fsSL https://gh.io/copilot-install | bash \
    && echo ok
