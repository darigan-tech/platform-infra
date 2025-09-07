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

// With more apps, we'd deploy this as as for each loop
module "nginx-deployment" {
  source = "./nginx"
  kubeconfig = var.ONLINE_KUBECONFIG
  app_name = var.nginx.app_name
  container = var.nginx.container
  deployment = var.nginx.deployment
  service = var.nginx.service
}

module "file-browser-deployment" {
  source = "./filebrowser"
  kubeconfig = var.ONLINE_KUBECONFIG
  app_name = var.file_browser.app_name
  container = var.file_browser.container
  deployment = var.file_browser.deployment
  service = var.file_browser.service
  volumes = var.file_browser.volumes
}

module "ingress" {
  source = "./ingress"
  kubeconfig = var.ONLINE_KUBECONFIG
  CADDY_EMAIL = var.CADDY_EMAIL
  nginx = {
      name = module.nginx-deployment.service_name
      port = var.nginx.service.port
  }
  file_browser = {
    name = module.file-browser-deployment.service_name
    port = var.file_browser.service.port
  }
}
