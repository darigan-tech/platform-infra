resource "hcloud_ssh_key" "k3s_ssh_key" {
  name       = var.ssh_key_name
  public_key = file(var.ssh_key_path)
}

resource "hcloud_floating_ip" "k3s_public_ip" {
  name          = var.floating_ip_name
  type          = "ipv4"
  home_location = var.location
}

resource "hcloud_server" "k3s_operator" {
  name        = var.server.name
  image       = var.server.image
  server_type = var.server.type
  location    = var.server.location
  ssh_keys    = [hcloud_ssh_key.k3s_ssh_key.id]
  firewall_ids = [var.firewall_id]

  network {
    network_id = var.server.network.id
    ip         = cidrhost(var.subnet_ip_range, var.host_number)
  }

  user_data = templatefile(var.user_data_path, {
    ssh_key = file(var.ssh_key_path)
    # advertise_address = hcloud_floating_ip.k3s_public_ip.ip_address
  })
}

resource "hcloud_floating_ip_assignment" "k3s_public_ip_assign" {
  floating_ip_id = hcloud_floating_ip.k3s_public_ip.id
  server_id      = hcloud_server.k3s_operator.id
}

variable "server" {
  type = object({
    name = string
    image = string
    type = string
    location = string
    network = object({
      id = string
      ip = string
    })
  })
}

variable "ssh" {
  type = object({
    user
  })
}