#!/bin/bash

helm repo add jetstack https://charts.jetstack.io &&
    helm install cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        --version v1.11.0 \
        --set installCRDs=true 