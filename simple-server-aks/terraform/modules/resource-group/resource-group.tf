
resource "azurerm_resource_group" "resource-group" {
  name     = "${var.prefix}-${var.env}-${var.rg_name}"
  location = "${var.location}"

  tags {
    Name        = "${var.prefix}-${var.env}-${var.rg_name}"
    Environment = "${var.prefix}-${var.env}"
    Terraform   = "true"
  }
}

