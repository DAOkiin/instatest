FROM wernight/phantomjs

USER root
RUN apt-get update && apt-get install -y git zlib1g-dev curl wget xz-utils autoconf bison build-essential libssl-dev libyaml-dev libreadline6 libreadline6-dev zlib1g

# skip installing gem documentation
RUN mkdir -p /usr/local/etc \
  && { \
    echo 'install: --no-document'; \
    echo 'update: --no-document'; \
  } >> /usr/local/etc/gemrc

ENV RUBY_MAJOR 2.5
ENV RUBY_VERSION 2.5.1
ENV RUBY_DOWNLOAD_SHA256 886ac5eed41e3b5fc699be837b0087a6a5a3d10f464087560d2d21b3e71b754d
ENV RUBYGEMS_VERSION 2.6.10

# some of ruby's build scripts are written in ruby
#   we purge system ruby later to make sure our final image uses what we just built
RUN set -ex \
  \
  && buildDeps=' \
    bison \
    libgdbm-dev \
    ruby \
  ' \
  && apt-get update \
  && apt-get install -y --no-install-recommends $buildDeps \
  && rm -rf /var/lib/apt/lists/* \
  \
  && wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz" \
  && echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum -c - \
  \
  && mkdir -p /usr/src/ruby \
  && tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1 \
  && rm ruby.tar.xz \
  \
  && cd /usr/src/ruby \
  \
# hack in "ENABLE_PATH_CHECK" disabling to suppress:
#   warning: Insecure world writable dir
  && { \
    echo '#define ENABLE_PATH_CHECK 0'; \
    echo; \
    cat file.c; \
  } > file.c.new \
  && mv file.c.new file.c \
  \
  && autoconf \
  && ./configure --disable-install-doc --enable-shared \
  && make -j"$(nproc)" \
  && make install \
  \
  && apt-get purge -y --auto-remove $buildDeps \
  && cd / \
  && rm -r /usr/src/ruby \
  \
  && gem update --system "$RUBYGEMS_VERSION"

ENV BUNDLER_VERSION 1.14.3

RUN gem install bundler --version "$BUNDLER_VERSION" \
  && apt-get update \
  && apt-get install -y libpq-dev \
  nodejs \
  && rm -rf /var/lib/apt/lists/* \
  && useradd -u 1000 deployer

# install things globally, for great justice
# and don't create ".bundle" in all our apps
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
  BUNDLE_BIN="$GEM_HOME/bin" \
  BUNDLE_SILENCE_ROOT_WARNING=1 \
  BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH

USER deployer
WORKDIR /app
