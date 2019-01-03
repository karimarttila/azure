

resource "azurerm_azuread_application" "application" {
  name     = "${var.prefix}-${var.env}-sp-app-${var.name}"
}

resource "azurerm_azuread_service_principal" "service-principal" {
  application_id = "${azurerm_azuread_application.application.application_id}"
}

resource "random_string" "service-principal-password" {
  length  = 16
  special = true

  keepers = {
    service_principal = "${azurerm_azuread_service_principal.service-principal.id}"
  }
}