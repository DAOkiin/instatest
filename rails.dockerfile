FROM ruby:2.5.0-alpine

USER root

ENV APP_HOME=/app \
    DEV_USER=deployer \
    PATH=/app/bin:$PATH

RUN set -ex \
  && adduser -u 1000 -D -H $DEV_USER \
  && runDeps="$( \
    scanelf --needed --nobanner --recursive /usr/local \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u \
      | xargs -r apk info --installed \
      | sort -u \
  )" \
  && apk add --no-cache --virtual .ruby-rundeps $runDeps \
    bzip2 \
    ca-certificates \
    libffi-dev \
    yaml-dev \
    procps \
    zlib-dev \
    build-base \
    tzdata \
    postgresql-dev \
    git \
    nodejs \
  && gem install bundler \
  && gem install rails \
  && mkdir -p $APP_HOME

COPY entrypoint.sh /
RUN chown -R $(id $DEV_USER -u) "$GEM_HOME" "$BUNDLE_BIN" "$APP_HOME" '/entrypoint.sh' \
  && chmod +x /entrypoint.sh

USER $DEV_USER
WORKDIR $APP_HOME
ENTRYPOINT ["/entrypoint.sh"]
