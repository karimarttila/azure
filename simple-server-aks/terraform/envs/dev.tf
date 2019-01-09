# Dev environment.
# NOTE: If environment copied, change environment related values (e.g. "dev" -> "perf").

##### Terraform configuration #####

provider "azurerm" {
    version               = "~> 1.20"
}

terraform {
  backend "azurerm" {
    storage_account_name  = "kariaksstorage"
    container_name        = "dev-kari-aks-terraform-container"
    key                   = "dev-terraform.tfstate"
  }
}


# Here we inject our values to the environment definition module which creates all actual resources.
module "env-def" {
  source   = "../modules/env-def"
  prefix   = "kari2ssaks"
  env      = "dev"
  location = "westeurope"
}