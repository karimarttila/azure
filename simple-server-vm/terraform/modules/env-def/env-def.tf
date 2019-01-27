# NOTE: This is the environment definition that will be used by all environments.
# The actual environments (like dev) just inject their environment dependent values to env-def which defines the actual environment and creates that environment using given values.


# Main resource group for the demonstration.
module "main-resource-group" {
  source                    = "../resource-group"
  prefix                    = "${var.prefix}"
  env                       = "${var.env}"
  location                  = "${var.location}"
  rg_name                   = "main-rg"
}


module "vnet" {
  source          = "../vnet"
  prefix          = "${var.prefix}"
  env             = "${var.env}"
  location        = "${var.location}"
  rg_name         = "${module.main-resource-group.resource_group_name}"

  address_space                     = "${var.address_space}"
  private_subnet_address_prefix     = "${var.private_subnet_address_prefix}"
  public_mgmt_subnet_address_prefix = "${var.public_mgmt_subnet_address_prefix}"
}

module "storage_tables" {
  source          = "../storage-tables"
  prefix          = "${var.prefix}"
  env             = "${var.env}"
  location        = "${var.location}"
  rg_name         = "${module.main-resource-group.resource_group_name}"
}

module "scale-set" {
  source                 = "../scale-set"
  prefix                 = "${var.prefix}"
  env                    = "${var.env}"
  location               = "${var.location}"
  rg_name                = "${module.main-resource-group.resource_group_name}"
  application_port       = "${var.application_port}"
  scaleset_image_name    = "${var.scaleset_image_name}"
  subnet_id              = "${module.vnet.private_scaleset_subnet_id}"
  vm_ssh_public_key_file = "${var.vm_ssh_public_key_file}"
  scaleset_capacity      = "${var.scaleset_capacity}"
}