resource "hcloud_network" "k3s_private_network" {
    name     = var.network.name
    ip_range = var.network.ip_range
}

resource "hcloud_network_subnet" "k3s_private_subnet" {
    network_id   = hcloud_network.k3s_private_network.id
    type         = var.network.subnet.type
    network_zone = var.network.zone
    ip_range     = var.network.subnet.ip_range
}

