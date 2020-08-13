---
layout: page
title: Поднимаем кластер kubernetes с помощью утилиты rke в системе виртуализации firecracker
date: 2020-08-13
comments: true
published: true
categories:
- linux
- centos
- debian
- amazon
- virtualization
- kvm
- firecracker
- kubernetes
- manual
- rancher
- rke
---

**Поднимаем кластер kubernetes с помощью утилиты rke в системе виртуализации firecracker** <!--more-->


В этой статье продолжаю исследовать [Firecracker](https://github.com/firecracker-microvm/firecracker/).  Совместно с утилитой rke можно легко установить кластер Kubernetes.

Firecracker - *это технология виртуализации с открытым исходным кодом, предназначенная для создания и управления защищенными, мультитенантными контейнерными и функциональными сервисами, обеспечивающими бессерверные операционные модели. Firecracker запускает рабочие нагрузки в облегченных виртуальных машинах, называемых microVMs, которые сочетают свойства безопасности и изоляции, предоставляемые технологией аппаратной виртуализации, со скоростью и гибкостью контейнеров.*

RKE - *Rancher Kubernetes Engine (RKE) is a CNCF-certified Kubernetes distribution that runs entirely within Docker containers. It works on bare-metal and virtualized servers. RKE solves the problem of installation complexity, a common issue in the Kubernetes community. With RKE, the installation and operation of Kubernetes is both simplified and easily automated, and it’s entirely independent of the operating system and platform you’re running. As long as you can run a supported version of Docker, you can deploy and run Kubernetes with RKE.*
  
## План работ

* Вступительное слово;
* Обсуждение архитекутуры;
* Сборка ядра;
* Сборка корневой системы;
    * Сборка корневой системы Debian Buster;
* Создание сетевой подсистемы
* Создание корневой системы из образа для виртуальных машин
* Установка необходимого ПО
* Конфигурация rke
* Запуск виртуальных машин и установка кластера
* Управление кластером
* Что делать дальшеВступительное слово.


## Вступительное слово

*АВТОР ПРЕДОСТАВЛЯЕТ СТАТЬЮ “КАК ЕСТЬ” БЕЗ КАКИХ-ЛИБО ГАРАНТИЙ, ЯВНЫХ ИЛИ ПОДРАЗУМЕВАЕМЫХ, ВКЛЮЧАЯ, НО НЕ ОГРАНИЧИВАЯСЬ, ПОДРАЗУМЕВАЕМЫМИ ГАРАНТИЯМИ ТОВАРНОЙ ПРИГОДНОСТИ И ПРИГОДНОСТИ ДЛЯ ОПРЕДЕЛЕННОЙ ЦЕЛИ. ВЕСЬ РИСК, СВЯЗАННЫЙ С КАЧЕСТВОМ И ЭФФЕКТИВНОСТЬЮ СТАТЬИ, ЛЕЖИТ НА ВАС. ЕСЛИ СОДЕРЖАНИЕ СТАТЬИ ОКАЖЕТСЯ НЕВЕРНЫМ, ВЫ БЕРЕТЕ НА СЕБЯ РАСХОДЫ НА ВСЕ НЕОБХОДИМОЕ ОБСЛУЖИВАНИЕ, РЕМОНТ ИЛИ ИСПРАВЛЕНИЕ.*

*Используемое оборудование - это сервер на базе материнской платы AsRock J1900D c 4 ядерным процессором Celeron и 16 Гигабайт ОЗУ. Данный сервер был выбран по причине дешевизны, наличия 4 ядер и пассивного охлаждения, что крайне необходимо для домашнего сервера.*

```
[nurmukhamed@otrs ~]$ lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                4
On-line CPU(s) list:   0-3
Thread(s) per core:    1
Core(s) per socket:    4
Socket(s):             1
NUMA node(s):          1
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 55
Model name:            Intel(R) Celeron(R) CPU  J1900  @ 1.99GHz
Stepping:              8
CPU MHz:               2415.903
CPU max MHz:           2415.7000
CPU min MHz:           1332.8000
BogoMIPS:              3993.60
Virtualization:        VT-x
L1d cache:             24K
L1i cache:             32K
L2 cache:              1024K
NUMA node0 CPU(s):     0-3
Flags:                 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 movbe popcnt tsc_deadline_timer rdrand lahf_lm 3dnowprefetch epb ibrs ibpb stibp tpr_shadow vnmi flexpriority ept vpid tsc_adjust smep erms dtherm ida arat md_clear spec_ctrl intel_stibp

[nurmukhamed@otrs ~]$ free
              total        used        free      shared  buff/cache   available
Mem:       15965700     1002912      278152    10462696    14684636     4161820
Swap:       8126460      142592     7983868
```

*Конфигурация виртуальных машин не является оптимальной и выбрана чтобы уместить на домашнем сервере 5 виртуальных машин в пределах 16 Гигабайт ОЗУ.* 

*Данная конфигурация сервера и виртуальных машин предназначена только для образовательных целях для проверки возможностей. Не является отказоустойчивой и развернута на одном сервере*

**Для более менее серьезных задач следуете рекомендациям создателей [Kubernetes](https://kubernetes.io/docs/setup/).**


## Обсуждение архитекутуры

Кластер kubernetes состоит из 5 узлов - виртуальные машины со следующими параметрами:

|  Name | Role  | CPU  | RAM, MB  | HDD, GB  | IP  |
|---|---|---|---|---|---|
| k8s01  | etcd  | 1  | 2  | 16  | 192.168.1.5 |
| k8s02  | control-plane  | 1  | 2  | 16  | 192.168.1.6 |
| k8s03  | control-plane  | 1  | 2  | 16  | 192.168.1.7 |
| k8s04  | worker  | 1  | 2  | 16  | 192.168.1.8 |
| k8s05  | worker  | 1  | 2  | 16  | 192.168.1.9 |

## Сборка ядра

Нам понадобится ядро Linux. Особенность firecracker - используется ядро со встроенными модулями. Без поддержки initrd. 

Также существуют [требования](https://rancher.com/docs/rke/latest/en/os/) к модулям ядра. Поэтому мы должны собрать новое ядро со встроенными модулями, чтобы не нарушать требования.

[По данной ссылке](https://linuxhint.com/compile-linux-kernel-centos7/) подготовим рабочее окружение и загрузим последнею версию ядра.

```
sudo yum install flex flex-devel bison bison-devel ncurses-devel make gcc bc openssl-devel elfutils-libelf-devel rpm-build

wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.6.13.tar.xz
tar xvf linux-5.6.13.tar.xz

cd linux-5.6.13
curl https://gist.githubusercontent.com/Nurmukhamed/033eacdc00ea20f5d3dd8d60d8ebea7b/raw/beae09d4984c84a8b335cb2f3dcdbb3ec2a179cc/firecracker-microvm-kubernetes-ready-kernel-config -o .config

make menuconfig
```

Ничего не выбираем, просто сохраняем конфиг как .config

```
make vmlinux
```

Скопируем полученный файл в каталог /var/lib/firecracker/kernels/

```
sudo cp ./vmlinux /var/lib/firecracker/kernels/k8s-5.6.13
```

## Сборка корневой системы

**ВНИМАНИЕ: Я потерял очень много времени пытаясь почему же у меня возникают ошибки, не проходит установка кластера. Виной всему оказалась ошибка в CentOS / Docker / iptables. Из-за чего не было возможности прокинуть порты из Docker наружу. Пока советую не использовать CentOS 7|8**

**ВНИМАНИЕ: В Debian Buster установка прошла успешно. Рекомендую использовать Debian Buster**

Нам понадобится образ корневой системы. 

### Сборка корневой системы Debian Buster

В данной сборке будет минимальная система Debian. Основной послужила [следующая статья](https://habr.com/ru/post/147522/). 

Создадим ключ для openssh для доступа на сервера

```
ssh-keygen -o -a 256 -t ed25519 -C "$(hostname)-$(date +'%d-%m-%Y')" -t ~/.ssh/rke
cat ~/.ssh/rke.pub
```

Подготовим рабочее окружение

```
sudo yum install debootstrap -y
mkdir ~/debian

sudo debootstrap --include=sudo,nano,wget --arch amd64 buster ~/debian http://mirror.neolabs.kz/debian/

sudo mount -o bind /dev ~/debian/dev
sudo mount -o bind /sys ~/debian/sys
sudo mount -o bind /proc ~/debian/proc

cat<<EOF | sudo tee ~/debian/etc/resolv.conf
search lan
nameserver 192.168.1.1
EOF
```


Рабочий вариант /etc/apt/source.list
```
cat<<EOF| sudo tee ~/debian/etc/apt/source.list
deb http://mirror.neolabs.kz/debian/ buster main contrib non-free
deb-src http://mirror.neolabs.kz/debian/ stretch main contrib non-free

deb http://mirror.neolabs.kz/debian/ buster-updates main contrib non-free
deb-src http://mirror.neolabs.kz/debian/ buster-updates main contrib non-free

deb http://security.debian.org/debian-security/ buster/updates main contrib non-free
deb https://download.docker.com/linux/debian buster stable
deb-src http://security.debian.org/debian-security/ buster/updates main contrib non-free

deb http://deb.debian.org/debian buster-backports main
EOF
```

Запустим chroot

```
env LANG=C env HOME=/root sudo -E chroot ~/debian /bin/bash /postinstall.sh
```

Выполняем
```
cat<<EOF| sudo tee ~/debian/postinstall.sh
#!/bin/bash

## обновление индекса репозитария
apt-get update

## настройка часовых поясов
dpkg-reconfigure tzdata

## участие в опросе популярности пакетов
apt-get -y install popularity-contest

## русский язык в консоли, русская локаль
## при настройке console-cyrillic лучше выбрать, как шрифт, UniCyr, а на последний вопрос ответить «Да»

apt-get -y install locales console-cyrillic
dpkg-reconfigure locales
dpkg-reconfigure console-cyrillic

# установим произвольный пароль для root
usermod -p ! root

# создадим нового пользователя rke
useradd rke

# set random password for user
usermod -p ! rke
  
# create .ssh folder and put authorized_keys
mkdir /home/rke/.ssh
chmod 700 /home/rke/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOYyQl0aVdv88oTRKuG6HvTJ6uQ5EaN7/dHkO1P3vdvv otrs.edenprime.kz-13-08-2020" > /home/rke/.ssh/authorized_keys
chmod 600 /home/rke/.ssh/authorized_keys
chown rke:rke -R /home/rke/.ssh
  
#create sudoers file for user
echo "rke  ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/rke
EOF

# установим рекомендуемую версию Docker
curl https://releases.rancher.com/install-docker/18.09.2.sh | sh

# добавим пользователя rke в группу Docker
usermod -aG docker rke
```

Отключаем разделы
```
sudo rm ~/debian/etc/resolv.conf
sudo umount ~/debian/dev
sudo umount ~/debian/sys
sudo umount ~/debian/proc
```

Произведем упаковку образа

```
sudo tar -Jcvf /var/lib/firecracker/rootfs/k8s-debian-buster-$(/bin/date +%Y%m%d).tar.xz -C ~/debian .
```

Теперь у нас имеется образ ОС Debian, готовый для развертывания Kubernetes.


## Создание сетевой подсистемы

Настроем сетевую подсистему для виртуальных машин.

**ВНИМАНИЕ: Я использую systemd-networkd и не использую NetworkManager.**

**ВНИМАНИЕ: br0 - это наименование моста для виртуальных машин, в данной конфигурации машины имеют прямой доступ к локальной сети.**
```
for i in {1..5}; do
sudo ip tuntap add tap${i} mode tap
sudo ip link set tap${i} master br0
sudo ip link set tap${i} up

sudo tee /etc/systemd/network/90-tap${i}.netdev << EOF
[NetDev]
Name=tap${i}
Kind=tap
EOF

sudo tee /etc/systemd/network/90-tap${i}.network << EOF
[Match]
Name=tap${i}

[Network]
Bridge=br0
EOF

done
```

## Создание корневой системы из образа для виртуальных машин

Написал небольшой скрипт для развертывания образа виртуальной машины.

```
VMDATA="/opt/k8s"
MOUNTDIR="/tmp/testmount"

declare -A servers
servers["k8s01"]=5
servers["k8s02"]=6
servers["k8s03"]=7
servers["k8s04"]=8
servers["k8s05"]=9

for server in "${!servers[@]}"; do

ip=${servers[${server}]}

sudo dd if=/dev/zero of=${VMDATA}/${server}.ext4 bs=1M count=16384
sudo mkfs.ext4 ${VMDATA}/${server}.ext4
sudo mkdir ${MOUNTDIR}
sudo mount -o loop ${VMDATA}/${server}.ext4 ${MOUNTDIR}
sudo tar -Jxvf /var/lib/firecracker/rootfs/k8s-debian-buster-$(/bin/date +%Y%m%d).tar.xz -C ${MOUNTDIR}

cat<<EOF| sudo tee ${MOUNTDIR}/etc/resolv.conf
search lan
nameserver 192.168.1.1
EOF

cat<<EOF | sudo tee ${MOUNTDIR}/etc/hostname
${server}.lan
EOF

cat<<EOF| sudo tee ${MOUNTDIR}/etc/network/interfaces
# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet static
      address 192.168.1.${ip}
      netmask 255.255.255.0
      gateway 192.168.1.1
EOF

cat<<EOF| sudo tee ${MOUNTDIR}/etc/hosts
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
192.168.1.5     k8s01.lan
192.168.1.6     k8s02.lan
192.168.1.7     k8s03.lan
192.168.1.8     k8s04.lan
192.168.1.9     k8s05.lan
EOF

sudo umount ${MOUNTDIR}
done
```

Образ развернут, конфигурация виртуальной машины будет выглядет так:

```

for i in {1..5}; do
macaddress=$(echo 00:60:2F:$[RANDOM%10]$[RANDOM%10]:$[RANDOM%10]$[RANDOM%10]:$[RANDOM%10]$[RANDOM%10])

cat<<EOF | sudo tee /etc/firecracker/k8s0${i}.json
{
  "boot-source": {
    "kernel_image_path": "/var/lib/firecracker/kernels/k8s-5.6.13",
    "boot_args": "console=ttyS0 reboot=k panic=1 pci=off"
  },
  "drives": [
    {
      "drive_id": "rootfs",
      "path_on_host": "/opt/k8s/k8s0${i}.ext4",
      "is_root_device": true,
      "is_read_only": false
    }
  ],
  "machine-config": {
    "vcpu_count": 2,
    "mem_size_mib": 2048,
    "ht_enabled": false
  },
  "network-interfaces": [ 
      {
      "iface_id": "eth0",
      "guest_mac": "${macaddress}",
      "host_dev_name": "k8s0${i}"
    }
  ],
  "actions": {
      "action_type": "InstanceStart"
  }
}
EOF
done
```

## Установка необходимого ПО

Нам необходимо дополнительное программное обеспечение для управления кластером Kubernetes

**kubectl**:

```
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client
```

**rke**

```
curl -s https://api.github.com/repos/rancher/rke/releases/latest | grep download_url | grep amd64 | cut -d '"' -f 4 | wget -qi -
chmod +x rke_linux-amd64
sudo mv rke_linux-amd64 /usr/local/bin/rke
rke --version
```

**helm**
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

## Конфигурация rke

Более подробно можно почитать [здесь](http://itisgood.ru/2020/01/29/ustanovka-proizvodstvennogo-klastera-kubernetes-s-rancher-rke/).

У меня получилась следующая конфигурация. 

```
mkdir ~/rke
cd ~/rke

cat<<EOF| tee cluster.yml
# If you intened to deploy Kubernetes in an air-gapped environment,
# please consult the documentation on how to configure custom RKE images.
nodes:
- address: 192.168.1.5
  port: "22"
  internal_address: ""
  role:
  - etcd
  hostname_override: ""
  user: rke
  docker_socket: /var/run/docker.sock
  ssh_key: ""
  ssh_key_path: /home/nurmukhamed/.ssh/rke
  ssh_cert: ""
  ssh_cert_path: ""
  labels: {}
  taints: []
- address: 192.168.1.6
  port: "22"
  internal_address: ""
  role:
  - controlplane
  hostname_override: ""
  user: rke
  docker_socket: /var/run/docker.sock
  ssh_key: ""
  ssh_key_path: /home/nurmukhamed/.ssh/rke
  ssh_cert: ""
  ssh_cert_path: ""
  labels: {}
  taints: []
- address: 192.168.1.7
  port: "22"
  internal_address: ""
  role:
  - controlplane
  hostname_override: ""
  user: rke
  docker_socket: /var/run/docker.sock
  ssh_key: ""
  ssh_key_path: /home/nurmukhamed/.ssh/rke
  ssh_cert: ""
  ssh_cert_path: ""
  labels: {}
  taints: []
- address: 192.168.1.8
  port: "22"
  internal_address: ""
  role:
  - worker
  hostname_override: ""
  user: rke
  docker_socket: /var/run/docker.sock
  ssh_key: ""
  ssh_key_path: /home/nurmukhamed/.ssh/rke
  ssh_cert: ""
  ssh_cert_path: ""
  labels: {}
  taints: []
- address: 192.168.1.9
  port: "22"
  internal_address: ""
  role:
  - worker
  hostname_override: ""
  user: rke
  docker_socket: /var/run/docker.sock
  ssh_key: ""
  ssh_key_path: /home/nurmukhamed/.ssh/rke
  ssh_cert: ""
  ssh_cert_path: ""
  labels: {}
  taints: []
services:
  etcd:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
    external_urls: []
    ca_cert: ""
    cert: ""
    key: ""
    path: ""
    uid: 0
    gid: 0
    snapshot: null
    retention: ""
    creation: ""
    backup_config: null
  kube-api:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
    service_cluster_ip_range: 10.43.0.0/16
    service_node_port_range: ""
    pod_security_policy: false
    always_pull_images: false
    secrets_encryption_config: null
    audit_log: null
    admission_configuration: null
    event_rate_limit: null
  kube-controller:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
    cluster_cidr: 10.42.0.0/16
    service_cluster_ip_range: 10.43.0.0/16
  scheduler:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
  kubelet:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
    cluster_domain: cluster.local
    infra_container_image: ""
    cluster_dns_server: 10.43.0.10
    fail_swap_on: false
    generate_serving_certificate: false
  kubeproxy:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
network:
  plugin: canal
  options: {}
  mtu: 0
  node_selector: {}
  update_strategy: null
authentication:
  strategy: x509
  sans: []
  webhook: null
addons: ""
addons_include: []
system_images:
  etcd: rancher/coreos-etcd:v3.4.3-rancher1
  alpine: rancher/rke-tools:v0.1.59
  nginx_proxy: rancher/rke-tools:v0.1.59
  cert_downloader: rancher/rke-tools:v0.1.59
  kubernetes_services_sidecar: rancher/rke-tools:v0.1.59
  kubedns: rancher/k8s-dns-kube-dns:1.15.2
  dnsmasq: rancher/k8s-dns-dnsmasq-nanny:1.15.2
  kubedns_sidecar: rancher/k8s-dns-sidecar:1.15.2
  kubedns_autoscaler: rancher/cluster-proportional-autoscaler:1.7.1
  coredns: rancher/coredns-coredns:1.6.9
  coredns_autoscaler: rancher/cluster-proportional-autoscaler:1.7.1
  nodelocal: rancher/k8s-dns-node-cache:1.15.7
  kubernetes: rancher/hyperkube:v1.18.6-rancher1
  flannel: rancher/coreos-flannel:v0.12.0
  flannel_cni: rancher/flannel-cni:v0.3.0-rancher6
  calico_node: rancher/calico-node:v3.13.4
  calico_cni: rancher/calico-cni:v3.13.4
  calico_controllers: rancher/calico-kube-controllers:v3.13.4
  calico_ctl: rancher/calico-ctl:v3.13.4
  calico_flexvol: rancher/calico-pod2daemon-flexvol:v3.13.4
  canal_node: rancher/calico-node:v3.13.4
  canal_cni: rancher/calico-cni:v3.13.4
  canal_flannel: rancher/coreos-flannel:v0.12.0
  canal_flexvol: rancher/calico-pod2daemon-flexvol:v3.13.4
  weave_node: weaveworks/weave-kube:2.6.4
  weave_cni: weaveworks/weave-npc:2.6.4
  pod_infra_container: rancher/pause:3.1
  ingress: rancher/nginx-ingress-controller:nginx-0.32.0-rancher1
  ingress_backend: rancher/nginx-ingress-controller-defaultbackend:1.5-rancher1
  metrics_server: rancher/metrics-server:v0.3.6
  windows_pod_infra_container: rancher/kubelet-pause:v0.1.4
ssh_key_path: ~/.ssh/id_rsa
ssh_cert_path: ""
ssh_agent_auth: false
authorization:
  mode: rbac
  options: {}
ignore_docker_version: null
kubernetes_version: ""
private_registries: []
ingress:
  provider: ""
  options: {}
  node_selector: {}
  extra_args: {}
  dns_policy: ""
  extra_envs: []
  extra_volumes: []
  extra_volume_mounts: []
  update_strategy: null
cluster_name: ""
cloud_provider:
  name: ""
prefix_path: ""
addon_job_timeout: 600
bastion_host:
  address: ""
  port: ""
  user: ""
  ssh_key: ""
  ssh_key_path: ""
  ssh_cert: ""
  ssh_cert_path: ""
monitoring:
  provider: ""
  options: {}
  node_selector: {}
  update_strategy: null
  replicas: null
restore:
  restore: false
  snapshot_name: ""
dns: null
EOF
```

## Запуск виртуальных машин и установка кластера

Запускаем виртуальные машины
```
for i in {1..5}; do
sudo systemctl enable --now firecracker@k8s0${i}
sudo systemctl status firecracker@k8s0${i}
done
```

Проверим удаленный доступ к серверам

```
for i in {5..9}; do
slogin -i ~/.ssh/rke rke@192.168.1.${i} "uname -r; uptime"
done
```

Запускаем установку кластера, через минут 10 (на моем железе) будет готовый кластер.

```
cd ~/rke
rke up
```

Если появились ошибки, нужно делать troubleshooting.


## Управление кластером

Теперь можем проверить состояние кластера.

```
cd ~/rke/
export KUBECONFIG=./kube_config_cluster.yml
kubectl get nodes
NAME          STATUS   ROLES          AGE   VERSION
192.168.1.5   Ready    etcd           24h   v1.18.6
192.168.1.6   Ready    controlplane   24h   v1.18.6
192.168.1.7   Ready    controlplane   24h   v1.18.6
192.168.1.8   Ready    worker         24h   v1.18.6
192.168.1.9   Ready    worker         24h   v1.18.6
```

Вы можете скопировать этот файл в $HOME/.kube/config, если у вас нет другого кластера kubernetes.

```
mkdir ~/.kube
cp kube_config_rancher-cluster.yml ~/.kube/config
```

## Что делать дальше

Кластер поднят, теперь можно настраивать приложения по [данной статье](https://serveradmin.ru/rabota-s-helm-3-v-kubernetes/)
```
kubectl get pods -w --namespace kubeapps
NAME                                                          READY   STATUS             RESTARTS   AGE
apprepo-kubeapps-sync-bitnami-1597317600-lslkt                0/1     Completed          0          28m
apprepo-kubeapps-sync-bitnami-1597318200-mb5xr                0/1     Completed          1          18m
apprepo-kubeapps-sync-bitnami-1597318800-vs5d9                0/1     Completed          0          8m25s
apprepo-kubeapps-sync-bitnami-grnf9-mz5nj                     0/1     Completed          2          24h
apprepo-kubeapps-sync-incubator-1597317600-9mzr7              0/1     Completed          0          28m
apprepo-kubeapps-sync-incubator-1597318200-mxgtz              0/1     Completed          0          18m
apprepo-kubeapps-sync-incubator-1597318800-2w5bp              0/1     Completed          0          8m24s
apprepo-kubeapps-sync-incubator-mld2z-r8t2f                   0/1     Completed          0          24h
apprepo-kubeapps-sync-stable-1597317600-lp84k                 0/1     Completed          0          28m
apprepo-kubeapps-sync-stable-1597318200-hjhqb                 0/1     Completed          1          18m
apprepo-kubeapps-sync-stable-1597318800-tqmcm                 0/1     Completed          1          8m23s
apprepo-kubeapps-sync-svc-cat-1597317600-j4gxj                0/1     Completed          0          28m
apprepo-kubeapps-sync-svc-cat-1597318200-fbtxf                0/1     Completed          0          18m
apprepo-kubeapps-sync-svc-cat-1597318800-n8ct9                0/1     Completed          0          8m22s
apprepo-kubeapps-sync-svc-cat-kwhcc-5ccj5                     0/1     Completed          0          24h
kubeapps-774c79fdd7-fmwkv                                     1/1     Running            0          24h
kubeapps-774c79fdd7-lqm85                                     1/1     Running            0          24h
kubeapps-internal-apprepository-controller-75548b76d8-m5jdm   1/1     Running            0          24h
kubeapps-internal-assetsvc-5f6cc69646-8n59w                   1/1     Running            0          24h
kubeapps-internal-assetsvc-5f6cc69646-k2gf4                   1/1     Running            0          24h
kubeapps-internal-dashboard-57cfbcfc9b-7zh8m                  1/1     Running            0          24h
kubeapps-internal-dashboard-57cfbcfc9b-phvbd                  1/1     Running            0          24h
kubeapps-internal-tiller-proxy-69f596b886-66z9b               0/1     CrashLoopBackOff   280        24h
kubeapps-internal-tiller-proxy-69f596b886-xpspw               0/1     CrashLoopBackOff   281        24h
kubeapps-postgresql-master-0                                  1/1     Running            0          24h
kubeapps-postgresql-slave-0                                   1/1     Running            0          24h

```

В случае ошибки, можно посмотреть логи системы.

*Не забудьте обновить свое резюме, впишите в него строку "Kubernetes, Rancher, RKE" и просите прибавку к зарплате +50 тысяч рублей РФ.*

 
