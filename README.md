# Megabrain Infra Manager

이 프로젝트는 Megabrain Kubernetes 인프라를 배포 하고 구성관리 및 Kubernetes를 통한 DevOps를 구축합니다.

- Rancher를 통한 Kubernetes 클러스터 생성 및 관리
- Terraform 및 YAML을 통한 Kubernetes 애플리케이션 배포 및 관리
- Kubernetes 워크로드 모니터링 및 로깅
- GitAction CI, ArgoCD를 통한 Devops 운영

## Get Started 

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

shell 기반의 IaC 를 이용한 클러스터 프로비저닝을 위한 스크립트를 제공합니다.
그리고 클러스터 구축을 위해 K3S Manual Install 과 Rancher를 이용한 방법을 제공합니다.

1. K3S Manual Install : K3S를 이용한 클러스터 구축
2. Rancher : Rancher를 이용한 클러스터 구축

### 1. K3S Manual Install Cluster 구축
클러스터 구축을 위한 리눅스 계열의 서버를 준비합니다.

cluster-provision 디렉토리의 `provision.sh` 파일을 열어 `K3S_URL_FULL` 마스터 서버의 IP를 입력해주세요.
다음 스크립트를 Master 서버에서 실행해주세요.

#### 1.1 k3s Master Node 구축

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

#### 1.2 k3s Worker Node 구축

```shell
> bash provision.sh worker install --token=<k3s_token>
```
기록한 k3s token값을 입력하여 Kubernetes의 Worker Node를 구축합니다.


#### 1.3. 프로비저닝된 클러스터의 Kubeconfig 로컬 등록
구축된 클러스터의 kubeconfig를 로컬에 등록합니다.

```shell

# k3s kubeconfig path
cat /etc/rancher/k3s/k3s.yaml

# k3s kubeconfig copy
scp root@<IP_OF_LINUX_MACHINE>:/etc/rancher/k3s/k3s.yaml ~/.kube/config

# k3s kubeconfig 등록
export KUBECONFIG=~/.kube/config

```

### 2. Rancher 설치 및 운영

Kubernetes 클러스터 생성 및 관리를 위해 Rancher를 설치합니다.

#### 2.1 Docker를 통해 설치 (권장하지 않음)
해당 방법은 Ubuntu 22 이하에서만 해주세요.
```
> cd ./rancher

> docker-compose up -d
```

#### 2.2 기본적인 설치 방법 (권장)
Rancher를 설치하기전 k3s를 설치합니다.

```shell
> bash ./rancher/install-k3s.sh
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

#### 2.2.1 Helm으로 Rancher 설치
```shell
export IP_OF_LINUX_NODE=<노드서버_IP>
export RANCHER_PASSWORD=<비밀번호>
> bash ./rancher/install-rancher.sh
```
설치하기전 해당 파일에서 `IP_OF_LINUX_NODE` 와 `PASSWORD_FOR_RANCHER_ADMIN` 를 환경변수로 정의후 실행합니다.

### 3. 대시보드 접속

```shell
echo https://${IP_OF_LINUX_NODE}.nip.io/dashboard/?setup\=$(kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}')
```

해당 명령어를 실행하여 대시보드 주소를 출력합니다.

... 이후 작성중

### 5. Terraforming
Terraforming을 통해 프로비저닝된 클러스터에 필수적으로 구성되어야할
ingress-nginx, longhorn, kubernetes-dashboard, prometheus, grafana를 배포합니다.

다음 Terraform 명령어를 /terraforming 경로에 위치하여 실행합니다.

```shell   

> terraform init

> terraform apply --auto-approve

```

### 6. Application 배포


# TODO

1. ArgoCD Terrafomring 단계로 이전
