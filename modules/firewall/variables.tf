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