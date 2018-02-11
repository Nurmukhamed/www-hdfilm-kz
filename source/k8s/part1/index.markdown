---
layout: page
title: Установка кластера 
date: '2018-02-11 14:58'
comments: true
sharing: true
footer: true
published: true
category:
- kubernetes
- k8s
- docker
---

# Вводные понятие и термины

| Термин   | Определения |
|--:|--:|
| Kubernetes   | ИС для автоматизированного разворачивания, мастабирования и управления контейнерами. СПО разработан корпорацией GOOGLE. |
| Docker | ПО для автоматизации развертывания и управления приложениями в среде виртуализации на уровне операционной системы. Разработан компаниией Docker, Inc. |
| Container Runtime Interface   | Стандарт исполняемой среды, позволяющий запустить различные контейнерные  реализации |
| CRI   | Container Runtime Interface |
| Container Network Interface   | Стандарт исполняемой среды, позволяющий запустить различные сетевые модули |
| CNI | Container Network Interface |
| Weave | Реализация сетевого модуля, совместимая со стандартом CNI |
| Гипервизор | Программа или аппаратная схема, обеспечивающая или позволяющая одновременное, параллельное выполнение нескольких операционных систем на одном и том же хост-компьютере. |
| VMware ESXi  | Реализация гипервизора на платформе x86_64 от компании VMware |
| NFS  | Протокол сетевого доступа к файловым системам |
| ISCSI  | Протокол, который базируется на TCP/IP и разработан для установления взаимодействия и управления системами хранения данных, серверами и клиентами. |
| IPXE  | Свободная реализация прошивок сетевых адаптеров для сетевой загрузки.  |
| VMware GuestInfo  | Возможность записать в файл конфигурации vmx виртуальной машины, дополнительные значения для использования сторонними утилитами, в частности, ipxe |
| Kubernetes Master, мастер узел  | Узел кластера, отвественный за управление кластером |
| Kubernetes Worker, рабочий узел  | Узел кластера, отвественный за запуск и выполнение контейнеров |
| PowerShell  | Расширяемое средство автоматизации от Microsoft с открытым исходным кодом |
| VMware PowerCLI  | Расширение для Powershell для управления продуктами компании VMware |
| CentOS  | Дистрибутив Linux, основанный на коммерческом Redhat Enterprise Linux и совместимый с ним. |
| Kickstart  | Метод быстрой установки операционных систем, основанных на RedHat Linux |
| ETCD  | Распределённая система хранения конфигурации  |


## Используются следующие продукты и технологии:

* VMWare ESXi, версии 6.5;
* CentOS 7;
* Kubernetes 1.9.1;
* CRI (Container Runtime Interface);
* CRI-модуль Docker, версии 1.12.6;
* CNI (Container Network Interface);
* CNI-модуль weave;
* ISCSI-хранилище;
* IPXE;
* VMware GuestInfo;

Kubernetes поддерживает различные интерфейсы – CRI (Container Runtime Interface), CNI (Container Network Interface). Идет постоянное улучшение существующих и разработка новых модулей. Под другие модули CRI, CNI будут выпущены отдельные учебные руководства.

Kubernetes обладает высоким порогом входа в технологию и данное руководство дает ответ на вопрос – с чего начать и как развернуть кластер на физическом и виртуальных машинах, как настроить сеть и подключить внешние носители информации (nfs,iscsi, fc и другие).

Основой для создания учебного пособия послужили следующие веб-ресурсы:

* (https://github.com/cookeem/kubeadm-ha);
* (https://wiki.centos.org/SpecialInterestGroup/Atomic/ContainerizedMaster);
* (https://www.projectatomic.io/docs/gettingstarted/);
* (Https://www.linuxtechi.com/install-kubernetes-1-7-centos7-rhel7/)


**Внимание - В учебном пособии разворачивается кластер Kubernetes высокой доступности с 4 мастер узлами и 20 рабочими узлами.**

{% imgcap /images/k8s-001.png %}

{% imgcap /images/k8s-002.png %}


## Используемое железо и технологии

### Железо:

* Сервер HP DL560 g8, 4*Xeon, 136GB RAM, HDD 140GB;
* Дисковая полка NetApp, ISCSI;

### Гипервизор:

* VMware ESXi, версия 6.5;
* IP-адрес: В приложение №1;

### Виртуальные машины:

| Название   | Процессор | Память | Жесткий диск  | IP-Адрес  | IPXE  | Kickstart  | Комментарии |
|--:|--:| -- | -- | -- | -- | -- | -- |
| | | | | | | | |
| K8s-repo | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №2 | Приложение №3 | Узел для загрузки конфигурации |
| K8s-iscsi | 2CPU | 2GB | 320GB | Приложение №1 | Приложение №4 | Приложение №5 | Тестовое дисковое хранилище |
| K8s-master-a | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №6 | Приложение №7 | Мастер узел |
| K8s-master-b | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №6 | Приложение №7 | Мастер узел |
| K8s-master-c | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №6 | Приложение №7 | Мастер узел |
| K8s-master-d | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №6 | Приложение №7 | Мастер узел |
| K8s-worker-040 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-041 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-0422 | CPU | 2GB | 40GB | Приложение №1 | Приложение №9 | Приложение №9 | Рабочий узел |
| K8s-worker-043 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-044 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-045 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-046 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-047 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-048 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-049 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-050 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-051 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-052 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-053 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-054 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-055 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-056 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-057 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-058 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |
| K8s-worker-059 | 2CPU | 2GB | 40GB | Приложение №1 | Приложение №8 | Приложение №9 | Рабочий узел |

### Конфигурация Kickstart:

* Приложение №9 – kickstart-файл, общие настройки для мастер узлов;
* Приложение №10 – kickstart-файл, общие настройки для рабочих узлов;

### Скрипты PowerShell:

* Приложение №11 – Создание виртуальной машины k8s-repo;
* Приложение №12 – Создание виртуальной машины k8s-master-a;
* Приложение №13 – Создание виртуальной машины k8s-master-b;
* Приложение №14 – Создание виртуальной машины k8s-master-c;
* Приложение №15 – Создание виртуальной машины k8s-master-d;
* Приложение №16 – Создание виртуальной машины k8s-workers;
* Приложение №17 – Список рабочих узлов;
* Приложение №18 – Создание виртуальной машины k8s-iscsi;

**Примечание: Только сервер k8s-repo имеет прямой доступ к сети. ** 

Доступ к сети для остальных машин организован через прокси-сервер на сервере k8s-repo. 

**На рабочей станции администратора должно быть установлено:**

* Powershell, версии 5.1 и выше;
* VMware PowerCLI, версии 6.3 и выше;
* Google Chromе, последней версии;

# Подготовка загрузочного диска

Используемые технологии для быстрого развертывания виртуальных машин:

* vmware powercli;
* vmware guestinfo;
* ipxe;
* kickstart


**VMware PowerCLI** – расширение для PowerShell, для управления виртуальной средой VMware через скрипты powershell.

**VMware GuestInfo** – возможность записать в файл конфигурации vmx виртуальной машины, дополнительные значения для использования сторонними утилитами, в частности, ipxe.

**IPXE** – замена традиционного PXE. Позволяет проводить установку систему через различные способы – tftp, http, ftp, https. Настройку сети ручным способом. Поддержка расширенных сетевых сетей – vlan, ipv6, vmware settings, wimboot, memdisk.

**Kickstart** – один из способов установки ОС Redhat/CentOS/Fedora, путем создания текстового файла с описанием установки.

Для создания загрузочного диска необходимо использовать веб-ресурс https://rom-o-matic.eu

Необходимо выбрать:

* Advanced, for experienced users;
* ISO bootable image (.iso);
* All-drivers;
* VMWARE_SETTINGS;
* NET_PROTO_IPV6;
* DOWNLOAD_PROTO_HTTPS;
* DOWNLOAD_PROTO_FTP;
* DOWNLOAD_PROTO_NFS;
* VLAN_CMD;
* PING_CMD;
* REBOOT_CMD;
* POWEROFF_CMD;

Нажать кнопку «Proceed», будет сгенерирован образ ISO ipxe.iso, сохранить данный образ в датасторе ESXi.

# Подготовка k8s-repo

Виртуальная машина, далее сервер, k8s-repo является первым сервером разворачиваемым в кластере. Сам сервер не будет входить в кластер kubernetes.

## Функции сервера k8s-repo:

* Локальный зеркало репозитория Centos и дополнительных репозиториев;
* Хранение настроек для ipxe;
* Хранение настроек для kickstart;
* Хранение дополнительных скриптов;
* Хранение образов docker;
* Днс-сервер;
* Прокси-сервер.

Нам нужно опубликовать два файла – ipxe, kickstart на любом доступном веб-сервере. Возможно, это будет внутренний сервер. Но, если «под рукой нет»  веб-сервера, можно воспользоваться сервисами подобными pastebin. Я выбираю sprunge.us как сервис, который можно использовать из командной строки.

### Шаг №1

Допустим, наша рабочая станция – это linux. Пропишем в .bashrc функцию sprunge, откройте файл .bashrc, добавьте следующий текст

<pre><code>
sprunge() {
If [[ $1 ]]; then
curl –F ‘sprunge=<-‘ http://sprunge.us <”$1”
Else
curl –F ‘sprunge=<’ “http://sprunge.us”    
}
source ~/.bashrc
</code></pre>

{% imgcap /images/k8s-003.png %}

## Публикация kickstart-файла на внешний веб-сервис

### Шаг №2

Файл kickstart называется k8s-repo.ks, то команда будет следующей
sprunge k8s-repo.ks, вывод будет ссылка на файл в сервисе sprunge.us. Запомните ссылку на этот файл.

{% imgcap /images/k8s-004.png %}

## Публикация ipxe-файла на внешний веб-сервис

### Шаг №3

Отредактируйте файл k8s-repo.ipxe, содержание файла должно быть следующим
<pre><code>
#!ipxe
set base http://mirror.neolabs.kz/centos/7/os/x86_64

set ip 192.168.207.11
set netmask 255.255.255.0
set gateway 192.168.207.1
set dns 8.8.8.8

set kickstart http://sprunge.us/EQje

kernel ${base}/images/pxeboot/vmlinuz ip=${ip} netmask=${netmask} gateway=${gateway} nameserver=${dns} inst.text inst.ks=${kickstart}
initrd ${base}/images/pxeboot/initrd.img
boot
</code></pre>

{% imgcap /images/k8s-005.png %}

### Шаг №4

Публикуем файл k8s-repo.ipxe 

<pre><code>
sprunge k8s-repo.ipxe
</code></pre>

{% imgcap /images/k8s-006.png %}

Запомнить ссылку на файл.

## Создание и запуск виртуальной машины

### Шаг №5

Откройте powershell, подключитесь к гипервизору ESXi

### Шаг №6

Отредактируйте файл VM_KUBERNETES_REPO.ps1, исправьте параметр "guestinfo.ipxe.filename". Замените значение на ссылку, полученную ранее. Сохраните файл

{% imgcap /images/k8s-007.png %}

### Шаг №7

Запустите скрипт VM_KUBERNETES_REPO.ps1

{% imgcap /images/k8s-008.png %}

### Шаг №8

Дождитесь, пока статус виртуальной машины станет PoweredOff, затем запустите виртуальную машину.

{% imgcap /images/k8s-009.png %}

## Проверка образов docker

### Шаг №9

Подключитесь к серверу k8s-repo, выполните следующие команды:

<pre><code>
systemctl status save-from-registry-to-tarfile
docker images
</code></pre>

{% imgcap /images/k8s-010.png %}

## Настройка днс-сервера

Подключитесь к серверу k8s-repo

### Шаг №10

Удалите конфигурацию по умолчанию dnsmasq

<pre><code>
rm –f /etc/dnsmasq.conf
</code></pre>

{% imgcap /images/k8s-011.png %}

### Шаг №11

Новая конфигурация dnsmasq

<pre><code>
echo “conf-dir=/etc/dnsmasq.d,.rpmnew,.rpmsave,.rpmorig” > /etc/dnsmasq.conf
</code></pre>

{% imgcap /images/k8s-012.png %}

### Шаг №12

Заполним таблицу адресов для прямой зоны kubernetes.local, обратной зоны 207.168.192.in-addr.arpa

<pre><code>
cat >/etc/dnsmasq.d/address.conf<<”EOF”

# address of repo server
address=/k8s-repo.kubernetes.local/192.168.207.11
ptr-record=11.207.168.192.in-addr.arpa,k8s-repo.kubernetes.local
# addresses of masters nodes
address=/k8s-master-a.kubernetes.local/192.168.207.12
ptr-record=12.207.168.192.in-addr.arpa,k8s-master-a.kubernetes.local
address=/k8s-master-b.kubernetes.local/192.168.207.13
ptr-record=13.207.168.192.in-addr.arpa,k8s-master-b.kubernetes.local
address=/k8s-master-c.kubernetes.local/192.168.207.14
ptr-record=14.207.168.192.in-addr.arpa,k8s-master-c.kubernetes.local
address=/k8s-master-d.kubernetes.local/192.168.207.15
ptr-record=15.207.168.192.in-addr.arpa,k8s-master-d.kubernetes.local
# address of master ha
address=/k8s-master.kubernetes.local/192.168.207.16
ptr-record=16.207.168.192.in-addr.arpa,k8s-master.kubernetes.local
# address of iscsi servers
address=/k8s-iscsi.kubernetes.local/192.168.207.17
ptr-record=17.207.168.192.in-addr.arpa,k8s-iscsi.kubernetes.local
# addresses of worker nodes
address=/k8s-worker-040.kubernetes.local/192.168.207.40
ptr-record=40.207.168.192.in-addr.arpa,k8s-worker-040.kubernetes.local
address=/k8s-worker-041.kubernetes.local/192.168.207.41
ptr-record=41.207.168.192.in-addr.arpa,k8s-worker-041.kubernetes.local
address=/k8s-worker-042.kubernetes.local/192.168.207.42
ptr-record=42.207.168.192.in-addr.arpa,k8s-worker-042.kubernetes.local
address=/k8s-worker-043.kubernetes.local/192.168.207.43
ptr-record=43.207.168.192.in-addr.arpa,k8s-worker-043.kubernetes.local
address=/k8s-worker-044.kubernetes.local/192.168.207.44
ptr-record=44.207.168.192.in-addr.arpa,k8s-worker-044.kubernetes.local
address=/k8s-worker-045.kubernetes.local/192.168.207.45
ptr-record=45.207.168.192.in-addr.arpa,k8s-worker-045.kubernetes.local
address=/k8s-worker-046.kubernetes.local/192.168.207.46
ptr-record=46.207.168.192.in-addr.arpa,k8s-worker-046.kubernetes.local
address=/k8s-worker-047.kubernetes.local/192.168.207.47
ptr-record=47.207.168.192.in-addr.arpa,k8s-worker-047.kubernetes.local
address=/k8s-worker-048.kubernetes.local/192.168.207.48
ptr-record=48.207.168.192.in-addr.arpa,k8s-worker-048.kubernetes.local
address=/k8s-worker-049.kubernetes.local/192.168.207.49
ptr-record=49.207.168.192.in-addr.arpa,k8s-worker-049.kubernetes.local
address=/k8s-worker-050.kubernetes.local/192.168.207.50
ptr-record=50.207.168.192.in-addr.arpa,k8s-worker-050.kubernetes.local
address=/k8s-worker-051.kubernetes.local/192.168.207.51
ptr-record=51.207.168.192.in-addr.arpa,k8s-worker-051.kubernetes.local
address=/k8s-worker-052.kubernetes.local/192.168.207.52
ptr-record=52.207.168.192.in-addr.arpa,k8s-worker-052.kubernetes.local
address=/k8s-worker-053.kubernetes.local/192.168.207.53
ptr-record=53.207.168.192.in-addr.arpa,k8s-worker-053.kubernetes.local
address=/k8s-worker-054.kubernetes.local/192.168.207.54
ptr-record=54.207.168.192.in-addr.arpa,k8s-worker-054.kubernetes.local
address=/k8s-worker-055.kubernetes.local/192.168.207.55
ptr-record=55.207.168.192.in-addr.arpa,k8s-worker-055.kubernetes.local
address=/k8s-worker-056.kubernetes.local/192.168.207.56
ptr-record=56.207.168.192.in-addr.arpa,k8s-worker-056.kubernetes.local
address=/k8s-worker-057.kubernetes.local/192.168.207.57
ptr-record=57.207.168.192.in-addr.arpa,k8s-worker-057.kubernetes.local
address=/k8s-worker-058.kubernetes.local/192.168.207.58
ptr-record=58.207.168.192.in-addr.arpa,k8s-worker-058.kubernetes.local
address=/k8s-worker-059.kubernetes.local/192.168.207.59
ptr-record=59.207.168.192.in-addr.arpa,k8s-worker-059.kubernetes.local
EOF
</code></pre>

{% imgcap /images/k8s-013.png %}

{% imgcap /images/k8s-014.png %}

### Шаг №13

Настройки сервера днс в dnsmasq

<pre><code>
cat >/etc/dnsmasq.d/dns.conf<<”EOF”
all-servers
resolv-file=/etc/resolv.dnsmasq
listen-address=192.168.207.11
EOF
</code></pre>

{% imgcap /images/k8s-015.png %}

### Шаг №14

Данные резолвера для dnsmasq

<pre><code>
cat >/etc/resolv.dnsmasq<<”EOF”
search nitec.kz
option rotate
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
</code></pre>

{% imgcap /images/k8s-016.png %}

### Шаг №15

Обновим настройки сетевой карты, изменим настройки днс-сервера

<pre><code>
cat >/etc/sysconfig/network-scripts/ifcfg-ens192<<”EOF”
TYPE=Ethernet
BOOTPROTO=static
NAME=ens192
DEVICE=ens192
ONBOOT=yes
IPADDR=192.168.207.11
PREFIX=24
GATEWAY=192.168.207.1
DNS1=192.168.207.11
DOMAIN=nitec.kz
ZONE=public
EOF
</code></pre>

{% imgcap /images/k8s-017.png %}

### Шаг №16

Перезапустим службы
<pre><code>
systemctl restart dnsmasq network
</code></pre>

## Настройка зеркала репозитариев

Сервер k8s-repo будет локальным зеркалом репозиториев. Будут зеркалированы следующие ресурсы:

| Имя репозитория | Ресурс | Тип протокола |
| -- | -- | -- |
| Base | mirror.neolabs.kz | rsync |
| Updates | mirror.neolabs.kz | rsync |
| Extras | mirror.neolabs.kz | rsync |
| Elrepo | elrepo.org | http |
| Elrepo-extras | elrepo.org | http |
| Elrepo-kernel | elrepo.org | http |
| Elrepo-testing | elrepo.org | http |
| Kubernetes | packages.cloud.google.com | http |

### Шаг №17

Зеркалируем репозитории CentOS с веб-ресурса mirror.neolabs.kz
<pre><code>
for repo in os updates extras; do
rsync –avz –delete mirror.neolabs.kz::centos/7/${repo}/x86_64/ /var/lib/mirror/centos/7/${repo}/x86_64/
done
</code></pre>

{% imgcap /images/k8s-018.png %}

### Шаг №18

Зеркалируем репозитории elrepo. Предварительная подготовка

<pre><code>
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm --Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
mkdir -p /var/lib/mirror/elrepo/{elrepo,elrepo-extras,elrepo-kernel,elrepo-testing}/7/x86_64/
Шаг №19
Зеркалируем репозиторий elrepo.
cd /var/lib/mirror/elrepo/elrepo/7/x86_64
reposync --gpgcheck -l --downloadcomps --download-metadata --repoid elrepo --norepopath
</code></pre>

{% imgcap /images/k8s-019.png %}

### Шаг №20

Зеркалируем репозиторий elrepo-extras.
<pre><code>
cd /var/lib/mirror/elrepo/elrepo-extras/7/x86_64
reposync --gpgcheck -l --downloadcomps --download-metadata --repoid elrepo-extras --norepopath
</code></pre>

{% imgcap /images/k8s-020.png %}

### Шаг №21

Зеркалируем репозиторий elrepo-kernel.

<pre><code>
cd /var/lib/mirror/elrepo/elrepo-kernel/7/x86_64
reposync --gpgcheck -l --downloadcomps --download-metadata --repoid elrepo-kernel –norepopath
</code></pre>

{% imgcap /images/k8s-021.png %}

### Шаг №22

Зеркалируем репозиторий elrepo-testing.

<pre><code>
cd /var/lib/mirror/elrepo/elrepo-testing/7/x86_64
reposync --gpgcheck -l --downloadcomps --download-metadata --repoid elrepo-testing –norepopath
</code></pre>

{% imgcap /images/k8s-022.png %}

### Шаг №23

Зеркалируем репозиторий kubernetes.
<pre><code>
cd /var/lib/mirror/centos/7/kubernetes/x86_64
reposync --gpgcheck -l --downloadcomps --download-metadata --repoid kubernetes –norepopath
</code></pre>

{% imgcap /images/k8s-023.png %}

## Копирование на сервер скриптов

### Шаг №24

Копирование ipxe файлов мастер-узлов. Откройте Приложение №6, вставьте содержимое во временный файл /tmp/ipxe. Выполните команду

<pre><code>
for i in {12..15}; do
cp /tmp/ipxe /var/lib/massdeploy/ipxe/192-168-207-${i}
sed –I “s,XXX,${i},” /var/lib/massdeploy/ipxe/192-168-207-${i}
done
</code></pre>

{% imgcap /images/k8s-024.png %}

### Шаг №25

Копирование ipxe файлов рабочих узлов. Откройте Приложение №8, вставьте содержимое в файл /tmp/ipxe. Выполните команду 

<pre><code>
for i in {40..59}; do
cp /tmp/ipxe /var/lib/massdeploy/ipxe/192-168-207-${i}
sed –I “s,XXX,${i},” /var/lib/massdeploy/ipxe/192-168-207-${i}
done
</code></pre>

{% imgcap /images/k8s-025.png %}

### Шаг №26

Копирование ipxe файл хранилища. Откройте приложение №4, вставьте содержимое в файл /var/lib/massdeploy/ipxe/192-168-207-17

{% imgcap /images/k8s-026.png %}

### Шаг №27

Копирование kickstart файлов мастер-узлов. Откройте Приложение №7, вставьте содержимое в /tmp/ks. Выполните команду

<pre><code>
for i in {12..15}; do
filename=”/var/lib/massdeploy/ks/192-168-207-${i}.ks”
cp /tmp/ipxe ${filename}
sed -i “s,XXX,${i},g” /var/lib/massdeploy/ks/${filename}
letter=””
case “${i}” in
“12”)
letter=”a”
;;
“13”)
letter=”b”
;;
“14”)
letter=”c”
;;
“15”)
letter=”d”
;;
esac
sed -i  “s,LETTER,${letter},” ${filename}
done</code></pre>

{% imgcap /images/k8s-027.png %}

### Шаг №28

Копирование kickstart файл common-master. Откройте Приложение №9. Вставьте содержимое файла в /var/lib/massdeploy/ks/common-master.ks

### Шаг №29

Копирование kickstart файлов мастер-узлов. Откройте Приложение №7, вставьте содержимое в /tmp/ks. Выполните команду

<pre><code>
for i in {12..15}; do
filename=”/var/lib/massdeploy/ks/192-168-207-${i}.ks”
cp /tmp/ipxe ${filename}
sed -i “s,XXX,${i},g” /var/lib/massdeploy/ks/${filename}
done</code></pre>

{% imgcap /images/k8s-028.png %}

### Шаг №30

Копирование kickstart файл common-master. Откройте Приложение №10. Вставьте содержимое файла в /var/lib/massdeploy/ks/common-worker.ks

