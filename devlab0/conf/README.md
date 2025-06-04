## Configuration files.

Various confguratin files either push/mounted to a target file inside containers (utilising configs primitive) or pushed into environment variables inside containers.

1. config.yaml              -   Flink JobManager and TaskManager configuration settings, This file replaces flink-conf.yaml

2. hive-site.xml            -   Minio settings for Hive to use.

3. hive.env                 -   Various Hive Metastore settings pulled into various configuration files.

4. log4j-*.properties       -   Log4J logging configuration files

5. pg_hba.conf              -   PostgreSql

6. postgresql.conf          -   PostgreSql

7. flink                    -   Flink/lib jar files

8. HDFS                     -   HDFS Cluster

9. Hadoop.env               -   Hadoop settings.

10. Confluent Kafka         -   Kafka Cluster

