#!/bin/sh

# The script to start the application.
MY_APP_FILE=/my-app/my-start-server.sh
printf "#!/bin/bash\n\n" >> $MY_APP_FILE
printf "export SS_ENV=\"single-node\"\n" >> $MY_APP_FILE
printf "export MY_ENV=\"dev\"\n" >> $MY_APP_FILE
printf "export SIMPLESERVER_CONFIG_FILE=\"resources/simpleserver.properties\"\n\n" >> $MY_APP_FILE
printf "java -jar app.jar\n\n" >> $MY_APP_FILE
sudo chmod u+x $MY_APP_FILE

# Create the simple server user to run the application.
adduser ssuser --no-create-home --shell /usr/sbin/nologin --disabled-password --gecos ""
# Change ownership of the application directory to ssuser.
sudo chown -R ssuser:ssuser /my-app

# Create the rc.local file to start the server.
MY_RC_LOCAL=/etc/rc.local
printf "#!/bin/bash\n\n" >> $MY_RC_LOCAL
printf "cd /my-app;sudo -u ssuser ./my-start-server.sh\n\n" >> $MY_RC_LOCAL
sudo chmod +x $MY_RC_LOCAL

# Finally reboot to start the server (using rc.local) in the next boot.
sudo reboot
