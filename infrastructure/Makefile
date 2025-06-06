.DEFAULT_GOAL := help

define HELP

Available commands:

- pullall: Pull all source images.
- buildall: Build all images.
- clean: Remove all *.gz files downloaded

- os: Docker Pull all source OS images.

- confluent: Pull all the Confluent Kafka source images.

- flink: Pull all the Apache Flink base image.

- db: Pull all our database images.

- S3: Pull our MinIO and MC console image.

- misc: Pull the additional images, acting as glue etc.


endef

export HELP
help:
	@echo "$$HELP"
.PHONY: help

pullall: os flink fluss db prometheus grafana pushgateway misc hadoop hive hdfs 

buildall: buildos buildopenjdk8 buildopenjdk11 buildhive buildflinkbase buildhdfs builddb


# Base images used along the way, used to build 2nd level images.
# arm64/v8 used as base for all images except the app/*.
os: 
	docker pull arm64v8/ubuntu:24.04
	
flink:
	docker pull flink:1.20.1-scala_2.12-java17

fluss:
	docker pull fluss/fluss:0.6.0

db:
	docker pull postgres:12	

prometheus:
	docker pull prom/prometheus:v3.3.0
grafana:
	docker pull grafana/grafana:11.6.1

misc:
	docker pull python:3.13-bookworm

# Base for hive server
hadoop:
	cd build-hive-openjdk8/basehadoop; mkdir stage; cd stage; wget https://downloads.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5-aarch64.tar.gz

hive:
# hive 3.1.3 is located in the Archive section now, to go on top of Hadoop 3.3.5
	cd build-hive-openjdk8/basehive; mkdir stage; cd  stage; wget https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
	cd build-hive-openjdk8/basehive; cd stage; wget https://downloads.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5-aarch64.tar.gz
	cd build-hive-openjdk8/basehive; cd stage; wget http://www.congiu.net/hive-json-serde/1.3.8/cdh5/json-serde-1.3.8-jar-with-dependencies.jar 
	cd build-hive-openjdk8/basehive; cd stage; wget https://jdbc.postgresql.org/download/postgresql-42.7.4.jar

# base for hdfs cluster
hdfs:
	cd build-hdfs-openjdk11/base/; mkdir stage; cd  stage; wget https://downloads.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5-aarch64.tar.gz


###### Build Section ######

# Build a base Ubuntu 20.04 OS
buildos:
	cd ./build-ubuntu-os-24.04; make build

# Add Open JDK 8 & 17
buildopenjdk8:
	cd ./build-ubuntu-os-openjdk8; make build

buildopenjdk11:
	cd build-ubuntu-os-openjdk11; make build

# Now add Hive 3.3.4 on the openjdk8 base
buildhive:
	cd build-hive-openjdk8; make build

# Base images with some add ons - Flink 1.20.1 - Java 17
buildflinkbase:
	cd build-flink-base-1.20.1; make build

buildhdfs:
	cd build-hdfs-openjdk11; make buildbase
	cd build-hdfs-openjdk11; make build

builddb:
	cd build-postgres-12.0; make build