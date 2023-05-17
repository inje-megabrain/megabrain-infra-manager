kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.6.5/manifests/install.yaml &&
    kubectl delete namespace argocd 