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
  token = var.hcloud_token
}

provider "kubernetes" {
  config_path = var.ONLINE_KUBECONFIG
}

// Web Page
resource "kubernetes_deployment_v1" "nginx_deployment" {
  metadata {
    name = "nginx-deployment"
    labels = {
      app = "nginx"
    }
  }
  spec {
    replicas = 1 # Number of Nginx instances
    selector {
      match_labels = {
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }
      spec {
        container {
          name = "nginx-web-server"
          image = "nginx:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }

}
#
# # --- Nginx Service ---
resource "kubernetes_service_v1" "nginx_service" {
  metadata {
    name = "nginx-service"
    labels = {
      app = "nginx"
    }
  }
  spec {
    selector = {
      app = "nginx"
    }
    port {
      protocol    = "TCP"
      port        = 8080
      target_port = 80
    }
    type = "LoadBalancer" # Or "NodePort" if you don't have HCLOUD LoadBalancer integration
  }
}