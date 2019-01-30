#!/bin/sh

# NOTE: This is a template file! You need to provide the AZURE_CONNECTION_STRING string to your Account storage here.
# (In real production system we should store all secrets in the Azure Key Vault, of course.)
# My real cloud-init-set-env-mode-azure-table-storage.sh file is in the personal-info folder which is not part of this Git repo.

# For some reason I couldn't make the script work in VM if exporting the environment variables in the main script.
# Therefore this set-env.sh script.

MY_SETENV_FILE=/my-app/my-set-env.sh
printf "#!/bin/bash\n\n" >> $MY_SETENV_FILE
printf "export SS_ENV=\"azure-table-storage\"\n" >> $MY_SETENV_FILE
printf "export MY_ENV=\"dev\"\n" >> $MY_SETENV_FILE
printf "# NOTE: You have to use the prefix that is in your terraform env!\n\n" >> $MY_APP_FILE
printf "export AZURE_TABLE_PREFIX=\"karissvmdemo3\"\n" >> $MY_SETENV_FILE
printf "# NOTE: You have to use the connection string that this env uses!\n\n" >> $MY_APP_FILE
printf "export AZURE_CONNECTION_STRING=\"YOUR-CONNECTION-STRING-HERE\"\n" >> $MY_SETENV_FILE
printf "export SIMPLESERVER_CONFIG_FILE=\"resources/simpleserver.properties\"\n\n" >> $MY_SETENV_FILE

sudo chmod u+x $MY_SETENV_FILE

# The script to start the application.
MY_APP_FILE=/my-app/my-start-server.sh
printf "#!/bin/bash\n\n" >> $MY_APP_FILE
printf "source ./my-set-env.sh\n\n" >> $MY_APP_FILE
printf "# NOTE: You can debug in production by switching dev/prod logging configuration.\n\n" >> $MY_APP_FILE
printf "java -Dlogback.configurationFile=resources/logconfig/dev/logback.xml -jar app.jar\n\n" >> $MY_APP_FILE

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
