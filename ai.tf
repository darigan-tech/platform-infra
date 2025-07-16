# # ai.tf (for Phase 1: Hetzner Infra and K3s Installation)
#
# terraform {
#   required_providers {
#     hcloud = {
#       source  = "hetznercloud/hcloud"
#       version = "~> 1.51"
#     }
#   }
# }
#
# # Provider for Hetzner Cloud
# provider "hcloud" {
#   token = var.hcloud_token
# }
#
# # --- Hetzner Cloud Infrastructure Resources ---
#
# # (Optional) Volume definition - uncomment and fill if needed
# # resource "hcloud_volume" "primary" {
# #   name = "k3s-data-volume"
# #   size = 50 # Example size in GB
# #   location = hcloud_server.k3s_operator.location # Must be same location as server
# #   format = "ext4"
# #   delete_protection = true
# # }
# # resource "hcloud_volume_attachment" "primary_attachment" {
#   volume_id = hcloud_volume.primary.id
# #   server_id = hcloud_server.k3s_operator.id
# #   automount = true
# # }
#
#
# # Private Network
# resource "hcloud_network" "k3s_private_network" {
#   name     = "k3s-private-network"
#   ip_range = "10.0.0.0/16"
# }
#
# resource "hcloud_network_subnet" "k3s_private_subnet" {
#   network_id   = hcloud_network.k3s_private_network.id
#   type         = "cloud"
#   network_zone = "eu-central" # Or your desired location
#   ip_range     = "10.0.1.0/24"
# }
#
# # SSH Key for Server Access
# resource "hcloud_ssh_key" "k3s_ssh_key" {
#   name       = "k3s-ssh-key"
#   public_key = file(var.public_ssh_key_path) # Use variable for path
# }
#
# # Hetzner Cloud Server for K3s
# resource "hcloud_server" "k3s_operator" {
#   name       = "personal-k3s-cloud"
#   image      = "ubuntu-22.04"
#   server_type = "cax11"
#   location   = "fsn1" # Or your desired location (must match network_zone for private net)
#   ssh_keys   = [hcloud_ssh_key.k3s_ssh_key.id]
#
#   network {
#     network_id = hcloud_network.k3s_private_network.id
#     ip         = cidrhost(hcloud_network_subnet.k3s_private_subnet.ip_range, 10) # 10.0.1.10
#   }
#
#   # --- IMPORTANT: Cloud-init for K3s installation ---
#   user_data = templatefile("cloud-init.yaml", {
#     ssh_key                 = file(var.public_ssh_key_path)
#     # Pass the Floating IP to cloud-init so K3s advertises it
#     k3s_advertise_address   = hcloud_floating_ip.k3s_operator_public_ip.ip_address
#   })
#
#   depends_on = [
#     hcloud_network_subnet.k3s_private_subnet
#   ]
# }
#
# # Floating IP for public access to the K3s API server
# resource "hcloud_floating_ip" "k3s_operator_public_ip" {
#   type            = "ipv4"
#   home_datacenter = hcloud_server.k3s_operator.location
#   name            = "k3s-master-float-ip"
# }
#
# resource "hcloud_floating_ip_assignment" "k3s_operator_public_ip_assign" {
#   floating_ip_id = hcloud_floating_ip.k3s_operator_public_ip.id
#   server_id      = hcloud_server.k3s_operator.id
# }
#
# # --- Fetch and Output Kubeconfig ---
# resource "null_resource" "get_k3s_kubeconfig" {
#   # This dependency ensures the server is up and K3s has likely installed
#   depends_on = [hcloud_server.k3s_operator]
#
#   provisioner "remote-exec" {
#     inline = [
#       "sleep 60", # Give K3s a bit more time to fully start and generate config
#       "sudo chmod 644 /etc/rancher/k3s/k3s.yaml", # Ensure permissions for copying
#       "sudo cat /etc/rancher/k3s/k3s.yaml",
#     ]
#     connection {
#       type        = "ssh"
#       user        = "root" # Or 'cluster' user if that's what you set up and has sudo
#       host        = hcloud_floating_ip.k3s_operator_public_ip.ip_address
#       private_key = file(var.private_ssh_key_path) # Need the private key here
#     }
#   }
#
#   # Local-exec to write the kubeconfig to a file on your local machine
#   # We use the raw output from the remote-exec and directly replace the IP
#   provisioner "local-exec" {
#     command = <<EOT
#       KUBECONFIG_RAW=$(echo "${self.provisioners.remote-exec.stdout}" | tr -d '\r')
#       echo "$KUBECONFIG_RAW" | sed 's/127.0.0.1/${hcloud_floating_ip.k3s_operator_public_ip.ip_address}/g' > ${path.module}/kubeconfig_personal-k3s-cloud.yaml
#       echo "Kubeconfig written to: ${path.module}/kubeconfig_personal-k3s-cloud.yaml"
#     EOT
#   }
#
#   triggers = {
#     # Force recreation if server ID changes or floating IP changes
#     server_id = hcloud_server.k3s_operator.id
#     float_ip = hcloud_floating_ip.k3s_operator_public_ip.ip_address
#   }
# }
#
# # Output the path to the generated kubeconfig file
# output "k3s_kubeconfig_path" {
#   value = "${path.module}/kubeconfig_personal-k3s-cloud.yaml"
#   description = "Local path to the generated K3s kubeconfig file"
# }
#
# output "k3s_master_public_ip" {
#   value = hcloud_floating_ip.k3s_operator_public_ip.ip_address
#   description = "Public IP address of the K3s master node"
# }