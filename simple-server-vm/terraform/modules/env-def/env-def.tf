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

# Let's create the storage account separately if we need to reset (delete/re-create)
# the tables - this way we don't need to change the AZURE_CONNECTION_STRING
# which is needed to import the test data to the tables.
module "table_storage_account" {
  source          = "../storage-account"
  prefix          = "${var.prefix}"
  env             = "${var.env}"
  location        = "${var.location}"
  rg_name         = "${module.main-resource-group.resource_group_name}"
}


module "storage_tables" {
  source          = "../storage-tables"
  prefix          = "${var.prefix}"
  env             = "${var.env}"
  location        = "${var.location}"
  rg_name         = "${module.main-resource-group.resource_group_name}"
  storage_account_name = "${module.table_storage_account.storage_account_name}"
}

module "scale-set" {
  source                       = "../scale-set"
  prefix                       = "${var.prefix}"
  env                          = "${var.env}"
  location                     = "${var.location}"
  rg_name                      = "${module.main-resource-group.resource_group_name}"
  application_port             = "${var.application_port}"
  scaleset_image_name          = "${var.scaleset_image_name}"
  subnet_id                    = "${module.vnet.private_scaleset_subnet_id}"
  vm_ssh_public_key_file       = "${var.vm_ssh_public_key_file}"
  scaleset_capacity            = "${var.scaleset_capacity}"
  scaleset_vm_custom_data_file = "${var.scaleset_vm_custom_data_file}"
  image_rg_name                = "${var.image_rg_name}"
}

