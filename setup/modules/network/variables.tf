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