variable config_path {
  type        = string
  default     = "../certification/mega-cluster.yaml"
  description = "Kubernetes-config path"
}

variable master_ip {
  type = string
  default = ""
}

variable "ingress_domain" {
  type = string
  default = "megabrain.kr"
}

