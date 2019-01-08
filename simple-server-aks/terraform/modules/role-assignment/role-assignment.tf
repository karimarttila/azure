
resource "azurerm_role_assignment" "role-assignment" {
  principal_id         = "${var.service_principal_id}"
  role_definition_name = "${var.role}"
  scope                = "${var.acr_id}"
}