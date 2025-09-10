module "network" {
  source = "../../modules/network"
  network = var.network
}

module "firewall" {
  source = "../../modules/firewall"
  name   = var.firewall.name
  rules = var.firewall.rules
}

module "server" {
  source = "../../modules/server"
  firewall_id = var.server.firewall_id
  floating_ip_name = var.server.floating_ip_name
  host_number = var.server.host_number
  network_id = var.server.network_id
  server_image = var.server.server_image
  server_name = var.server.server_name
  server_type = var.server.server_type
  ssh_key_name = var.server.ssh_key_name
  ssh_key_path = var.server.ssh_key_path
  subnet_ip_range = var.server.subnet_ip_range // ???
  user_data_path = var.server.user_data_path // ??
}

