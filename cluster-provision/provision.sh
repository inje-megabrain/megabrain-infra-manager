#!/bin/bash

## ENV VARS
K3S_VERSION="v1.24.13+k3s1"
K3S_TOKEN="" 

if [ -z $1 ]; then
    bash $0 --help
    exit 1
fi

# param $1 : token
getToken() {
    if [ -z $1 ] || [[ !($1 =~ "--token=") ]]; then
        echo "--token 옵션을 입력해주세요."
        exit 1
    fi  
    K3S_TOKEN=$(echo $1 | cut -d "=" -f 2)

    if [ -z $K3S_TOKEN ]; then
        echo "토큰을 입력해주세요."
        exit 1
    fi
}

while getopts b-: OPT; do
    echo "메가브레인 Cluster Provision (클러스터 구축/삭제) 스크립트"
    echo "해당 스크립트는 Linux 기반의 쿠버네티스 클러스터 구축을 위해 작성되었습니다."
    echo "created by 박성훈"
    echo ""

    if [ $OPT = - ]; then
        OPT=${OPTARG%%=*}
        OPTARG=${OPTARG#$OPT}
        OPTARG=${OPTARG#=}
    fi

    case $OPT in
        master)
            case $2 in
                i | install | c | create )
                    echo "Start master k3s install"

                    curl -sfL https://get.k3s.io | \
                    INSTALL_K3S_VERSION=${K3S_VERSION} \
                        sh -s - server \
                        --cluster-init \
                        --disable traefik \
                        --disable local-storage
                    
                    K3S_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
                    ;;
                u | uninstall | d | destroy )
                    echo "Start master k3s uninstall"
                    /usr/local/bin/k3s-uninstall.sh
                    ;;
                t | token )
                    K3S_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
                    ;;
                *)
                    echo "Usage: $0 --master [install | uninstall | token]"
                    exit 1
                    ;;
            esac
            ;;
        new-master)
            case $2 in 
                i | install | c | create )
                    echo "Start new master k3s install"
                    getToken $3
                    # New Master Join
                    curl -sfL https://get.k3s.io | \
                        INSTALL_K3S_VERSION=${K3S_VERSION} \
                        K3S_TOKEN=${K3S_TOKEN} \
                        sh -s - server \
                        --server https://${K3S_URL_FULL}:6443 \
                        --disable traefik \
                        --disable local-storage                    
                ;;
                u | uninstall | d | destroy )
                    echo "Start new master k3s uninstall"
                    /usr/local/bin/k3s-uninstall.sh
                ;;
                * )
                    echo "Usage: $0 --new-master [install | uninstall] [--token <token>]]"
                    exit 1
            esac
            ;;
        worker)
            case $2 in
                i | install | c | create )
                    echo "Start worker k3s install"
                    getToken $3
                    curl -sfL: https://get.k3s.io | \
                        INSTALL_K3S_VERSION=${K3S_VERSION} K3S_URL=https://${K3S_URL_FULL}:6443 K3S_TOKEN=${K3S_TOKEN} sh -
                ;;
                u | uninstall | d | destroy )
                    echo "Start worker k3s uninstall"
                    /usr/local/bin/k3s-agent-uninstall.sh
                ;;
                * )
                    echo "Usage: $0 --worker [install | uninstall]"
                    exit 1
                ;;
            esac
            ;;
        * | h | help | ?)
            echo "Usage: $0 [--master] [--new-master] [--worker] [--help]"
            exit 
            ;;
    esac
done
