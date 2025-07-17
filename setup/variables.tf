variable "HCLOUD_TOKEN" {
  type        = string
  sensitive   = true
}

variable "hcloud_network" {
  type = object({
    name = string
    ip_range = string
  })
}

variable "hcloud_network_subnet" {
  type = object({
    type         = string,
    network_zone = string
    ip_range     = string
  })
}

variable "hcloud_ssh_key" {
  type = object({
    name = string
    public_key_filepath = string
  })
}

variable "hcloud_server" {
  type = object({
    name = string
    image = string
    server_type = string
    location = string
    host_number = number
  })
}
variable "cloud_init" {
  type = object({
    path = string
  })
}
variable "public_floating_ip" {
  type = object({
    name = string
    type = string
    home_location = string
  })
}