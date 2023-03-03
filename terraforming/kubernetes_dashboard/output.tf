# Token
output "kubernetes-dashboard-token-value" {
  sensitive = true
  value = data.kubernetes_secret_v1.admin_token
}
