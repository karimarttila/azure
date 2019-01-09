locals {
  my_name  = "${var.prefix}-${var.env}-${var.pip_name}"
  my_env   = "${var.prefix}-${var.env}"
}

resource "azurerm_public_ip" "public_ip" {
  name                         = "${local.my_name}"
  location                     = "${var.location}"
  resource_group_name          = "${var.rg_name}"
  public_ip_address_allocation = "static"

  tags {
    Name        = "${local.my_name}"
    Environment = "${local.my_env}"
    Terraform   = "true"
  }
}

