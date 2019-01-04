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

# Should be injected as environmental variables:
# export TF_VAR_aks_client_id=${ARM_CLIENT_ID}
# export TF_VAR_aks_client_secret=${ARM_CLIENT_SECRET}
# See README.md.
variable "aks_client_id" {}
variable "aks_client_secret" {}

# Here we inject our values to the environment definition module which creates all actual resources.
module "env-def" {
  source   = "../modules/env-def"
  prefix   = "karissaks"
  env      = "dev"
  location = "westeurope"
  aks_client_id     = "${var.aks_client_id}"
  aks_client_secret = "${var.aks_client_secret}"

}