#!/bin/bash

export MY_ENV="dev"
export SIMPLESERVER_CONFIG_FILE="resources/simpleserver.properties"

echo $SS_ENV
echo $MY_ENV
echo $SIMPLESERVER_CONFIG_FILE
java -jar app.jar

