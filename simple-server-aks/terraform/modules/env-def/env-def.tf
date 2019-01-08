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
  acr_sku         = "Basic"
}

# Public ips.
# IP for Singe-node version of Simple Server.
module "single-node-pip" {
  source          = "../public-ip"
  prefix          = "${var.prefix}"
  env             = "${var.env}"
  location        = "${var.location}"
  rg_name         = "${module.main-resource-group.resource_group_name}"
  pip_name        = "single-node-pip"
}
# IP for Azure Table Storage version of Simple Server.
module "table-storage-pip" {
  source          = "../public-ip"
  prefix          = "${var.prefix}"
  env             = "${var.env}"
  location        = "${var.location}"
  rg_name         = "${module.main-resource-group.resource_group_name}"
  pip_name        = "table-storage-pip"
}

# Service principal for AKS.
module "service_principal" {
  source       = "../service-principal"
  prefix       = "${var.prefix}"
  env          = "${var.env}"
  name         = "aks-service-principal"
}

# Give Reader role of ACR scope for AKS's Service principal.
# Without this kubectl deployment fails since AKS's Service principal do not have right to read ACR.
module "acr-aks-role-assignment" {
  source               = "../role-assignment"
  prefix               = "${var.prefix}"
  env                  = "${var.env}"
  role                 = "Reader"
  acr_id               = "${module.acr.acr_id}"
  service_principal_id = "${module.service_principal.service_principal_id}"
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
  service_principal_client_id     = "${module.service_principal.service_principal_client_id}"
  service_principal_client_secret = "${module.service_principal.service_principal_client_secret}"
}
