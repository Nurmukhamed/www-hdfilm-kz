---
layout: post
title: Запускаем Kubernetes на кластере CoreOS
date: '2017-04-04 12:30:30 +0600'
comments: true
published: false
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
Решил создать отдельный репозиторий, куда выложу файлы необходимые для запуска kubernetes в кластере coreos

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
      - 1298.5.0
        - coreos_production_pxe_image.cpio.gz
        - coreos_production_pxe.vmlinuz
      - 1298.6.0
        - coreos_production_pxe_image.cpio.gz
        - coreos_production_pxe.vmlinuz
      - 1298.7.0
        - coreos_production_pxe_image.cpio.gz
        - coreos_production_pxe.vmlinuz
  - profiles
    - a-coreos.json
    - b-coreos.json
    - c-coreos.json
  - sshkeys
    - nurmukhamed.pub
