

--- Create source Flink Table's sourced via Flink source connector

CREATE OR REPLACE TABLE hive_catalog.kafka.factory_iot_north (
     ts              BIGINT
    ,metadata        ROW<
         siteId          INTEGER
        ,deviceId        INTEGER
        ,sensorId        INTEGER
        ,unit            STRING
        ,ts_human        STRING
        ,location        ROW<
             latitude        DOUBLE
            ,longitude       DOUBLE
        >
        ,deviceType      STRING
    >
    ,measurement         DOUBLE
    ,ts_wm               AS TO_TIMESTAMP_LTZ(ts, 3)
    ,WATERMARK           FOR ts_wm AS ts_wm - INTERVAL '1' MINUTE
) WITH (
    'connector'                     = 'kafka',
    'topic'                         = 'factory_iot_north',
    'properties.bootstrap.servers'  = 'broker:29092',
    'properties.group.id'           = 'devlab0',
    'scan.startup.mode'             = 'earliest-offset',
    'format'                        = 'json',
    'json.fail-on-missing-field'    = 'false',
    'json.ignore-parse-errors'      = 'true'
);


CREATE TABLE hive_catalog.kafka.factory_iot_south (
     ts              BIGINT
    ,metadata        ROW<
         siteId          INTEGER
        ,deviceId        INTEGER
        ,sensorId        INTEGER
        ,unit            STRING
        ,ts_human        STRING
        ,location        ROW<
             latitude        DOUBLE
            ,longitude       DOUBLE
        >
    >
    ,measurement         DOUBLE
    ,ts_wm               AS TO_TIMESTAMP_LTZ(ts, 3)
    ,WATERMARK           FOR ts_wm AS ts_wm - INTERVAL '1' MINUTE
) WITH (
    'connector'                     = 'kafka',
    'topic'                         = 'factory_iot_south',
    'properties.bootstrap.servers'  = 'broker:29092',
    'properties.group.id'           = 'devlab0',
    'scan.startup.mode'             = 'earliest-offset',
    'format'                        = 'json',
    'json.fail-on-missing-field'    = 'false',
    'json.ignore-parse-errors'      = 'true'
);


CREATE TABLE hive_catalog.kafka.factory_iot_east (
     ts              BIGINT
    ,metadata        ROW<
         siteId          INTEGER
        ,deviceId        INTEGER
        ,sensorId        INTEGER
        ,unit            STRING
        ,ts_human        STRING
        ,location        ROW<
             latitude        DOUBLE
            ,longitude       DOUBLE
        >
        ,deviceType      STRING
    >
    ,measurement         DOUBLE
    ,ts_wm               AS TO_TIMESTAMP_LTZ(ts, 3)
    ,WATERMARK           FOR ts_wm AS ts_wm - INTERVAL '1' MINUTE
) WITH (
    'connector'                     = 'kafka',
    'topic'                         = 'factory_iot_east',
    'properties.bootstrap.servers'  = 'broker:29092',
    'properties.group.id'           = 'devlab0',
    'scan.startup.mode'             = 'earliest-offset',
    'format'                        = 'json',
    'json.fail-on-missing-field'    = 'false',
    'json.ignore-parse-errors'      = 'true'
);