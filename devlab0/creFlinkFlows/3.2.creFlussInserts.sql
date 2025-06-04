

SET 'parallelism.default' = '2';
SET 'sql-client.verbose' = 'true';
SET 'execution.runtime-mode' = 'streaming';


--- Push Data to Prometheus ---

SET 'pipeline.name' = 'Push North metrics to factory_iot_unnested';

INSERT INTO fluss_catalog.fluss.factory_iot_unnested
SELECT
     ts                                             AS ts
    ,CAST(metadata.siteId AS "VARCHAR")             AS siteId
    ,CAST(metadata.deviceId AS "VARCHAR")           AS deviceId
    ,CAST(metadata.sensorId AS "VARCHAR")           AS sensorId
    ,unit                                           AS unit
    ,ts_human                                       AS ts_human
    ,CAST(NULL AS "DOUBLE")                         AS longitude
    ,CAST(NULL AS "DOUBLE")                         AS latitude   
    ,CAST(NULL AS "STRING")                         AS deviceType
    ,measurement                                    AS measurement
    ,DATE_FORMAT(TO_TIMESTAMP_LTZ(ts, 3), 'yyyyMM') AS partition_month
    ,ts_wm                                          AS ts_wm
FROM hive_catalog.iot.factory_iot_north;


SET 'pipeline.name' = 'Push South metrics to factory_iot_unnested';

INSERT INTO fluss_catalog.fluss.factory_iot_unnested
SELECT
     ts                                             AS ts
    ,CAST(siteId AS "VARCHAR")                      AS siteId
    ,CAST(deviceId AS "VARCHAR")                    AS deviceId
    ,CAST(sensorId AS "VARCHAR")                    AS sensorId
    ,unit                                           AS unit
    ,ts_human                                       AS ts_human
    ,location.longitude                             AS longitude
    ,location.latitude                              AS latitude    
    ,CAST(NULL AS "STRING")                         AS deviceType
    ,measurement                                    AS measurement
    ,DATE_FORMAT(TO_TIMESTAMP_LTZ(ts, 3), 'yyyyMM') AS partition_month
    ,ts_wm                                          AS ts_wm
FROM hive_catalog.iot.factory_iot_south;



SET 'pipeline.name' = 'Push East metrics to factory_iot_unnested';

INSERT INTO fluss_catalog.fluss.factory_iot_unnested
SELECT
     ts                                             AS ts
    ,CAST(siteId AS "VARCHAR")                      AS siteId
    ,CAST(metadata.deviceId AS "VARCHAR")           AS deviceId
    ,CAST(metadata.sensorId AS "VARCHAR")           AS sensorId
    ,unit                                           AS unit
    ,ts_human                                       AS ts_human
    ,location.longitude                             AS longitude
    ,location.latitude                              AS latitude
    ,metadata.deviceType                            AS deviceType
    ,measurement                                    AS measurement
    ,DATE_FORMAT(TO_TIMESTAMP_LTZ(ts, 3), 'yyyyMM') AS partition_month
    ,ts_wm                                          AS ts_wm
FROM hive_catalog.iot.factory_iot_east;