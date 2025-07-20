terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = var.ONLINE_KUBECONFIG
}

provider "helm" {
  kubernetes {
    config_path = var.ONLINE_KUBECONFIG
  }
}

resource "kubernetes_namespace_v1" "caddy_system" {
  metadata {
    name = "caddy-system"
  }
}

resource "helm_release" "caddy_ingress_controller" {
  name       = "caddy-ingress-controller"
  repository = "https://caddyserver.github.io/ingress/"
  chart      = "caddy-ingress-controller"
  namespace  = kubernetes_namespace_v1.caddy_system.metadata[0].name


  # Values to configure the Caddy Ingress Controller
  values = [
    yamlencode({
      ingressController = {
        config = {
          automaticHTTPS = true
          email = var.CADDY_EMAIL
        }
      }
      persistence = {
        enabled = true
        # storageClassName = "standard" # <--- IMPORTANT: Uncomment and set if your K3s cluster has a specific StorageClass
        #      (e.g., 'gp2' on AWS, 'standard' on GCP, or 'local-path' for K3s default)
        #      If left commented, it will use the default StorageClass if one exists.
        size = "1Gi" # Adjust size as needed for certificate storage
      }
      # If you need to expose Caddy via a LoadBalancer (e.g., on a cloud provider)
      service = {
        type = "LoadBalancer"
      }
    })
  ]
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

// Error:
/* Errors
* Connection Refused - Open Firewall 80 & 443 to all addresses for challenges
* secrets "caddy.ingress--acme.acme-v02.api.letsencrypt.org-directory.users.default.default.key" already exists; Delete the secret from the namespace
 */
resource "kubernetes_ingress_v1" "caddy_ingress" {
  metadata {
    name = "whoami-ingress"
    annotations = {
      # Explicitly tell Kubernetes to use the caddy IngressClass
      "kubernetes.io/ingress.class" : "caddy"
    }
  }
  spec {
    # Specify the IngressClass that the Caddy Ingress Controller creates
    ingress_class_name = "caddy"
    rule {
      host = "drive.darigan.tech" # CHANGE THIS to a domain you control!
      http {
        path {
          path     = "/"
          path_type = "Prefix"
          backend {
            service {
              name = module.file-browser-deployment.service_name
              port {
                number = var.file_browser.service.port
              }
            }
          }
        }
      }
    }
    rule {
      host = "web.darigan.tech"
      http {
        path {
          path     = "/"
          path_type = "Prefix"
          backend {
            service {
              name = module.nginx-deployment.service_name
              port {
                number = var.nginx.service.port
              }
            }
          }
        }
      }
    }
  }
}