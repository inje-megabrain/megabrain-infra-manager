# rook-ceph 설치

resource "kubernetes_namespace" "longhorn-namespace" {
  metadata {
    name = "longhorn"
  }
}

resource "helm_release" "longhorn" {
  name  = "longhorn"
  chart = "longhorn/longhorn"
  version = var.longhorn_version
  namespace = kubernetes_namespace.longhorn-namespace.metadata[0].name
  wait_for_jobs = true
  timeout = 2000 # about 30min
  
}

resource "kubernetes_ingress_v1" "longhorn_ingress" {
  metadata {
    name = "longhorn-ingress"
    namespace = "longhorn-system"
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