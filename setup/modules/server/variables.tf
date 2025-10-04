variable "server" {
  type = object({
    name = string
    image = string
    type = string
    location = string
  })
}

variable "private_network_id" {
  type = string
}

variable "user_data" {
  type = string
  sensitive = true
}

variable "ssh_key_id" {
  type = string
  sensitive = true
}

variable "firewall_id" {
  type = string
}