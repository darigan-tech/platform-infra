variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "ONLINE_KUBECONFIG" {
  type = string
  sensitive = true
}