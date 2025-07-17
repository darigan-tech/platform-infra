variable "ONLINE_KUBECONFIG" {
  type = string
}

variable "nginx" {
  type = object({
    app_name = string
    deployment = object({
      name = string
      replicas = number
    })
    container = object({
      name = string
      image = string
      port = number
    })
    service = object({
      name = string
      type = string
      protocol = string
      port = number
      target_port = number
    })
  })
}