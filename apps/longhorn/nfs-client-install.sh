# https://longhorn.io/docs/1.4.2/deploy/install/#installing-nfsv4-client
# longhorn RWX를 위한 nfx 설치

# nfs install
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.4.2/deploy/prerequisite/longhorn-nfs-installation.yaml

kubectl get pod | grep longhorn-nfs-installation