
resource "kubernetes_namespace" "monitoring-namespace" {
  metadata {
    name = "monitoring"
  }
}


resource "helm_release" "prometheus-community" {
  name = "prometheus-community"
  chart      = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  namespace = kubernetes_namespace.monitoring-namespace.metadata[0].name
  version = "45.15.0"
  wait_for_jobs = true
  cleanup_on_fail = true

  set {
    name = "prometheus-node-exporter.hostRootFsMount.enabled"
    value = "false"
  }
  

  set {
    name ="grafana.adminPassword"
    value = "mega123!@#"
  }

  set {
    name = "grafana.deploymentStrategy.type"
    value = "Recreate"
  }

  set {
    name = "grafana.persistence.enabled"
    value = "true"
  }

  set {
    name = "grafana.persistence.type"
    value = "pvc"
  }

  set {
    name = "grafana.persistence.size"
    value = "5Gi"
  }

  set {
    name = "grafana.persistence.storageClassName"
    value = "longhorn"
  }

  set {
    name = "grafana.persistence.accessModes[0]"
    value = "ReadWriteOnce"
  }

  set {
    name = "grafana.persistence.finalizers[0]"
    value = "kubernetes.io/pvc-protection"
  }

  set {
    name = "prometheus.prometheusSpec.enableAdminAPI"
    value = "true"
  }

  set {
    name = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = "longhorn"
  }

  set {
    name = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "10Gi"
  }

  set {
    name = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]"
    value = "ReadWriteOnce"
  }

  set {
    name = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  set {
    name = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }

  set {
    name = "grafana.ini.server.root_url"
    value = "https://dashboard.grafana.${var.ingress_domain}"
  }

  set {
    name = "grafana.env.GF_SERVER_ROOT_URL"
    value = "https://dashboard.grafana.${var.ingress_domain}"
  }

  set {
    name = "grafana.imageRenderer.enabled"
    value = "true"
  }

  set {
    name = "grafana.imageRenderer.env.GF_RENDERING_SERVER_URL"
    value = "http://prometheus-community-grafana-image-renderer.monitoring:8081/render"
  }

  set {
    name = "grafana.imageRenderer.env.GF_RENDERING_CALLBACK_URL"
    value = "http://prometheus-community-grafana.monitoring:80/"
  }

}

resource "kubernetes_ingress_v1" "prometheus_ingress" {
  metadata {
    name = "prometheus-ingress"
    namespace = kubernetes_namespace.monitoring-namespace.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class": "nginx"
      "nginx.ingress.kubernetes.io/backend-protocol": "HTTP"
      "nginx.ingress.kubernetes.io/proxy-body-size": "1000000m"
      "cert-manager.io/cluster-issuer": "letsencrypt-prod"
    }
  }
  spec {
    tls {
      hosts = [
        "dashboard.prometheus.${var.ingress_domain}"
      ]
      secret_name = "prometheus-ingress-tls"
    }

    rule {
      host = "dashboard.prometheus.${var.ingress_domain}"
      http {
        path {
          path = "/"

          backend {
            service {
              name = "prometheus-community-kube-prometheus"
              port {
                number = 9090
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "grafana_ingress" {
  metadata {
    name = "grafana-ingress"
    namespace = kubernetes_namespace.monitoring-namespace.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class": "nginx"
      "nginx.ingress.kubernetes.io/backend-protocol": "HTTP"
      "nginx.ingress.kubernetes.io/proxy-body-size": "1000000m"
      "cert-manager.io/cluster-issuer": "letsencrypt-prod"
    }
  }
  spec {
    tls {
      hosts = [
        "dashboard.grafana.${var.ingress_domain}"
      ]
      secret_name = "grafana-ingress-tls"
    }

    rule {
      host = "dashboard.grafana.${var.ingress_domain}"
      http {
        path {
          path = "/"

          backend {
            service {
              name = "prometheus-community-grafana"
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

