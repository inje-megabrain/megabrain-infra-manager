# Ingress-nginx 설치
resource "kubernetes_namespace" "ingress-nginx-namespace" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx"
  chart = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace = kubernetes_namespace.ingress-nginx-namespace.metadata[0].name
  version = "4.6.1"
  wait = true

  set {
    name = "controller.service.nodePorts.http"
    value = "32580"
  }

  set {
    name = "controller.service.nodePorts.https"
    value = "32443"
  }
}
