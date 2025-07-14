resource "hcloud_server" "k3s_operator" {
  name       = "k3s-master-01"
  image      = "ubuntu-22.04"
  server_type = "cax11"
  location   = "fsn1"
  ssh_keys   = [hcloud_ssh_key.k3s_ssh_key.id]

  # Attach to the private network
  network {
    network_id = hcloud_network.k3s_private_network.id
    ip         = cidrhost(hcloud_network_subnet.k3s_private_subnet.ip_range, 10) # e.g., 10.0.1.10
  }

  user_data = templatefile("${path.module}/cloud-init/operator-cloud-init.yaml", {
    k3s_token               = var.k3s_token
    k3s_version             = "v1.33.2+k3s1"
    master_private_ip       = cidrhost(hcloud_network_subnet.k3s_private_subnet.ip_range, 10)
    # The --tls-san for a single node will be its own public IP
    master_public_ip        = hcloud_floating_ip.operator_public_ip.ip_address # This will be the public IP assigned by Hetzner
  })

  # Ensure network is created before the server
  depends_on = [
    hcloud_network_subnet.k3s_private_subnet
  ]
}

resource "hcloud_floating_ip" "operator_public_ip" {
  type        = "ipv4"
  home_location = "fsn1"
}

resource "hcloud_floating_ip_assignment" "master_public_ip_assignment" {
  floating_ip_id = hcloud_floating_ip.operator_public_ip.id
  server_id     = hcloud_server.k3s_operator.id
  depends_on    = [hcloud_server.k3s_operator]
}