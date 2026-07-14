---
title: "Серьезные изменения в настройке кластеров Talos"
date: 2026-07-14T12:44:55+05:00
summary: ""
categories:
- talos
- kubernetes
- persistent volumes
- local-path-provisioner

---
Серьезные изменения в настройке кластеров Talos
<!--more-->

# Intro 

Мне нравится проект [Talos](https://www.siderolabs.com/talos-linux) - минимальный дистрибутив для развертывания кластера Kubernetes.
Использую в лабораторных проектах, в принципе все устраивает.

Но вот в 2025 году не было проектов, а в июле 2026 пришлось поработать и вот обнаружил изменения в настройках.


## Изменился talosctl

talosctl изменился и команды, которые раньше работали нужно исправлять. Ну это не самое страшное.

## Изменение в разбиение дисков

Ранее, в 2022-2024 годах можно было спокойно поставить talos, затем запустить local-path-provisioner, повесить labels на namespace.
Ну и все работало. Для лабораторных работ больше не нужно было.

Теперь же нужно нужно добавлять новые манифесты UserVolumeConfig, VolumeConfig.

## get disks

Всю информацию о дисковой подсистеме можно получить используя следующие команды.

~~~bash
talosctl get disks --insecure -e 192.168.1.2 -n 192.168.1.2

talosctl get disks --insecure -o yaml -e 192.168.1.2 -n 192.168.1.2
~~~

## EPHEMERAL занимает все свободное место на диске

Ставим с нуля talos, затем допустим запускаем longhorn, а оно не работает. Нет места.

Это решается следующим образом, в control-plane.yaml (worker.yaml) добавляем следующие строки

~~~yaml
---
apiVersion: v1alpha1
kind: VolumeConfig
name: EPHEMERAL
provisioning:
  maxSize: 100GB
---
version: v1alpha1
debug: false
persist: true
machine:
    type: controlplane
~~~

EPHEMERAL ограничен размером в 100ГБайт. Не забывайте, что etcd data dir хранится в EPHEMERAL, не сильно ограничивайте EPHEMERAL 
в размере без особой необходимости.

Также можно ограничить и другие Volumes - EFI, META, STATE. Более подробнее [здесь](https://docs.siderolabs.com/talos/v1.13/configure-your-talos-cluster/storage-and-disk-management/disk-management/layout). 

## Добавить раздел для longhorn

В 2026 году следует отказаться от local-path-provisioner, перейти на longhorn. 
Но в стандартной конфигурации оно не заработает. Нужно добавить следующую конфигурацию.

~~~yaml
---
apiVersion: v1alpha1
kind: VolumeConfig
name: EPHEMERAL
provisioning:
  maxSize: 100GB
---
apiVersion: v1alpha1
kind: UserVolumeConfig
name: longhorn
provisioning:
  diskSelector:
    match: disk.transport == 'sata'
  minSize: 20GB
  maxSize: 200GB
---
version: v1alpha1
debug: false
persist: true
machine:
    type: controlplane
    kubelet:
        image: ghcr.io/siderolabs/kubelet:v1.36.2
        defaultRuntimeSeccompProfileEnabled: true
        disableManifestsDirectory: true
        extraMounts:
            - destination: /var/mnt/longhorn
              type: bind
              source: /var/mnt/longhorn
              options:
                  - bind
                  - rshared
                  - rw
~~~

Если longhorn устанавливается через Helm, то не забудьте заменить путь с /var/lib/longhorn на /var/mnt/longhorn.

## Теперь можно указать установочный диск

Теперь можно явно в конфигурации указать на какой жесткий диск нужно устанавливать Talos.

~~~yaml
---
version: v1alpha1
debug: false
persist: true
machine:
    type: controlplane
    install:
        disk: /dev/disk/by-id/ata-WDC_1234567890-1234567_12-123456789012
        wipe: true
        image: ghcr.io/siderolabs/installer:v1.13.5 # Allows for supplying the image used to perform the installation.
        grubUseUKICmdline: true

~~~

## Используйте diskSelector для многодисковой конфигурации.

Можно использовать diskSelector для многодисковых конфигурации. 
Пример - есть сервер с 3 дисковыми устройствами. Первый диск отдадим под систему, второй под EPHEMERAL, третий под longhorn.

~~~yaml
---
apiVersion: v1alpha1
kind: VolumeConfig
name: EPHEMERAL
provisioning:
  diskSelector:
    match: 'disk.transport == "sata" && !system_disk'
  grow: true
---
apiVersion: v1alpha1
kind: UserVolumeConfig
name: longhorn
provisioning:
  diskSelector:
    match: 'disk.transport == "sata" && !system.disk'
  grow: true
---
version: v1alpha1
debug: false
persist: true
machine:
    type: controlplane
    kubelet:
        image: ghcr.io/siderolabs/kubelet:v1.36.2
        defaultRuntimeSeccompProfileEnabled: true
        disableManifestsDirectory: true
        extraMounts:
            - destination: /var/mnt/longhorn
              type: bind
              source: /var/mnt/longhorn
              options:
                  - bind
                  - rshared
                  - rw
~~~

## Используйте diskSelector для выбора подходяшего диска по размеру (критерий)

diskSelector также можно использовать, чтобы разместить userVolumeConfig, volumeConfig на подходящий по размеру диск.

~~~yaml
---
apiVersion: v1alpha1
kind: UserVolumeConfig
name: data
provisioning:
  diskSelector:
    # Match disks between 100GB and 500GB
    match: 'disk.size >= 100u * GB && disk.size <= 500u * GB'
~~~

## Используйте diskSelector для выбора подходяшего диска по интерфейсу (критерий) 

diskSelector также можно использовать, чтобы размещать userVolumeConfig по типу интерфейса.
Например, базы данных держать на nvme, архивы и бакапы на sata, а что не жалко вообще вынести на usb флешку.

~~~yaml
---
apiVersion: v1alpha1
kind: UserVolumeConfig
name: databases
provisioning:
  diskSelector:
    # Match either an NVMe drive or a large SSD
    match: 'disk.transport == "nvme" || (!disk.rotational && disk.size >= 500u * GB)'
---
apiVersion: v1alpha1
kind: UserVolumeConfig
name: backups
provisioning:
  diskSelector:
    # Match either an NVMe drive or a large SSD
    match: 'disk.transport == "sata" || (!disk.rotational && disk.size >= 1500u * GB)'
---
apiVersion: v1alpha1
kind: UserVolumeConfig
name: others
provisioning:
  diskSelector:
    # Match either an NVMe drive or a large SSD
    match: disk.transport == usb
~~~

Больше примеров можно найти [здесь](https://oneuptime.com/blog/post/2026-03-03-use-disk-selectors-with-cel-expressions-in-talos-linux/view).
