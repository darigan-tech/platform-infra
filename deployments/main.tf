// With more apps, we'd deploy this as as for each loop
module "nginx-deployment" {
  source = "./nginx"
  kubeconfig = var.ONLINE_KUBECONFIG
  app_name = var.nginx.app_name
  container = var.nginx.container
  deployment = var.nginx.deployment
  service = var.nginx.service
}