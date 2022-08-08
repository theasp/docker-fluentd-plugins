#!/bin/bash

set -exu
set -o pipefail

BUILD_DEPS=(jq curl make gcc g++ rake patch libc-dev ruby-dev zlib1g-dev libcurl4-openssl-dev libpq-dev libssl-dev libsqlite3-dev default-libmysqlclient-dev libgeoip-dev libsasl2-dev libxml2-dev libffi-dev libmaxminddb-dev ruby-aws-sdk)
JQ=''
ALLOW_FAIL=true
SKIP='^fluent-plugin-(geoblipper|chef-client|grassland|mysql-binlog|monolog|filter-list|couchbase|splunk-hec|azure-loganalytics|amplitude|cloud-feeds|aerospike-cluster|cassandra|calyptia-monitoring|better-timestamp)$'

function main {
  local series=$1

  if [[ -z $series ]]; then
    echo "Usage: $0 <series>"
  fi

  install_deps
  install_plugins "${series}"
  cleanup
}

function install_deps {
  sed -r -i -e 's! main! main contrib non-free!g' /etc/apt/sources.list

  apt-get update -q
  apt-get install -qy --no-install-recommends "${BUILD_DEPS[@]}"

  install_plugins "${series}"
}

function install_plugins {
  local series=$1

  echo "About to install for series ${series}:"
  plugins_to_install "${series}" | sed -re 's/^/  - /'

  if ! (plugins_to_install "${series}" | xargs -tr gem install); then
    if [[ $ALLOW_FAIL != true ]]; then
      echo "ERROR: Problem installing plugins for ${series}" 1>&2
      exit 1
    fi
  fi
}

function plugins_to_install {
  local series=$1

  comm -13 <(plugins_installed) <(plugins_for_series "${series}")
}



function plugins_installed {
  gem list --installed \
    | egrep ^fluent-plugin- \
    | awk '{ print $1 }' \
    | sort
}

function plugins_for_series {
  local series=$1

  case $1 in
    certified) JQ='map(select(.obsolete != true and (.certified|length) > 0)) | .[].name | @text' ;;
    slim)      JQ='map(select(.obsolete != true and (.downloads > 20000 or (.certified|length) > 0))) | .[].name | @text' ;;
    common)    JQ='map(select(.obsolete != true and (.downloads > 5000 or (.certified|length) > 0))) | .[].name | @text' ;;
    all)       JQ='map(select(.obsolete != true) | .[].name | @text'
               SKIP='^$'
               ALLOW_FAIL=true ;;
    *)
      echo "Unknown build type: $1"
      exit 1 ;;
  esac


  if ! curl -s https://www.fluentd.org/plugins \
      | grep '^  var plugins' \
      | cut -f 2- -d = \
      | sed -e 's/;$//' \
      | jq -r "$JQ" \
      | egrep -v "$SKIP" \
      | sort; then
    echo "ERROR: Unable to get list of plugins" 1>&2
    exit 1
  fi
}

function make_plugin_list {
  gem list 'fluent-plugins*' | tee /plugins-installed
  gem sources --clear-all
}


function cleanup {
  apt-get purge -qy $(dpkg-query --show --showformat '${Package}\n' '*-dev')
  rm -rf /var/lib/apt/lists/* /home/fluent/.gem/ruby/*/cache/*.gem
}

main "$@"
