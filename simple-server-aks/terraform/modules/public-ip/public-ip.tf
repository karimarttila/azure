
resource "azurerm_public_ip" "public_ip" {
  name                         = "${var.prefix}-${var.env}-${var.pip_name}"
  location                     = "${var.location}"
  resource_group_name          = "${var.rg_name}"
  public_ip_address_allocation = "static"

  tags {
    Name        = "${var.prefix}-${var.env}-${var.pip_name}"
    Environment = "${var.prefix}-${var.env}"
    Terraform   = "true"
  }
}

