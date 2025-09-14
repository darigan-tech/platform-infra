variable "HCLOUD_TOKEN" {
  type = string
  sensitive = true
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

variable "network" {
  type = object({
    name = string
    ip_range = string
    subnet_ip_range = string
    zone = string
  })
}

variable "server" {
  type = object({
    firewall_id = string
    floating_ip_name = string
    host_number = number
    network_id = string
    server_image = string
    server_name = string
    server_type = string
    ssh_key_name = string
    ssh_key_path = string
    subnet_ip_range = string
    user_data_path = string
  })
}

variable "ssh" {
  type = object({
    key = object({
      name = string
      path = string
    })
    user_data_path = string
  })
}