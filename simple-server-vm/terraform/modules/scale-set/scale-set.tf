locals {
  my_name       = "${var.prefix}-${var.env}-${var.rg_name}"
  my_env        = "${var.prefix}-${var.env}"
  my_admin_user_name = "ubuntu"
}


resource "azurerm_public_ip" "scaleset_public_ip" {
  name                           = "${local.my_name}-scaleset-public-ip"
  location                       = "${var.location}"
  resource_group_name            = "${var.rg_name}"
  public_ip_address_allocation   = "static"
  domain_name_label              = "${local.my_name}-app"

  tags {
    Name        = "${local.my_name}-scaleset-public-ip"
    Environment = "${local.my_env}"
    Terraform   = "true"
  }
}


resource "azurerm_lb" "scaleset_lb" {
  name                = "${local.my_name}-scaleset-lb"
  location            = "${var.location}"
  resource_group_name = "${var.rg_name}"

  frontend_ip_configuration {
    name                = "${local.my_name}-scaleset-frontend-public-ip"
    public_ip_address_id = "${azurerm_public_ip.scaleset_public_ip.id}"
  }

  tags {
    Name        = "${local.my_name}"
    Environment = "${local.my_env}"
    Terraform   = "true"
  }
}

resource "azurerm_lb_backend_address_pool" "scaleset_lb_backend_pool" {
  name                = "${local.my_name}-scaleset-lb-backend-pool"
  resource_group_name = "${var.rg_name}"
  loadbalancer_id     = "${azurerm_lb.scaleset_lb.id}"
}

resource "azurerm_lb_probe" "scaleset_lb_probe" {
  name                = "${local.my_name}-scaleset-lb-probe"
  resource_group_name = "${var.rg_name}"
  loadbalancer_id     = "${azurerm_lb.scaleset_lb.id}"
  port                = "${var.application_port}"
}

resource "azurerm_lb_rule" "scaleset_lb_nat_rule" {
  name                           = "${local.my_name}-scaleset-lb-nat-rule"
  resource_group_name            = "${var.rg_name}"
  loadbalancer_id                = "${azurerm_lb.scaleset_lb.id}"
  protocol                       = "Tcp"
  frontend_port                  = "${var.application_port}"
  backend_port                   = "${var.application_port}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.scaleset_lb_backend_pool.id}"
  frontend_ip_configuration_name = "${local.my_name}-scaleset-frontend-public-ip"
  probe_id                       = "${azurerm_lb_probe.scaleset_lb_probe.id}"
}

# NOTE: We use data since the image building is not part of Terraform but has been done previously using Packer.
data "azurerm_image" "scaleset_image_reference" {
  name                = "${var.scaleset_image_name}"
  resource_group_name = "${var.rg_name}"
}


resource "azurerm_virtual_machine_scale_set" "scaleset" {
  name                = "${local.my_name}-scaleset"
  location            = "${var.location}"
  resource_group_name = "${var.rg_name}"
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_DS1_v2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    id="${data.azurerm_image.scaleset_image_reference.id}"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun            = 0
    caching        = "ReadWrite"
    create_option  = "Empty"
    disk_size_gb   = 10
  }

  os_profile {
    computer_name_prefix = "${local.my_name}-scaleset-vm"
    admin_username       = "${local.my_admin_user_name}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${local.my_admin_user_name}/.ssh/authorized_keys"
      key_data = "${file("${var.vm_ssh_public_key_file}")}"

    }
  }


  network_profile {
    name    = "${local.my_name}-scaleset-profile"
    primary = true

    ip_configuration {
      name         = "${local.my_name}-scaleset-ip-configuration"
      subnet_id    = "${var.subnet_id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.scaleset_lb_backend_pool.id}"]
      primary = true
    }
  }

  tags {
    Name        = "${local.my_name}-scaleset-profile"
    Environment = "${local.my_env}"
    Terraform   = "true"
  }
}