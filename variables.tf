# variables.tf
variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "k3s_token" {
  type = string
  sensitive = true
}
