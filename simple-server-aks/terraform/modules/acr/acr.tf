
resource "azurerm_container_registry" "acr" {
  # NOTE: In ACR name you cannot use hyphens.
  name                   = "${var.prefix}${var.env}${var.acr_name}"
  resource_group_name    = "${var.rg_name}"
  location               = "${var.location}"
  sku                    = "${var.acr_sku}"
  admin_enabled          = false
}
