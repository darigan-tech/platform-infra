terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = var.ONLINE_KUBECONFIG
}

module "production" {
    source = "./prod"
    namespace = "prod"
}

module "staging" {
  source = "./staging"
  namespace = "staging"
}

module "dev" {
  source = "./dev"
  namespace = "dev"
}