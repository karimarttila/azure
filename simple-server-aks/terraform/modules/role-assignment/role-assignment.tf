locals {
  my_name  = "${var.prefix}-${var.env}-${var.name}-role-assignment-for-sp-${var.service_principal_id}"
  my_env   = "${var.prefix}-${var.env}"
}

resource "azurerm_role_assignment" "role-assignment" {
  // NOTE: You cannot use my_name as name (not a GUID).
  principal_id         = "${var.service_principal_id}"
  role_definition_name = "${var.role}"
  scope                = "${var.scope_id}"
}