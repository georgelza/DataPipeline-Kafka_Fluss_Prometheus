
-- https://github.com/apache/flink-connector-prometheus/pull/22

-- when the project writes up some docs... it needs to be highlighted that remote write is used...
-- and that you need to pass  - "--web.enable-remote-write-receiver" as part of the start command and that the write destination for the table is this url..
-- oh and then, this one got me... check prometheus server time vs your writers time... my case my server was running utc and my code as local which os +2... so the server rejected the writes as being to far into the future.

-- The metric_name column will contain the well, the name of the metric... in the below case "sensor_readings"
-- followed by pretty much the labels for the sensor_reading... this structure is really elegant in that you can one single
-- table for all our prometheus metrics.

CREATE TABLE hive_catalog.prometheus.Promtest (
    `metric_name`          STRING
   ,`sensorId`             INT
   ,`siteId`               INT
   ,`deviceId`             INT
   ,`measurement`          DOUBLE
   ,`ts`                   TIMESTAMP(3)
) WITH (
   'connector'               = 'prometheus',
   'metric.endpoint-url'     = 'http://prometheus:9090/api/v1/write',
   'metric.name'             = 'metric_name',
   'metric.label.keys'       = '[sensorId,siteId,deviceId]',
   'metric.sample.key'       = 'measurement',
   'metric.sample.timestamp' = 'ts'
);