// Web Page
resource "kubernetes_deployment_v1" "file_browser_deployment" {
  metadata {
    name = var.deployment.name
    labels = {
      app = var.app_name
    }
  }
  spec {
    replicas = var.deployment.replicas
    selector {
      match_labels = {
        app = var.app_name
      }
    }
    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }
      spec {
        container {
          name = var.container.name
          image = var.container.image
          port {
            container_port = var.container.port
          }
        }
      }
    }
  }

}

# # --- Nginx Service ---
resource "kubernetes_service_v1" "file_browser_service" {
  metadata {
    name = var.service.name
    labels = {
      app = var.app_name
    }
  }
  spec {
    selector = {
      app = var.app_name
    }
    port {
      protocol = var.service.protocol
      port = var.service.port
      target_port = var.service.target_port
    }
    type = var.service.type
  }
}

output "service_name" {
  value = kubernetes_service_v1.file_browser_service.metadata[0].name
}

