terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.51" # Use the latest stable version
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.23" # Use a compatible version
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "kubernetes" {
  config_path = var.ONLINE_KUBECONFIG
}

resource "hcloud_network" "k3s_private_network" {
  # "CIDR range for the private network"
  name     = "k3s-private-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "k3s_private_subnet" {
  # "CIDR range for the private subnet"
  network_id   = hcloud_network.k3s_private_network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_ssh_key" "k3s_ssh_key" {
  name       = "k3s-ssh-key"
  public_key = file("~/.ssh/id_hetzner_k3s.pub")
}

resource "hcloud_server" "k3s_operator" {
  name       = "personal-k3s-cloud"
  image      = "ubuntu-22.04"
  server_type = "cax11"
  location   = "fsn1"
  ssh_keys   = [hcloud_ssh_key.k3s_ssh_key.id]

  # Attach to the private network
  network {
    network_id = hcloud_network.k3s_private_network.id
    ip         = cidrhost(hcloud_network_subnet.k3s_private_subnet.ip_range, 10) # e.g., 10.0.1.10

  }

  user_data = templatefile("cloud-init.yaml", {
    ssh_key = file("~/.ssh/id_hetzner_k3s.pub")
    k3s_advertise_address   = hcloud_floating_ip.k3s_operator_public_ip.ip_address
  })

  # Ensure network is created before the server
  depends_on = [
    hcloud_network_subnet.k3s_private_subnet
  ]
}

# Floating IP for public access to the K3s API server
resource "hcloud_floating_ip" "k3s_operator_public_ip" {
  type            = "ipv4"
  home_location   = "fsn1"
  name            = "k3s-master-float-ip"
}

# Assign floating IP
resource "hcloud_floating_ip_assignment" "k3s_operator_public_ip_assign" {
  floating_ip_id = hcloud_floating_ip.k3s_operator_public_ip.id
  server_id      = hcloud_server.k3s_operator.id
}

# --- Fetch and Output Kubeconfig ---
# resource "null_resource" "get_k3s_kubeconfig" {
#   # This dependency ensures the server is up and K3s has likely installed.
#   # We also need to wait for the floating IP to be assigned.
#   depends_on = [
#     hcloud_server.k3s_operator,
#     hcloud_floating_ip_assignment.k3s_operator_public_ip_assign # Ensure IP is assigned
#   ]
#
#   # This 'null_resource' simply acts as a trigger to run the local-exec command
#   # after the server and IP are ready.

#   provisioner "local-exec" {
#     # It's good practice to add a sleep here in case the server needs a moment
#     # for K3s to be fully up and the kubeconfig file written after cloud-init.
#     # The SSH command will directly fetch the content.
#     command = <<EOT
#       # Give the server a moment for K3s to be fully ready
#       sleep 90 # Increased sleep, K3s can take a bit longer to stabilize
#
#       # SSH command to fetch the kubeconfig content
#       # -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null to avoid host key prompts
#       # We use 'sudo cat' to read the file, and then sed to replace the IP.
#       KUBECONFIG_RAW_CONTENT="$(ssh -i ${"~/.ssh/id_hetzner_k3s"} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${hcloud_floating_ip.k3s_operator_public_ip.ip_address} 'sudo chmod 644 /etc/rancher/k3s/k3s.yaml && sudo cat /etc/rancher/k3s/k3s.yaml' | sed 's/127.0.0.1/${hcloud_floating_ip.k3s_operator_public_ip.ip_address}/g')"
#
#       # Write the processed kubeconfig content to a local file
#       echo "$KUBECONFIG_RAW_CONTENT" > ${"~/.kube/online-config.yaml"}
#       echo "Kubeconfig written to: ${"~/.kube/online-config.yaml"}
#     EOT
#   }
#
#   triggers = {
#     # These triggers ensure the local-exec runs if the server or IP changes.
#     server_id  = hcloud_server.k3s_operator.id
#     float_ip   = hcloud_floating_ip.k3s_operator_public_ip.ip_address
#     # Add a timestamp to always regenerate on apply (useful during development)
#     always_run = timestamp()
#   }
# }