# Simple Server Azure VM / Scale Set Demonstration  <!-- omit in toc -->

# Table of Contents  <!-- omit in toc -->
- [Introduction](#introduction)
- [Azure Configurations for Terraform](#azure-configurations-for-terraform)
  - [Basic Azure Command Line Commands](#basic-azure-command-line-commands)
  - [Create the Azure Storage Account for Terraform Backend](#create-the-azure-storage-account-for-terraform-backend)
  - [Create an Azure Environmental Variables Export Bash Script](#create-an-azure-environmental-variables-export-bash-script)
- [Using Terraform to Create the Azure AKS Infrastructure](#using-terraform-to-create-the-azure-aks-infrastructure)
- [Azure Terraform Configuration](#azure-terraform-configuration)
  - [Virtual Network Topology](#virtual-network-topology)
  - [Scale set](#scale-set)
    - [Testing the Scale set](#testing-the-scale-set)
  - [Storage Account](#storage-account)
  - [Load Balancer](#load-balancer)
  - [Table Storage Tables](#table-storage-tables)
- [Virtual Machine Image](#virtual-machine-image)
  - [Service Principal for Creating Azure VM Images](#service-principal-for-creating-azure-vm-images)
  - [Creating the Image](#creating-the-image)
  - [Starting Application on Boot](#starting-application-on-boot)
- [Miscellaneous](#miscellaneous)
  - [Azure VM Instance Metadata](#azure-vm-instance-metadata)


**NOTE: WORK IN PROGRESS!!!**
I'll finalize the documentation once the actual exercise is done.


# Introduction

I don't recommend reading this README.md file as is since this Azure VM and Scale set exercise was just a quick personal exercise to explore how it is to create a custom Azure Linux VM image and use it in an Azure Scale set. I have documented all kinds of stuff (also failed experiments) in this README.md file and it is not therefore that readable. If you want to read a more reader friendly version there are two blog posts regarding this project:
 
- [Creating Azure Custom Linux VM Image](https://medium.com/@kari.marttila/creating-azure-custom-linux-vm-image-46f2a15c95bc).
- [Creating Azure Scale Set](TODO)

I created this Simple Server Azure VM / Scaleset to study how to create vnet, subnets and related security (security groups), load balancers and how to create a golden image VM and deploy it to this Terraform project Scaleset.

I used my Simple Server Table Storage version (see [Azure Table Storage with Clojure](https://medium.com/@kari.marttila/azure-table-storage-with-clojure-12055e02985c)) as the VM image that is created using [Packer](TODO)
 
 
# Azure Configurations for Terraform

Read the following documents before starting to use Terraform with Azure:

- [Install and configure Terraform to provision VMs and other infrastructure into Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)
 - [Store Terraform state in Azure Storage](https://docs.microsoft.com/en-us/azure/terraform/terraform-backend)
 - [Terraform Azure Provider](https://www.terraform.io/docs/providers/azurerm/)

You need to download and install Azure and Terraform command line tools, of course.


## Basic Azure Command Line Commands

```bash
az login                                       # Login to Azure.
az account list --output table                 # List your Azure accounts.
az account set -s "<choose-the-account>"       # Set the Azure account you want to use.
```
 

## Create the Azure Storage Account for Terraform Backend

Use script [create-azure-storage-account.sh](TODO) to create an Azure Storage Account to be used for Terraform Backend. You need to supply for arguments for the script:

- The Azure location to be used.
- The resource group name for this exercise.
- The Storage account name for this exercise.
- The container name for the Terraform backend state (stored in the Storage account the script creates).

NOTE: You might want to use prefix "dev-" with your container name if you are going to store several Terraform environment backends in the same Azure Storage account.


## Create an Azure Environmental Variables Export Bash Script

Create a bash script in which you export the environmental variables you need to work with this project. Store the file e.g. in ~/.azure (i.e. **DO NOT STORE THE FILE IN GIT** since you don't want these secrets to be in plain text in your Git repository!). Example:

```bash
#!/bin/bash
echo "Setting environment variables for Simple Server Azure AKS Terraform project."
export ARM_ACCESS_KEY=your-storage-account-name from storage account command result
```

You can then source the file using bash command:

```bash
source ~/.azure/your-bash-file.sh
```

Just to remind myself that I created file with name "kari-ss-vm-demo.sh" for this project. So, I source it like:

```bash
source ~/.azure/kari-ss-vm-demo.sh
```

# Using Terraform to Create the Azure AKS Infrastructure

Go to terraform directory. Give commands:

```bash
terraform init    # => Initializes Terraform, gets modules...
terraform plan    # => Shows the plan (what is going to be created...)
terraform apply   # => Apply changes
```

**NOTE**: Terraform apply may fail the first time. Most probably this is caused because some AD app or Service principal resource is not ready. Wait a couple of minutes and run terraform plan/apply again - the second time terraform should be able to create all resources succesfully. 

# Azure Terraform Configuration

## Virtual Network Topology

The virtual network topology is depicted in the diagram below.

![Simple Server VM Scaleset Network Topology](diagrams/azure-simple-server-vm-vnet-topology.png?raw=true "Simple Server VM Scaleset Network Topology")

There is an **Azure Virtual network (vnet)** which has two subnets. A **public management subnet** with a bastion host which accepts ssh connections only from certain IP numbers (administrators) and requires a ssh private key for the connection. Only from the bastion host the administrators are able to connect to virtual machines in the private subnet. The **private scaleset subnet** hosts the Azure Scale set which hosts identical Virtual machines in which we have provisioned OpenJDK11 and the Simple Server Clojure Table Storage version. The Azure Scale set uses the **custom VM image** in which I have provisioned OpenJDK10 and the Simple Server (see chapter "Virtual Machine Image").

Clients are able to access the system only using the **external load balancer**. The external load balancer connects to the **internal load balancer** which distributes load to the virtual machines in the scale set. 

The virtual machines use the **Table storage** no-sql database tables as data store. The tables are located in an **Azure Storage account**.


## Scale set

I followed Microsoft documentation [Use Terraform to create an Azure virtual machine scale set](https://docs.microsoft.com/en-us/azure/terraform/terraform-create-vm-scaleset-network-disks-hcl) and [Use Terraform to create an Azure virtual machine scale set from a Packer custom image](https://docs.microsoft.com/en-us/azure/terraform/terraform-create-vm-scaleset-network-disks-using-packer-hcl). The code is in [scale-set](TODO) Terraform module.

I define the environment dependent scaleset variables in the [dev.tf](TODO) file:

```hcl-terraform
locals {
  ...
  vm_ssh_public_key_file = "/mnt/edata/aw/kari/github/azure/simple-server-vm/personal-info/vm_id_rsa.pub"
  application_port       = "3045"
  # NOTE: The custom image must have been created by Packer previously.
  scaleset_image_name    = "karissvmdemo-v1-image-vm"
  scaleset_capacity      = "2"
  # This way you can inject the environment variables regarding Simple Server mode
  # at the point we actually create the VM.
  scaleset_vm_custom_data_file = "/mnt/edata/aw/kari/github/azure/simple-server-vm/packer/cloud-init-set-env-mode-single-node.sh"
```

So, here you should give the Virtual Machine image name that was previously created using Packer (see chapter "Virtual Machine Image") and also inject the custom data file which comprises the cloud-init configuration (see chapter "Starting Application on Boot").

### Testing the Scale set 

Testing the Scale set and later the Scale set with running the app with azure-table-storage mode hitting the Storage account Tables turned out to be a real pain in the ass. More about it in this and the next chapter.

When I had finalized the VM image configurations and successfully tested the image by creating a test virtual machine using that image (using Azure command line). I uncommented the Scale set module in the env-def.tf, supplied the name of the VM image in dev.tf and the cloud-init file for the single-node test version of the server, and ran 'terraform init' and 'terraform apply'. When the deployment was ready I checked the dns name of the load balancer of the new scale set and curled the API - the LB swiftly replied to my request. Just to make sure the single-node version worked just fine I ran my poor man's Robot framework simulator  ./call-all-ip-port.sh LB-DNS 3045 => worked just fine. So, at least the basic setup was working nicely. 

Next I commented the scale set and ran terraform apply to remove the scale set. Then I changed the Azure table storage cloud init version (not in the Github since the Storage account connection string is in that file (in real world project the connection string would be stored in the Azure Key Vault, of course) to be injected with the image when creating the new virtual machine (i.e. start the Simple Server with Azure table storage mode) and ran terraform init and terraform apply.

Then testing the azure-table-storage version. The curl for /info worked just fine (does not hit the database). But all APIs that hit the database failed. Ok, obviously something wrong with the database connection. :-)   This was actually a good thing since I had to figure out how to get a shh connection to a VM in a Scale set. Then I realized that I don't actually need to go to the scale set vm. I can create a test vm using that image, set the azure-table-storage mode and connection string there and debug the problem regarding the database connection. I did that. I created a test VM, ssh'd inside and curled inside the VM one API that I knew that will hit the database, then checked the logs, then in the Clojure server source code followed the trace to the function that failed and immediately saw the problem: I had hardcoded the table name prefix (since the aks exercise was the only Azure exercise that far). I fixed the issue, build the app, build a new VM image and tried again. 
 
BTW. This is actually also an interesting best practice that I didn't realize I have been doing for many years. If you implement a server, implement into the same server two modes: One test mode which has no external dependencies but simulates e.g. database and external connections locally, and one mode for the real thing (real connections to the database...). This way you can test e.g. scaling isolated from the external connections (using the test mode). It's always a lot faster to test things in isolation than to start setting database, db tables, uploading real-look-like test data... before you can test something like scaling which has nothing to do with the database connections.

BTW. I really love terraform in testing situations like this. When you have a modular terraform configuration it is pretty easy to uncomment certain terraform module and delete all resources in that module, and make a new infra deployment with different parameters to test something (like above the server mode which is given by the cloud-init configuration).

BTW. It's pretty easy to change image using terraform. First set the scale set capacity to 0 - this effectively deletes the old virtual machines. Then just set the new image name and new capacity in terraform configuration, init + apply and you get the the virtual machines up using the new image.

## Storage Account

The storage account hosts the Simple Server database - 4 storage tables.

After that prefix fix I still couldn't connect from the VM to the table storage account with the right connection string. I first thought that I need to give some access right for the VM to access the storage account, see more details in Microsoft documentation: [Tutorial: Use a Windows VM system-assigned managed identity to access Azure Storage](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/tutorial-vm-windows-access-storage) and [Configure managed identities for Azure resources on a VM using the Azure portal](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/qs-configure-portal-windows-vm), [Configure Azure Storage firewalls and virtual networks](https://docs.microsoft.com/en-us/azure/storage/common/storage-network-security).

But before hassling too much I wanted to make a test. I copied my Python data-importer to that VM machine and tried to use it for importing some test data to productgroups table - ran smoothly with the same connection string. Ok, now I verified that I actually don't need to make any special role for VM and give that role access right to the storage account. (But actually in a real production system you should not expose the storage account to internet but only to your VMs, e.g. with some NSG and this kind of role based access). So, the issue was somewhere in the Clojure application. I had verified of course that the Clojure app works with that connection string in my local workstation. 

Ok, now I knew that there is nothing wrong with the VM itself to connect to the storage account. Next I tarred my whole app development env, copied to that VM and untarred it there and ran the unit tests - it worked: wtf? The same application worked in one situation (running unit tests) but not in another (running as server). So, there is something different between those situations. Debugging is often detective work like this, you have certain hypothesis and you need to logically and systematically make your problem space smaller and smaller until you have found the culprit. 

Ok, I finally found the culprit. I had forgotten the new 'AZURE_TABLE_PREFIX' environment variable that I added to make the Azure version of Simple Server generic (to run in any environment and using environment prefix that is found also in the tables). I ran my ./call-all-ip-port.sh using this test server and everything worked just fine. 

Next I dropped scale set capacity again to zero to terminate the old VMs in the scale set, then raised the capacity to 2 again to create two new VMs, this time using the new cloud-init script for the azure-table-storage version in which I fixed the missing AZURE_TABLE_PREFIX environment variable. Again I ran my ./call-all-ip-port.sh using the load balancer of this scale set and everything worked fine: Yihaa, finally! (I even changed the price of "Once Upon a Time in the West" to $9999 using the Storage Account Storage Explorer (in Portal, in preview when writing this) so that I would be certain that the app is hitting the Tables in the Storage account and not using the internal DB). 

Actually, this debugging session was a nice exercise. What I learned here:

- Always implement good logging to your servers.
- Python is a handy tool to test connections (you quickly implement a small application that should access resources...).
- Do not try to debug a VM in a Scale set - create a test VM and debug there.


## Load Balancer

The scale-set.tf file defines also the load balancer for the Scale set. You can go to portal and click the public ip entity with the load balancer name - you get the dns that Azure created for that load balancer. You can use that dns to curl the service in port 3045. Load balancer forwards the request to some VM in the Scale set.


## Table Storage Tables

The Tables are created in the terraform "storage-tables" module. I could have created a terraform module to create a Table and then use it four times in the "storage-tables" module but since the tables are small entities I just added them here inline.



# Virtual Machine Image

## Service Principal for Creating Azure VM Images

Use script:

```bash
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
# =>
#  "client_id": "111111111111111",
#  "client_secret": "1111111111111111111",
#  "tenant_id": "ccccccccccccccccc"
```

You get the service principal credentials, copy-paste them to your ~/.azure/<environmen-settings.sh> to be sourced later.


## Creating the Image

I considered using Packer and instruction [How to use Packer to create Linux virtual machine images in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer) to create an Ubuntu 18 virtual image to Azure. My first idea was to install all needed software (OpenJDK...) using Packer and then upload the application tar.gz using Packer File provisioner and untar the file in the preliminary Packer VM which then Packer would convert into an Azure VM image which I could start using cloud-init script (to start the Simple Server). This turned out not to be an easy task. The main thing that really pissed me off with hassling these virtual images was how slow the development cycle was - creating the virtual image takes ....... a long time compared to creating a Docker image. And if the image building fails at the end of the process you have to start over and again wait ....... a long time. 

For some reason I couldn't upload the Clojure application tar which is pretty big file, some 100MB (standalone distributable: Clojure library + embedded Tomcat...). Then I realized another solution. Why don't I use procedure instead:
1. Create the base VM image using Packer (install OpenJDK etc. but don't upload the app.tar.gz).
2. Upload the big app.tar.gz file to Azure Storage Blob.
3. Boot up another VM using this base VM image (created in step #1) and download the app.tar.gz from Azure Storage Blog, untar the file, => and create another image from this VM instance!
4. Use cloud-init script to start the actual VM from the image created in step #3. 

Let's see if this procedure works. If not, then I think I just create a VM image by hand (use the VM image created in step #1, manually scp the app.tag.gz there, untar...), manually create a VM image from this instance and use this instance in the rest of this exercise using the VM image in Azure Scale set... so, the idea is not to get stuck in this VM building process but to continue to the Azure VM Scale set infra and let's consider that we figure out later on some clever way to automate the VM image building.

Let's first demonstrate using Packer:


```text
./create-vm-image.sh karissvmdemo9tartest karissvmdemo1-dev-main-rg
... a lot of stuff... when packer starts a temporary VM, starts provisioning etc.
... finally Packer captures the image of the provisioned VM and starts to delete 
... the temporary resource group with temporary VM and other related stuff.... 
==> azure-arm: Capturing image ...
==> azure-arm:  -> Compute ResourceGroupName : 'packer-Resource-Group-xrul56mhm9'
...
==> azure-arm: Deleting resource group ...
==> azure-arm:  -> ResourceGroupName : 'packer-Resource-Group-xrul56mhm9'
==> azure-arm: 
==> azure-arm: The resource group was created by Packer, deleting ...
==> azure-arm: Deleting the temporary OS disk ...
==> azure-arm:  -> OS Disk : skipping, managed disk was used...
==> azure-arm: Deleting the temporary Additional disk ...
==> azure-arm:  -> Additional Disk : skipping, managed disk was used...
Build 'azure-arm' finished.
==> Builds finished. The artifacts of successful builds are:
--> azure-arm: Azure.ResourceManagement.VMImage:
OSType: Linux
ManagedImageResourceGroupName: karissvmdemo1-dev-main-rg
ManagedImageName: karissvmdemo9tartest-vm
ManagedImageId: /subscriptions/111111111111111111/resourceGroups/karissvmdemo1-dev-main-rg/providers/Microsoft.Compute/images/karissvmdemo9tartest-vm
ManagedImageLocation: westeurope
```

(Changed the subscription id to "1111111111111" in the listing above, of course).

Then you can create a Virtual Machine using this image:

```bash
az vm create --resource-group karissvmdemo1-dev-main-rg --name start9-test1 --image karissvmdemo9tartest-vm --custom-data testing_init.sh --ssh-key-value @vm_id_rsa.pub --vnet-name karissvmdemo1-dev-vnet --subnet karissvmdemo1-dev-private-scaleset-subnet --admin-username ubuntu --location westeurope
```

First you have to generate ssh keys, inject the public key to the new VM as above.

Open the ssh port (22) to this machine in the <prefix>-dev-private-scaleset-subnet's network security group (I didn't add this rule to the Terraform infra since my IP number is a bit sensitive information).

You get a result:

```json
{
  "fqdns": "",
  "id": "/subscriptions/11111111111111/resourceGroups/karissvmdemo1-dev-main-rg/providers/Microsoft.Compute/virtualMachines/start10-test1",
  "location": "westeurope",
  "macAddress": "11-11-11-11-11-11",
  "powerState": "VM running",
  "privateIpAddress": "10.0.1.8",
  "publicIpAddress": "11.11.11.11",
  "resourceGroup": "karissvmdemo1-dev-main-rg",
  "zones": ""
}
```

(Changed all sensitive information using ones ("1").)

Logon to the VM:
```bash
ssh -i vm_id_rsa ubuntu@11.11.11.11
~$ java -version
openjdk version "10.0.2" 2018-07-17
OpenJDK Runtime Environment (build 10.0.2+13-Ubuntu-1ubuntu0.18.04.4)
OpenJDK 64-Bit Server VM (build 10.0.2+13-Ubuntu-1ubuntu0.18.04.4, mixed mode)
```

(Use the real IP, not my dummy "11.11.11.11", of course.)
Ok, so I managed to create at least a base image which has OpenJDK10, Emacs and Ansible. And if the app.tar.gz application binary is not uploading I can try my second option later (create another image from this base image - use Packer to boot a temporary VM from this base image, fetch the app.tar.gz from Azure Storage blob, provision the software (untar) and then Packer creates the final VM image with provisioned appliction which can be used to create the actual VMs for the Scale set.)

But, yihaa! While writing this I finally managed to upload the actual binary app.tar.gz just using Packer in the base image! And upload was actually amazingly fast. I just had screwed the previous Packer configuration. I'll now push this Packer configuration to my Github.

I started the VM, logged on to the machine, cd /my-app, started the script: './start-server.sh', watched logs flowing everything was nice. I then open the port 3045 for my machine in the private subnet into which I deployed the VM, and curled the app with the public ip of the VM: curl http://11.11.11.11:3045/info (changed again ip to ones): but, nothing happened. I investigated this a bit until I realized that the VM itself also had a network security group (NSG) attached to itself. I opened port 3045 to my machine also in this NSG, curled: yihaa! It worked! Damn, it was beautiful to see all APIs returning the right test data.


**One final NOTE regarding Packer and Azure VM building**: There is a bug in Packer 1.3.3, you have to use Packer 1.3.2, see [Github comment](https://github.com/MicrosoftDocs/azure-docs/issues/21944#issuecomment-452597596).

See [packer](https://github.com/karimarttila/azure/tree/master/simple-server-vm/packer) directory for the scripts I used for building the VM.


## Starting Application on Boot

I provisioned into the image a default 'start-server.sh' script (actually not used, I found later a better way):

```bash
#!/bin/bash
export SS_ENV="single-node"
export MY_ENV="dev"
export SIMPLESERVER_CONFIG_FILE="resources/simpleserver.properties"
echo $SS_ENV
echo $MY_ENV
echo $SIMPLESERVER_CONFIG_FILE
java -jar app.jar
```

This start script is just for testing purposes (no dependencies to real databases). The actual environment variables and server start command should be provided by some mechanism.

I googled this startup mechanism a bit and there are a few alternatives:

- Bake the startup mechanism into the VM image using Ansible.
- Cloud-init (as described in [Cloud-init support for virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init)).
 
If you develop the **Ansible script** when creating the VM image the development cycle is way too long (since creating the VM image takes a lot time). A better process is this:

1. Create a Linux server from the VM image.
2. Create the application user and rc.local scripts etc. to start the application on boot using the application user.
3. Try to boot the VM and see that the application starts.
4. Create another VM for testing Ansible.
5. In VM 2 create Ansible script that provisions the user and application as you did manually with VM 1. 
6. Try to boot VM 2 and see that application starts.
7. Integrate the ansible script to Packer process to create an image which has the user and application in rc.local.
8. Create VM using this image - check that the application started.
9. Try to re-boot the VM - check that the application started.

**Cloud-init** would be nice if I could export the environment variables in the cloud-init script (e.g. SS_ENV=single-node or SS_ENV=azure-table-storage...). This way I could create only one image (which is pretty time consuming) and use this custom image to create a test VM (using single-node version, as in the example above), or in the cloud-init set real Azure Table storage connection string for using the Simple Server in the real Azure mode. But I somehow understood that you should mainly use cloud-init to provision stuff and not use it to start servers etc. 

Actually this could be a nice way to do it:

1. Use ansible to create the user and rc.local startup script.
2. Use cloud-init to set the environment variables - should be done once in early boot process before rc.local.

Let's try that first manually. Let's create a VM manually which starts the application. And then manually create an image of that VM. Then try to create a new VM on that image and inject the environment variables using cloud-init: try both single-node and azure-table-storage (remember to upload the test data to Table storage first).

Note regarding security. This is just an exercise so we can do the environment variables reading a bit more relaxed manner. But in real production system we should store the Azure Storage Account connection string in the Azure Key Vault and somehow authorize the VM to read the connection string from the Key Vault. Maybe I try this a bit later.

I created two cloud-init scripts: 'cloud-init-set-env-mode-single-node.sh' and 'cloud-init-set-env-mode-azure-table-storage.sh'. The first one is in the packer directory, the second one is in my personal-data directory which is not part of this git repository (sensitive information - the Azure storage account connection string). In real production system we should read the connection string from the Azure Key Vault, of course, but this is an exercise and I wanted to focus on the VM and Scale set side, let's examine the Key vault in some following exercise.

The script is pretty simple:

```bash
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
```

So. First we create the application startup script and export the environment variables for this mode. Then we create a new ssuser to run the application, change ownership of the application directory to this user. Then we create a rc.local file in which we set the environment variables and start the application as the ssuser.

Next testing to create a new VM and the cloud-init configures the application startup.

```bash
az vm create --resource-group karissvmdemo2-dev-main-rg --name karissvmdemo2-inittest-vm --image karissvmdemo-v1-image-vm --custom-data ../packer/cloud-init-set-env-mode-single-node.sh --ssh-key-value @vm_id_rsa.pub --vnet-name karissvmdemo2-dev-vnet --subnet karissvmdemo2-dev-private-scaleset-subnet --admin-username ubuntu --location westeurope
```

ssh to server and test that the application is running:
```bash
ps aux | grep java
# => ssuser    ...  java -jar app.jar
sudo systemctl status rc-local
# => rc-local.service - /etc/rc.local Compatibility ... Active: activating (start) since Mon 2019-01-28 18:14:52 UTC; 27min ago
...
```

Ok. We now have a mechanism to start the server in the mode we wish. 

Let's next try this server in the Azure Scale set.




# Miscellaneous

## Azure VM Instance Metadata

curl -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-08-01"



