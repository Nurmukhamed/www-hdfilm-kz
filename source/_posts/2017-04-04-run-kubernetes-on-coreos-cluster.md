---
layout: post
title: Запускаем Kubernetes на кластере CoreOS
date: '2017-04-04 12:30:30 +0600'
comments: true
published: true
categories:
- coreos
- kubernetes
- ipxe
- github
- howto
---

Как запустить Kubernetes на кластере CoreOS. <!--more-->

##Получилось

Две недели пришлось потратить и вот у меня запущен kubernetes на кластере coreos.
Решил создать [отдельный репозиторий](https://github.com/Nurmukhamed/run-kubernetes-over-coreos-cluster-ipxe-booted), куда выложил файлы необходимые для запуска kubernetes в кластере coreos.

****Содержимое****

- /etc/kubernetes/
  - manifests
    - apiserver-pod.json
    - controller-mgr-pod.json
    - scheduler-pod.json
- /opt/coreos-ipxe-server/
  - configs
    - a-cloud-config.yml
	- b-cloud-config.yml
    - c-cloud-config.yml
  - coreos-ipxe-server
  - images
    - amd64-usr
  - profiles
    - a-coreos.json
    - b-coreos.json
    - c-coreos.json
  - sshkeys
    - nurmukhamed.pub

##Описание
- Количество машин в кластере - 3
- Тип машин - виртуальные машины в libvirt
- Тип загрузки - по сети через ipxe

Kubernetes запускается поверх кластера, [который уже был настроен ранее]({{ root.url }}/blog/2017/03/28/coreos-ipxe-server-working-configurations/).

Все файлы необходимые для старта kubernetes загружаются из конфигурационного файл coreos.
