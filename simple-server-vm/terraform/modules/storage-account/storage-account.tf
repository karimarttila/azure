locals {
  my_name  = "${var.prefix}${var.env}"
  my_env   = "${var.prefix}-${var.env}"
}

# Storage account for the Tables.
resource "azurerm_storage_account" "tables_storage_account" {
  name                     = "${local.my_name}tables"
  resource_group_name      = "${var.rg_name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    Name        = "${local.my_name}"
    Environment = "${local.my_env}"
    Terraform   = "true"
  }
}


