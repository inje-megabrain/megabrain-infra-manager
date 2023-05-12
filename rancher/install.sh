# install k3s on linux

INSTALL_K3S_VERSION="v1.24.10+k3s1"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=<VERSION> sh -s - server --cluster-init &
