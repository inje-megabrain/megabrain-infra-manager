#!/bin/bash

# install k3s on linux 
# k3s for rancher

INSTALL_K3S_VERSION="v1.24.13+k3s1"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${INSTALL_K3S_VERSION} sh -s - server --cluster-init --disable traefik &