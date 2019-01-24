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


resource "azurerm_storage_table" "session" {
  name                 = "${local.my_name}session"
  resource_group_name  = "${var.rg_name}"
  storage_account_name = "${azurerm_storage_account.tables_storage_account.name}"
}

resource "azurerm_storage_table" "users" {
  name                 = "${local.my_name}users"
  resource_group_name  = "${var.rg_name}"
  storage_account_name = "${azurerm_storage_account.tables_storage_account.name}"
}

resource "azurerm_storage_table" "productgroup" {
  name                 = "${local.my_name}productgroup"
  resource_group_name  = "${var.rg_name}"
  storage_account_name = "${azurerm_storage_account.tables_storage_account.name}"
}

resource "azurerm_storage_table" "product" {
  name                 = "${local.my_name}product"
  resource_group_name  = "${var.rg_name}"
  storage_account_name = "${azurerm_storage_account.tables_storage_account.name}"
}

