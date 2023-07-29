# Megabrain Infra Manager

이 프로젝트는 Megabrain Kubernetes 인프라를 배포 하고 구성관리 및 Kubernetes를 통한 DevOps를 구축합니다.

- Rancher를 통한 Kubernetes 클러스터 생성 및 관리
- Terraform 및 YAML을 통한 Kubernetes 애플리케이션 배포 및 관리
- Kubernetes 워크로드 모니터링 및 로깅
- GitAction CI, ArgoCD를 통한 Devops 운영

#### 클러스터 필수 구성 애플리케이션 (/terraformming)
- Ingress Nginx v4.5.2
- Kubernetes Dashboard v6.0.7
- Kube-Prometheus-Stack v45.15.0
- Longhorn v1.4.2

#### 애플리케이션 목록 (/apps)
- ArgoCD v2.6.5 : Shell Script [V] 
- Cert-Manager v1.11.0 : Shell Script [V] 
- Keycloak v20.* : 
- Longhorn NFS v1.4.2 : Kubernetes Manifest [V]
- Grafana Image Renderer latest : Kubernetes Manifest [V]

## Get Started 
### 목차
- [Prerequisite](#prerequisite)
- [프로젝트 구조](#프로젝트-구조)
- [1. 클러스터 구축](#1-클러스터-구축)
    - [1.1 K3S 클러스터 구축](#11-k3s-클러스터-구축)
        - [1.1.1 K3S Master Node 구축](#111-k3s-master-node-구축)
        - [1.1.2 K3S Worker Node 구축](#112-k3s-worker-node-구축)
        - [1.1.3 K3S 클러스터의 KubeConfig 등록](#113-k3s-클러스터의-kubeconfig-등록)
        - [1.1.4 K3S 클러스터 확인](#114-k3s-클러스터-확인)
    - [1.2 Rancher 클러스터 구축](#12-rancher-클러스터-구축)
        - [1.2.1 Docker를 통해 Rancher 설치 (권장하지 않음)](#121-docker를-통해-rancher-설치-권장하지-않음)
        - [1.2.2 기본적인 설치 방법 (권장)](#122-기본적인-설치-방법-권장)
        - [1.2.3 Helm으로 Rancher 설치](#123-helm으로-rancher-설치)
        - [1.2.4 Rancher 대시보드 접속](#124-rancher-대시보드-접속)
        - [1.2.5 Rancher로 클러스터 생성](#125-rancher로-클러스터-생성)
        - [1.2.6 Rancher로 Worker Node 등록](#126-rancher로-worker-node-등록)
- [2. 클러스터 필수 구성 설치](#2-클러스터-필수-구성-애플리케이션-설치)
- [3. 애플리케이션 배포](#3-애플리케이션-배포) 
    - [3.1 ArgoCD](#31-argocd)
    - [3.2 Cert-Manager](#32-cert-manager)
- [TODO](#todo)


### Prerequisite

| name      | version |
| --------- | ------- |
| Kubectl   | ^1.22   |
| Helm      | ^3.11.1 |
| Terraform | ^1.3.9  |
| Python    | ^3.11.2 |

### 프로젝트 구조

```shell
.
├── LICENSE
├── README.md
├── apply-kubectl.sh
├── apps/
├── certification/
├── cluster-provision/
└── terraforming/
```

- apps/ kubernetes object manifest 위치
- certification/ kubeconfig 위치
- cluster-provision/ 클러스터 프로비저닝/디프로비저닝을 위한 스크립트 위치
- terraforming/ terraform을 통한 클러스터 구축을 위한 스크립트 위치

## 1. 클러스터 구축

Shell Script 기반의 IaC 를 이용한 클러스터 프로비저닝을 위한 스크립트를 제공합니다.
클러스터는 두가지 방법으로 구축할 수 있습니다.

1. K3S : K3S를 이용한 클러스터 구축
2. Rancher : Rancher를 이용한 클러스터 구축

### 1.1 K3S 클러스터 구축
클러스터 구축을 위한 리눅스 계열의 서버를 준비합니다.

cluster-provision 디렉토리의 `provision.sh` 파일을 열어 `K3S_URL_FULL` 마스터 서버의 IP를 입력해주세요.
다음 스크립트를 Master 서버에서 실행해주세요.

#### 1.1.1 K3S Master Node 구축

```shell
> bash provision.sh master install
```
위 스크립트를 실행하여 Kubernetes의 Master Node를 구축합니다.
실행후 k3s token값을 기록하거나 복사해주세요.

추가적으로 Master Node를 추가하여 클러스터를 구성한다면 
새로운 마스터 서버에 접속하여 다음 스크립트를 실행해주세요.

```shell
> bash provision.sh new-master install --token=<k3s_token>
```

#### 1.1.2 K3S Worker Node 구축

```shell
> bash provision.sh worker install --token=<k3s_token>
```
기록한 k3s token값을 입력하여 Kubernetes의 Worker Node를 구축합니다.


#### 1.1.3 K3S 클러스터의 KubeConfig 등록
구축된 클러스터의 kubeconfig를 로컬에 등록합니다.

```shell

# k3s kubeconfig path
cat /etc/rancher/k3s/k3s.yaml

# k3s kubeconfig copy
scp root@<IP_OF_LINUX_MACHINE>:/etc/rancher/k3s/k3s.yaml ~/.kube/config

# k3s kubeconfig 등록
export KUBECONFIG=~/.kube/config

```

#### 1.1.4 K3S 클러스터 확인
```shell
> kubectl get nodes
```
위 명령어를 통해 클러스터의 노드가 정상적으로 구축되었는지 확인합니다.

추가한 노드가 정상적으로 작동하면 클러스터가 구축되었습니다.

### 1.2 Rancher 클러스터 구축

Kubernetes 클러스터 생성 및 관리를 위해 Rancher를 설치합니다.

#### 1.2.1 Docker를 통해 Rancher 설치 (권장하지 않음)
해당 방법은 Ubuntu 22 이하에서만 해주세요.

```
> cd ./cluster-provision/rancher

> docker-compose up -d
```

#### 1.2.2 기본적인 설치 방법 (권장)
Rancher를 설치하기전 k3s를 설치합니다.

```shell
> bash ./cluster-provision/rancher/install-k3s.sh
```

```shell
scp root@<IP_OF_LINUX_MACHINE>:/etc/rancher/k3s/k3s.yaml ~/.kube/config
```

`/etc/rancher/k3s/k3s.yaml` 경로의 kubeconfig를 로컬 환경의 `~/.kube/config` 로 위치해주세요.
그 후 로컬 환경에서 `KUBECONFIG=~/.kube/config` 환경변수를 정의해주세요.

```shell
> vi ~/.kube/config
```
`server` 항목에 `<노드서버_IP>:6443` 으로 수정합니다.

#### 1.2.3 Helm으로 Rancher 설치
```shell
export IP_OF_LINUX_NODE=<노드서버_IP>
export RANCHER_PASSWORD=<비밀번호>
> bash ./rancher/install-rancher.sh
```
설치하기전 해당 파일에서 `IP_OF_LINUX_NODE` 와 `PASSWORD_FOR_RANCHER_ADMIN` 를 환경변수로 정의후 실행합니다.

#### 1.2.4 Rancher 대시보드 접속

```shell
echo https://${IP_OF_LINUX_NODE}.nip.io/dashboard/?setup\=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')
```

해당 명령어를 실행하여 대시보드 주소를 출력합니다.
정상적으로 접속이 된다면 Rancher 설치가 완료된 것입니다.

#### 1.2.5 Rancher로 클러스터 생성
Rancher 대시보드에서 클러스터를 생성합니다.

```
Cluster Management > Add Cluster > Custom > Cluster Name 입력 > Next > Node Options > Node Name 입력 > Next > Finish
```

Registration Command를 복사하여 Master Node 터미널에 실행합니다.

#### 1.2.6 Rancher로 Worker Node 등록
```
Register an existing Kubernetes cluster > Linux > Copy the command to the clipboard > Next > Finish
```

Registration Command를 복사하여 Worker Node 터미널에 실행합니다.

위 과정을 통해 정상적으로 클러스터가 구축되었습니다.


### 2. 클러스터 필수 구성 애플리케이션 설치
Terraforming을 통해 프로비저닝된 클러스터에 필수적으로 구성되어야할
ingress-nginx, longhorn, kubernetes-dashboard, prometheus, grafana를 배포합니다.

다음 Terraform 명령어를 /terraforming 경로에 위치하여 실행합니다.

```shell

> terraform init

> terraform apply --auto-approve

```

위 명령어를 통해 Terraform 모듈을 통해 애플리케이션을 배포합니다.

다음 4개의 애플리케이션이 배포되었는지 확인합니다.

```shell

> kubectl get pods -n ingress-nginx

> kubectl get pods -n longhorn-system

> kubectl get pods -n kubernetes-dashboard

> kubectl get pods -n monitoring

```

모두 정상적으로 배포되었다면 클러스터 구성에 필수적으로 구성되어야할 애플리케이션을 배포한 것입니다.


### 3. 애플리케이션 배포

Kubernetes 환경에서 구동되는 애플리케이션들을 배포합니다.

#### 3.1 ArgoCD

##### 3.1.1 ArgoCD 설치

```shell

> bash ./apps/argocd/install.sh

> kubectl apply -f ./apps/argocd/ingress.yaml

```

##### 3.1.2 ArgoCD 접속

ingress에 구성된 주소를 통해 접속합니다.

##### 3.1.3 ArgoCD 삭제

```shell

> bash ./apps/argocd/uninstall.sh

> kubectl delete -f ./apps/argocd/ingress.yaml

```

#### 3.2 Cert-Manager

##### 3.2.1 Cert-Manager 설치

```shell

> bash ./apps/cert-manager/install.sh

```

##### 3.2.2 Cert-Manager 삭제

```shell

> bash ./apps/cert-manager/uninstall.sh

```


## TODO
1. ArgoCD Terrafomring 단계로 이전
