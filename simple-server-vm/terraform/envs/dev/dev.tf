# Dev environment.
# NOTE: If environment copied, change environment related values (e.g. "dev" -> "perf").

##### Terraform configuration #####
# NOTE: You need to source the Azure Blog storage access key first:
# source ~/.azure/kari-ss-vm-demo.sh


provider "azurerm" {
    version               = "~> 1.20"
}

terraform {
  backend "azurerm" {
    storage_account_name  = "devkarissvmterrastorage"
    container_name        = "dev-kari-ss-vm-terraform-container"
    key                   = "dev-terraform.tfstate"
  }
}

locals {
  my_prefix   = "karissvmdemo1"
  my_env      = "dev"
  my_location = "westeurope"
}


# Here we inject our values to the environment definition module which creates all actual resources.
module "env-def" {
  source   = "../../modules/env-def"
  prefix   = "${local.my_prefix}"
  env      = "${local.my_env}"
  location = "${local.my_location}"
  # For making different vnets and subnets in different environments.
  # Here you define address space for dev environment.
  address_space                     = "10.0.1.0/24"
  private_subnet_address_prefix     = "10.0.1.0/26"
  public_mgmt_subnet_address_prefix = "10.0.1.64/28"

}

