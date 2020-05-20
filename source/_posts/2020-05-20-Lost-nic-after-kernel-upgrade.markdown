---
layout: post
title: Пропала сеть при обновление ядра kernel-ml
date: '2020-05-20 12:30:30 +0600'
comments: true
published: true
categories:
- linux
- centos
- kernel
- elrepo
- realtek
- r8169
- 8411
- systemd
---

**Пропала сеть при обновление ядра** <!--more-->

В качестве домашнего сервера сейчас работает компьютер на базе ASRock Q1900M. Хорошая матплата, поддерживает 16ГБ ОЗУ, процессор встроен.

Пропала сеть при обновление ядра kernel-ml. Установлена сетевая карта Realtek 8411.

```
lspci -nnk
04:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller [10ec:8168] (rev 11)
        Subsystem: ASRock Incorporation Motherboard (one of many) [1849:8168]
        Kernel driver in use: r8169
        Kernel modules: r8169
```

В интернете подсказали что эта проблема [случается](https://bugs.centos.org/view.php?id=16413) и ее можно [решить](https://superuser.com/questions/1520212/realtek-ethernet-not-working-after-kernel-update).

Пока придумал только один костыль

```
cat <<EOF| sudo tee /etc/systemd/system/load-realtek-driver.service
[Unit]
Description=Load Realtek drivers.
Before=network-online.target

[Service]
Type=simple
ExecStartPre=/usr/sbin/rmmod r8169
ExecStart=/usr/sbin/modprobe r8169

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable load-realtek-driver.service
```
