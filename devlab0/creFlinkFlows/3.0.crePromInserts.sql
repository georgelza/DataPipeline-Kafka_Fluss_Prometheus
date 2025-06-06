
SET 'parallelism.default'    = '2';
SET 'sql-client.verbose'     = 'true';
SET 'execution.runtime-mode' = 'streaming';


INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 40, TIMESTAMP '2025-06-06 10:20:05.000');
INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 45, TIMESTAMP '2025-06-06 10:21:25.000');
INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 48, TIMESTAMP '2025-06-06 10:22:55.000');
INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 45, TIMESTAMP '2025-06-06 10:23:10.000');
INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 50, TIMESTAMP '2025-06-06 10:24:30.000');
INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 55, TIMESTAMP '2025-06-06 10:25:55.000');
INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 58, TIMESTAMP '2025-06-06 10:26:25.000');
INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 65, TIMESTAMP '2025-06-06 10:27:00.000');
INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 60, TIMESTAMP '2025-06-06 10:28:10.000');
INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 65, TIMESTAMP '2025-06-06 10:29:50.000');
INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 70, TIMESTAMP '2025-06-06 10:30:20.000');
INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 75, TIMESTAMP '2025-06-06 10:31:30.000');
INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 80, TIMESTAMP '2025-06-06 10:32:40.000');
INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 75, TIMESTAMP '2025-06-06 10:33:50.000');
INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 70, TIMESTAMP '2025-06-06 10:34:56.000');
INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 65, TIMESTAMP '2025-06-06 10:35:40.000');

-- INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 60, TIMESTAMP '2025-06-06 10:16:40.000');
-- INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 50, TIMESTAMP '2025-06-06 10:17:10.000');
-- INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 45, TIMESTAMP '2025-06-06 10:18:10.000');
-- INSERT INTO hive_catalog.prometheus.Promtest VALUES ('test_readings', 10222, 101, 1031, 40, TIMESTAMP '2025-06-06 10:19:10.000');
