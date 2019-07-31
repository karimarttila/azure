output "service_principal_id" {
  value = "${azuread_service_principal.service-principal.id}"
}

output "service_principal_client_id" {
  value = "${azuread_service_principal.service-principal.application_id}"
}

output "service_principal_client_secret" {
  sensitive = true
  value     = "${random_string.service-principal-random-password.result}"
}
