
output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate}"
}

output "kube_config_raw" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
}

output "aks_name" {
  value = "${azurerm_kubernetes_cluster.aks.name}"
}

# NOTE: AKS creates a separate resource group
# and you have to put the public ip for K8 Loadbalancer to this rg!
output "aks_resource_group_name" {
  value = "${azurerm_kubernetes_cluster.aks.node_resource_group}"
}

output "aks_service_principal_id" {
  value = "${module.aks-service-principal.service_principal_id}"
}