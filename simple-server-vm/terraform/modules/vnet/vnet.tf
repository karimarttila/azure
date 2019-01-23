locals {
  my_name = "${var.prefix}-${var.env}"
  my_env = "${var.prefix}-${var.env}"
}

resource "azurerm_virtual_network" "vm-vnet" {
  name = "${local.my_name}-vnet"
  location = "${var.location}"
  address_space = ["${var.address_space}"]
  resource_group_name = "${var.rg_name}"
  dns_servers = "${var.dns_servers}"

  subnet {
    name = "${var.private_subnet_name}"
    address_prefix = "${var.private_subnet_address_prefix}"
    security_group = "${azurerm_application_security_group.private_subnet_sg.id}"
  }

  subnet {
    name = "${var.public_mgmt_subnet_name}"
    address_prefix = "${var.public_mgmt_subnet_address_prefix}"
    security_group = "${azurerm_application_security_group.public_mgmt_subnet_sg.id}"
  }

  tags {
    Name = "${local.my_name}-vnet"
    Environment = "${local.my_env}"
    Terraform = "true"
  }
}

resource "azurerm_application_security_group" "private_subnet_sg" {
  name = "${local.my_name}-private-subnet-sg"
  location = "${var.location}"
  resource_group_name = "${var.rg_name}"

  tags {
    Name = "${local.my_name}-private-subnet-sg"
    Environment = "${local.my_env}"
    Terraform = "true"
  }
}

resource "azurerm_application_security_group" "public_mgmt_subnet_sg" {
  name = "${local.my_name}-public-mgmt-subnet-sg"
  location = "${var.location}"
  resource_group_name = "${var.rg_name}"

  tags {
    Name = "${local.my_name}-public-mgmt-subnet-sg"
    Environment = "${local.my_env}"
    Terraform = "true"
  }
}