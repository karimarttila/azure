# NOTE: This is the environment definition that will be used by all environments.
# The actual environments (like dev) just inject their environment dependent values to env-def which defines the actual environment and creates that environment using given values.


# Main resource group for the demonstration.
module "main-resource-group" {
  source                    = "../resource-group"
  prefix                    = "${var.prefix}"
  env                       = "${var.env}"
  location                  = "${var.location}"
  pg_name                   = "main"
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
  agent_count     = "3"
  agent_pool_name = "akspool"
  vm_size         = "Standard_A1"
  os_disk_size_gb = "30"
}
