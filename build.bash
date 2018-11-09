#!/bin/bash

set -exu
set -o pipefail

BUILD_DEPS="jq curl make gcc g++ rake patch libc-dev ruby-dev zlib1g-dev libcurl4-openssl-dev libpq-dev libssl-dev libsqlite3-dev default-libmysqlclient-dev libgeoip-dev libsasl2-dev libxml2-dev libffi-dev libmaxminddb-dev ruby-aws-sdk"
JQ=''
SKIP='^$'
ALLOW_FAIL=false

case $1 in
  certified) JQ='map(select(.obsolete != true and (.certified|length) > 0)) | .[].name | @text' ;;
  slim)      JQ='map(select(.obsolete != true and (.downloads > 20000 or (.certified|length) > 0))) | .[].name | @text' ;;
  common)    JQ='map(select(.obsolete != true and (.downloads > 5000 or (.certified|length) > 0))) | .[].name | @text'
             SKIP='^fluent-plugin-(chef-client|grassland|mysql-binlog|monolog|filter-list)$' ;;
  all)       JQ='map(select(.obsolete != true) | .[].name | @text'
             ALLOW_FAIL=true ;;
  *)
    echo "Unknown build type: $1"
    exit 1 ;;
esac

sed -r -i -e 's! main! main contrib non-free!g' /etc/apt/sources.list

apt-get update -q
apt-get install -qy --no-install-recommends $BUILD_DEPS

if ! curl -s https://www.fluentd.org/plugins \
    | grep '^  var plugins' \
    | cut -f 2- -d = \
    | sed -e 's/;$//' \
    | jq -r "$JQ" \
    | egrep -v "$SKIP" \
    | xargs -r gem install;
then
  if [[ $ALLOW_FAIL != true ]]; then
    echo "Error installing packages"
    exit 1
  fi
fi

gem list 'fluent-plugins*' | tee /plugins-installed
gem sources --clear-all

apt-get purge -qy $(dpkg-query --show --showformat '${Package}\n' '*-dev')
rm -rf /var/lib/apt/lists/* /home/fluent/.gem/ruby/*/cache/*.gem
