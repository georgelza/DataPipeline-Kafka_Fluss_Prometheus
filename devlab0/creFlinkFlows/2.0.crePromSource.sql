
-- https://github.com/apache/flink-connector-prometheus/pull/22


CREATE TABLE hive_catalog.prometheus.Promtest (
   `sensorId`       STRING,
   `siteId`         STRING,
   `deviceId`       STRING,
   `measurement`    BIGINT,
   `ts_wm`          TIMESTAMP(3)
) WITH (
   'connector'               = 'prometheus',
   'metric.endpoint-url'     = 'http://pushgateway:9091/metrics/job/PromTest/instance/North',
   'metric.name'             = 'sensorId',
   'metric.label.keys'       = '[siteId,deviceId,sensorId]',
   'metric.sample.key'       = 'measurement',
   'metric.sample.timestamp' = 'ts_wm'
);



-- Direct Curl testing of pushgateway
--
-- cat <<EOF | curl --data-binary @- http://127.0.0.1:9091/metrics/job/Promtest/instance/North
--   # TYPE sensor_reading counter
--   sensor_reading{siteId="101", deviceId="1031", sensorId="10222"} 5
--   # TYPE sensorId gauge
--   sensorId{siteId="101", deviceId="1031", sensorId="10221"} 41
--   # TYPE another_metric gauge
--   # HELP another_metric Just an example.
--   another_metric{deviceId="1031", sensorId="10521"} 2398.283
-- EOF


-- cat <<EOF | curl --data-binary @- http://127.0.0.1:9091/metrics/job/Promtest/instance/North
--   # TYPE sensor_reading counter
--   sensor_reading{siteId="101", deviceId="1031", sensorId="10222"} 6
--   # TYPE sensorId gauge
--   sensorId{siteId="101", deviceId="1031", sensorId="10221"} 42
--   # TYPE another_metric gauge
--   # HELP another_metric Just an example.
--   another_metric{deviceId="1031", sensorId="10521"} 2394.283
-- EOF

-- cat <<EOF | curl --data-binary @- http://127.0.0.1:9091/metrics/job/Promtest/instance/North
--   # TYPE sensor_reading counter
--   sensor_reading{siteId="101", deviceId="1031", sensorId="10222"} 9
--   # TYPE sensorId gauge
--   sensorId{siteId="101", deviceId="1031", sensorId="10221"} 43
--   # TYPE another_metric gauge
--   # HELP another_metric Just an example.
--   another_metric{deviceId="1031", sensorId="10521"} 2395.283
-- EOF

-- cat <<EOF | curl --data-binary @- http://127.0.0.1:9091/metrics/job/Promtest/instance/North
--   # TYPE sensor_reading counter
--   sensor_reading{siteId="101", deviceId="1031", sensorId="10222"} 12
--   # TYPE sensorId gauge
--   sensorId{siteId="101", deviceId="1031", sensorId="10221"} 45
--   # TYPE another_metric gauge
--   # HELP another_metric Just an example.
--   another_metric{deviceId="1031", sensorId="10521"} 2393.283
-- EOF

-- cat <<EOF | curl --data-binary @- http://127.0.0.1:9091/metrics/job/Promtest/instance/North
--   # TYPE sensor_reading counter
--   sensor_reading{siteId="101", deviceId="1031", sensorId="10222"} 14
--   # TYPE sensorId gauge
--   sensorId{siteId="101", deviceId="1031", sensorId="10221"} 44
--   # TYPE another_metric gauge
--   # HELP another_metric Just an example.
--   another_metric{deviceId="1031", sensorId="10521"} 2397.283
-- EOF

-- cat <<EOF | curl --data-binary @- http://127.0.0.1:9091/metrics/job/Promtest/instance/North
--   # TYPE sensor_reading counter
--   sensor_reading{siteId="101", deviceId="1031", sensorId="10222"} 15
--   # TYPE sensorId gauge
--   sensorId{siteId="101", deviceId="1031", sensorId="10221"} 43
--   # TYPE another_metric gauge
--   # HELP another_metric Just an example.
--   another_metric{deviceId="1031", sensorId="10521"} 2395.283
-- EOF

-- cat <<EOF | curl --data-binary @- http://127.0.0.1:9091/metrics/job/Promtest/instance/North
--   # TYPE sensor_reading counter
--   sensor_reading{siteId="101", deviceId="1031", sensorId="10222"} 16
--   # TYPE sensorId gauge
--   sensorId{siteId="101", deviceId="1031", sensorId="10221"} 40
--   # TYPE another_metric gauge
--   # HELP another_metric Just an example.
--   another_metric{deviceId="1031", sensorId="10521"} 2394.283
-- EOF