locals {
  my_name = "${var.prefix}-${var.env}"
  my_env = "${var.prefix}-${var.env}"
}

resource "azurerm_virtual_network" "vm-vnet" {
  name = "${local.my_name}-vnet"
  location = "${var.location}"
  address_space = ["${var.address_space}"]
  resource_group_name = "${var.rg_name}"

  tags {
    Name        = "${local.my_name}-vnet"
    Environment = "${local.my_env}"
    Terraform   = "true"
  }
}

resource "azurerm_subnet" "private_scaleset_subnet" {
  name                 = "${local.my_name}-private-scaleset-subnet"
  address_prefix       = "${var.private_subnet_address_prefix}"
  resource_group_name  = "${var.rg_name}"
  virtual_network_name = "${azurerm_virtual_network.vm-vnet.name}"
  # NOTE: This field will be depricated in terraform 2.0 but now required or nw-sg will be disassociated with every terraform apply.
  network_security_group_id  = "${azurerm_network_security_group.private_scaleset_subnet_nw_sg.id}"
}

resource "azurerm_subnet" "public_mgmt_subnet" {
  name                 = "${local.my_name}-public-mgmt-subnet"
  address_prefix       = "${var.public_mgmt_subnet_address_prefix}"
  resource_group_name  = "${var.rg_name}"
  virtual_network_name = "${azurerm_virtual_network.vm-vnet.name}"
  # NOTE: This field will be depricated in terraform 2.0 but now required or nw-sg will be disassociated with every terraform apply.
  network_security_group_id  = "${azurerm_network_security_group.public_mgmt_subnet_nw_sg.id}"

}


resource "azurerm_network_security_group" "private_scaleset_subnet_nw_sg" {
  name = "${local.my_name}-private-scaleset-subnet-nw-sg"
  location = "${var.location}"
  resource_group_name = "${var.rg_name}"

  tags {
    Name        = "${local.my_name}-private-scaleset-subnet-nw-sg"
    Environment = "${local.my_env}"
    Terraform   = "true"
  }
}


resource "azurerm_network_security_group" "public_mgmt_subnet_nw_sg" {
  name = "${local.my_name}-public-mgmt-subnet-nw-sg"
  location = "${var.location}"
  resource_group_name = "${var.rg_name}"

  tags {
    Name        = "${local.my_name}-public-mgmt-subnet-nw-sg"
    Environment = "${local.my_env}"
    Terraform   = "true"
  }
}


resource "azurerm_subnet_network_security_group_association" "private_scaleset_subnet_assoc" {
  subnet_id                 = "${azurerm_subnet.private_scaleset_subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.private_scaleset_subnet_nw_sg.id}"
}


resource "azurerm_subnet_network_security_group_association" "public_mgmt_subnet_assoc" {
  subnet_id                 = "${azurerm_subnet.public_mgmt_subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.public_mgmt_subnet_nw_sg.id}"
}


resource "azurerm_network_security_rule" "private_scaleset_subnet_nw_sg" {
  name = "${local.my_name}-private-scaleset-subnet-nw-sg-allow-http-3045-rule"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3045"
  source_address_prefix       = "*"
  destination_address_prefix  = "${var.private_subnet_address_prefix}"
  resource_group_name         = "${var.rg_name}"
  network_security_group_name = "${azurerm_network_security_group.private_scaleset_subnet_nw_sg.name}"
}