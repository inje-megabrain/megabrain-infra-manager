# longhorn 설치

resource "kubernetes_namespace" "longhorn-namespace" {
  metadata {
    name = "longhorn-system"
  }
}

resource "helm_release" "longhorn-release" {
  name  = "longhorn"
  chart = "longhorn"
  repository = "https://charts.longhorn.io"
  version = var.longhorn_version
  namespace  = kubernetes_namespace.longhorn-namespace.metadata[0].name
  wait_for_jobs = true
  timeout = 3000 # about 30min
}

resource "kubernetes_ingress_v1" "longhorn_ingress" {
  metadata {
    name = "longhorn-ingress"
    namespace = kubernetes_namespace.longhorn-namespace.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class": "nginx"
      "nginx.ingress.kubernetes.io/proxy-body-size": "1000000m"
    }
  }
  spec {
    rule {
      host = "longhorn.${var.ingress_domain}"
      http {
        path {
          path = "/"

          backend {
            service {
              name = "longhorn-frontend"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}