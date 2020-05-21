---
layout: page
title: "CoreOS: Установка кластера CoreOS"
date: 2015-02-25
comments: true
sharing: true
footer: true
categories: [coreos, docker, docker registry, vmware, esxi]
previous: "coreos-hardware-description"
next: "coreos-setup-private-repository"
---

**Установка кластера CoreOS**

Рекомендую ознакомится со [следующей статьей](https://www.digitalocean.com/community/tutorial_series/getting-started-with-coreos-2), здесь достаточно подробно описана технология coreos.

Для меня самой большой проблемой было понять, для чего нужен https://discovery.etcd.io/ и как быть, если в корпоративной сети нет доступа к этому ресурсу. Пока не прочел [данную статью](https://coreos.com/docs/cluster-management/setup/cluster-architectures/), где описан вариант Easy Development/Testing Cluster. этот вариант установки кластера буду использовать.

{{< imgcap src="/images/image010.png" caption="image010" >}}

**Варианты установки**:

*   Установка через Cd-rom
*   Установка через netboot

**Установка через Cd-rom**

Я использовал этот вариант как самый простой способ. Необходимо скачать с сервера [образ диска](https://coreos.com/docs/running-coreos/platforms/iso/), при включение виртуальной машины указываем на наш образ и производим загрузку с образа.

{{< imgcap src="/images/image009.png" caption="image009" >}}

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


```
    alias ip='sudo ip'

    ip ad add 192.168.254.202/24 dev ens192
    ip ro add default via 192.168.254.254

    sudo echo "search nurm.local" > /etc/resolv.conf
    sudo echo "nameserver 192.168.254.252" >> /etc/resolv.conf
```

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


```
    alias ip='sudo ip'

    ip link add link ens192 name ens192.777 type vlan id 777

    ip ad add 192.168.254.202/24 dev ens192.777
    ip ro add default via 192.168.254.254

    sudo echo "search nurm.local" > /etc/resolv.conf
    sudo echo "nameserver 192.168.254.252" >> /etc/resolv.conf
```

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


```
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
```

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

```
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
```

**Виртуальная машина: a.coreos**

Виртуальная машина a.coreos будет основной, на ней будет запущен сервис etcd, необходимый для управления кластером. Подготовим cloud-config.yaml для этой виртуальной машины

```
#cloud-config
hostname: a.coreos.nurm.local
ssh_authorized_keys:
    - ssh-rsa AAAA....

users:
  - name: nurmukhamed
    passwd: ..../
    groups:
      - sudo
      - docker

write_files:
    - path: /etc/resolv.conf
      permissions: 0644
      content: |
        search nurm.local
        nameserver 192.168.254.252

coreos:
    etcd:
        addr: 192.168.254.202:4001
    units:
        - name: 10-eth0.network
          command: restart
          content: |
            [Match]
            Name=ens192

            [Network]
            Address=192.168.254.202/24
            Gateway=192.168.254.254
        - name: etcd.service
          command: start
        - name: fleet.service
          command: start
```

**Виртуальная машина: b.coreos**

Виртуальные машины {b,c,d,e}.coreos будут рабочими. Подготовим cloud-config.yaml для этой виртуальной машины

```
#cloud-config
hostname: b.coreos.nurm.local
ssh_authorized_keys:
    - ssh-rsa AAAA....
users:
  - name: nurmukhamed
    passwd: ..../
    groups:
      - sudo
      - docker
write_files:
    - path: /etc/resolv.conf
      permissions: 0644
      content: |
        search nurm.local
        nameserver 192.168.254.252
    - path: /etc/profile.d/etcdctl.sh
      permissions: 0644
      owner: core
      content: |
        # configure etcdctl to work with our etcd servers set above
        export ETCDCTL_PEERS="http://192.168.254.202:4001"
    - path: /etc/profile.d/fleetctl.sh
      permissions: 0644
      owner: core
      content: |
        # configure fleetctl to work with our etcd servers set above
        export FLEETCTL_ENDPOINT=/var/run/fleet.sock
        export FLEETCTL_EXPERIMENTAL_API=true
coreos:
    fleet:
      etcd_servers: "http://192.168.254.202:4001"
    units:
        - name: 10-eth0.network
          command: restart
          content: |
            [Match]
            Name=ens192

            [Network]
            Address=192.168.254.203/24
            Gateway=192.168.254.254
        - name: fleet.service
          command: start
```

**Виртуальная машина: c.coreos**

Виртуальные машины {b,c,d,e}.coreos будут рабочими. Подготовим cloud-config.yaml для этой виртуальной машины

```
#cloud-config
hostname: c.coreos.nurm.local
ssh_authorized_keys:
    - ssh-rsa AAAA....
users:
  - name: nurmukhamed
    passwd: ..../
    groups:
      - sudo
      - docker
write_files:
    - path: /etc/resolv.conf
      permissions: 0644
      content: |
        search nurm.local
        nameserver 192.168.254.252
    - path: /etc/profile.d/etcdctl.sh
      permissions: 0644
      owner: core
      content: |
        # configure etcdctl to work with our etcd servers set above
        export ETCDCTL_PEERS="http://192.168.254.202:4001"
    - path: /etc/profile.d/fleetctl.sh
      permissions: 0644
      owner: core
      content: |
        # configure fleetctl to work with our etcd servers set above
        export FLEETCTL_ENDPOINT=/var/run/fleet.sock
        export FLEETCTL_EXPERIMENTAL_API=true
coreos:
    fleet:
      etcd_servers: "http://192.168.254.202:4001"
    units:
        - name: 10-eth0.network
          command: restart
          content: |
            [Match]
            Name=ens192

            [Network]
            Address=192.168.254.204/24
            Gateway=192.168.254.254
        - name: fleet.service
          command: start
```

**Виртуальная машина: d.coreos**

Виртуальные машины {b,c,d,e}.coreos будут рабочими. Подготовим cloud-config.yaml для этой виртуальной машины

```
#cloud-config
hostname: d.coreos.nurm.local
ssh_authorized_keys:
    - ssh-rsa AAAA....
users:
  - name: nurmukhamed
    passwd: ..../
    groups:
      - sudo
      - docker
write_files:
    - path: /etc/resolv.conf
      permissions: 0644
      content: |
        search nurm.local
        nameserver 192.168.254.252
    - path: /etc/profile.d/etcdctl.sh
      permissions: 0644
      owner: core
      content: |
        # configure etcdctl to work with our etcd servers set above
        export ETCDCTL_PEERS="http://192.168.254.202:4001"
    - path: /etc/profile.d/fleetctl.sh
      permissions: 0644
      owner: core
      content: |
        # configure fleetctl to work with our etcd servers set above
        export FLEETCTL_ENDPOINT=/var/run/fleet.sock
        export FLEETCTL_EXPERIMENTAL_API=true
coreos:
    fleet:
      etcd_servers: "http://192.168.254.202:4001"
    units:
        - name: 10-eth0.network
          command: restart
          content: |
            [Match]
            Name=ens192

            [Network]
            Address=192.168.254.205/24
            Gateway=192.168.254.254
        - name: fleet.service
          command: start
```

**Виртуальная машина: e.coreos**

Виртуальные машины {b,c,d,e}.coreos будут рабочими. Подготовим cloud-config.yaml для этой виртуальной машины

```
#cloud-config
hostname: e.coreos.nurm.local
ssh_authorized_keys:
    - ssh-rsa AAAA....
users:
  - name: nurmukhamed
    passwd: ..../
    groups:
      - sudo
      - docker
write_files:
    - path: /etc/resolv.conf
      permissions: 0644
      content: |
        search nurm.local
        nameserver 192.168.254.252
    - path: /etc/profile.d/etcdctl.sh
      permissions: 0644
      owner: core
      content: |
        # configure etcdctl to work with our etcd servers set above
        export ETCDCTL_PEERS="http://192.168.254.202:4001"
    - path: /etc/profile.d/fleetctl.sh
      permissions: 0644
      owner: core
      content: |
        # configure fleetctl to work with our etcd servers set above
        export FLEETCTL_ENDPOINT=/var/run/fleet.sock
        export FLEETCTL_EXPERIMENTAL_API=true
coreos:
    fleet:
      etcd_servers: "http://192.168.254.202:4001"
    units:
        - name: 10-eth0.network
          command: restart
          content: |
            [Match]
            Name=ens192

            [Network]
            Address=192.168.254.206/24
            Gateway=192.168.254.254
        - name: fleet.service
          command: start
```


**Установка системы**

Я скопировал конфиги для хостов на dnsmasq.nurm.local. при установке системы, копирую конфиг с dnsmasq.nurm.local.

*Вариант установки без прокси-сервера*

```
    sudo -i
    scp nurmukhamed@dnsmasq:/tmp/a.coreos.cloud-config.yaml /tmp/cloud-config.yaml
    coreos-install -d /dev/sda -c /tmp/cloud-config.yaml
    reboot
```

*Вариант установки c прокси-сервером*

```
    sudo -i
    scp nurmukhamed@dnsmasq:/tmp/a.coreos.cloud-config.yaml /tmp/cloud-config.yaml

    export http_proxy="http://proxy.nurm.local:3128"
    export https_proxy="http://proxy.nurm.local:3128"
    export ftp_proxy="http://proxy.nurm.local:3128"

    coreos-install -d /dev/sda -c /tmp/cloud-config.yaml
    reboot
```

Провести данную процедуру на каждой виртуальной машине.

