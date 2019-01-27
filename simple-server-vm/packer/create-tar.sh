#!/bin/bash

# NOTE: This was a preliminary idea to bake the startup script for the table storage as well
# but when creating this script I realized that we don't know the ENDPOINT and AZURE_CONNECTION_STRING
# environment variables at this point (we know them only when deploying the VM image to Scale set
# - therefore we have to inject this startup script at that point or at least inject those two
# environment variables to VM at that point.

SS_DIR=/mnt/edata/aw/kari/github/clojure/clj-ring-cljs-reagent-demo/simple-server
TABLE_STORAGE_MODE_FILE="tmp/start-server-table-storage-mode.sh"

function create-table-storage-mode-file {
  echo "Creating table storage file"
  printf "#!/bin/bash\n\n" > $TABLE_STORAGE_MODE_FILE
  printf "export SS_ENV=\"azure-table-storage\"\n" >> $TABLE_STORAGE_MODE_FILE
  printf "export MY_ENV=\"dev\"\n" >> $TABLE_STORAGE_MODE_FILE
  printf "export SIMPLESERVER_CONFIG_FILE=\"resources/simpleserver.properties\"\n\n" >> $TABLE_STORAGE_MODE_FILE
  printf "echo \$SS_ENV\n" >> $TABLE_STORAGE_MODE_FILE
  printf "echo \$MY_ENV\n" >> $TABLE_STORAGE_MODE_FILE
  printf "echo \$SIMPLESERVER_CONFIG_FILE\n" >> $TABLE_STORAGE_MODE_FILE
  printf "echo *** NOTE***: You also need two other environment variables:\n" >> $TABLE_STORAGE_MODE_FILE
  printf "echo ENDPOINT and AZURE_CONNECTION_STRING\n\n" >> $TABLE_STORAGE_MODE_FILE
  printf "java -jar app.jar\n\n" >> $TABLE_STORAGE_MODE_FILE
  chmod u+x $TABLE_STORAGE_MODE_FILE
}

echo "Starting to build the distributable for the Azure VM..."
echo "Cleaning tmp directory..."
rm -rf ./tmp
mkdir -p tmp/logs
echo "Copying app jar and resources..."
cp $SS_DIR/target/uberjar/simple-server-1.0-standalone.jar tmp/app.jar
cp -r $SS_DIR/resources tmp/.
echo "Copying start server scripts..."
cp install/start-server-single-node-mode.sh tmp/.
cp install/start-server.sh tmp/.
create-table-storage-mode-file
cd tmp
echo "Tarring distributable..."
tar -zcvf ../app.tar.gz *
cd ..
echo "Distributable: app.tar.gz is ready"

