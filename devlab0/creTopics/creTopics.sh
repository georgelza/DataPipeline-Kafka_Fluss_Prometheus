#!/bin/bash

export COMPOSE_PROJECT_NAME=pipeline

# Retension is set to 1 day below
docker compose exec broker kafka-topics \
 --create -topic factory_iot_north \
 --bootstrap-server localhost:9092 \
 --partitions 1 \
 --replication-factor 1 \
 --if-not-exists \
 --retention.ms 86400000

docker compose exec broker kafka-topics \
 --create -topic factory_iot_south \
 --bootstrap-server localhost:9092 \
 --partitions 1 \
 --replication-factor 1 \
 --if-not-exists \
 --retention.ms 86400000

 docker compose exec broker kafka-topics \
 --create -topic factory_iot_east \
 --bootstrap-server localhost:9092 \
 --partitions 1 \
 --replication-factor 1 \
 --if-not-exists \
 --retention.ms 86400000


# Lets list topics, excluding the default Confluent Platform topics
docker compose exec broker kafka-topics \
 --bootstrap-server localhost:9092 \
 --list | grep -v '_confluent' |grep -v '__' |grep -v '_schemas' | grep -v 'default' | grep -v 'docker-connect'

