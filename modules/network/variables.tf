variable "network" {
  type = object({
    name = string
    ip_range = string
    subnet_ip_range = string
    zone = string
  })
}