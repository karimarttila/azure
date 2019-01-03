# Simple Server Azure AKS Demonstration  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [Introduction](#introduction)

# Introduction

This Simple Server Azure AKS project relates to my previous project [Azure Table Storage with Clojure](https://medium.com/@kari.marttila/azure-table-storage-with-clojure-12055e02985c) in which I implemented the Simple Server to use Azure Table Storage as the application database. The Simple Server Azure version is in my Github account: [Clojure Simple Server](https://github.com/karimarttila/clojure/tree/master/clj-ring-cljs-reagent-demo/simple-server).

In this new Simple Server Azure AKS project I created a Terraform deployment configuration for the Simple Server Azure version. There is also a Kubernetes deployment configuration in which you can test the Simple Server Docker container both in Minikube and in Azure AKS service.
 
So, the rationale of this project was mainly to learn how to use Terraform with Azure, how to create a Kubernetes deployment and use the Kubernetes deployment configuration with Minikube and Azure AKS. In the next project I create the deployment in the AWS side for EKS and Fargate.

 
# Basic Azure Command Line Commands

```bash
az login                                       # Login to Azure.
az account list --output table                 # List your Azure accounts.
az account set -s "<choose-the-account>"       # Set the Azure account you want to use.

```

# Azure Configurations for Terraform

Read the following documents before starting to use Terraform with Azure:

- [Install and configure Terraform to provision VMs and other infrastructure into Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)
 - [Store Terraform state in Azure Storage](https://docs.microsoft.com/en-us/azure/terraform/terraform-backend)
 

## Create the Azure Storage Account for Terraform Backend

Use script [create-azure-storage-account.sh](https://github.com/karimarttila/azure/blob/master/simple-server-aks/scripts/create-azure-storage-account.sh) to create an Azure Storage Account to be used for Terraform Backend. You need to supply for arguments for the script:

- The Azure location to be used.
- The resource group name for this exercise.
- The Storage account name for this exercise.
- The container name for the Terraform backend state (stored in the Storage account the script creates).

NOTE: You might want to use prefix "dev-" with your container name if you are going to store several Terraform environment backends in the same Azure Storage account.

## Create Service Principal for Use with Terraform

Create a service principal for Terraform:

```bash
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"
```

## Create an Azure Environmental Variables Export Bash Script

Create a bash script in which you export the environmental variables you need to work with this project. Store the file e.g. in ~/.azure (i.e. **DO NOT STORE THE FILE IN GIT** since you don't want these secrets to be in plain text in your Git repository!). Example:

#!/bin/bash

echo "Setting environment variables for Simple Server Azure AKS Terraform project."
export AZURE_STORAGE_ACCOUNT=<your-storage-account-name from storage account command result>
export AZURE_STORAGE_KEY=<your-storage-account-key from storage account command result>
export ARM_ACCESS_KEY=<your-storage-account-name from storage account command result>
export ARM_SUBSCRIPTION_ID=<your-subscription-id>
export ARM_CLIENT_ID=<app-id from service principal command result>
export ARM_CLIENT_SECRET=<secret from Service Principal command result>
export ARM_TENANT_ID=<tenant id from Service Principal command result>

(NOTE: Terraform requires the account key in environmental variable "ARM_ACCESS_KEY", I have used AZURE_STORAGE_KEY in some other scripts that's why I have the value twice).

You can then source the file using bash command:
 
 ```bash
source ~/.azure/your-bash-file.sh
```

Just to remind myself that I created file with name "kari-aks-demo.sh" for this project. So, I source it like:

 ```bash
source ~/.azure/kari-aks-demo.sh
```


# Using Terraform to Create the Azure AKS Infrastructure

Go to terraform directory. Give commands:

```bash
terraform init    # => Initializes Terraform, gets modules...
terraform plan    # => Shows the plan (what is going to be created...)
terraform apply   # => Apply changes
```



