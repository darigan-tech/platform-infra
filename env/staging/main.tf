resource "kubernetes_namespace_v1" "env_namespace" {
  metadata {
    name = var.namespace
  }
}