# syntax=docker/dockerfile:1

# https://hub.docker.com/_/mediawiki
FROM mediawiki:1.43.9-fpm
ARG MEDIAWIKI_BRANCH=REL1_43

RUN set -eux; \
    ## system packages
    apt-get update; \
    apt-get install -y --no-install-recommends nginx; \
    rm -rf /var/lib/apt/lists/*; \
    ## php extensions
    curl -sSLf -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions; \
    chmod +x /usr/local/bin/install-php-extensions; \
    install-php-extensions \
        pdo_mysql \
        pcntl \
        redis \
        wikidiff2 \
        zip

RUN set -eux \
    ## mediawiki extensions
    && cd /var/www/html/extensions/ \
    && git clone --depth=1 -b $MEDIAWIKI_BRANCH https://gerrit.wikimedia.org/r/mediawiki/extensions/AntiSpoof.git \
    && git clone --depth=1 -b $MEDIAWIKI_BRANCH https://gerrit.wikimedia.org/r/mediawiki/extensions/CheckUser.git \
    && git clone --depth=1 -b $MEDIAWIKI_BRANCH https://gerrit.wikimedia.org/r/mediawiki/extensions/CharInsert.git \
    && git clone --depth=1 -b $MEDIAWIKI_BRANCH https://gerrit.wikimedia.org/r/mediawiki/extensions/intersection.git \
    && git clone --depth=1 -b $MEDIAWIKI_BRANCH https://gerrit.wikimedia.org/r/mediawiki/extensions/MsUpload.git \
    && git clone --depth=1 -b $MEDIAWIKI_BRANCH https://gerrit.wikimedia.org/r/mediawiki/extensions/Score.git \
    && git clone --depth=1 -b $MEDIAWIKI_BRANCH https://gerrit.wikimedia.org/r/mediawiki/extensions/TemplateStyles.git \
    && git clone --depth=1 -b $MEDIAWIKI_BRANCH https://gerrit.wikimedia.org/r/mediawiki/extensions/UserMerge.git \
    && git clone --depth=1 -b $MEDIAWIKI_BRANCH https://gerrit.wikimedia.org/r/mediawiki/extensions/Widgets.git \
    && git clone --depth=1 -b $MEDIAWIKI_BRANCH https://gerrit.wikimedia.org/r/mediawiki/extensions/Wikibase.git \
    && echo ok

RUN set -eux \
    ## mediawiki extensions extra
    && cd /var/www/html/extensions/ \
    && git clone --depth=1 -b v0.14.0 https://github.com/edwardspec/mediawiki-aws-s3.git                     AWS \
    && git clone --depth=1 -b v4.1.0  https://github.com/StarCitizenWiki/mediawiki-extensions-EmbedVideo.git EmbedVideo \
    && git clone --depth=1 -b v0.1.1  https://github.com/jmnote/Resend.git                                   Resend \
    && git clone --depth=1 -b v0.2.1  https://github.com/jmnote/SimpleMaps.git                               SimpleMaps \
    && git clone --depth=1 -b v0.1.0  https://github.com/jmnote/SimpleMarkdown.git                           SimpleMarkdown \
    && git clone --depth=1 -b v0.8.11 https://github.com/jmnote/SimpleMathJax.git                            SimpleMathJax \
    && git clone --depth=1 -b v0.1.2  https://github.com/jmnote/SimpleMermaid.git                            SimpleMermaid \
    && echo ok
