# main.tf
terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.51" # Use the latest stable version
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

// Network
resource "hcloud_network" "k3s_private_network" {
  # "CIDR range for the private network"
  name     = "k3s-private-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "k3s_private_subnet" {
  # "CIDR range for the private subnet"
  network_id   = hcloud_network.k3s_private_network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_ssh_key" "k3s_ssh_key" {
  name       = "k3s-ssh-key"
  public_key = file("~/.ssh/hetzner.pub")
}