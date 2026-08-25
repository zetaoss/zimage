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
        pcntl \
        pdo_mysql \
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
    && git clone --depth=1 -b $MEDIAWIKI_BRANCH https://gerrit.wikimedia.org/r/mediawiki/extensions/Score.git \
    && git clone --depth=1 -b $MEDIAWIKI_BRANCH https://gerrit.wikimedia.org/r/mediawiki/extensions/TemplateStyles.git \
    && git clone --depth=1 -b $MEDIAWIKI_BRANCH https://gerrit.wikimedia.org/r/mediawiki/extensions/UserMerge.git \
    && git clone --depth=1 -b $MEDIAWIKI_BRANCH https://gerrit.wikimedia.org/r/mediawiki/extensions/Widgets.git \
    # auto-generated
    && git clone --depth=1 -b v0.14.0 https://github.com/edwardspec/mediawiki-aws-s3.git                     AWS \
    && git clone --depth=1 -b v4.1.0  https://github.com/StarCitizenWiki/mediawiki-extensions-EmbedVideo.git EmbedVideo \
    && git clone --depth=1 -b v0.1.1  https://github.com/mailapi/mediawiki-extensions-MailAPI.git            MailAPI \
    && git clone --depth=1 -b REL1_43 https://gerrit.wikimedia.org/r/mediawiki/extensions/MsUpload.git       MsUpload \
    && git clone --depth=1 -b v0.2.2  https://github.com/jmnote/SimpleMaps.git                               SimpleMaps \
    && git clone --depth=1 -b v0.1.1  https://github.com/jmnote/SimpleMarkdown.git                           SimpleMarkdown \
    && git clone --depth=1 -b v0.9.0  https://github.com/jmnote/SimpleMathJax.git                            SimpleMathJax \
    && git clone --depth=1 -b v0.1.4  https://github.com/jmnote/SimpleMermaid.git                            SimpleMermaid \
    # /auto-generated
    && echo ok

# Composer is mounted only for dependency installation and is not retained in the image.
RUN --mount=type=bind,from=composer:2.10,source=/usr/bin/composer,target=/usr/local/bin/composer \
    set -eux; \
    cd /var/www/html; \
    cp composer.local.json-sample composer.local.json; \
    composer update --no-dev --no-scripts --optimize-autoloader
