#!/bin/bash

SS_DIR=/mnt/edata/aw/kari/github/clojure/clj-ring-cljs-reagent-demo/simple-server

# TODO: Here also make the build first for the right profile.

rm -rf ./tmp
mkdir -p tmp/logs
cp $SS_DIR/target/uberjar/simple-server-1.0-standalone.jar tmp/app.jar
cp -r $SS_DIR/resources tmp/.
cp install/start-server.sh tmp/.
cd tmp
tar -zcvf ../app.tar.gz *
cd ..


