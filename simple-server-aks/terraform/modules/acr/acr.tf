locals {
  my_name  = "${var.prefix}${var.env}${var.acr_name}"
  my_env   = "${var.prefix}-${var.env}"
}

# Give Contributor role of ACR scope for AKS's Service principal.
# Without this kubectl deployment fails since AKS's Service principal do not have right to read ACR.
module "acr-aks-image-pull-role-assignment" {
  source               = "../role-assignment"
  prefix               = "${var.prefix}"
  env                  = "${var.env}"
  name                 = "acr-aks-image-pull-role"
  role                 = "Contributor"
  scope_id             = "${azurerm_container_registry.acr.id}"
  service_principal_id = "${var.ext_service_principal_id}"
}


resource "azurerm_container_registry" "acr" {
  # NOTE: In ACR name you cannot use hyphens.
  name                   = "${local.my_name}"
  resource_group_name    = "${var.rg_name}"
  location               = "${var.location}"
  sku                    = "${var.acr_sku}"
  admin_enabled          = false

  tags {
    Name        = "${local.my_name}"
    Environment = "${local.my_env}"
    Terraform   = "true"
  }

}
