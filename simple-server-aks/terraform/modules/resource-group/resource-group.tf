locals {
  my_name  = "${var.prefix}-${var.env}-${var.rg_name}"
  my_env   = "${var.prefix}-${var.env}"
}

resource "azurerm_resource_group" "resource-group" {
  name     = "${local.my_name}"
  location = "${var.location}"

  tags {
    Name        = "${local.my_name}"
    Environment = "${local.my_env}"
    Terraform   = "true"
  }
}

