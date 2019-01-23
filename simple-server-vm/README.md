# Simple Server Azure VM / Scaleset Demonstration  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [Introduction](#introduction)
- [Azure Configurations for Terraform](#azure-configurations-for-terraform)
  - [Basic Azure Command Line Commands](#basic-azure-command-line-commands)
  - [Create the Azure Storage Account for Terraform Backend](#create-the-azure-storage-account-for-terraform-backend)
  - [Create an Azure Environmental Variables Export Bash Script](#create-an-azure-environmental-variables-export-bash-script)
- [Using Terraform to Create the Azure AKS Infrastructure](#using-terraform-to-create-the-azure-aks-infrastructure)
- [Azure Terraform Configuration](#azure-terraform-configuration)
  - [VNET](#vnet)
  - [Sclaleset](#sclaleset)
- [Virtual Machine Image](#virtual-machine-image)


# Introduction

There is a blog post regarding this project: [TODO](https://medium.com/@kari.marttila/TODO).

I created this Simple Server Azure VM / Scaleset to study how to create vnet, subnetss and related security (security groups), load balancers and how to create a golden image VM and deploy it to this Terraform project Scaleset.

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

There is an Azure Virtual network which has two subnets. A public management subnet with a bastion host which accepts ssh connections only from certain IP numbers (administrators) and requires a ssh private key for the connection. Only from the bastion host the administrators are able to connect to virtual machines in the private subnet. The private subnet hosts the Azure Scale set which hosts identical Virtual machines in which we have provisioned OpenJDK11 and the Simple Server Clojure Table Storage version. 

Clients are able to access the system only using the external load balancer. The external load balancer connects to the internal load balancer which distributes load to the virtual machines in the scale set. 

The virtual machines use the Table storage no-sql database tables as data store. The tables are located in an Azure Storage account.
  

## Scaleset

TODO.

## Table Storage Tables

TODO.

# Virtual Machine Image

TODO: Packer...

