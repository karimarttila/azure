#!/bin/bash

export SS_ENV="single-node"
export MY_ENV="dev"
export SIMPLESERVER_CONFIG_FILE="resources/simpleserver.properties"

echo $SS_ENV
echo $MY_ENV
echo $SIMPLESERVER_CONFIG_FILE
java -jar app.jar

#SIMPLESERVER_CONFIG_FILE=resources/simpleserver.properties;MY_ENV=dev;SS_ENV=single-node java -jar app.jar
