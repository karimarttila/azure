locals {
  my_name  = "${var.prefix}${var.env}${var.name}"
  my_env   = "${var.prefix}-${var.env}"
}

# NOTE: In this demonstration the actual Tables were not created as part of Terraform
# but using the scripts found in the Simple Server Clojure / azure-table-storage directory.
# TODO: If you sometimes continue this demonstration create a table-storage module and create the tables there (see simple-server-vm project).

resource "azurerm_storage_account" "storage-account" {
  name                     = "${local.my_name}"
  resource_group_name      = "${var.rg_name}"
  location                 = "${var.location}"
  account_tier             = "${var.account_tier}"
  account_replication_type = "${var.account_replication_type}"

  tags {
    Name        = "${local.my_name}"
    Environment = "${local.my_env}"
    Terraform   = "true"
  }

}
