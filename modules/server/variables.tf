variable "ssh_key_name" {
  type        = string
  description = "The name of the SSH key resource."
}

variable "ssh_key_path" {
  type        = string
  description = "The path to the public SSH key file."
}

variable "floating_ip_name" {
  type        = string
  description = "The name for the floating IP resource."
}

variable "server_name" {
  type        = string
  description = "The name of the server."
}

variable "server_image" {
  type        = string
  description = "The server image to use (e.g., 'ubuntu-22.04')."
}

variable "server_type" {
  type        = string
  description = "The server type (e.g., 'cpx11')."
}

variable "location" {
  type        = string
  description = "The Hetzner Cloud location for the server."
  default     = "fsn1"
}

variable "firewall_id" {
  type        = string
  description = "The ID of the firewall to attach to the server."
}

variable "network_id" {
  type        = string
  description = "The ID of the private network to attach to the server."
}

variable "subnet_ip_range" {
  type        = string
  description = "The IP range of the subnet for the server's private IP."
}

variable "host_number" {
  type        = number
  description = "The host number in the subnet IP range to assign to the server."
}

variable "user_data_path" {
  type        = string
  description = "The path to the user data script for cloud-init."
}

