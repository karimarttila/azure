locals {
  my_name  = "${var.prefix}-${var.env}-${var.name}"
  my_env   = "${var.prefix}-${var.env}"
}

resource "azurerm_azuread_application" "service-principal-app" {
    name = "${var.prefix}-${var.env}-${var.name}-app"
}

resource "azurerm_azuread_service_principal" "service-principal" {
    application_id = "${azurerm_azuread_application.service-principal-app.application_id}"
}

resource "random_string" "service-principal-random-password" {
  length  = 16
  special = true

  keepers = {
    service_principal = "${azurerm_azuread_service_principal.service-principal.id}"
  }
}

resource "azurerm_azuread_service_principal_password" "service-principal-password" {
    service_principal_id = "${azurerm_azuread_service_principal.service-principal.id}"
    value                = "${random_string.service-principal-random-password.result}"
    # 720h = 1 month, should be enough for this exercise.
    end_date             = "${timeadd(timestamp(), "720h")}"
    lifecycle {
        ignore_changes = ["end_date"]
    }
    provisioner "local-exec" {
        command = "sleep 30"
    }

}