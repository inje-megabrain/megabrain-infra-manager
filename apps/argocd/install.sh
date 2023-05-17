kubectl create namespace argocd ||
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.6.5/manifests/install.yaml &&
  kubectl get secret -n argocd argocd-initial-admin-secret --template={{.data.password}} | base64 -D