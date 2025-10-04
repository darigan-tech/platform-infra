terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"  # <--- Change this line
      version = "~> 1.51"
    }
  }
}