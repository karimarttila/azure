#!/bin/bash

# Just quickly testing that we can create a VM using the image and cloud-init works and we have rc.local which starts the application automatically.

cd ../personal-info

az vm create --resource-group karissvmdemo2-dev-main-rg --name karissvmdemo2-inittest3-vm --image karissvmdemo-v1-image-vm --custom-data ../packer/cloud-init-set-env-mode-single-node.sh --ssh-key-value @vm_id_rsa.pub --vnet-name karissvmdemo2-dev-vnet --subnet karissvmdemo2-dev-private-scaleset-subnet --admin-username ubuntu --location westeurope
