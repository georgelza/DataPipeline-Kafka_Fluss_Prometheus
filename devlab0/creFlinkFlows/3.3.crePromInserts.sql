

SET 'parallelism.default' = '2';
SET 'sql-client.verbose' = 'true';
SET 'execution.runtime-mode' = 'streaming';

-- insert into hive_catalog.prometheus.factory_iot_north select * from fluss_catalog.fluss.factory_iot_unnested where siteId='101';
-- insert into hive_catalog.prometheus.factory_iot_south select * from fluss_catalog.fluss.factory_iot_unnested where siteId='102';
-- insert into hive_catalog.prometheus.factory_iot_south select * from fluss_catalog.fluss.factory_iot_unnested where siteId='103';

--- Push Data to Prometheus ---

SET 'pipeline.name' = 'Push North metrics to factory_iot_north';

INSERT INTO hive_catalog.prometheus.factory_iot_north
    (siteId, deviceId, sensorId, measurement, ts_wm)
SELECT
     CAST(siteId AS "VARCHAR")      AS siteId
    ,CAST(deviceId AS "VARCHAR")    AS deviceId
    ,CAST(sensorId AS "VARCHAR")    AS sensorId
    ,measurement                    AS measurement
    ,ts_wm                          AS ts_wm
FROM fluss_catalog.fluss.factory_iot_unnested
WHERE siteId=101;


SET 'pipeline.name' = 'Push South metrics to factory_iot_south';

INSERT INTO hive_catalog.prometheus.factory_iot_south
    (siteId, deviceId, sensorId, measurement, ts_wm)
SELECT
     CAST(siteId AS "VARCHAR")      AS siteId
    ,CAST(deviceId AS "VARCHAR")    AS deviceId
    ,CAST(sensorId AS "VARCHAR")    AS sensorId
    ,measurement                    AS measurement
    ,ts_wm                          AS ts_wm
FROM fluss_catalog.fluss.factory_iot_unnested
WHERE siteId=102;


SET 'pipeline.name' = 'Push East metrics to factory_iot_east';

INSERT INTO hive_catalog.prometheus.factory_iot_east
    (siteId, deviceId, sensorId, measurement, deviceType, ts_wm)
SELECT
     CAST(siteId AS "VARCHAR")      AS siteId
    ,CAST(deviceId AS "VARCHAR")    AS deviceId
    ,CAST(sensorId AS "VARCHAR")    AS sensorId
    ,deviceType                     AS deviceType
    ,measurement                    AS measurement
    ,ts_wm                          AS ts_wm
FROM fluss_catalog.fluss.factory_iot_unnested
WHERE siteId=103;
