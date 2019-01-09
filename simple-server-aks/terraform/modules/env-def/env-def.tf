# NOTE: This is the environment definition that will be used by all environments.
# The actual environments (like dev) just inject their environment dependent values to env-def which defines the actual environment and creates that environment using given values.


# Main resource group for the demonstration.
module "main-resource-group" {
  source                    = "../resource-group"
  prefix                    = "${var.prefix}"
  env                       = "${var.env}"
  location                  = "${var.location}"
  rg_name                   = "main"
}

# ACR registry configuration.
module "acr" {
  source          = "../acr"
  prefix          = "${var.prefix}"
  env             = "${var.env}"
  location        = "${var.location}"
  rg_name         = "${module.main-resource-group.resource_group_name}"
  acr_name        = "acrdemo"
  acr_sku         = "standard"
  ext_service_principal_id = "${module.aks.aks_service_principal_id}"
}


# AKS configuration.
module "aks" {
  source          = "../aks"
  prefix          = "${var.prefix}"
  env             = "${var.env}"
  location        = "${var.location}"
  rg_name         = "${module.main-resource-group.resource_group_name}"
  cluster_name    = "aks-demo"
  dns_prefix      = "aksdemo"
  agent_count     = "2"
  agent_pool_name = "akspool"
  vm_size         = "Standard_A1"
  os_disk_size_gb = "30"
}

# Public ips.
# IP for Singe-node version of Simple Server.
module "single-node-pip" {
  source          = "../public-ip"
  prefix          = "${var.prefix}"
  env             = "${var.env}"
  location        = "${var.location}"
  rg_name         = "${module.aks.aks_resource_group_name}"
  pip_name        = "single-node-pip"
}
# IP for Azure Table Storage version of Simple Server.
module "table-storage-pip" {
  source          = "../public-ip"
  prefix          = "${var.prefix}"
  env             = "${var.env}"
  location        = "${var.location}"
  rg_name         = "${module.aks.aks_resource_group_name}"
  pip_name        = "table-storage-pip"
}
