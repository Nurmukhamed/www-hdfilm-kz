---
layout: page
title: "CoreOS: Описание железа, виртуальных машин, топология сети"
date: 2015-02-25 15:45
comments: true
sharing: true
footer: true
categories: [centos, coreos, docker, docker registry, vmware, esxi]
previous: "coreos/intro"
next: "coreos/setup-coreos-cluster-etcd2"
---

**Описание железа, виртуальных машин, топология сети:**


*   **Сервер**:
    *   HP Proliant Microserver
    *   16GB Ram
    *   160GB SSD
    *   1GB NIC
*   **Операционная система**
    *   VmWare ESXi 5.5
*   **Виртуальные машины**
    *   Router
    *   Dnsmasq
    *   Developer
    *   Hub
    *   a.coreos
    *   b.coreos
    *   c.coreos
    *   d.coreos
    *   e.coreos
*   **Docker Containers**
    *   a.httpd
    *   b.httpd
    *   c.httpd
    *   a.haproxy
    *   a.curl
    *   b.curl
    *   c.curl
*   **Сетевые настройки**
    *   Network - 192.168.254.0/24
    *   Router  - 192.168.254.254
    *   ESXi    - 192.168.254.253
    *   Dnsmasq - 192.168.254.252
    *   Developer - 192.168.254.200
    *   Hub     - 192.168.254.201
    *   a.CoreOS    - 192.168.254.202
    *   b.CoreOS    - 192.168.254.203
    *   c.CoreOS    - 192.168.254.204
    *   d.CoreOS    - 192.168.254.205
    *   e.CoreOS    - 192.168.254.206
    *   a.httpd     - 192.168.254.207
    *   b.httpd     - 192.168.254.208
    *   c.httpd     - 192.168.254.209
    *   a.haproxy   - 192.168.254.210
    *   a.curl      - 192.168.254.212
    *   b.curl      - 192.168.254.213
    *   c.curl      - 192.168.254.214
*   **Параметры виртуальных машин**
    *   **Developer**
        *   CPU - 1
        *   RAM - 512Mb
        *   HDD - 8Gb
        *   NIC - 1 Vmxnet3
    *   **Hub**
        *   CPU - 1
        *   RAM - 512Mb
        *   HDD - 16GB
        *   NIC - 1 Vmxnet3
    *   **CoreOS**
        *   CPU - 1
        *   RAM - 512Mb
        *   HDD - 16Gb
        *   NIC - 1 Vmxnet3


{% imgcap /images/image001.png %}
{% imgcap /images/image006.png %}
{% imgcap /images/image008.png %}
{% imgcap /images/image002.png %}
{% imgcap /images/image003.png %}
{% imgcap /images/image004.png %}
{% imgcap /images/image005.png %}
{% imgcap /images/image007.png %}

