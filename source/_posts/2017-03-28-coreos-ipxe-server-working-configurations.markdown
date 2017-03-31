---
layout: post
title: COREOS - загрузка по сети
date: '2017-03-28 12:30:30 +0600'
comments: true
published: true
categories:
  - coreos
  - ipxe
  - libvirtd
  - qemu
  - etcd2
---

Решил настроить тестовый кластер coreos с загрузкой по сети.<!--more-->

****UPDATE: 31-03-2017:**** Изменил скрипт поиска обновлений CoreOS.

****Используемые инструменты****:

- домашний сервер CentOS 7
- libvirtd
- coreos 1205
- coreos-ipxe-server
- etcd2

****Задача****:

- Загрузить тестовый кластер по сети;
- Делать разбивку диска при загрузке;
- Создать нового пользователя и его окружение.

###****Настройка libvirtd****

Все виртуальные машины используют сеть по умолчанию в режиме nat, внес изменения в сеть default, закрепил адреса к макадресам виртуальных машин.

{% highlight bash %}
sudo virsh net-edit default

<network>
  <name>default</name>
  <uuid>4b147bf4-7496-4351-acdb-f957fd20d38c</uuid>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:05:d1:18'/>
  <dns>
    <forwarder addr='192.168.10.2'/>
  </dns>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.100' end='192.168.122.254'/>
      <host mac='52:54:00:55:1c:ee' name='a-coreos' ip='192.168.122.2'/>
      <host mac='52:54:00:47:51:e4' name='b-coreos' ip='192.168.122.3'/>
      <host mac='52:54:00:81:ac:aa' name='c-coreos' ip='192.168.122.4'/>
    </dhcp>
  </ip>
</network>
{% endhighlight %}

Виртуальные машины грузятся только по сети. Ниже конфигурация машины a.coreos

{% highlight bash %}
<domain type='kvm'>
  <name>a.coreos</name>
  <uuid>c6c30f6a-4a1b-4337-8325-c4c2543ad437</uuid>
  <memory unit='KiB'>1048576</memory>
  <currentMemory unit='KiB'>1048576</currentMemory>
  <vcpu placement='static'>1</vcpu>
  <os>
    <type arch='x86_64' machine='pc-i440fx-rhel7.0.0'>hvm</type>
    <boot dev='network'/>
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <cpu mode='custom' match='exact'>
    <model fallback='allow'>Penryn</model>
  </cpu>
  <clock offset='utc'>
    <timer name='rtc' tickpolicy='catchup'/>
    <timer name='pit' tickpolicy='delay'/>
    <timer name='hpet' present='no'/>
  </clock>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <pm>
    <suspend-to-mem enabled='no'/>
    <suspend-to-disk enabled='no'/>
  </pm>
  <devices>
    <emulator>/usr/libexec/qemu-kvm</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw'/>
      <source file='/storage/iscsi/a.coreos.img'/>
      <target dev='hda' bus='ide'/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>
    <controller type='scsi' index='0' model='virtio-scsi'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </controller>
    <controller type='usb' index='0' model='ich9-ehci1'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x7'/>
    </controller>
    <controller type='usb' index='0' model='ich9-uhci1'>
      <master startport='0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0' multifunction='on'/>
    </controller>
    <controller type='usb' index='0' model='ich9-uhci2'>
      <master startport='2'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x1'/>
    </controller>
    <controller type='usb' index='0' model='ich9-uhci3'>
      <master startport='4'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x2'/>
    </controller>
    <controller type='pci' index='0' model='pci-root'/>
    <controller type='ide' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/>
    </controller>
    <interface type='bridge'>
      <mac address='52:54:00:55:1c:ee'/>
      <source bridge='virbr0'/>
      <model type='virtio'/>
      <rom bar='on' file='/usr/share/ipxe/coreos/a/virtio-net.rom'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <input type='mouse' bus='ps2'/>
    <input type='keyboard' bus='ps2'/>
    <video>
      <model type='cirrus' vram='16384' heads='1' primary='yes'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </memballoon>
  </devices>
</domain>
{% endhighlight %}

Для каждой виртуальной машины был собран свой образ ipxe для сетевой карты.
Вот настройки сетевой карты для a.coreos

{% highlight bash %}
    <interface type='bridge'>
      <mac address='52:54:00:55:1c:ee'/>
      <source bridge='virbr0'/>
      <model type='virtio'/>
      <rom bar='on' file='/usr/share/ipxe/coreos/a/virtio-net.rom'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
{% endhighlight %}

Соберем образ ipxe для виртуальной машины a.coreos

{% highlight bash %}
cd /usr/src/ipxe/src

cat menu.ipxe
#!ipxe
dhcp
chain http://192.168.122.1:4777?profile=c-coreos

make clean
make EMBED=menu.ipxe bin/virtio-net.rom

mkdir -p /usr/share/ipxe/coreos/{a,b,c}
mv bin/virtio-net.rom /usr/share/ipxe/coreos/a/virtio-net.rom

{% endhighlight %}


###****Coreos-ipxe-server****


Я использую [coreos-ipxe-server](https://github.com/kelseyhightower/coreos-ipxe-server) для загрузки по сети конфигурации для coreos-машин

{% highlight bash %}
mkdir -p ${GOPATH}/src/github.com/kelseyhightower
cd ${GOPATH}/src/github.com/kelseyhightower
git clone git@github.com:kelseyhightower/coreos-ipxe-server.git

cd ${GOPATH}/src/github.com/kelseyhightower/coreos-ipxe-server
go build .

mkdir -p /opt/coreos-ipxe-server/{configs,images,profiles,sshkeys}
cp coreos-ipxe-server /opt/coreos-ipxe-server

cat <<EOF > /etc/systemd/system/coreos-ipxe-server.service
[Unit]
Description=coreos-ipxe-server service
After=libvirtd.service

[Service]
Type=simple
Environment=COREOS_IPXE_SERVER_BASE_URL=coreos-ipxe.nurm.local:4777

ExecStart=/opt/coreos-ipxe-server/coreos-ipxe-server
KillSignal=SIGINT
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

systemctl enable coreos-ipxe-server
systemctl start coreos-ipxe-server

{% endhighlight %}

Время от времени нужно проверять текущую версию Coreos. я написал небольшой скрипт, который:

- проверяет текущую версию на сайте;
- изменяет версии во всех профайлах;
- скачивает последние версии на сервер.

Закинул данный файл в /etc/cron.daily/

{% highlight bash %}
#!/bin/bash

curl http://stable.release.core-os.net/amd64-usr/current/coreos_production_pxe.sh -o /tmp/coreos-current-version.sh

left=$(cat /tmp/coreos-current-version.sh | grep "VM_NAME" | grep "coreos_production"| cut -d "=" -f 2 | cut -d '-' -f 2)
center=$(cat /tmp/coreos-current-version.sh | grep "VM_NAME" | grep "coreos_production" | cut -d "=" -f 2 | cut -d '-' -f 3)
right=$(cat /tmp/coreos-current-version.sh | grep "VM_NAME" | grep "coreos_production" | cut -d "=" -f 2 | cut -d '-' -f 4 | sed "s/'//")

CURRENT_RELEASE_VERSION=$(echo ${left}.${center}.${right})
echo ${CURRENT_RELEASE_VERSION}

echo "start circle"

for profile in $(ls /opt/coreos-ipxe-server/profiles); do
    USED_RELEASE_VERSION=$(cat /opt/coreos-ipxe-server/profiles/${profile} | jq '.version' | sed 's/\"//g')
    echo ${USED_RELEASE_VERSION}

    if [ "${USED_RELEASE_VERSION}" != "${CURRENT_RELEASE_VERSION}" ]; then
        echo "used release version dont match with current release version from website"
        sed -i "s/${USED_RELEASE_VERSION}/${CURRENT_RELEASE_VERSION}/" /opt/coreos-ipxe-server/profiles/${profile}
    fi
done

if [ ! -d "/opt/coreos-ipxe-server/images/amd64-usr/${CURRENT_RELEASE_VERSION}" ]; then
   mkdir -p /opt/coreos-ipxe-server/images/amd64-usr/${CURRENT_RELEASE_VERSION}
fi

if [ ! -f /opt/coreos-ipxe-server/images/amd64-usr/${CURRENT_RELEASE_VERSION}/coreos_production_pxe.vmlinuz ]; then
   curl -o /opt/coreos-ipxe-server/images/amd64-usr/${CURRENT_RELEASE_VERSION}/coreos_production_pxe.vmlinuz http://stable.release.core-os.net/amd64-usr/${CURRENT_RELEASE_VERSION}/coreos_production_pxe.vmlinuz
fi

if [ ! -f /opt/coreos-ipxe-server/images/amd64-usr/${CURRENT_RELEASE_VERSION}/coreos_production_pxe_image.cpio.gz ]; then
   curl -o /opt/coreos-ipxe-server/images/amd64-usr/${CURRENT_RELEASE_VERSION}/coreos_production_pxe_image.cpio.gz http://stable.release.core-os.net/amd64-usr/${CURRENT_RELEASE_VERSION}/coreos_production_pxe_image.cpio.gz
fi

{% endhighlight %}

Создаем профили для виртуальных машин

{% highlight bash %}
[nurmukhamed@corei3 coreos-ipxe-server]$ cat profiles/a-coreos.json 
{
    "cloud_config": "a-cloud-config",
    "rootfstype": "btrfs",
    "sshkey": "nurmukhamed",
    "version": "1298.6.0"
}
[nurmukhamed@corei3 coreos-ipxe-server]$ cat profiles/b-coreos.json 
{
    "cloud_config": "b-cloud-config",
    "rootfstype": "btrfs",
    "sshkey": "nurmukhamed",
    "version": "1298.6.0"
}
[nurmukhamed@corei3 coreos-ipxe-server]$ cat profiles/c-coreos.json 
{
    "cloud_config": "c-cloud-config",
    "rootfstype": "btrfs",
    "sshkey": "nurmukhamed",
    "version": "1298.6.0"
}
{% endhighlight %}

Просмотр конфигурации для a-coreos. Что делает данная конфигурация:

- Задает имя сервера;
- Создает нового пользователя nurmukhamed;
- Добавляет пользователя nurmukhamed в группы sudo, docker;
- Задает ssh-ключ для авторизации;
- Создает файл /home/nurmukhamed/.bashrc, где задаются алиасы и полезные утилиты;
- Производит очистку жесткого диска, разбиение диска на два раздела;
- Производит форматирование разделов, подключает разделы к /var/lib/docker, /var/lib/rkt;
- Настраивает сервер для работы с etcd2 сервисом, на сервере CentOS.

{% highlight bash %}
#cloud-config
hostname: a-coreos.nurm.local
users:
  - name: nurmukhamed
    groups:
      - sudo
      - docker
    ssh-authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDnnMkmWq5JNNn/cEx0WyRO330OAmlvWeVwrite-files:
  - path: /home/nurmukhamed/.bashrc
    permissions: '0644'
    content: |
      # .bashrc
      
      # Source global definitions
      if [ -f /etc/bashrc ]; then
        ./etc/bashrc
      fi
      
      alias systemctl='sudo systemctl'
      alias svim='sudo vim'
      alias list-units='sudo fleetctl list-units'
      alias list-machines='sudo fleetctl list-machines'
      alias list-unit-files='sudo fleetctl list-unit-files'
      
      service_del() {
        sudo fleetctl stop "$@"
        sudo fleetctl unload "$@"
        sudo fleetctl destroy "$@"
        
      }
      service_add() {
        sudo fleetctl submit "$@"
        sudo fleetctl load "$@"
        sudo fleetctl start "$@"
      }
      
      sprunge() {
        if [[ $1 ]]; then
          curl -F 'sprunge=<-' "http://sprunge.us" <"$1"
        else
          curl -F 'sprunge=<-' "http://sprunge.us"
        fi
      }
coreos:
  units:
    - name: format-ephemeral.service
      command: start
      content: |
        [Unit]
        Description=Formats the ephemeral drive
        After=dev-sda.device
        Requires=dev-sda.device
        Before=docker.service
        Before=fleet.service
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        ExecStart=/usr/sbin/wipefs -f /dev/sda
        ExecStart=/usr/sbin/parted -s /dev/sda mklabel gpt
        ExecStart=/usr/sbin/parted -s /dev/sda mkpart primary ext4 0 9614
        ExecStart=/usr/sbin/parted -s /dev/sda mkpart primary ext4 9615 19229
        ExecStart=/usr/sbin/mkfs.ext4 -F /dev/sda1
        ExecStart=/usr/sbin/mkfs.ext4 -F /dev/sda2
    - name: var-lib-docker.mount
      command: start
      content: |
        [Unit]
        Description=Mount ephemeral to /var/lib/docker
        Requires=format-ephemeral.service
        After=format-ephemeral.service
        Before=docker.service
        [Mount]
        What=/dev/sda1
        Where=/var/lib/docker
        Type=ext4
    - name: var-lib-rkt.mount
      command: start
      content: |
        [Unit]
        Description=Mount ephemeral to /var/lib/rkt
        Requires=format-ephemeral.service
        After=format-ephemeral.service
        Before=fleet.service
        [Mount]
        What=/dev/sda2
        Where=/var/lib/rkt
        Type=ext4
    - name: docker.service
      command: start
    - name: fleet.service
      command: start
  fleet:
    etcd_servers: "http://coreos-ipxe.nurm.local:2379"
  locksmith:
    endpoint: "http://coreos-ipxe.nurm.local:2379"
{% endhighlight %}

###****Настройка dnsmasq****

{% highlight bash %}
cat /etc/dnsmasq.d/addresses.conf
address=/coreos-ipxe.nurm.local/192.168.122.1
address=/a-coreos.nurm.local/192.168.122.2
address=/b-coreos.nurm.local/192.168.122.3
address=/c-coreos.nurm.local/192.168.122.4
srv-host=_etcd-server._tcp.nurm.local,coreos-ipxe.nurm.local,2380,1
srv-host=_etcd-client._tcp.nurm.local,coreos-ipxe.nurm.local,2380,1
{% endhighlight %}

###****Настройка ETCD2****

{% highlight bash %}
cat /etc/etcd/etcd.conf
# [member]
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
#ETCD_WAL_DIR=""
#ETCD_SNAPSHOT_COUNT="10000"
#ETCD_HEARTBEAT_INTERVAL="100"
#ETCD_ELECTION_TIMEOUT="1000"
ETCD_LISTEN_PEER_URLS="http://192.168.122.1:2380"
#ETCD_LISTEN_CLIENT_URLS="http://coreos-ipxe.nurm.local:2379"
#ETCD_MAX_SNAPSHOTS="5"
#ETCD_MAX_WALS="5"
#ETCD_CORS=""
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379,http://0.0.0.0:4001"
#ETCD_ADVERTISE_CLIENT_URLS="http://coreos-ipxe.nurm.local:2379"
#
#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://coreos-ipxe.nurm.local:2380"
# if you use different ETCD_NAME (e.g. test), set ETCD_INITIAL_CLUSTER value for this name, i.e. "test=http://..."
#ETCD_INITIAL_CLUSTER="default=http://localhost:2380"
#ETCD_INITIAL_CLUSTER_STATE="new"
#ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-1"
ETCD_ADVERTISE_CLIENT_URLS="http://coreos-ipxe.nurm.local:2379"
#ETCD_DISCOVERY=""
#ETCD_DISCOVERY_SRV="nurm.local"
#ETCD_DISCOVERY_FALLBACK="proxy"
#ETCD_DISCOVERY_PROXY=""
#
#[proxy]
#ETCD_PROXY="off"
#ETCD_PROXY_FAILURE_WAIT="5000"
#ETCD_PROXY_REFRESH_INTERVAL="30000"
#ETCD_PROXY_DIAL_TIMEOUT="1000"
#ETCD_PROXY_WRITE_TIMEOUT="5000"
#ETCD_PROXY_READ_TIMEOUT="0"
#
#[security]
#ETCD_CERT_FILE=""
#ETCD_KEY_FILE=""
#ETCD_CLIENT_CERT_AUTH="false"
#ETCD_TRUSTED_CA_FILE=""
#ETCD_PEER_CERT_FILE=""
#ETCD_PEER_KEY_FILE=""
#ETCD_PEER_CLIENT_CERT_AUTH="false"
#ETCD_PEER_TRUSTED_CA_FILE=""
#
#[logging]
#ETCD_DEBUG="false"
# examples for -log-package-levels etcdserver=WARNING,security=DEBUG
#ETCD_LOG_PACKAGE_LEVELS=""
{% endhighlight %}

###****Настройка ssh-клиента****

Также требуется внести изменения в работе ssh-клиента. При каждой загрузке виртуальной машины, сервер coreos генерирует новые ssh-ключи, нужно научить ssh-клиента не обращать на это внимание.

{% highlight bash %}
Host a-coreos
    Hostname a-coreos.nurm.local
    User nurmukhamed
    StrictHostKeyChecking no

Host b-coreos
    Hostname b-coreos.nurm.local
    User nurmukhamed
    StrictHostKeyChecking no

Host c-coreos
    Hostname c-coreos.nurm.local
    User nurmukhamed
    StrictHostKeyChecking no
{% endhighlight %}

###Итоги

Данная конфигурация рабочая, после запуска 3х серверов, получаем рабочий кластер coreos.
