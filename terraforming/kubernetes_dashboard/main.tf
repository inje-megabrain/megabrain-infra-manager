
resource "kubernetes_namespace" "kubernetes-dashboard-namespace" {
  metadata {
    name = "kubernetes-dashboard"
  }
}

resource "helm_release" "dashboard" {
  name = "kubernetes-dashboard"
  chart      = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  namespace = kubernetes_namespace.kubernetes-dashboard-namespace.metadata[0].name
  version = "6.0.7"
  wait_for_jobs = true
  cleanup_on_fail = true

  set {
    name = "extraArgs"
    value = "{--token-ttl=0}"
  }
}

resource "kubernetes_ingress_v1" "kubernetes_dashboard_ingress" {
  metadata {
    name = helm_release.dashboard.name
    namespace = kubernetes_namespace.kubernetes-dashboard-namespace.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class": "nginx"
      "nginx.ingress.kubernetes.io/backend-protocol": "HTTPS"
      "nginx.ingress.kubernetes.io/proxy-body-size": "1000000m"
    }
  }
  spec {
    tls {
      hosts = [
        "dashboard.k8s.${var.ingress_domain}"
      ]
    }

    rule {
      host = "dashboard.k8s.${var.ingress_domain}"
      http {
        path {
          path = "/"

          backend {
            service {
              name = "kubernetes-dashboard"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }
}

# Service Account 생성
resource "kubernetes_service_account_v1" "admin-user-sa" {
  depends_on = [
    helm_release.dashboard
  ]

  metadata {
    namespace = kubernetes_namespace.kubernetes-dashboard-namespace.metadata[0].name
    name = "admin-user"
  }
}

# ClusterRoleBinding 
resource "kubernetes_cluster_role_binding" "admin-user-crb" {
  metadata {
    name = kubernetes_service_account_v1.admin-user-sa.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name = kubernetes_service_account_v1.admin-user-sa.metadata[0].name
    namespace = kubernetes_namespace.kubernetes-dashboard-namespace.metadata[0].name
  }
}

# token
resource "kubernetes_secret_v1" "admin_token" {
  metadata {    
    name      = kubernetes_service_account_v1.admin-user-sa.metadata[0].name
    namespace = kubernetes_namespace.kubernetes-dashboard-namespace.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.admin-user-sa.metadata[0].name
    }

  } 
  type = "kubernetes.io/service-account-token"
}
