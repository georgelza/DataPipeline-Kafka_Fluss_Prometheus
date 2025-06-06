
-- https://github.com/apache/flink-connector-prometheus/pull/22

CREATE TABLE hive_catalog.prometheus.region_north (
    `metric_name`          STRING
   ,`sensorId`             INT
   ,`siteId`               INT
   ,`deviceId`             INT
   ,`measurement`          DOUBLE
   ,`ts`                   TIMESTAMP(3)
) WITH (
    'connector'               = 'prometheus'
   ,'metric.endpoint-url'     = 'http://prometheus:9090/api/v1/write'
   ,'metric.name'             = 'metric_name'
   ,'metric.label.keys'       = '[sensorId,siteId,deviceId]'
   ,'metric.sample.key'       = 'measurement'
   ,'metric.sample.timestamp' = 'ts'
);

CREATE TABLE hive_catalog.prometheus.region_south (
    `metric_name`          STRING
   ,`sensorId`             INT
   ,`siteId`               INT
   ,`deviceId`             INT
   ,`measurement`          DOUBLE
   ,`ts`                   TIMESTAMP(3)
) WITH (
    'connector'               = 'prometheus'
   ,'metric.endpoint-url'     = 'http://prometheus:9090/api/v1/write'
   ,'metric.name'             = 'metric_name'
   ,'metric.label.keys'       = '[sensorId,siteId,deviceId]'
   ,'metric.sample.key'       = 'measurement'
   ,'metric.sample.timestamp' = 'ts'
);

CREATE TABLE hive_catalog.prometheus.region_east (
    `metric_name`          STRING
   ,`sensorId`             INT
   ,`siteId`               INT
   ,`deviceId`             INT
   ,`measurement`          DOUBLE
   ,`ts`                   TIMESTAMP(3)
) WITH (
    'connector'               = 'prometheus'
   ,'metric.endpoint-url'     = 'http://prometheus:9090/api/v1/write'
   ,'metric.name'             = 'metric_name'
   ,'metric.label.keys'       = '[sensorId,siteId,deviceId]'
   ,'metric.sample.key'       = 'measurement'
   ,'metric.sample.timestamp' = 'ts'
);