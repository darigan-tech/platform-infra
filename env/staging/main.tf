module "network" {
  source = "../../modules/network"
  network = var.network
}

module "firewall" {
  source = "../../modules/firewall"
  firewall = var.firewall
}

module "server" {
  source = "../../modules/server"
  server = var.server
  firewall_id = var.server.firewall_id
  ssh = {}
}

