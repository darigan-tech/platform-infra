resource "hcloud_network" "private_network" {
  name     = var.private_network.name
  ip_range = var.private_network.ip_range

  lifecycle {
    prevent_destroy = true
  }
}

resource "hcloud_network_subnet" "private_network_subnet" {
  type         = var.private_network_subnet.type
  network_id   = hcloud_network.private_network.id
  network_zone = var.private_network_subnet.network_zone
  ip_range     = var.private_network_subnet.ip_range

  lifecycle {
    prevent_destroy = true
  }
}