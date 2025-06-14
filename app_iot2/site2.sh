#!/bin/bash

. ./.pws


# Do we want to run the historic loop.
export RUNHISTORIC=0

### Confluent Cloud Cluster  -> see .pws
export KAFKA_TOPIC_NAME=factory_iot_south
export KAFKA_MODE=1
export KAFKA_BATCH_SIZE=1000


# Debug Levels:
# 0 Debug       -> Allot of information will be printed, including printing site configuration to logfile.
# 1 Info        -> We just printing that processes is starting/ending
# 2 Warning     -> Will decide
# 3 Error       -> used in any try/except block
# 4 Critical    -> used when we going to kill the programm.

# Console Handler
export CONSOLE_DEBUGLEVEL=0
# File Handler
export FILE_DEBUGLEVEL=0

# Irrespective of debug level, lets control if we want to echo the entire seedfile or not.
export ECHOSEEDFILE=0
export SEEDFILE=conf/Full.json
export SITEIDS=102,105

# Data persistance will be controlled per site, using:
# sites["data_persistence"]
# 0 - no persist
# 1 - File based -> NOTE, if site is configured with file_debuglevel = 0, then it will be saved to logfile also.
# 2 - MongoDB Atlas

# If 1 => Specify Filename, we will add the date/time to filename to make it unique.
# If 2 -> Specify Mongo connection information in environment variables, or currently we do this via the .pwd file (listed in .gitignore)

export LOGDIR=logs
export LOGGINGFILE=logger_south

# TSHUMAN adds when 1 a human readable timestamp to the metadata sub tag
# STRUCMOD adds when 1 a location base on longitude and latitude to the metadata sub tag
# DEVICETYPE adds the deviceType value from the device definision from the full.json file

export TSHUMAN=1
export STRUCTMOD=1
export DEVICETYPE=0

python3 ../app_iot1/main.py
