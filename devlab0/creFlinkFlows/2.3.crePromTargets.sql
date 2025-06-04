
-- https://github.com/apache/flink-connector-prometheus/pull/22


CREATE TABLE hive_catalog.prometheus.factory_iot_north (
    `sensorId`       STRING
   ,`siteId`         STRING
   ,`deviceId`       STRING
   ,`measurement`    BIGINT
   ,`ts_wm`          TIMESTAMP(3)
) WITH (
   'connector'               = 'prometheus',
   'metric.endpoint-url'     = 'http://pushgateway:9091/metrics/job/factory_iot/instance/North',
   'metric.name'             = 'sensorId',
   'metric.label.keys'       = '[siteId,deviceId,sensorId]',
   'metric.sample.key'       = 'measurement',
   'metric.sample.timestamp' = 'ts_wm'
);

CREATE TABLE hive_catalog.prometheus.factory_iot_south (
    `sensorId`       STRING
   ,`siteId`         STRING
   ,`deviceId`       STRING
   ,`measurement`    BIGINT
   ,`ts_wm`          TIMESTAMP(3)
) WITH (
   'connector'               = 'prometheus',
   'metric.endpoint-url'     = 'http://pushgateway:9091/metrics/job/factory_iot/instance/South',
   'metric.name'             = 'sensorId',
   'metric.label.keys'       = '[siteId,deviceId,sensorId]',
   'metric.sample.key'       = 'measurement',
   'metric.sample.timestamp' = 'ts_wm'
);

CREATE TABLE hive_catalog.prometheus.factory_iot_east (
    `sensorId`       STRING
   ,`siteId`         STRING
   ,`deviceId`       STRING
   ,`deviceType`     STRING
   ,`measurement`    BIGINT
   ,`ts_wm`          TIMESTAMP(3)
) WITH (
   'connector'               = 'prometheus',
   'metric.endpoint-url'     = 'http://pushgateway:9091/metrics/job/factory_iot/instance/East',
   'metric.name'             = 'sensorId',
   'metric.label.keys'       = '[siteId,deviceId,sensorId]',
   'metric.sample.key'       = 'measurement',
   'metric.sample.timestamp' = 'ts_wm'
);
