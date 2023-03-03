# Token
output "kubernetes-dashboard-token-value" {
  sensitive = true
  value = resource.kubernetes_secret_v1.admin_token
}
