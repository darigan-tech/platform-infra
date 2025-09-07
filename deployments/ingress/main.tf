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
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "2.32.0"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig
  }
}

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "drive_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "drive_tls_cert" {
  private_key_pem = tls_private_key.drive_tls_key.private_key_pem
  validity_period_hours = 8760
  subject {
    common_name  = "drive.darigan.tech"
    organization = "Drive Darigan Tech"
  }

  dns_names = [
    "sub.drive.darigan.tech"
  ]

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
}

resource "kubernetes_secret" "drive_tls_secret" {
  metadata {
    name      = "myexampled-tech-tls-secret"
    namespace = "default"
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.crt" = tls_self_signed_cert.drive_tls_cert.cert_pem
    "tls.key" = tls_private_key.drive_tls_key.private_key_pem
  }
}

resource "kubernetes_ingress_v1" "caddy_ingress" {
  metadata {
    name = "whoami-ingress"
    annotations = {
      "kubernetes.io/ingress.class" : "caddy"
    }
  }
  spec {
    ingress_class_name = "caddy"
    rule {
      host = "sub.drive.darigan.tech"
      http {
        path {
          path     = "/"
          path_type = "Prefix"
          backend {
            service {
              name = var.file_browser.name
              port {
                number = var.file_browser.port
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
          path     = "/*"
          path_type = "Prefix"
          backend {
            service {
              name = var.nginx.name
              port {
                number = var.nginx.port
              }
            }
          }
        }
      }
    }
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
        size = "1Gi"
      }
      service = {
        type = "LoadBalancer"
      }
    })
  ]
}

variable "file_browser" {
  type = object({
    name = string
    port = number
  })
}

variable "nginx" {
  type = object({
    name = string
    port = number
  })
}

variable "CADDY_EMAIL" {
  type = string
}

variable "kubeconfig" {
  type = string
  sensitive = true
}