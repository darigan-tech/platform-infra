output "public_ip" {
  value = hcloud_floating_ip.k3s_public_ip.ip_address
}

output "private_ip" {
  value = hcloud_server.k3s_operator.network[0].ip
}