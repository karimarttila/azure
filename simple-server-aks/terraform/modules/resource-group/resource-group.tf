
resource "azurerm_resource_group" "main-resource-group" {
  name     = "${var.prefix}-${var.env}-${var.pg_name}"
  location = "${var.location}"

  tags {
    Name        = "${var.prefix}-${var.env}-${var.pg_name}"
    Environment = "${var.prefix}-${var.env}"
    Terraform   = "true"
  }
}

