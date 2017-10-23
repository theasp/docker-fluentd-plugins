# theasp/fluentd-plugins

The official [Fluentd](https://hub.docker.com/r/fluent/fluentd/) docker image with several plugins installed.  The `latest` tag has many commonly used plugins, and `all` has almost all plugins installed.  I only intend to support the `latest` tag.  If you would like plugins added to `latest`, please create a pull request on github.

https://github.com/theasp/docker-fluentd-plugins

# Installed Plugins

The (possibly outdated) list of plugins included in `latest` is:
- add
- amazon_sns
- anonymizer
- assert
- aws-elasticsearch-service
- bigquery
- cloudwatch
- cloudwatch_ya
- collectd-influxdb
- concat
- couch
- datacalculator
- dedot_filter
- docker-format
- docker-journald-concat
- docker_metadata_filter
- dynamodb
- elasticsearch
- elasticsearch-timestamp-check
- elb-access-log
- elb-log
- esslowquery
- eval-filter
- fields-parser
- filter
- filter_typecast
- forward-aws
- gcloud-pubsub-custom
- geoip
- google-cloud
- graphite
- grep
- grok-parser
- growthforecast
- hipchat
- ignore-filter
- ikachan
- influxdb
- irc
- json-in-json
- json-nest2flat
- json-parser
- kinesis
- kinesis-aggregation
- kubernetes
- kubernetes_metadata_filter
- ltsv-parser
- mongo
- mongo-slow-query
- mqtt-io
- multi-format-parser
- mysql
- mysql-query
- mysql-replicator
- newsyslog
- norikra
- parser
- pghstore
- ping-message
- rds-log
- rds-slowlog
- record-modifier
- record-reformer
- redshift
- referer-parser
- retag
- rewrite-tag-filter
- s3
- script
- sns
- splunkapi
- sqs
- sqs-poll
- statsd
- sumologic-cloud-syslog
- sumologic_output
- td
- time_parser
- twilio
- ua-parser
- viaq_data_model
- webhdfs
- woothee
- zabbix
- zabbix-simple-bufferd


# Todo

1. `ONBUILD` support
