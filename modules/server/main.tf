resource "hcloud_server" "master-node" {
  name        = var.server.name
  image       = var.server.image
  server_type = var.server.type
  location    = var.server.location

  ssh_keys = [var.ssh_key_id]
  firewall_ids = [var.firewall_id]

  network {
    network_id = var.private_network_id
  }

  user_data = var.user_data

  lifecycle {
    prevent_destroy = true
  }
}