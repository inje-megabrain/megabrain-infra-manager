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
  version = "4.5.2"
  wait = true
  wait_for_jobs = true
  timeout = 6000 # about 60min

  set {
    name = "controller.service.nodePorts.http"
    value = "32580"
  }

  set {
    name = "controller.service.nodePorts.https"
    value = "32443"
  }
}