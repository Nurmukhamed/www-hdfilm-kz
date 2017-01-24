---
layout: page
title: "CoreOS: Установка виртуальной машины Delevopers"
date: 2015-02-25 15:45
comments: true
sharing: true
footer: true
categories: [centos, coreos, docker, docker registry, vmware, esxi]
previous: "coreos/setup-private-repository"
next: "coreos/docker-base-tools"
---
**Установка виртуальной машины Delevopers**

Для чего нужна виртуальная машина Developers:

*   Для создания, тестирования новых образов Docker.
*   Для push/pull образов Docker в частный репозитарий.

Данная виртуальная машина будет полигоном для нашего кластера.
Кузница новых образов, модернизации старых образов Docker.
Вся грязная работа будет проводиться здесь. Кратко опишем, что нужно сделать, чтобы установить ОС.

*Шаги:*

*   Установить минимальный образ CentOS
*   Отключить selinux
*   Настроить сеть, имя хоста
*   Подключить yum репозиторий epel
*   Провести обновление пакетов

*Установка Docker*

<pre><code>
    yum install docker-io
</code></pre>

