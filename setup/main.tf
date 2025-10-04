resource "hcloud_ssh_key" "pubkey_prod" {
  name       = var.pubkey_name
  public_key = file(var.HCLOUD_PROD_PUBKEY_PATH)
}

module "firewall" {
  source = "./modules/firewall"
  firewall = var.firewall
}

module "network" {
  source = "./modules/network"
  private_network = var.private_network
  private_network_subnet = var.private_network_subnet
}

module "server" {
  source = "./modules/server"
  server = var.server
  private_network_id = module.network.private_network_id
  ssh_key_id = hcloud_ssh_key.pubkey_prod.id
  firewall_id = module.firewall.firewall_id

  user_data = templatefile("${path.module}/cloud-init.yaml", {
    ssh_key = hcloud_ssh_key.pubkey_prod.public_key,
  })
  depends_on = [module.network]
}



