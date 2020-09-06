---
layout: page
title: "CoreOS: Установка Private Repository"
date: 2015-02-25 15:45
comments: true
sharing: true
footer: true
categories: [coreos, docker, docker registry, vmware, esxi]
previous: "coreos/setup-coreos-cluster"
next: "coreos/setup-developers-vm"
---
**Установка Private Repository**

Для чего нужен частный репозиторий:

*   Для локального хранения образов Docker.
*   Для хранения образов, которые по требованиям безопасности нельзя выкладывать в общий доступ.
*   Для ускорения создания новых образов, тестирования.

Еще следует отметить, что большинство образов в публичных репозиториях никак не контролируется.

Шаги:

*   Установить минимальный образ CentOS
*   Отключить selinux
*   Настроить сеть, имя хоста
*   Подключить yum репозиторий epel
*   Провести обновление пакетов
*   Создать папку /docker-registry

```
    yum install docker-io, docker-repository
    mkdir -p /usr/lib/python2.6/site-packages/backports/lzma
    cp -r /usr/lib64/python2.6/site-packages/backports/lzma/* /usr/lib/python2.6/site-packages/backports/lzma
    cp -r /usr/lib64/python2.6/site-packages/backports.lzma-0.0.2-py2.6.egg-info /usr/lib/python2.6/site-packages/
```

У меня при установке возникла проблема с запуском службы docker-registry. Проблема была связана с тем, что docker-registry нужны были файлы от 32битного питона, а нужные библиотеки, в частности, backport-lzma, находились в 64битном питоне.

в файле /etc/docker-registry.yml измените следующие строки

```
     sqlalchemy_index_database: _env:SQLALCHEMY_INDEX_DATABASE:sqlite:////docker-registry/docker-registry.db
     storage_path: /var/lib/docker-registry
```

Добавим службы в автозагрузку, запустим службы.

```
    chkconfig docker on
    chkconfig docker-registry on
    service docker start
    service docker-registry on
```

Проверим работу частного репозитария

```
[nurmukhamed@hub ~]$ sudo netstat -anp| grep ":5000"
tcp        0      0 0.0.0.0:5000                0.0.0.0:*                   LISTEN      3040/python
```

Работает, отлично. Переходим к следующей главе.

