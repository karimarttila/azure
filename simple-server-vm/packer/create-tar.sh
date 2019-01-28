#!/bin/bash

# NOTE: This was a preliminary idea to bake the startup script for the table storage as well
# but when creating this script I realized that we don't know the ENDPOINT and AZURE_CONNECTION_STRING
# environment variables at this point (we know them only when deploying the VM image to Scale set
# - therefore we have to inject this startup script at that point or at least inject those two
# environment variables to VM at that point.

SS_DIR=/mnt/edata/aw/kari/github/clojure/clj-ring-cljs-reagent-demo/simple-server

echo "Starting to build the distributable for the Azure VM..."
echo "Cleaning tmp directory..."
rm -rf ./tmp
mkdir -p tmp/logs
echo "Copying app jar and resources..."
cp $SS_DIR/target/uberjar/simple-server-1.0-standalone.jar tmp/app.jar
cp -r $SS_DIR/resources tmp/.
cd tmp
echo "Tarring distributable..."
tar -zcvf ../app.tar.gz *
cd ..
echo "Distributable: app.tar.gz is ready"

