.DEFAULT_GOAL := help
include ../devlab0/.env

IMAGE_NAME=iot_datagen
VERSION=3.3

define HELP

Available commands:

- build: Build the Python IoT Datagen App

endef

export HELP
help:
	@echo "$$HELP"
.PHONY: help

build:
	docker build -t ${REPO_NAME}/${IMAGE_NAME}:${VERSION} .

