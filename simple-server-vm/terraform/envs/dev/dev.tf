# Dev environment.
# NOTE: If environment copied, change environment related values (e.g. "dev" -> "perf").

##### Terraform configuration #####

provider "azurerm" {
    version               = "~> 1.20"
}

terraform {
  backend "azurerm" {
    storage_account_name  = "devkarissvmterratorage"
    container_name        = "dev-kari-ss-vm-terraform-container"
    key                   = "dev-terraform.tfstate"
  }
}


# Here we inject our values to the environment definition module which creates all actual resources.
module "env-def" {
  source   = "../modules/env-def"
  prefix   = "karivmdemo1"
  env      = "dev"
  location = "westeurope"
}

