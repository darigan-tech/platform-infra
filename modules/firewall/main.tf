resource "hcloud_firewall" "k3s_firewall" {
  name   = var.firewall.name
    dynamic "rule" {
    for_each = var.firewall.rules
    content {
      direction       = rule.value.direction
      protocol        = rule.value.protocol
      port            = rule.value.port
      source_ips      = rule.value.source_ips
      destination_ips = rule.value.destination_ips
      description     = rule.value.description
    }
  }
}

