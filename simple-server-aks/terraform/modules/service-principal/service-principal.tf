resource "azurerm_azuread_application" "service-principal-app" {
    name = "${var.prefix}-${var.env}-aks-sp-app"
}

resource "azurerm_azuread_service_principal" "service-principal" {
    application_id = "${azurerm_azuread_application.service-principal-app.application_id}"
}

resource "random_string" "service-principal-password" {
  length  = 16
  special = true

  keepers = {
    service_principal = "${azurerm_azuread_service_principal.service-principal.id}"
  }
}