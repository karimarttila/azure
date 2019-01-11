locals {
  my_name  = "${var.prefix}${var.env}${var.name}"
  my_env   = "${var.prefix}-${var.env}"
}

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
