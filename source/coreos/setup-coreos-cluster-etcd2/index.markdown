---
layout: page
title: 'CoreOS: Установка кластера CoreOS ETCD2'
date: '2017-03-10 12:30'
comments: true
sharing: true
footer: true
categories:
  - centos
  - coreos
  - docker
  - docker registry
  - vmware
  - esxi
previous: coreos/hardware-description
next: coreos/setup-private-repository
published: true
---
**Установка кластера CoreOS**

****Update****: С февраля 2015 года coreos успел сменить etcd на etcd2. В связи с этим изменилась настройка серверов coreos. Здесь я изменил настройки для работы с более современными версиями coreos.

Рекомендую ознакомится со [следующей статьей](https://www.digitalocean.com/community/tutorial_series/getting-started-with-coreos-2), здесь достаточно подробно описана технология coreos.

Для меня самой большой проблемой было понять, для чего нужен https://discovery.etcd.io/ и как быть, если в корпоративной сети нет доступа к этому ресурсу. Пока не прочел [данную статью](https://coreos.com/docs/cluster-management/setup/cluster-architectures/), где описан вариант Easy Development/Testing Cluster. этот вариант установки кластера буду использовать.

{% imgcap /images/image010.png %}


**Варианты установки**:

*   Установка через Cd-rom
*   Установка через netboot

**Установка через Cd-rom**

Я использовал этот вариант как самый простой способ. Необходимо скачать с сервера [образ диска](https://coreos.com/docs/running-coreos/platforms/iso/), при включение виртуальной машины указываем на наш образ и производим загрузку с образа.

{% imgcap /images/image009.png %}

**Варианты сетевых настроек**:

Рассмотрим различные варианты настроек сети

*Простая настройка*

<table>
    <tr>
        <td>NIC1</td>
        <td>ens192</td>
    </tr>
    <tr>
        <td>NIC2</td>
        <td>NA</td>
    </tr>
    <tr>
        <td>VLAN-ID</td>
        <td>NA</td>
    </tr>
    <tr>
        <td>BONDING</td>
        <td>NA</td>
    </tr>
</table>


<pre><code>
    alias ip='sudo ip'

    ip ad add 192.168.254.202/24 dev ens192
    ip ro add default via 192.168.254.254

    sudo echo "search nurm.local" > /etc/resolv.conf
    sudo echo "nameserver 192.168.254.252" >> /etc/resolv.conf
</code></pre>

*Настройка VLAN*

<table>
    <tr>
        <td>NIC1</td>
        <td>ens192</td>
    </tr>
    <tr>
        <td>NIC2</td>
        <td>NA</td>
    </tr>
    <tr>
        <td>VLAN-ID</td>
        <td>777</td>
    </tr>
    <tr>
        <td>BONDING</td>
        <td>NA</td>
    </tr>
</table>


<pre><code>
    alias ip='sudo ip'

    ip link add link ens192 name ens192.777 type vlan id 777

    ip ad add 192.168.254.202/24 dev ens192.777
    ip ro add default via 192.168.254.254

    sudo echo "search nurm.local" > /etc/resolv.conf
    sudo echo "nameserver 192.168.254.252" >> /etc/resolv.conf
</code></pre>

*Настройка Bonding*

<table>
    <tr>
        <td>NIC1</td>
        <td>ens192</td>
    </tr>
    <tr>
        <td>NIC2</td>
        <td>ens193</td>
    </tr>
    <tr>
        <td>VLAN-ID</td>
        <td>NA</td>
    </tr>
    <tr>
        <td>BONDING</td>
        <td>bond0</td>
    </tr>
</table>


<pre><code>
    alias ip='sudo ip'

    sudo modprobe bonding miimon=100

    ip link set dev ens192 down
    ip link set dev ens193 down

    ip link set dev ens192 master bond0
    ip link set dev ens193 master bond0

    ip ad add 192.168.254.202/24 dev bond0
    ip ro add default via 192.168.254.254

    echo "search nurm.local" > /etc/resolv.conf
    echo "nameserver 192.168.254.252" >> /etc/resolv.conf
</code></pre>

*Настройка VLAN over Bonding*

<table>
    <tr>
        <td>NIC1</td>
        <td>ens192</td>
    </tr>
    <tr>
        <td>NIC2</td>
        <td>ens193</td>
    </tr>
    <tr>
        <td>VLAN-ID</td>
        <td>777</td>
    </tr>
    <tr>
        <td>BONDING</td>
        <td>bond0</td>
    </tr>
</table>

<pre><code>
    alias ip='sudo ip'

    sudo modprobe bonding miimon=100

    ip link set dev ens192 down
    ip link set dev ens193 down

    ip link set dev ens192 master bond0
    ip link set dev ens193 master bond0

    ip link add link bond0 name bond0.777 type vlan id 777

    ip ad add 192.168.254.202/24 dev bond0.777
    ip ro add default via 192.168.254.254

    echo "search nurm.local" > /etc/resolv.conf
    echo "nameserver 192.168.254.252" >> /etc/resolv.conf
</code></pre>

##Настройка DNS-сервера

ETCD2 имеет возможность определить через днс-сервер, где находятся сервера ETCD2.
У меня используется dnsmasq. Ниже настройки:

<pre><code>
address=/a-coreos.nurm.local/192.168.122.2
address=/b-coreos.nurm.local/192.168.122.3
address=/c-coreos.nurm.local/192.168.122.4
srv-host=_etcd-server._tcp.nurm.local,a-coreos.nurm.local,2380,1
srv-host=_etcd-server._tcp.nurm.local,b-coreos.nurm.local,2380,1
srv-host=_etcd-server._tcp.nurm.local,c-coreos.nurm.local,2380,1
srv-host=_etcd-client._tcp.nurm.local,a-coreos.nurm.local,2380,1
srv-host=_etcd-client._tcp.nurm.local,b-coreos.nurm.local,2380,1
srv-host=_etcd-client._tcp.nurm.local,c-coreos.nurm.local,2380,1
</code></pre>


**Виртуальная машина: a.coreos**

Виртуальная машина a.coreos будет основной, на ней будет запущен сервис etcd2, необходимый для управления кластером. Подготовим cloud-config.yaml для этой виртуальной машины

<pre><code>
#cloud-config
hostname: a-coreos.nurm.local
users:
  - name: nurmukhamed
    passwd: OPENSSL GENERATED HASH
    groups:
      - sudo
      - docker
    ssh-authorized-keys:
      - ssh-rsa AAA
write-files:
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
    - name: 10-static.network
      runtime: no
      content: |
        [Match]
        Name=eth0

        [Network]
        Address=192.168.10.18/24
        Gateway=192.168.10.1
        DNS=192.168.10.2
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start
    - name: docker.service
      command: start
    - name: rpc-statd.service
      command: start
      enable: true
  etcd2:
    name: a-coreos
    discovery-srv: nurm.local
    initial-advertise-peer-urls: http://a-coreos.nurm.local:2380
    initial-cluster-token: etcd-cluster-1
    initial-cluster-state: new
    advertise-client-urls: http://a-coreos.nurm.local:2379
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    listen-peer-urls: http://a-coreos.nurm.local:2380
</code></pre>

**Виртуальная машина: b.coreos**

Виртуальные машины {b,c,d,e}.coreos будут рабочими. Подготовим cloud-config.yaml для этой виртуальной машины

<pre><code>
#cloud-config
hostname: b-coreos.nurm.local
users:
  - name: nurmukhamed
    passwd: SOME SSL GENERATED HASH
    groups:
      - sudo
      - docker
    ssh-authorized-keys:
      - ssh-rsa AAAA
write-files:
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
    - name: 10-static.network
      runtime: no
      content: |
        [Match]
        Name=eth0

        [Network]
        Address=192.168.10.19/24
        Gateway=192.168.10.1
        DNS=192.168.10.2
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start
    - name: docker.service
      command: start
  etcd2:
    name: b-coreos
    discovery-srv: nurm.local
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    advertise-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    proxy: on
  fleet:
    etcd_servers: "http://localhost:2379"
  locksmith:
    endpoint: "http://localhost:2379"
</code></pre>

**Виртуальная машина: c.coreos**

Виртуальные машины {b,c,d,e}.coreos будут рабочими. Подготовим cloud-config.yaml для этой виртуальной машины

<pre><code>
#cloud-config
hostname: c-coreos.nurm.local
users:
  - name: nurmukhamed
    passwd: SOME SSL GENERATED HASH
    groups:
      - sudo
      - docker
    ssh-authorized-keys:
      - ssh-rsa AAAA
write-files:
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
    - name: 10-static.network
      runtime: no
      content: |
        [Match]
        Name=eth0

        [Network]
        Address=192.168.10.20/24
        Gateway=192.168.10.1
        DNS=192.168.10.2
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start
    - name: docker.service
      command: start
  etcd2:
    name: c-coreos
    discovery-srv: nurm.local
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    advertise-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    proxy: on
  fleet:
    etcd_servers: "http://localhost:2379"
  locksmith:
    endpoint: "http://localhost:2379"
</code></pre>

**Виртуальная машина: d.coreos**

Виртуальные машины {b,c,d,e}.coreos будут рабочими. Подготовим cloud-config.yaml для этой виртуальной машины

<pre><code>
#cloud-config
hostname: d-coreos.nurm.local
users:
  - name: nurmukhamed
    passwd: SOME SSL GENERATED HASH
    groups:
      - sudo
      - docker
    ssh-authorized-keys:
      - ssh-rsa AAAA
write-files:
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
    - name: 10-static.network
      runtime: no
      content: |
        [Match]
        Name=eth0

        [Network]
        Address=192.168.10.21/24
        Gateway=192.168.10.1
        DNS=192.168.10.2
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start
    - name: docker.service
      command: start
  etcd2:
    name: d-coreos
    discovery-srv: nurm.local
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    advertise-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    proxy: on
  fleet:
    etcd_servers: "http://localhost:2379"
  locksmith:
    endpoint: "http://localhost:2379"</code></pre>

**Виртуальная машина: e.coreos**

Виртуальные машины {b,c,d,e}.coreos будут рабочими. Подготовим cloud-config.yaml для этой виртуальной машины

<pre><code>
#cloud-config
hostname: e-coreos.nurm.local
users:
  - name: nurmukhamed
    passwd: SOME SSL GENERATED HASH
    groups:
      - sudo
      - docker
    ssh-authorized-keys:
      - ssh-rsa AAAA
write-files:
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
    - name: 10-static.network
      runtime: no
      content: |
        [Match]
        Name=eth0

        [Network]
        Address=192.168.10.22/24
        Gateway=192.168.10.1
        DNS=192.168.10.2
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start
    - name: docker.service
      command: start
  etcd2:
    name: e-coreos
    discovery-srv: nurm.local
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    advertise-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    proxy: on
  fleet:
    etcd_servers: "http://localhost:2379"
  locksmith:
    endpoint: "http://localhost:2379"
  </code></pre>


**Установка системы**

Я скопировал конфиги для хостов на dnsmasq.nurm.local. при установке системы, копирую конфиг с dnsmasq.nurm.local.

*Вариант установки без прокси-сервера*

<pre><code>
    sudo -i
    scp nurmukhamed@dnsmasq:/tmp/a.coreos.cloud-config.yaml /tmp/cloud-config.yaml
    coreos-install -d /dev/sda -c /tmp/cloud-config.yaml
    reboot
</code></pre>

*Вариант установки c прокси-сервером*

<pre><code>
    sudo -i
    scp nurmukhamed@dnsmasq:/tmp/a.coreos.cloud-config.yaml /tmp/cloud-config.yaml

    export http_proxy="http://proxy.nurm.local:3128"
    export https_proxy="http://proxy.nurm.local:3128"
    export ftp_proxy="http://proxy.nurm.local:3128"

    coreos-install -d /dev/sda -c /tmp/cloud-config.yaml
    reboot
</code></pre>

Провести данную процедуру на каждой виртуальной машине.
