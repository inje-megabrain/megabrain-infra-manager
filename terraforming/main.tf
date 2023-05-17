# terraform init, apply, destroy
# terraform apply -
# Provider Init#
# Kube Config 주입
provider "kubernetes" {
  config_path = var.config_path
}

provider "helm" {
  kubernetes {
    config_path = var.config_path
  }
}

module "ingress_nginx" {
  source = "./ingress_nginx"

  # vars
}

module "kubernetes_dashboard" {
  depends_on = [
    module.ingress_nginx
  ]
  source = "./kubernetes_dashboard"

  # vars
  ingress_domain = var.ingress_domain
}  


module "storage_longhorn" {
  depends_on = [ module.ingress_nginx ]
  source = "./storage_longhorn"
  
  # vars
  ingress_domain = var.ingress_domain
}

module "prometheus_grafana" {
  depends_on = [ module.ingress_nginx, module.storage_longhorn]
  source = "./prometheus_grafana"

  ingress_domain = var.ingress_domain
}

# module "rook-ceph" {
#   source = "./rook-ceph"
  
#   # vars
#   master_ip = var.master_ip
#   ingress_domain = var.ingress_domain
# }

output "kuberentes_dashboard_token" {
  value = module.kubernetes_dashboard.kubernetes-dashboard-token-value
  sensitive = true
}
