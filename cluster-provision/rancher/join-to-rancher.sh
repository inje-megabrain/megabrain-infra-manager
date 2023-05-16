#!/bin/bash

source ./env.sh

# #sudo apt update
# #sudo apt -y dist-upgrade

# #Ubuntu (Docker install)
# #sudo apt -y install docker.io

# sudo apt -y install linux-image-extra-$(uname -r)

# #Debian 9 (Docker install)
# #sudo apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common
# #curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
# #sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
# #sudo apt update
# #sudo apt -y install docker-ce

# sudo mkdir -p /etc/systemd/system/docker.service.d/
# sudo cat <<EOF > /etc/systemd/system/docker.service.d/mount_propagation_flags.conf
# [Service]
# MountFlags=shared
# EOF

# sudo systemctl daemon-reload
# sudo systemctl restart docker.service

#This is dependent on your Rancher server
sudo docker run -d --privileged \ 
--restart=unless-stopped \ 
--net=host -v /etc/kubernetes:/etc/kubernetes \
-v /var/run:/var/run \ 
rancher/${RANCHER_AGENT_DOCKER_IMAGE} \ # image
--server ${RANCHER_HOST_IP} \ 
# --token ${RANCHER_TOKEN} \ 
# --ca-checksum ${RANCHER_CA_CHECKSUM} \ 
--etcd --controlplane --workerz