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
    && cd / \
    && git clone https://github.com/zetaoss/zengine.git app \
    && cd /app/ \
    && mv /var/www/html /app/w \
    && ln -s /app/mwz/extensions/ZetaExtension /app/w/extensions/ \
    && ln -s /app/mwz/skins/ZetaSkin /app/w/skins/ \
    && cd /app/svelte/ && pnpm install && pnpm run build \
    && cd /app/w/skins/ZetaSkin/svelte/ && pnpm install && pnpm run build \
    && chown www-data:www-data -R /app/* \
    && echo ok

RUN set -eux \
    && curl -fsSL https://chatgpt.com/codex/install.sh | sh \
    && curl -fsSL https://gh.io/copilot-install | bash \
    && echo ok
