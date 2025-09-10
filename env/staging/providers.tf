terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.51" # Use the latest stable version
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.23" # Use a compatible version
    }
  }
}

provider "hcloud" {
  token = var.HCLOUD_TOKEN
}