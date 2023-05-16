
# 추가적으로 외부 노출 시 해당 cert manager 설치합니다.
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml

helm repo add jetstack https://charts.jetstack.io

helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.11.0 

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

kubectl create namespace cattle-system

helm install rancher rancher-latest/rancher \
    --namespace cattle-system \
    --set hostname=${IP_OF_LINUX_NODE}.nip.io \
    --set replicas=1 \
    --set bootstrapPassword=${RANCHER_PASSWORD}


echo https://${IP_OF_LINUX_NODE}.nip.io/dashboard/?setup=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')