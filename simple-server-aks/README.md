# Simple Server Azure AKS Demonstration  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [Introduction](#introduction)

# Introduction

This Simple Server Azure AKS project relates to my previous project [Azure Table Storage with Clojure](https://medium.com/@kari.marttila/azure-table-storage-with-clojure-12055e02985c) in which I implemented the Simple Server to use Azure Table Storage as the application database. The Simple Server Azure version is in my Github account: [Clojure Simple Server](https://github.com/karimarttila/clojure/tree/master/clj-ring-cljs-reagent-demo/simple-server).

In this new Simple Server Azure AKS project I created a Terraform deployment configuration for the Simple Server Azure version. There is also a Kubernetes deployment configuration in which you can test the Simple Server Docker container both in Minikube and in Azure AKS service.
 
So, the rationale of this project was mainly to learn how to use Terraform with Azure, how to create a Kubernetes deployment and use the Kubernetes deployment configuration with Minikube and Azure AKS. In the next project I create the deployment in the AWS side for EKS and Fargate.

 

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

Use script [create-azure-storage-account.sh](https://github.com/karimarttila/azure/blob/master/simple-server-aks/scripts/create-azure-storage-account.sh) to create an Azure Storage Account to be used for Terraform Backend. You need to supply for arguments for the script:

- The Azure location to be used.
- The resource group name for this exercise.
- The Storage account name for this exercise.
- The container name for the Terraform backend state (stored in the Storage account the script creates).

NOTE: You might want to use prefix "dev-" with your container name if you are going to store several Terraform environment backends in the same Azure Storage account.


## Create Service Principal for Use with Terraform 

NOTE: Use this service principal if you want to inject the same service principal you are using with Terraform for AKS as well (as environmental variables). If you want more elegant solution, see next chapter.

Create a service principal for Terraform:

```bash
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"
```

Terraform uses this service principal when it creates resources in Azure.


## NOT USED - SKIP THIS CHAPTER - Create Service Principal for Use with Terraform

I keep this chapter for historical reasons. I tried to create a custom Terraform Service Principal to be used with Terraform so that in terraform scripts I could be able to create other service principals (e.g. AKS needs one). Seemed to be pretty hard and I finally couldn't do this since I lack my corporation AD admin rights. 

Most Azure Terraform examples that need to use service principal just create the service principal beforehand using azure cli and then use this service principal id in terraform code. This solution works in examples but is not that elegant since the cloud infra best practice is to create all infra using the configuration only (if possible). Azure AKS needs a service principal to create AKS resources. The default contributor role service principal cannot create apps and other service principals and therefore we need to create a custom service principal for Terraform.

Create file ~/.azure/<your-custom-terraform-role>.json:

```json
{
    "Name":  "Terraform",
    "IsCustom":  true,
    "Description":  "Custom Contributor to be able to create apps and roles in Terraform.",
    "Actions":  [
        "*"
        ],
    "NotActions":  [
        "Microsoft.Authorization/classicAdministrators/write",
        "Microsoft.Authorization/classicAdministrators/delete",
        "Microsoft.Authorization/denyAssignments/write",
        "Microsoft.Authorization/denyAssignments/delete",
        "Microsoft.Authorization/locks/write",
        "Microsoft.Authorization/locks/delete",
        "Microsoft.Authorization/policyAssignments/write",
        "Microsoft.Authorization/policyAssignments/delete",
        "Microsoft.Authorization/policyDefinitions/write",
        "Microsoft.Authorization/policyDefinitions/delete",
        "Microsoft.Authorization/policySetDefinitions/write",
        "Microsoft.Authorization/policySetDefinitions/delete",
        "Microsoft.Authorization/elevateAccess/Action",
        "Microsoft.Blueprint/*/write",
        "Microsoft.Blueprint/*/delete"
        ],
    "DataActions": [],
    "NotDataActions": [],
    "AssignableScopes":  [
        "/subscriptions/00000000000000000000000000000000"
        ]
}
``` 

Change your Azure subscription in that file. NOTE: Do not add this file to your Git project - keep it in your ~/.azure directory!

Create role and role assignment:

```bash
az role definition create --role-definition ~/.azure/kari-aks-demo-terraform.json
az role definition list -o table | grep -i terraform   # => List that you see it was created. 
az ad sp list --all | jq '.[] | select(.displayName == "Terraform") | { id: .objectId, name: .displayName }'  # => Lists the role definition name and id.
az role assignment create --role "Terraform" --assignee "ID-YOU-GOT-FROM-PREVIOUS-COMMAND"
az role assignment list -o table # => You should see the new role assignment Terraform.
az role definition list --name Terraform  # => List the role definition.
az ad sp create-for-rbac --name "http://0000000000000000000000/TerraformSP" --role "Terraform" --scopes="/subscriptions/0000000000000000000000" # => Change the 0-string with your subscription id. You get the appId, password and tenant as result, save them, you need them in the next chapter.
```

After this I updated the Environmental variables as explained in the next chapter and sourced the new variables, and tried terraform init and apply - again same error: "Insufficient privileges to complete the operation". I tried to follow the document [Using Terraform to extend beyond ARM](https://azurecitadel.com/automation/terraform/lab8/) :

- Navigate to Azure Active Directory (AAD)
- Under the Manage list, select App registrations (Preview)
- Ensure the All Applications tab is selected
- Search for, and select the Terraform Service Principal application
- Select API Permissions
- Add Permissions
- In "Azure Active Directory Graph" choose:
  - Application.ReadWrite.All
  - User.Read

This does not work since Application.ReadWrite.All requires admin rights for my corporation AD in which the subscription is linked. 

I left the Terraform SP and the right grant request - let's see if my corporation AD admin grants the right. If yes, I'll try to use this service principal with terraform. I saved this service principal in file "ss-aks-profile-custom-terraform.sh" (for my information if I need it later).

 

## Create an Azure Environmental Variables Export Bash Script

Create a bash script in which you export the environmental variables you need to work with this project. Store the file e.g. in ~/.azure (i.e. **DO NOT STORE THE FILE IN GIT** since you don't want these secrets to be in plain text in your Git repository!). Example:

```bash
#!/bin/bash

echo "Setting environment variables for Simple Server Azure AKS Terraform project."
export AZURE_STORAGE_ACCOUNT=<your-storage-account-name from storage account command result>
export AZURE_STORAGE_KEY=<your-storage-account-key from storage account command result>
export ARM_ACCESS_KEY=<your-storage-account-name from storage account command result>
export ARM_SUBSCRIPTION_ID=<your-subscription-id>
export ARM_CLIENT_ID=<app-id from service principal command result>
export ARM_CLIENT_SECRET=<password from Service Principal command result>
export ARM_TENANT_ID=<tenant id from Service Principal command result>
# Since there was some hassle to create the service principal in
# Terraform code, let's just use the service principal for AKS we
# created using azure cli.
export TF_VAR_aks_client_id=${ARM_CLIENT_ID}
export TF_VAR_aks_client_secret=${ARM_CLIENT_SECRET}

```

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


# Azure AKS Terraform Configuration

I followed these three documentation:

- [Create a Kubernetes cluster with Azure Kubernetes Service and Terraform](https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks)
- [Terraform azurerm_kubernetes_cluster resource](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html)
- [Creating a Kubernetes Cluster with AKS and Terraform](https://www.hashicorp.com/blog/kubernetes-cluster-with-aks-and-terraform)


# Some Azure Terraform Observations

## Service Principal Hassle

I first thought that it would be nice to create the Service Principal that AKS uses in Terraform as well. I created a Terraform module for it ([service-principal](TODO)) but when running ```terraform apply``` I got error ```azurerm_azuread_application.application: graphrbac.ApplicationsClient#Create: ...Details=[{"odata.error":{"code":"Authorization_RequestDenied","message":{"lang":"en","value":"Insufficient privileges to complete the operation."}}}]``` I pretty soon realized that Terraform is running under the service principal I created earlier (see chapter "Create Service Principal for Use with Terraform") and there I assigned role "Contributor" for this principal. So, a contributor role can create Azure resources but it cannot create other roles. Therefore there are three solutions: 1. Create the service principal with role "owner" -> owner can create other roles. 2. Add some right to the service principal to create other roles. 3. Remove the service principal creation in Terraform code and use some existing service principal that has been created outside Terraform. Option 1. is a bit overkill. Option 3 is not elegant since you should be able to create all cloud resources in your cloud infra configuration and not have scripts here and there. Option 2 would be the optimal solution but it takes a bit time. 

I tried option 1 and created a service principal with owner role. Terraform apply command gave the same error when trying to create the service principal for AKS, damn.

Then some googling. I found a way to provide option 2, i.e. a custom service principal definition: [Terraform and Multi Tenanted Environments](https://azurecitadel.com/automation/terraform/lab5/#advanced-service-principal-configuration). I tried these instructions but I finally noticed that I should have AD admin rights in our corporation AD that is linked to the Azure subscription that I'm using - didn't work. So, I had to fall back to option 3 and create the service principal for AKS outside terraform code and inject the service principal using environmental variables. Not cloud infra best practice but after this hassle I thought that I just need to move on.




