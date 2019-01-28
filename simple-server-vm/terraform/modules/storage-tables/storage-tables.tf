locals {
  my_name  = "${var.prefix}${var.env}"
  my_env   = "${var.prefix}-${var.env}"
}


resource "azurerm_storage_table" "session" {
  name                 = "${local.my_name}session"
  resource_group_name  = "${var.rg_name}"
  storage_account_name = "${var.storage_account_name}"
}

resource "azurerm_storage_table" "users" {
  name                 = "${local.my_name}users"
  resource_group_name  = "${var.rg_name}"
  storage_account_name = "${var.storage_account_name}"
}

resource "azurerm_storage_table" "productgroup" {
  name                 = "${local.my_name}productgroup"
  resource_group_name  = "${var.rg_name}"
  storage_account_name = "${var.storage_account_name}"
}

resource "azurerm_storage_table" "product" {
  name                 = "${local.my_name}product"
  resource_group_name  = "${var.rg_name}"
  storage_account_name = "${var.storage_account_name}"
}

