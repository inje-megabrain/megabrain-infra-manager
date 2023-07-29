

# Certmanager가 필수로 요구됨

# 1. 수동으로 올라간 기존 ingress를 수정하는 방법
kubectl edit deployment.apps/kubernetes-dashboard -n kubernetes-dashboard

## 1.1 annotation 추가
cert-manager.io/cluster-issuer: "letsencrypt-prod"

## 1.2 spec.tls 추가 
  tls:
  - hosts: 
    - dashboard.k8s.domain.com
    secretName: k8s-dashboard-secret

# 2. 자동 스크립트 
kubectl apply -f ingress-apply-cert.yaml -n kubernetes-dashboard