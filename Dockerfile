FROM fluent/fluentd:stable-debian

# below RUN includes plugin as examples elasticsearch is not required
# you may customize including plugins as you wish

ENV BUILD_DEPS="sudo make gcc g++ libc-dev ruby-dev"

RUN set -ex ; \
   apt-get update ; \
   apt-get install -y --no-install-recommends $BUILD_DEPS

RUN set -ex ; \
   gem search ^fluent-plugin- | cut -f 1 -d ' ' | xargs -r sudo gem install || true ; \
   sudo gem sources --clear-all ; \
   SUDO_FORCE_REMOVE=yes apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $BUILD_DEPS ; \
   rm -rf /var/lib/apt/lists/* /home/fluent/.gem/ruby/*/cache/*.gem
