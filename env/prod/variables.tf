variable "HCLOUD_TOKEN" {
  type = string
  sensitive = true
}

variable "HCLOUD_PROD_PUBKEY_PATH" {
  type = string
}

variable "pubkey_name" {
  type = string
}

variable "private_network" {
  type = object({
    name = string
    ip_range = string
  })
}

variable "private_network_subnet" {
  type = object({
    type = string
    network_zone = string
    ip_range = string
  })
}

variable "firewall" {
  type = object({
    name = string
    rules = list(object({
      direction       = string
      protocol        = string
      port            = optional(string)
      source_ips      = optional(list(string))
      destination_ips = optional(list(string))
      description     = optional(string)
    }))
  })
}

variable "server" {
  type = object({
    name = string
    image = string
    type = string
    location = string
  })
}