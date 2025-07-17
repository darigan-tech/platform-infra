variable "kubeconfig" {
  type = string
  sensitive = true
}

variable "app_name" {
  type = string
}

variable "deployment" {
  type = object({
    name = string
    replicas = number
  })
}

variable "container" {
  type = object({
    name = string
    image = string
    port = number
  })
}

variable "service" {
  type = object({
    name = string
    type = string
    protocol = string
    port = number
    target_port = number
  })
}