---
layout: page
title: "CoreOS: Работа с контейнерами, создание базового образа"
date: 2015-02-25 15:46
comments: true
sharing: true
footer: true
categories: [centos, coreos, docker, docker registry, vmware, esxi]
previous: "coreos-setup-developers-vm"
next: "coreos-create-docker-images-for-test"
---

Кратко опишем, что нужно сделать, чтобы создать новый образ, как загрузить образ в репозиторий.

*Создание нового образа*

Мы не будем использовать публичные репозитории. все образы будут собраны нами. что позволит нам лучше контролировать образы, улучшить безопасность.

Для генерации нового образа воспользуемся скриптом [mkimage-yum.sh](https://github.com/docker/docker/blob/master/contrib/mkimage-yum.sh). Данный скрипт создает CentOS из под CentOS.

*Скачаем скрипт с github*

```
    cd /usr/local/bin
    wget https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-yum.sh
    chmod +x mkimage-yum.sh
```

*Создадим первый образ*

```
    sudo /usr/local/bin/mkimage-yum.sh centos
```

*Проверим образ*

```
    docker images
```

```
centos 6.6 ${IMAGE_ID} 6 days ago 203.9 MB
```

Локальный образ создан, нужно теперь залить данный образ на репозиторий

*Push Image*

```
    docker tag ${IMAGE_ID} hub.nurm.local:5000/centos
    docker push hub.nurm.local:5000/centos
    docker images
```

```
hub.nurm.local:5000/centos                       6.6                 ${IMAGE_ID}        6 days ago          203.9 MB
centos                                                       6.6                 ${IMAGE_ID}        6 days ago          203.9 MB
hub.nurm.local:5000/centos/6.6                   latest              ${IMAGE_ID}        6 days ago          203.9 MB
```

Наш образ успешно загружен на репозиторий.

Для лучшего понимания работы Docker рекомендую прочитать документацию на официальном сайте [Docker](https://docs.docker.com/)

