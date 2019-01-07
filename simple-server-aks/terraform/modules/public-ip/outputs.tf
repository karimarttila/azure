
output "public_ip_address" {
  value = "${azurerm_public_ip.public_ip.ip_address}"
}
