

SET 'parallelism.default'    = '2';
SET 'sql-client.verbose'     = 'true';
SET 'execution.runtime-mode' = 'streaming';


--- Push Data to Prometheus ---

SET 'pipeline.name' = 'Push North metrics to prometheus region_north';

INSERT INTO hive_catalog.prometheus.region_north
    (metric_name, siteId, deviceId, sensorId, measurement, ts)
SELECT
     CAST('sensor_reading' AS STRING)           AS metric_name
    ,siteId                                     AS siteId
    ,deviceId                                   AS deviceId
    ,sensorId                                   AS sensorId
    ,measurement                                AS measurement
    ,TO_TIMESTAMP(FROM_UNIXTIME(ts / 1000))     AS ts
FROM fluss_catalog.fluss.factory_iot_unnested
WHERE siteId=101;


SET 'pipeline.name' = 'Push South metrics to prometheus region_south';

INSERT INTO hive_catalog.prometheus.region_south
    (metric_name, siteId, deviceId, sensorId, measurement, ts)
SELECT
     CAST('sensor_reading' AS STRING)           AS metric_name
    ,siteId                                     AS siteId
    ,deviceId                                   AS deviceId
    ,sensorId                                   AS sensorId
    ,measurement                                AS measurement
    ,TO_TIMESTAMP(FROM_UNIXTIME(ts / 1000))     AS ts
FROM fluss_catalog.fluss.factory_iot_unnested
WHERE siteId=102;


SET 'pipeline.name' = 'Push East metrics to prometheus region_east';

INSERT INTO hive_catalog.prometheus.region_east
    (metric_name, siteId, deviceId, sensorId, measurement, ts)
SELECT
     CAST('sensor_reading' AS STRING)           AS metric_name
    ,siteId                                     AS siteId
    ,deviceId                                   AS deviceId
    ,sensorId                                   AS sensorId
    ,measurement                                AS measurement
    ,TO_TIMESTAMP(FROM_UNIXTIME(ts / 1000))     AS ts
FROM fluss_catalog.fluss.factory_iot_unnested
WHERE siteId=103;
