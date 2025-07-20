terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.51" # Use the latest stable version
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.23" # Use a compatible version
    }
  }
}

provider "hcloud" {
  token = var.HCLOUD_TOKEN
}

resource "hcloud_ssh_key" "k3s_ssh_key" {
  name       = var.hcloud_ssh_key.name
  public_key = file(var.hcloud_ssh_key.public_key_filepath)
}

resource "hcloud_network" "k3s_private_network" {
  name = var.hcloud_network.name
  ip_range = var.hcloud_network.ip_range
}

resource "hcloud_network_subnet" "k3s_private_subnet" {
  network_id   = hcloud_network.k3s_private_network.id
  type         = var.hcloud_network_subnet.type
  network_zone = var.hcloud_network_subnet.network_zone
  ip_range     = var.hcloud_network_subnet.ip_range
}

resource "hcloud_floating_ip" "k3s_operator_public_ip" {
  name            = var.public_floating_ip.name
  type            = var.public_floating_ip.type
  home_location   = var.public_floating_ip.home_location
}

resource "hcloud_firewall" "k3s_operator_firewall" {
  name = var.firewall.name
  labels = {
    environment = var.firewall.labels.environment
    purpose = var.firewall.labels.purpose
  }

  dynamic "rule" {
    for_each = var.firewall.rules
    content {
      direction = rule.value.direction
      protocol = rule.value.protocol
      port = rule.value.port
      source_ips = rule.value.source_ips
      destination_ips = rule.value.destination_ips
      description = rule.value.description
    }
  }
}

resource "hcloud_server" "k3s_operator" {
  name        = var.hcloud_server.name
  image       = var.hcloud_server.image
  server_type = var.hcloud_server.server_type
  location    = var.hcloud_server.location
  ssh_keys    = [hcloud_ssh_key.k3s_ssh_key.id]
  firewall_ids = [hcloud_firewall.k3s_operator_firewall.id]

  network {
    network_id = hcloud_network.k3s_private_network.id
    ip         = cidrhost(hcloud_network_subnet.k3s_private_subnet.ip_range, var.hcloud_server.host_number)
  }

  user_data = templatefile(var.cloud_init.path, {
    ssh_key = file(var.hcloud_ssh_key.public_key_filepath)
    k3s_advertise_address   = hcloud_floating_ip.k3s_operator_public_ip.ip_address
  })

  depends_on = [
    hcloud_network_subnet.k3s_private_subnet
  ]
}

resource "hcloud_floating_ip_assignment" "k3s_operator_public_ip_assign" {
  floating_ip_id = hcloud_floating_ip.k3s_operator_public_ip.id
  server_id      = hcloud_server.k3s_operator.id
}